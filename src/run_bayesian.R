#!/usr/bin/env Rscript

#libs
library(rjags)
library(coda)
library(optparse)
library(config)

#get dir of the script
get_root <- function(argv) {
    root <- argv[grepl("^--file", argv)]
    root <- sub("^--file=", "", root)
    root <- dirname(normalizePath(root))
    return(root)
}


#get root and argv
argv <- commandArgs(trailingOnly = FALSE)
root <- get_root(argv)
sprintf("root: %s", root)

#source 
source(file.path(root, "utils", "logging.R"))
source(file.path(root, "utils", "read_config.R"))

#logging setup
log_file <- file.path(root, "logs", "blcm.log")
if (!dir.exists(dirname(log_file))) {
    log_info(sprintf("Creating log directory: %s", dirname(log_file)))
    dir.create(dirname(log_file), recursive = TRUE)
}
log_info("Starting Bayesian analysis...", log_file = log_file)


#read config
config_file <- file.path(root, "config", "config.yml")
config <- read_config(config_file)

