
summarize_rhat <- function(bugs_summary_table, log_file = NULL) {
    pi_and_p_rows <- bugs_summary_table[grep("^(pi|p)\\[", rownames(bugs_summary_table)), "Rhat"]
    write_log("Summary of pi and p Rhat values: (we want < 1.1)", log_file = log_file)
    write_log(paste0(capture.output(summary(pi_and_p_rows))), log_file = log_file)
}

group_by_column_headers <- function(column_names, groups, log_file = NULL) {
    # Iterate over column_headers, then iterate over groups and see if an identifier matches the column header, if so, assign the column_header to that group
    grouped_column_headers <- list()
    
    for (column in column_names) {
        column_header <- column[1]
        # Check each group to see if the column header matches any of the group's identifiers
        for (group_name in names(groups)) {
            for (id in groups[[group_name]]) {
                if (grepl(tolower(id), tolower(column_header), fixed = TRUE)) {
                    group_message <- paste0("Column: ", column_header, " grouped to: ", group_name)
                    write_log(group_message, log_file = log_file)
                    grouped_column_headers[[group_name]] <- c(grouped_column_headers[[group_name]], column_header)
                }
            }
        }
    }
    return(grouped_column_headers)
}



generate_pred_scores <- function(input_data, eta_samples, config, log_file = NULL, results_dir = NULL) {
    test_data_indices <- which(input_data[[config$DATA_META$training_column_name]] == 0)
    latent_class_labels <- names(input_data)[startsWith(names(input_data), config$DATA_META$class_column_prefix)]
    n_classes <- length(latent_class_labels)
    # mat_test: cols = test samples, rows = MCMC samples (if n_test = 5 and n_iter = 100, there will be 5 columns and 100 rows)
    mat_test <- eta_samples[, test_data_indices, drop = FALSE]
    write_log(paste0("generate_pred_scores input dimensions: ", nrow(mat_test), " rows and ", ncol(mat_test), " columns"), log_file = log_file)
    
    #matrix: columns = latent classes, rows = test samples
    pred_scores <- matrix(
        NA_real_,
        nrow = length(test_data_indices),
        ncol = n_classes,
        dimnames = list(
            input_data[[config$DATA_META$id_column_name]][test_data_indices],
            latent_class_labels
            )
    )
    
    write_log(paste0("Initializing pred_scores matrix with ", length(test_data_indices), " rows and ", n_classes, " columns"), log_file = log_file)
    for (i in 1:n_classes) {
        v <- apply(mat_test, MARGIN = 2, function(v) mean(v == i))
        pred_scores[, i] <- v
    }
    if (!is.null(results_dir)) {
        write.csv(pred_scores,
              file = file.path(results_dir, "pred_scores_raw.csv"),
              row.names = TRUE)
    }
    return(pred_scores)
}

#placeholder for future code
generate_blcm_summary <- function(pred_scores, test_data_indices, config, log_file = NULL, results_dir = NULL) {
    write_log("starting generate_blcm_summary", log_file = log_file)
    grouped_column_headers <- group_by_column_headers(colnames(pred_scores), config$ANALYSIS$groups, log_file = log_file)
    


    
}


# mat_test <- eta_samples[, test_id]

# v1 <- apply(mat_test,2,function(v) mean(v==1))
# v2 <- apply(mat_test,2,function(v) mean(v==2))
# v3 <- apply(mat_test,2,function(v) mean(v==3))
# v4 <- apply(mat_test,2,function(v) mean(v==4))
# v5 <- apply(mat_test,2,function(v) mean(v==5))
# v6 <- apply(mat_test,2,function(v) mean(v==6))
# v7 <- apply(mat_test,2,function(v) mean(v==7))
# v8 <- apply(mat_test,2,function(v) mean(v==8))
# v9 <- apply(mat_test,2,function(v) mean(v==9))
# v10 <- apply(mat_test,2,function(v) mean(v==10))