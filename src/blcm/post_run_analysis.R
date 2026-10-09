
summarize_rhat <- function(bugs_summary_table, log_file = NULL) {
    pi_and_p_rows <- bugs_summary_table[grep("^(pi|p)\\[", rownames(bugs_summary_table)), "Rhat"]
    write_log("Summary of pi and p Rhat values: (we want < 1.1)", log_file = log_file)
    write_log(paste0(capture.output(summary(pi_and_p_rows))), log_file = log_file)
}

group_by_column_headers <- function(column_names, groups, log_file = NULL) {
    write_log("Grouping column headers to meat or human hosts", log_file = log_file)
    # Iterate over column_headers, then iterate over groups and see if an identifier matches the column header, if so, assign the column_header to that group
    grouped_column_headers <- list()
    
    for (column in column_names) {
        column_header <- column[1]
        # Check each group to see if the column header matches any of the group's identifiers
        for (group_name in names(groups)) {
            for (id in groups[[group_name]]) {
                if (grepl(id, column_header, ignore.case = TRUE)) {
                    group_message <- paste0("Column: ", column_header, " grouped to: ", group_name)
                    write_log(group_message, log_file = log_file)
                    grouped_column_headers[[group_name]] <- c(grouped_column_headers[[group_name]], column_header)
                }
            }
        }
    }
    # Returns a named list (like a dict): each group name maps to its matching column names.
    return(grouped_column_headers)
}

#TODO: make dynamic later
generate_host_mapping <- function(input_data, test_data_indices, config, log_file = NULL) {
    write_log("Generating host mapping for test data isolates...", log_file = log_file)
    isolate_source <- rep(NA_character_, length(test_data_indices))

    hosts <- c(config$ANALYSIS$groups$human, config$ANALYSIS$groups$meat)
    write_log(paste0("Hosts: ", paste(hosts, collapse = ", ")), log_file = log_file)

    #if row value == 1 and column header matches a host, assign that host to the isolate_source
    class_column_names <- names(input_data)[startsWith(names(input_data), config$DATA_META$class_column_prefix)]
    write_log(paste0("Class column names: ", paste(class_column_names, collapse = ", ")), log_file = log_file)
    class_columns <- input_data[test_data_indices, class_column_names, drop = FALSE]

    # Iterate over each test data isolate and assign the initial host based on class columns
    for (i in 1:length(test_data_indices)) {
        for (col in class_column_names) {
            if (class_columns[i, col] == 1) {
                isolate_source[i] <- col
                break
            }
        }
    }
    write_log("renaming to make sense based on host groups", log_file = log_file)
    for (i in 1:length(isolate_source)) {
        for (host in hosts) {
            if (grepl(host, isolate_source[i], ignore.case = TRUE)) {
                isolate_source[i] <- gsub("_", "", host) #gsub because config has _ in front of host names
                break
            }
        }
    }
    return(isolate_source)
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
generate_blcm_summary <- function(input_data, pred_scores, test_data_indices, config, log_file = NULL, results_dir = NULL) {
    write_log("starting generate_blcm_summary", log_file = log_file)
    grouped_column_headers <- group_by_column_headers(colnames(pred_scores), config$ANALYSIS$groups, log_file = log_file)
    isolate_source <- generate_host_mapping(input_data, test_data_indices, config, log_file = log_file)

    #include if seperation needed
    #write.csv(pred_scores[, grouped_column_headers$meat, drop = FALSE], file = file.path(results_dir, "meat.csv"))
    #write.csv(pred_scores[, grouped_column_headers$human, drop = FALSE], file = file.path(results_dir, "human.csv"))


    pred_scores_results <- data.frame(
        pred_scores,
        isolate_source  = isolate_source,
        human_pred      = rowSums(pred_scores[, grouped_column_headers$human, drop = FALSE]),
        meat_pred       = rowSums(pred_scores[, grouped_column_headers$meat, drop = FALSE]),
        Human_class     = ifelse(rowSums(pred_scores[, grouped_column_headers$human, drop = FALSE]) <= 0.2, 1, 0),
        Indeterminate   = ifelse(rowSums(pred_scores[, grouped_column_headers$human, drop = FALSE]) > 0.2 & rowSums(pred_scores[, grouped_column_headers$meat, drop = FALSE]) < 0.8, 1, 0),
        Meat_class      = ifelse(rowSums(pred_scores[, grouped_column_headers$meat, drop = FALSE]) >= 0.8, 1, 0),
        other_pred      = rowSums(pred_scores[, !(colnames(pred_scores) %in% c(grouped_column_headers$meat, grouped_column_headers$human)), drop = FALSE])
    )
    
    write.csv(pred_scores_results, file = file.path(results_dir, "pred_scores_summary.csv"))
    return(pred_scores_results)

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