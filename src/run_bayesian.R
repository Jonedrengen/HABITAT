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
source(file.path(root, "utils", "data_reader.R"))
write_log(sprintf("Root directory: %s", root))


#parse input and define options
option_list <- list(
    make_option(c("--input", "-i"), type = "character", metavar = "FILE_PATH", help = "Path to input file (.csv)"),
    make_option(c("--output", "-o"), type = "character", metavar = "DIR_PATH", help = "Path to output directory"),
    make_option(c("--config", "-c"), type = "character", metavar = "FILE_PATH", help = "Path to config file (.yml)")
)
parser <- OptionParser(usage = "Usage: %prog [options]", option_list = option_list)
args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE), print_help_and_exit = TRUE, positional_arguments = FALSE, convert_hyphens_to_underscores = FALSE)
input_file <- args$input
output_dir <- args$output
config_file <- args$config
log_file <- file.path(args$output, "logs", "blcm.log")

#create output structure
output_sub_dirs <- c("logs", "results", "temp")
output_dir <- write_output_structure(args$output, output_sub_dirs)
write_log(sprintf("Outputs: %s", output_dir), log_file = log_file)

#read config
config <- read_config(config_file)
validate_config(config, log_file = log_file)
write_log(sprintf("Config: %s", config_file), log_file = log_file)
write_log(sprintf("JAGS_DATA: %s", paste(names(config$JAGS_DATA),":", config$JAGS_DATA)), log_file = log_file)
write_log(sprintf("DATA_META: %s", paste(names(config$DATA_META),":", config$DATA_META)), log_file = log_file)
write_log(sprintf("id_column_index: %s", config$DATA_META$id_column_index), log_file = log_file)

#read and validate data
raw_input_data <- read_data(input_file)
write_log(sprintf("Input data dimensions: %s", paste(dim(raw_input_data), collapse = " x ")), log_file = log_file)
input_data <- validate_data(raw_input_data, config, log_file = log_file)