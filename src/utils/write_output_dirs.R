write_output_structure <- function(output_dir, sub_dirs) {
    if (!dir.exists(output_dir)) {
        dir.create(output_dir, recursive = TRUE)
    }
    for (sub_dir in sub_dirs) {
        dir_path <- file.path(output_dir, sub_dir)
        if (!dir.exists(dir_path)) {
            dir.create(dir_path, recursive = TRUE)
        }
    }
    return(output_dir)
}