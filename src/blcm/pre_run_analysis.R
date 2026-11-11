count_feature_proportions <- function(test_feature_matrix = NULL, temp_dir = NULL) {
    # count features per column of the test data
    # input: feature_matrix
    # output: counts per column
    if (!is.null(test_feature_matrix) && nrow(test_feature_matrix) > 0) {
        col_counts <- colSums(test_feature_matrix)
        feature_counts <- data.frame(feature = names(col_counts), count = unname(col_counts), proportion = round(unname(col_counts)/nrow(test_feature_matrix),3))
        if (!is.null(temp_dir)) {
            write.csv(feature_counts, file.path(temp_dir, "feature_counts.csv"), row.names = FALSE)
        }
        return(feature_counts)
    } else {
        stop("No test data for counting")
    }
}