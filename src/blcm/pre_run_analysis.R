count_feature_proportions <- function(feature_matrix = NULL) {
    # count features per column of the data
    # input: feature_matrix
    # output: counts per column
    if (!is.null(feature_matrix) && nrow(feature_matrix) > 0) {
        col_counts <- colSums(feature_matrix)
        feature_counts <- data.frame(feature = names(col_counts), count = unname(col_counts), proportion = round(unname(col_counts)/nrow(feature_matrix),3))
        return(feature_counts)
    } else {
        stop("No data for counting")
    }
}