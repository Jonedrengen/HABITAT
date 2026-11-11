read_config <- function(file_path) {
    config <- config::get(file = file_path)
    return(config)
}