
summarize_rhat <- function(bugs_summary_table, log_file = NULL) {
    pi_and_p_rows <- bugs_summary_table[grep("^(pi|p)\\[", rownames(bugs_summary_table)), "Rhat"]
    write_log("Summary of pi and p Rhat values: (we want < 1.1)", log_file = log_file)
    write_log(paste0(capture.output(summary(pi_and_p_rows))), log_file = log_file)
}

mean_test_matrix <- function(input_data, eta_samples, config, log_file = NULL, results_dir = NULL) {
    test_data_indices <- which(input_data[, config$DATA_META$training_column_index] == 0)
    latent_class_labels <- grep(paste("^", config$DATA_META$class_column_prefix, sep = ""), colnames(input_data), value = TRUE)
    n_classes <- length(latent_class_labels)
    # mat_test: cols = test samples, rows = MCMC samples (if n_test = 5 and n_iter = 100, there will be 5 columns and 100 rows)
    mat_test <- eta_samples[, test_data_indices]
    write_log(paste0("mean_test_matrix summary: ", nrow(mat_test), " rows and ", ncol(mat_test), " columns"), log_file = log_file)
    
    results <- matrix(nrow = length(test_data_indices), ncol = n_classes)
    write_log(paste0("Initializing results matrix with ", length(test_data_indices), " rows and ", n_classes, " columns"), log_file = log_file)
    for (i in 1:n_classes) {
        v <- apply(mat_test, MARGIN = 2, function(v) mean(v == i)) # compute the mean of latent class i for each test sample
        results[, i] <- v                                          # store the mean of latent class i for each test sample
    }
    colnames(results) <- latent_class_labels
    rownames(results) <- input_data[test_data_indices, config$DATA_META$id_column_index]
    if (!is.null(results_dir)) {
        write_csv(results, include_row_names = TRUE, file.path(results_dir, "mean_test_matrix.csv"), log_file = log_file)
    }
    return(results)
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