
summarize_rhat <- function(bugs_summary_table, log_file = NULL) {
    pi_and_p_rows <- bugs_summary_table[grep("^(pi|p)\\[", rownames(bugs_summary_table)), "Rhat"]
    write_log("Summary of pi and p Rhat values: (we want < 1.1)", log_file = log_file)
    write_log(paste0(capture.output(summary(pi_and_p_rows))), log_file = log_file)
}

#returns a named list (like a dict): each group name (e.g., "human", "meat") maps to its matching column names.
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

#returns a named list, mapping each host to the indices of the class columns corresponding to that host
map_host_to_col_indices <- function(input_data, config) {
    class_column_names <- names(input_data)[startsWith(names(input_data), config$DATA_META$class_column_prefix)]
    hosts <- c(config$ANALYSIS$groups$human, config$ANALYSIS$groups$meat)

    write_log("Mapping hosts to column indices...", log_file = log_file)

    #get indices of class columns corresponding to each host
    host_to_col_indices <- lapply(hosts, function(host) {
        which(grepl(tolower(host), tolower(class_column_names), fixed = TRUE))
    })

    #name the list elements with the corresponding host names
    names(host_to_col_indices) <- hosts
    

    return(host_to_col_indices)
}

# returns a vector with host assignments for each test data isolate (like: "human", "chicken", "pork")
generate_isolate_source <- function(input_data, test_data_indices, config, log_file = NULL) {
    write_log("Generating host mapping for test data isolates...", log_file = log_file)
    isolate_source <- rep(NA_character_, length(test_data_indices))

    hosts <- c(config$ANALYSIS$groups$human, config$ANALYSIS$groups$meat)
    write_log(paste0("Hosts: ", paste(hosts, collapse = ", ")), log_file = log_file)

    #if row value == 1 and column header matches a host, assign that host to the isolate_source
    class_column_names <- names(input_data)[startsWith(names(input_data), config$DATA_META$class_column_prefix)]
    write_log(paste0("Class column names: ", paste(class_column_names, collapse = ", ")), log_file = log_file)
    class_columns <- input_data[test_data_indices, class_column_names, drop = FALSE]

    # Iterate over each test data isolate and assign the host based on class columns
    for (i in seq_along(test_data_indices)) {
        for (col in class_column_names) {
            if (class_columns[i, col] == 1) {
                isolate_source[i] <- col
                break
            }
        }
    }
    write_log("renaming based on host groups..", log_file = log_file)
    #this is just a rename step...
    for (i in seq_along(isolate_source)) {
        for (host in hosts) {
            if (grepl(host, isolate_source[i], ignore.case = TRUE)) {
                isolate_source[i] <- host
                break
            }
        }
    }
    return(isolate_source)
}

generate_pred_scores_raw <- function(input_data, eta_samples, config, log_file = NULL, results_dir = NULL) {
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
generate_pred_scores <- function(input_data, pred_scores, test_data_indices, config, log_file = NULL, results_dir = NULL) {
    write_log("writing pred_scores (with some additional info)", log_file = log_file)
    grouped_column_headers <- group_by_column_headers(colnames(pred_scores), config$ANALYSIS$groups, log_file = log_file)
    isolate_source <- generate_isolate_source(input_data, test_data_indices, config, log_file = log_file)

    #include if seperation needed
    #write.csv(pred_scores[, grouped_column_headers$meat, drop = FALSE], file = file.path(results_dir, "meat.csv"))
    #write.csv(pred_scores[, grouped_column_headers$human, drop = FALSE], file = file.path(results_dir, "human.csv"))

    pred_scores_summary <- data.frame(
        pred_scores,
        isolate_source  = isolate_source,
        human_pred      = rowSums(pred_scores[, grouped_column_headers$human, drop = FALSE]),
        meat_pred       = rowSums(pred_scores[, grouped_column_headers$meat, drop = FALSE]),
        Human_class     = ifelse(rowSums(pred_scores[, grouped_column_headers$human, drop = FALSE]) >= 0.8, 1, 0),
        Indeterminate   = ifelse(rowSums(pred_scores[, grouped_column_headers$human, drop = FALSE]) < 0.8 & rowSums(pred_scores[, grouped_column_headers$meat, drop = FALSE]) < 0.8, 1, 0),
        Meat_class      = ifelse(rowSums(pred_scores[, grouped_column_headers$meat, drop = FALSE]) >= 0.8, 1, 0),
        other_pred      = rowSums(pred_scores[, !(colnames(pred_scores) %in% c(grouped_column_headers$meat, grouped_column_headers$human)), drop = FALSE])
    )
    write.csv(pred_scores_summary, file = file.path(results_dir, "pred_scores.csv"))
    return(pred_scores_summary)
}

# credible intervals for FZEC summary - Dans code mostly. Jon takes minimal responsibilities.
generate_CIs_FZEC_pred_scores <- function(input_data, pred_scores_summary, test_data_indices, jags_parameters, model_results, config, log_file = NULL, results_dir = NULL) {
    #this function is mostly Dan implementations
    # Jon takes minimal resposibilities.
    write_log("generating FZEC summary... as per Dan implementation", log_file = log_file)

    
    # Class membership probabilities for each test isolate at each draw
    # P(class j | MGE profile, p, pi) at iteration m. 
    # Summing within host and taking quantiles across draws generates credible intervals
    
    species_list <- map_host_to_col_indices(input_data = input_data, config = config)
    write_log(paste0("species names: ", paste(names(species_list), collapse = ", ")), log_file = log_file)
    human_classes <- unlist(species_list[config$ANALYSIS$groups$human])
    animal_classes <- unlist(species_list[config$ANALYSIS$groups$meat])
    write_log(paste0("human class col indices: ", paste(human_classes, collapse = ", ")), log_file = log_file)
    write_log(paste0("animal class col indices: ", paste(animal_classes, collapse = ", ")), log_file = log_file)

    Y_test <- jags_parameters$Y[test_data_indices, , drop = FALSE]
    obs    <- !is.na(Y_test)
    Y1     <- ifelse(obs, Y_test, 0)       # contributes log(p)
    Y0     <- ifelse(obs, 1 - Y_test, 0)   # contributes log(1 - p); excluding missings
    eps    <- 1e-12
    pi_samples <- model_results$pi_samples

    n_iter <- nrow(pi_samples)
    n_test <- length(test_data_indices)
    n_species <- length(species_list)
    species_prob_mcmc <- array(NA_real_, dim = c(n_iter, n_test, n_species), dimnames = list(NULL, NULL, names(species_list)))
    animal_prob_mcmc  <- matrix(NA_real_, nrow = n_iter, ncol = n_test)

    #ci intervals..
    p_samples <- model_results$p_samples
    for (m in 1:n_iter) {
        p_m <- p_samples[m, , ]                                             # M_fit x K
        lp  <- Y1 %*% t(log(p_m + eps)) + Y0 %*% t(log(1 - p_m + eps))      # n_test x M_fit
        lp  <- sweep(lp, 2, log(pi_samples[m, ] + eps), "+")
        lp  <- lp - apply(lp, 1, max)                                       # row-wise stabilization
        pr  <- exp(lp)
        pr  <- pr / rowSums(pr)                                             # P(class j | data), draw m

        # Aggregate to host level (per draw; full class array not kept to save memory)
        for (sp in names(species_list)) {
            species_prob_mcmc[m, , sp] <- rowSums(pr[, species_list[[sp]], drop = FALSE])
        }
        animal_prob_mcmc[m, ] <- rowSums(pr[, animal_classes, drop = FALSE])
    }

    animal_total <- colMeans(animal_prob_mcmc)
    human_total <- colMeans(species_prob_mcmc[, , config$ANALYSIS$groups$human])
    isolate_source <- pred_scores_summary$isolate_source
    test_is_human <- isolate_source == config$ANALYSIS$groups$human

    # Define FZEC using the posterior
    fzec_status <- ifelse(
        test_is_human,
        animal_total > 0.80,
        NA
    )

    fzec_summary_results <- data.frame(
        sample_id = input_data[test_data_indices, config$DATA_META$id_column_name],
        isolate_source = isolate_source,
        human_total = human_total,
        animal_total = animal_total,
        animal_ci_2.5 = apply(animal_prob_mcmc, 2, quantile, probs = 0.025),     #lower bound:  2.5% quantile
        animal_ci_97.5 = apply(animal_prob_mcmc, 2, quantile, probs = 0.975),    #upper bound: 97.5% quantile
        is_human = test_is_human,
        fzec_status = fzec_status,
        stringsAsFactors = FALSE
    )
    if (!is.null(results_dir)) {
        write.csv(fzec_summary_results, file = file.path(results_dir, "pred_scores_CIs_FZEC.csv"), row.names = FALSE)
    }
    return(fzec_summary_results)
}

# summary - Dans code mostly again
generate_zoonotic_frac_summary <- function() {

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