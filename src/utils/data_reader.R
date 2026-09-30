#############################################
#### sub_functions for data validation #####
#############################################

validate_sample_ids <- function(raw_input_data, id_column_index, log_file = NULL) {
    sample_id_vect <- raw_input_data[[id_column_index]]
    if (anyDuplicated(sample_id_vect)) {
        write_log("Duplicate sample IDs found.", level = "ERROR", log_file = log_file)
        stop("Duplicate sample IDs found.")
    }
    write_log("No duplicate SampleIDs", level = "INFO", log_file = log_file)
}

validate_training_column <- function(raw_input_data, training_column_index, log_file = NULL) {
    if (!(all(raw_input_data[[training_column_index]] %in% c(1, 0)))) {
        write_log("Training column not valid. (0 or 1 expected)", level = "ERROR", log_file = log_file)
        stop("Training column must be either 1 for training or 0 for testing.")
    }
    write_log("Training column validated. (Expected values: 0 or 1)", level = "INFO", log_file = log_file)
}

validate_class_columns <- function(raw_input_data, class_column_prefix, log_file = NULL) {
    class_col_names <- grep(paste0("^", class_column_prefix), colnames(raw_input_data))
    if (length(class_col_names) == 0) {
        write_log(paste0("No class columns found. (Expected prefix: ", class_column_prefix, ")"), level = "ERROR", log_file = log_file)
        stop("No class columns found.")
    }

    class_columns <- raw_input_data[, class_col_names, drop = FALSE]
    for (class_col in class_columns) {
        if (!(all(class_col >= 0 & class_col <= 1))) {
            write_log(paste0("Class column contains invalid values. (0 or 1 expected)"), level = "ERROR", log_file = log_file)
            stop("Class column contains invalid values. (0 or 1 expected)")
        }
    }
    
    write_log("Class columns validated.", level = "INFO", log_file = log_file)
}

validate_feature_columns <- function(raw_input_data, feature_column_prefix, log_file = NULL) {
    feature_col_names <- grep(paste0("^", feature_column_prefix), colnames(raw_input_data))
    if (length(feature_col_names) == 0) {
        write_log(paste0("No feature columns found. (Expected prefix: ", feature_column_prefix, ")"), level = "ERROR", log_file = log_file)
        stop("No feature columns found.")
    }
    feature_columns <- raw_input_data[, feature_col_names, drop = FALSE]
    for (feature_col in feature_columns) {
        if (!(all(feature_col >= 0 & feature_col <= 1))) {
            write_log(paste0("Feature column contains invalid values. (0 or 1 expected)"), level = "ERROR", log_file = log_file)
            stop("Feature column contains invalid values. (0 or 1 expected)")
        }
    }
    write_log("Feature columns validated.", level = "INFO", log_file = log_file)
}

#############################################
#### main functions for data handling ######
#############################################

validate_data <- function(raw_input_data, config, log_file = NULL) {
    validate_sample_ids(raw_input_data, config$DATA_META$id_column_index, log_file = log_file)
    validate_training_column(raw_input_data, config$DATA_META$training_column_index, log_file = log_file)
    validate_class_columns(raw_input_data, config$DATA_META$class_column_prefix, log_file = log_file)
    validate_feature_columns(raw_input_data, config$DATA_META$feature_column_prefix, log_file = log_file)
    return(raw_input_data)
}

read_data <- function(file_path) {
    data <- read.csv(file_path, stringsAsFactors = FALSE)
    return(data)
}