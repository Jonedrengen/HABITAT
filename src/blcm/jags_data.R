generate_eta_vector <- function(input_data,
                                training_column_name,
                                class_column_prefix) {
    class_column_names <- names(input_data)[startsWith(names(input_data), class_column_prefix)]
    
    training_mask <- input_data[[training_column_name]] == 1

    class_matrix <- as.matrix(input_data[, class_column_names, drop = FALSE])

    eta_vect <- rep(NA_integer_, nrow(input_data))
    eta_vect[training_mask] <- max.col(class_matrix[training_mask, , drop = FALSE], ties.method = "first")
    return(eta_vect)
}

generate_feature_matrix <- function(input_data,
                                    feature_column_prefix) {
    feature_column_names <- names(input_data)[startsWith(names(input_data), feature_column_prefix)]
    feature_matrix <- as.matrix(input_data[, feature_column_names, drop = FALSE])
    #storage mode, because Dan used this
    storage.mode(feature_matrix) <- "numeric"

    return(feature_matrix)
}

assemble_jags_data <- function(input_data,
                               training_column_name,
                               class_column_prefix,
                               feature_column_prefix) {
    eta_vector <- generate_eta_vector(input_data, training_column_name = training_column_name, class_column_prefix = class_column_prefix)
    feature_matrix <- generate_feature_matrix(input_data, feature_column_prefix = feature_column_prefix)
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