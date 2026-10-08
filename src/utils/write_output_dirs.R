write_output_structure <- function(output_dir) {
    paths <- list(
        root = output_dir,
        logs = file.path(output_dir, "logs"),
        results = file.path(output_dir, "results"),
        plots = file.path(output_dir, "results", "plots"),
        temp = file.path(output_dir, "temp")
    )

    for (path in paths) {
        dir.create(path, recursive = TRUE, showWarnings = FALSE)
    }
    return(paths)
}