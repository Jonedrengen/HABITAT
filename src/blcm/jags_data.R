write_eta_vector <- function(input_data,
                             id_column_name,
                             training_column_name,
                             class_column_prefix,
                             temp_dir = NULL) {
    class_column_names <- names(input_data)[startsWith(names(input_data), class_column_prefix)]
    
    training_mask <- input_data[[training_column_name]] == 1

    class_matrix <- as.matrix(input_data[, class_column_names, drop = FALSE])

    eta_vect <- rep(NA_integer_, nrow(input_data))
    eta_vect[training_mask] <- max.col(class_matrix[training_mask, , drop = FALSE], ties.method = "first")
    if (!is.null(temp_dir)) {
        data_frame <- data.frame(sample_id = input_data[[id_column_name]], 
                                 training = input_data[[training_column_name]], 
                                 eta = eta_vect)
        #write eta
        write.csv(data_frame,file = file.path(temp_dir, "eta_vector.csv"),row.names = FALSE)

        #write class
        write.csv(class_matrix,file = file.path(temp_dir, "class_matrix.csv"),row.names = FALSE)
    }
    return(eta_vect)
}

write_feature_matrix <- function(input_data,
                                 feature_column_prefix,
                                 temp_dir = NULL) {
    feature_column_names <- names(input_data)[startsWith(names(input_data), feature_column_prefix)]
    feature_matrix <- as.matrix(input_data[, feature_column_names, drop = FALSE])
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
                               temp_dir = NULL) {
    eta_vector <- write_eta_vector(input_data, id_column_name = id_column_name, training_column_name = training_column_name, class_column_prefix = class_column_prefix, temp_dir = temp_dir)
    feature_matrix <- write_feature_matrix(input_data, feature_column_prefix = feature_column_prefix, temp_dir = temp_dir)
    n_classes <- sum(startsWith(names(input_data), class_column_prefix))
    n_samples <- nrow(input_data)
    n_features <- ncol(feature_matrix)

    jags_parameters <- list(
        eta = eta_vector,
        Y = feature_matrix,
        M_fit = n_classes,
        N = n_samples,
        K = n_features
    )
    return(jags_parameters)
}