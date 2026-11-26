#!/usr/bin/env Rscript

#libs
suppressPackageStartupMessages(library(rjags))
suppressPackageStartupMessages(library(coda))
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(yardstick))

#get dir of the script
get_root <- function(argv) {
    root <- argv[grepl("^--file", argv)]
    root <- sub("^--file=", "", root)
    root <- dirname(normalizePath(root))
    return(root)
}

#get root, argv and source
argv <- commandArgs(trailingOnly = FALSE)
root <- get_root(argv)
#sourcing functionality
source(file.path(root, "utils", "config_utils.R"))
source(file.path(root, "utils", "write_output_dirs.R"))
source(file.path(root, "blcm", "data_reader.R"))
source(file.path(root, "blcm", "pre_run_analysis.R"))
source(file.path(root, "blcm", "jags_data.R"))
source(file.path(root, "blcm", "run_model.R"))
source(file.path(root, "blcm", "post_run_analysis.R"))
source(file.path(root, "blcm", "plotting.R"))

#start time for runtime calculation
start_time <- Sys.time()
########################################################################################
####### define command line options, parse arguments and define Global variables #######
########################################################################################
option_list <- list(
    make_option(c("--input", "-i"), type = "character", metavar = "FILE_PATH", required = TRUE, help = "Path to input file (.csv)"),
    make_option(c("--output", "-o"), type = "character", metavar = "DIR_PATH", required = TRUE, help = "Path to output directory"),
    make_option(c("--config", "-c"), type = "character", metavar = "FILE_PATH", required = TRUE, help = "Path to config file (.yml)")
)
parser <- OptionParser(usage = "Usage: Rscript %prog [options]; -h for help", option_list = option_list)
args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE), print_help_and_exit = TRUE, positional_arguments = FALSE, convert_hyphens_to_underscores = FALSE)
input_file <- args$input
config_file <- args$config


#create output structure
output_dirs <- tryCatch({
                print("Creating output structure...")
                write_output_structure(args$output)
}, error = function(e) {
    stop("Error creating output structure: ", conditionMessage(e))
})
model_file <- file.path(root, "model", "model.bug")
#read config and save a copy in output
config <- tryCatch({
    print("Reading config...")
    read_config(config_file)
}, error = function(e) {
    stop("Error reading config: ", conditionMessage(e))
})
file.copy(config_file, file.path(output_dirs$temp, paste0(Sys.Date(), "_config.yml")))

print(sprintf("Starting Bayesian analysis at %s", start_time))
##########################################
######## Start Bayesian analysis #########
##########################################

# set seed for reproducibility if specified in config
if (!is.null(config$JAGS_DATA$seed)) {
  set.seed(config$JAGS_DATA$seed)
}

#read and validate input data
print("Reading and validating input data...")
raw_input_data <- read_data(input_file)
input_data <- validate_data(raw_input_data, config)
print("getting test and training indices")
training_data_indices <- which(input_data[[config$DATA_META$training_column_name]] == 1)
test_data_indices <- which(input_data[[config$DATA_META$training_column_name]] == 0)

#write input data, so validation and reproducibility is easier
write.csv(input_data, file = file.path(output_dirs$temp, "input_data.csv"), row.names = FALSE)
write.csv(input_data[training_data_indices, ], file = file.path(output_dirs$temp, "training_data.csv"), row.names = FALSE)
write.csv(input_data[test_data_indices, ], file = file.path(output_dirs$temp, "test_data.csv"), row.names = FALSE)
print(sprintf("Input data dimensions: %s", paste(dim(raw_input_data), collapse = " x ")))
print(sprintf("Training samples: %d; test samples: %d", length(training_data_indices), length(test_data_indices)))

#handle JAGS data assembly
jags_parameters <- tryCatch({
    print("Assembling JAGS data...")
    parameters <- assemble_jags_data(input_data,
                                     training_column_name = config$DATA_META$training_column_name,
                                     class_column_prefix = config$DATA_META$class_column_prefix,
                                     feature_column_prefix = config$DATA_META$feature_column_prefix)
    eta_table <- data.frame(sample_id = input_data[[config$DATA_META$id_column_name]],
                            training = input_data[[config$DATA_META$training_column_name]],
                            eta = parameters$eta)
    class_columns <- names(input_data)[startsWith(names(input_data), config$DATA_META$class_column_prefix)]
    class_matrix <- as.matrix(input_data[, class_columns, drop = FALSE])
    write.csv(eta_table, file.path(output_dirs$temp, "eta_vector.csv"), row.names = FALSE)
    write.csv(class_matrix, file.path(output_dirs$temp, "class_matrix.csv"), row.names = FALSE)
    write.csv(data.frame(parameters$Y), file.path(output_dirs$temp, "feature_matrix.csv"), row.names = FALSE)
    parameters
}, error = function(e) {
  stop("Error assembling JAGS data: ", conditionMessage(e))
})

#count features per column for training and test data
tryCatch({
    print("Counting features...")
    training_features_counts <- count_feature_proportions(feature_matrix = jags_parameters$Y[training_data_indices, , drop = FALSE])
    write.csv(training_features_counts, file.path(output_dirs$temp, "training_feature_counts.csv"), row.names = FALSE)
    test_features_counts <- count_feature_proportions(feature_matrix = jags_parameters$Y[test_data_indices, , drop = FALSE])
    write.csv(test_features_counts, file.path(output_dirs$temp, "test_feature_counts.csv"), row.names = FALSE)
}, error = function(e) {
  stop("Error counting features: ", conditionMessage(e))
})

model_output <- tryCatch({
    print("Running JAGS model...")
    model_results <- run_model(jags_parameters = jags_parameters, config = config, model_file = model_file)
    write.csv(model_results$bugs_summary_table, file.path(output_dirs$temp, "bugs_summary_table.csv"), row.names = TRUE)
    write.csv(model_results$model_size, file.path(output_dirs$temp, "model_size.csv"), row.names = FALSE)
    model_results
}, error = function(e) {
  stop("Error running model: ", conditionMessage(e))
})

rhat_summary <- tryCatch({
    print("Summarizing Rhat for pi and p (target < 1.1)...")
    rhat_summary <- summarize_rhat(bugs_summary_table = model_output$bugs_summary_table)
    write.csv(rhat_summary, file.path(output_dirs$temp, "rhat_summary.csv"), row.names = FALSE)
    print(rhat_summary)
    rhat_summary
}, error = function(e) {
    stop("Error summarizing Rhat: ", conditionMessage(e))
})


pred_scores <- tryCatch({
    print("Generating raw prediction scores...")
    scores <- generate_pred_scores_raw(input_data = input_data,
                                       eta_samples = model_output$eta_samples,
                                       config = config)
    write.csv(scores, file.path(output_dirs$results, "pred_scores_raw.csv"), row.names = TRUE)
    scores
}, error = function(e) {
    stop("Error generating raw prediction scores: ", conditionMessage(e))
})

pred_scores_summary <- tryCatch({
    print("Summarizing prediction scores...")
    pred_score_summary <- generate_pred_scores(input_data = input_data,
                                          features = jags_parameters$Y,
                                          pred_scores = pred_scores,
                                          test_data_indices = test_data_indices,
                                          config = config)
    write.csv(pred_score_summary, file.path(output_dirs$results, "pred_scores_summary.csv"))
    pred_score_summary
}, error = function(e) {
    stop("Error summarizing prediction scores: ", conditionMessage(e))
})

#FZEC summary as per Dan's implementation
ci_fzec_return_list <- tryCatch({
    print("Generating FZEC summary...")
    fzec_results <- generate_CIs_FZEC_pred_scores(input_data = input_data,
                                                   pred_scores_summary = pred_scores_summary,
                                                   test_data_indices = test_data_indices,
                                                   jags_parameters = jags_parameters,
                                                   model_results = model_output,
                                                   config = config)
    write.csv(fzec_results$ci_fzec_results, file.path(output_dirs$more_results, "pred_scores_CIs_FZEC.csv"), row.names = FALSE)
    fzec_results
}, error = function(e) {
    stop("Error generating FZEC summary: ", conditionMessage(e))
})

zoonotic_frac_summary <- tryCatch({
    print("Generating zoonotic fraction summary...")
    zoonotic_summary <- generate_zoonotic_frac_summary(ci_fzec_results = ci_fzec_return_list$ci_fzec_results,
                                                        animal_prob_mcmc = ci_fzec_return_list$animal_prob_mcmc)
    write.csv(zoonotic_summary, file.path(output_dirs$more_results, "zoonotic_frac_summary.csv"), row.names = FALSE)
    zoonotic_summary
}, error = function(e) {
    stop("Error generating zoonotic fraction summary: ", conditionMessage(e))
})


write_host_mappings(input_data = input_data, config = config, temp_dir = output_dirs$temp)
print("Generating prediction score histograms...")
#generate histograms for the prediction scores summary
generate_histograms(pred_scores_summary = pred_scores_summary, plots_dir = output_dirs$plots)


print("Analysis complete. Rendering report...")
print(sprintf("Outputs: %s", output_dirs$root))
end_time <- Sys.time()
time_passed <- round(difftime(end_time, start_time, units = "mins"), digits = 2)
time_message <- sprintf("Runtime: %.2f min", time_passed)
print(time_message)
write.csv(data.frame(time_passed = time_passed), file.path(output_dirs$temp, "runtime.csv"), row.names = FALSE)

tryCatch(
    {
        rmarkdown::render(
            input = file.path(root, "report", "output_overview.Rmd"),
            output_file = "overview.pdf",
            output_dir = output_dirs$root,
            params = list(output_dir = normalizePath(output_dirs$root))
        )
        print("Report rendered.")
    },
    error = function(error) {
        warning("Report not rendered: ", conditionMessage(error))
    }
)


#delete temporary files if the option is set to TRUE
if (config$OPTIONS$delete_temp_files) {
    unlink(output_dirs$temp, recursive = TRUE)
}