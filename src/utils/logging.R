
log_info <- function(message = "no message provided",
                     level = "INFO",
                     log_file = NULL) {
    time <- Sys.time()
    time <- format(time, "%Y-%m-%d %H:%M:%OS2")
    if (!is.null(log_file)) {
        if (!file.exists(log_file)) {
            dir.create(dirname(log_file), recursive = TRUE, showWarnings = FALSE)
        }
        cat(sprintf("[%s] [%s] %s\n", level, time, message), file = log_file, append = TRUE)
    }
  print(sprintf("[%s] [%s] %s", level, time, message))
}