#############################################
#### sub_functions for data validation #####
#############################################

validate_JAGS_DATA <- function(jags_data) {
    if (is.null(jags_data)) {
        stop("JAGS_DATA section is missing in the config.")
    }
    if (jags_data$chains < 2L) {
        stop("Chains must be at least 2.")
    }
    if (jags_data$iterations != 10000 && jags_data$burn_in != 5000) {
        warning(sprintf("we recommend 10000 iterations and 5000 burn-in. Current: %d/%d", jags_data$iterations, jags_data$burn_in))
    }
}

validate_config_sections <- function(config) {
    if (is.null(config$DATA_META)) {
        stop("DATA_META section is missing in the config.")
    }
    if (is.null(config$OPTIONS)) {
        stop("OPTIONS section is missing in the config.")
    }
    if (is.null(config$ANALYSIS)) {
        stop("ANALYSIS section is missing in the config.")
    }
}

validate_DATA_META <- function(data_meta) {
    if (is.null(data_meta$id_column_name) || is.null(data_meta$training_column_name)) {
        message <- "DATA_META must define id_column_name and training_column_name."
        stop(message)
    }
    if (is.null(data_meta$feature_column_prefix)) {
        stop("Feature column prefix missing.")
    }
    if (is.null(data_meta$class_column_prefix)) {
        stop("Class column prefix missing.")
    }
}

validate_ANALYSIS <- function(raw_input_data, analysis_params) {
    groups <- c(analysis_params$groups)
    if (length(groups) != 2) {
        stop("Expected 2 groups. More might be added in the future.")
    }

    group_1 <- groups[1]
    group_2 <- groups[2]
    if (length(group_1) == 0) {
        stop("Group 1 is empty.")
    }
    if (length(group_2) == 0) {
        stop("Group 2 is empty.")
    }

    if (!is.null(raw_input_data)) {
        sub_groups <- unlist(groups, use.names = FALSE)
        col_names <- colnames(raw_input_data)
        for (sg in sub_groups) {
            if (!any(grepl(sg, col_names, ignore.case = TRUE))) {
                message <- paste("Sub group:", sg, "not found in input data column header. Check if groups match header")
                stop(message)
            }
        }
    }
}

validate_config <- function(raw_input_data = NULL, config) {
    validate_JAGS_DATA(config$JAGS_DATA)
    validate_config_sections(config)
    validate_DATA_META(config$DATA_META)
    validate_ANALYSIS(raw_input_data, config$ANALYSIS)
}

validate_column_names <- function(raw_input_data) {
    if (anyDuplicated(names(raw_input_data))) {
        message <- "Duplicate input column names found."
        stop(message)
    }
}

validate_sample_ids <- function(raw_input_data, id_column_name) {
    if (!(id_column_name %in% names(raw_input_data))) {
        message <- paste0("ID column not found: ", id_column_name)
        stop(message)
    }

    sample_id_vect <- raw_input_data[[id_column_name]]
    if (anyDuplicated(sample_id_vect)) {
        stop("Duplicate sample IDs found.")
    }
}

validate_training_column <- function(raw_input_data, training_column_name) {
    if (!(training_column_name %in% names(raw_input_data))) {
        message <- paste0("Training column not found: ", training_column_name)
        stop(message)
    }

    if (!(all(raw_input_data[[training_column_name]] %in% c(1, 0)))) {
        stop("Training column must be either 1 for training or 0 for testing.")
    }
}

validate_class_columns <- function(raw_input_data, class_column_prefix) {
    class_col_names <- grep(paste0("^", class_column_prefix), colnames(raw_input_data))
    if (length(class_col_names) == 0) {
        stop("No class columns found.")
    }
    

    # check class columns for 0/1 values
    class_columns <- raw_input_data[, class_col_names, drop = FALSE]
    for (class_col in class_columns) {
        if (!(all(class_col == 0 | class_col == 1))) {
            stop("Class column contains invalid values. (0 or 1 expected)")
        }
    }

    # check each row has at least one positive class
    for (row in 1:nrow(class_columns)) {
        if (sum(class_columns[row, ]) == 0) {
            stop("Row has no class positives. Make sure a source is specified with `1`")
        }
    }
    
}

validate_feature_columns <- function(raw_input_data, feature_column_prefix) {
    feature_col_names <- grep(paste0("^", feature_column_prefix), colnames(raw_input_data))
    if (length(feature_col_names) == 0) {
        stop("No feature columns found.")
    }
    feature_columns <- raw_input_data[, feature_col_names, drop = FALSE]
    for (feature_col in feature_columns) {
        if (!(all(feature_col == 0 | feature_col == 1))) {
            stop("Feature column contains invalid values. (0 or 1 expected)")
        }
    }
}

#############################################
#### main functions for data handling ######
#############################################

validate_data <- function(raw_input_data, config) {
    validate_config(raw_input_data, config)
    validate_column_names(raw_input_data)
    validate_sample_ids(raw_input_data, config$DATA_META$id_column_name)
    validate_training_column(raw_input_data, config$DATA_META$training_column_name)
    validate_class_columns(raw_input_data, config$DATA_META$class_column_prefix)
    validate_feature_columns(raw_input_data, config$DATA_META$feature_column_prefix)

    return(raw_input_data)
}

read_data <- function(file_path) {
    data <- read.csv(file_path, stringsAsFactors = FALSE, check.names = FALSE)
    return(data)
}