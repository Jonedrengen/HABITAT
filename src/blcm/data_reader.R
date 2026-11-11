#############################################
#### sub_functions for data validation #####
#############################################

validate_JAGS_DATA <- function(jags_data, log_file = NULL) {
    if (is.null(jags_data)) {
        write_log("JAGS_DATA section is missing in the config.", level = "ERROR", log_file = log_file)
        stop("JAGS_DATA section is missing in the config.")
    }
}

validate_config_sections <- function(config, log_file = NULL) {
    if (is.null(config$DATA_META)) {
        write_log("DATA_META section is missing in the config.", level = "ERROR", log_file = log_file)
        stop("DATA_META section is missing in the config.")
    }
    if (is.null(config$OPTIONS)) {
        write_log("OPTIONS section is missing in the config.", level = "ERROR", log_file = log_file)
        stop("OPTIONS section is missing in the config.")
    }
    if (is.null(config$ANALYSIS)) {
        write_log("ANALYSIS section is missing in the config.", level = "ERROR", log_file = log_file)
        stop("ANALYSIS section is missing in the config.")
    }
}

validate_DATA_META <- function(data_meta, log_file = NULL) {
    if (is.null(data_meta$id_column_name) || is.null(data_meta$training_column_name)) {
        message <- "DATA_META must define id_column_name and training_column_name."
        write_log(message, level = "ERROR", log_file = log_file)
        stop(message)
    }
    if (is.null(data_meta$feature_column_prefix)) {
        write_log("Feature column prefix missing.", level = "ERROR", log_file = log_file)
        stop("Feature column prefix missing.")
    }
    if (is.null(data_meta$class_column_prefix)) {
        write_log("Class column prefix missing.", level = "ERROR", log_file = log_file)
        stop("Class column prefix missing.")
    }
}

validate_ANALYSIS <- function(raw_input_data, analysis_params, log_file = NULL) {
    groups <- c(analysis_params$groups)
    if (length(groups) != 2) {
        write_log("Expected 2 groups More might be added in the future.", level = "ERROR", log_file = log_file)
        stop("Expected 2 groups. More might be added in the future.")
    }

    group_1 <- groups[1]
    group_2 <- groups[2]
    if (length(group_1) == 0) {
        write_log("Group 1 is empty.", level = "ERROR", log_file = log_file)
        stop("Group 1 is empty.")
    }
    if (length(group_2) == 0) {
        write_log("Group 2 is empty.", level = "ERROR", log_file = log_file)
        stop("Group 2 is empty.")
    }

    if (!is.null(raw_input_data)) {
        sub_groups <- unlist(groups, use.names = FALSE)
        col_names <- colnames(raw_input_data)
        for (sg in sub_groups) {
            if (!any(grepl(sg, col_names, ignore.case = TRUE))) {
                message <- paste("Sub group:", sg, "not found in input data column header. Check if groups match header")
                write_log(message, level = "ERROR", log_file = log_file)
                stop(message)
            }
        }
    }
}

validate_config <- function(raw_input_data = NULL, config, log_file = NULL) {
    validate_JAGS_DATA(config$JAGS_DATA, log_file = log_file)
    validate_config_sections(config, log_file = log_file)
    validate_DATA_META(config$DATA_META, log_file = log_file)
    validate_ANALYSIS(raw_input_data, config$ANALYSIS, log_file = log_file)
}

validate_column_names <- function(raw_input_data, log_file = NULL) {
    if (anyDuplicated(names(raw_input_data))) {
        message <- "Duplicate input column names found."
        write_log(message, level = "ERROR", log_file = log_file)
        stop(message)
    }
}

validate_sample_ids <- function(raw_input_data, id_column_name, log_file = NULL) {
    if (!(id_column_name %in% names(raw_input_data))) {
        message <- paste0("ID column not found: ", id_column_name)
        write_log(message, level = "ERROR", log_file = log_file)
        stop(message)
    }

    sample_id_vect <- raw_input_data[[id_column_name]]
    if (anyDuplicated(sample_id_vect)) {
        write_log("Duplicate sample IDs found.", level = "ERROR", log_file = log_file)
        stop("Duplicate sample IDs found.")
    }
    write_log("No duplicate SampleIDs", level = "INFO", log_file = log_file)
}

validate_training_column <- function(raw_input_data, training_column_name, log_file = NULL) {
    if (!(training_column_name %in% names(raw_input_data))) {
        message <- paste0("Training column not found: ", training_column_name)
        write_log(message, level = "ERROR", log_file = log_file)
        stop(message)
    }

    if (!(all(raw_input_data[[training_column_name]] %in% c(1, 0)))) {
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
    

    # check class columns for 0/1 values
    class_columns <- raw_input_data[, class_col_names, drop = FALSE]
    for (class_col in class_columns) {
        if (!(all(class_col == 0 | class_col == 1))) {
            write_log(paste0("Class column contains invalid values. (0 or 1 expected)"), level = "ERROR", log_file = log_file)
            stop("Class column contains invalid values. (0 or 1 expected)")
        }
    }

    # check each row has at least one positive class
    for (row in 1:nrow(class_columns)) {
        if (sum(class_columns[row, ]) == 0) {
            write_log("Row has no class positives.", level = "ERROR", log_file = log_file)
            stop("Row has no class positives. Make sure a source is specified with `1`")
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
        if (!(all(feature_col == 0 | feature_col == 1))) {
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
    validate_config(raw_input_data, config, log_file = log_file)
    validate_column_names(raw_input_data, log_file = log_file)
    validate_sample_ids(raw_input_data, config$DATA_META$id_column_name, log_file = log_file)
    validate_training_column(raw_input_data, config$DATA_META$training_column_name, log_file = log_file)
    validate_class_columns(raw_input_data, config$DATA_META$class_column_prefix, log_file = log_file)
    validate_feature_columns(raw_input_data, config$DATA_META$feature_column_prefix, log_file = log_file)

    return(raw_input_data)
}

read_data <- function(file_path) {
    data <- read.csv(file_path, stringsAsFactors = FALSE, check.names = FALSE)
    return(data)
}