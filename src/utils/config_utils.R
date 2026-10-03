read_config <- function(file_path) {
    config <- config::get(file = file_path)
    return(config)
}

validate_config <- function(config, log_file = NULL) { 
    if (is.null(config$JAGS_DATA)) {
        write_log("JAGS_DATA section is missing in the config.", level = "ERROR", log_file = log_file)
        stop("JAGS_DATA section is missing in the config.")
    }
    if (is.null(config$DATA_META)) {
        write_log("DATA_META section is missing in the config.", level = "ERROR", log_file = log_file)
        stop("DATA_META section is missing in the config.")
    }
}