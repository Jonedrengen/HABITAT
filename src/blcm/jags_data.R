

write_eta_vector <- function(input_data,
                             id_column_name,
                             training_column_name,
                             class_column_prefix,
                             temp_dir = NULL,
                             log_file = NULL) {
    class_column_names <- names(input_data)[startsWith(names(input_data), class_column_prefix)]
    write_log(paste0("Class cols identified: ", paste(class_column_names, collapse = ", ")), log_file=log_file)
    
    training_mask <- input_data[[training_column_name]] == 1
    write_log(paste0("Training samples: ", sum(training_mask)), log_file=log_file)

    class_matrix <- as.matrix(input_data[, class_column_names, drop = FALSE])
    eta_vect <- rep(NA_integer_, nrow(input_data))
    eta_vect[training_mask] <- max.col(class_matrix[training_mask, ], ties.method = "first")
    if (!is.null(temp_dir)) {
        write_log(paste0("see eta vector, with training samples and class assignments in temp_dir: ", temp_dir), log_file=log_file)
        data_frame <- data.frame(sample_id = input_data[[id_column_name]], training = input_data[[training_column_name]], eta = eta_vect,class_matrix)
        write.csv(data_frame,file = file.path(temp_dir, "eta_vector.csv"),row.names = FALSE)
    }
    return(eta_vect)
}

write_feature_matrix <- function(input_data,
                                 feature_column_prefix,
                                 temp_dir = NULL,
                                 log_file = NULL) {
    feature_column_names <- names(input_data)[startsWith(names(input_data), feature_column_prefix)]
    write_log(paste0("Feature cols identified: ", paste(feature_column_names, collapse = ", ")), log_file=log_file)
    feature_matrix <- as.matrix(input_data[, feature_column_names, drop = FALSE])
    write_log(paste0("Feature matrix dimensions: ", paste(dim(feature_matrix), collapse = " x ")), log_file=log_file)
    #storage mode, because Dan used this
    storage.mode(feature_matrix) <- "numeric"

    if (!is.null(temp_dir)) {
        write.csv(data.frame(feature_matrix),
              file = file.path(temp_dir, "feature_matrix.csv"),
              row.names = FALSE)
    }

    return(feature_matrix)
}

assemble_jags_data <- function(input_data,
                               id_column_name,
                               training_column_name,
                               class_column_prefix,
                               feature_column_prefix,
                               temp_dir = NULL,
                               log_file = NULL) {
    write_log("Assembling JAGS data...", log_file = log_file)
    write_log(paste0("id_column_name=", id_column_name, " training_column_name=", training_column_name, " class_column_prefix=", class_column_prefix," feature_column_prefix=", feature_column_prefix), log_file = log_file)

    eta_vector <- write_eta_vector(input_data, id_column_name = id_column_name, training_column_name = training_column_name, class_column_prefix = class_column_prefix, temp_dir = temp_dir, log_file = log_file)
    feature_matrix <- write_feature_matrix(input_data, feature_column_prefix = feature_column_prefix, log_file = log_file)
    n_classes <- sum(startsWith(names(input_data), class_column_prefix))
    n_samples <- nrow(input_data)
    n_features <- ncol(feature_matrix)

    write_log(paste0("n classes: ", n_classes), log_file = log_file)
    write_log(paste0("n samples: ", n_samples), log_file = log_file)
    write_log(paste0("n features: ", n_features), log_file = log_file)

    jags_parameters <- list(
        eta = eta_vector,
        Y = feature_matrix,
        M_fit = n_classes,
        N = n_samples,
        K = n_features
    )
    return(jags_parameters)
}