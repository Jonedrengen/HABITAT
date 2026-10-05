#!/usr/bin/env Rscript

#libs
suppressPackageStartupMessages(library(rjags))
suppressPackageStartupMessages(library(coda))
suppressPackageStartupMessages(library(optparse))

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
source(file.path(root, "utils", "logging.R"))
source(file.path(root, "utils", "config_utils.R"))
source(file.path(root, "utils", "write_output_dirs.R"))
source(file.path(root, "blcm", "data_reader.R"))
source(file.path(root, "blcm", "jags_data.R"))
source(file.path(root, "blcm", "run_model.R"))
source(file.path(root, "blcm", "post_run_analysis.R"))
write_log(sprintf("Root directory: %s", root))

########################################################################################
####### define command line options, parse arguments and define Global variables #######
########################################################################################
option_list <- list(
    make_option(c("--input", "-i"), type = "character", metavar = "FILE_PATH", help = "Path to input file (.csv)"),
    make_option(c("--output", "-o"), type = "character", metavar = "DIR_PATH", help = "Path to output directory"),
    make_option(c("--config", "-c"), type = "character", metavar = "FILE_PATH", help = "Path to config file (.yml)")
)
parser <- OptionParser(usage = "Usage: %prog [options]", option_list = option_list)
args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE), print_help_and_exit = TRUE, positional_arguments = FALSE, convert_hyphens_to_underscores = FALSE)
input_file <- args$input
config_file <- args$config

#create output structure
output_dirs <- write_output_structure(args$output)
log_file <- file.path(output_dirs$logs, "blcm.log")
model_file <- file.path(root, "model", "model.bug")
write_log(sprintf("Outputs: %s", output_dirs$root), log_file = log_file)

#read config
config <- read_config(config_file)
validate_config(config, log_file = log_file)
write_log(sprintf("Config: %s", config_file), log_file = log_file)
write_log(sprintf("JAGS_DATA: %s", paste(names(config$JAGS_DATA),":", config$JAGS_DATA)), log_file = log_file)
write_log(sprintf("DATA_META: %s", paste(names(config$DATA_META),":", config$DATA_META)), log_file = log_file)
write_log(sprintf("id_column_index: %s", config$DATA_META$id_column_index), log_file = log_file)

##########################################
######## Start Bayesian analysis #########
##########################################

#read and validate input data
raw_input_data <- read_data(input_file)
write_log(sprintf("Input data dimensions: %s", paste(dim(raw_input_data), collapse = " x ")), log_file = log_file)
input_data <- validate_data(raw_input_data, config, log_file = log_file)
training_ids <- which(input_data[, config$DATA_META$training_column_index] == 1)
write_log(sprintf("Number of training samples: %s", length(training_ids)), log_file = log_file)
write_log(sprintf("Training IDs: %s", head(training_ids)), log_file = log_file)
test_ids <- which(input_data[, config$DATA_META$training_column_index] == 0)
write_log(sprintf("Number of test samples: %s", length(test_ids)), log_file = log_file)

#handle JAGS data assembly
jags_parameters <- assemble_jags_data(input_data,
                                      id_column_index = config$DATA_META$id_column_index,
                                      training_column_index = config$DATA_META$training_column_index,
                                      class_column_prefix = config$DATA_META$class_column_prefix,
                                      feature_column_prefix = config$DATA_META$feature_column_prefix,
                                      temp_dir = output_dirs$temp,
                                      log_file = log_file)

model_output <- run_model(jags_parameters = jags_parameters, config = config, model_file = model_file, log_file = log_file, temp_dir = output_dirs$temp)

#summaries 
summarize_rhat(bugs_summary_table = model_output$bugs_summary_table, log_file = log_file)

#get mean of test data (their posterior probabilities)
mean_test_matrix(eta_samples = model_output$eta_samples, test_id = test_ids, log_file = log_file, temp_dir = output_dirs$temp)