read_config <- function(file_path) {
    config <- config::get(file = file_path)
    return(config)
}

validate_config <- function(config) { 
    if (is.null(config$JAGS_DATA)) {
        stop("JAGS_DATA section is missing in the config.")
    }
    if (is.null(config$DATA_META)) {
        stop("DATA_META section is missing in the config.")
    }
}