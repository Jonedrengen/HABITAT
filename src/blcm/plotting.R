#generates a histogram of predicted food-animal origin for isolates
#dependencies: ggplot2, dplyr

Meat_hist_config <- list(
    bin_width           = 0.02,
    boundary            = 0,
    intercepts          = c(0.2, 0.8),
    annotate_positions  = c(0.1, 0.5, 0.9),
    linetype            = "dashed",
    x_label             = "Predicted Food-Animal Origin",
    y_label             = "Frequency",
    title               = "Histogram of Predicted Food-Animal Origin",
    human_threshold     = 0.2,
    food_animal_threshold = 0.8,
    groups              = c("Human", "Indeterminate", "Animal"),
    group_color_map = c(
        "Human" = "goldenrod1",
        "Indeterminate" = "grey70",
        "Animal" = "red3"
  ),

    file_save_name      = "main_histogram.png",
    width               = 16,
    height              = 12
)

generate_hist <- function(Meat_pred_vector, Meat_hist_config, plots_dir = NULL, log_file = NULL) {
    #--------docstring----------
  # Creates a histogram of predicted food-animal origin. Isolates are grouped
  # as Human (Meat_pred <= 0.2), Indeterminate (> 0.2 and < 0.8), or
  # Food-animal (Meat_pred >= 0.8).
  #
  # Args:
  #   Meat_pred_vector: Numeric vector of predicted food-animal origin probabilities.
  #   hist_config: List containing histogram configuration (bin_width, x_label, y_label, title).
  #   log_file: Optional path to a log file.
  #
  # Returns:
  #   A ggplot2 object representing the histogram.
  #save: ggsave(file="DTU_TAIWAN_treemap.svg", plot=big_treemap, width=18, height=14)
    
    # this is a nested ifelse to categorize each prediction into Human, Indeterminate, or Animal based on thresholds
    # sorry...
    write_log("generating hist plot...", log_file = log_file)
    group <- ifelse(Meat_pred_vector <= Meat_hist_config$human_threshold, Meat_hist_config$groups[1], 
             ifelse(Meat_pred_vector >= Meat_hist_config$food_animal_threshold, Meat_hist_config$groups[3], Meat_hist_config$groups[2]))
    
    
    group               = factor(group, levels = Meat_hist_config$groups)
    group_counts        = as.integer(table(group))
    denominator         = sum(group_counts)
    percentages         = if (denominator) round(100 * group_counts / denominator, 1) else rep(0, length(group_counts))
    labels              = paste0(Meat_hist_config$groups, "\nn=", group_counts, " (", percentages, "%)")

    calc_log_mes <- c(paste0("Group counts: ", paste(group_counts, collapse = ", ")),
                      paste0("Percentages: ", paste(percentages, collapse = ", ")),
                      paste0("Labels: ", paste(labels, collapse = ", ")))
    write_log(calc_log_mes, log_file = log_file)

    plot_data <- data.frame(
        Meat_pred = Meat_pred_vector,
        group = group
    )

    histogram_plot <- ggplot2::ggplot(plot_data, aes(x = .data$Meat_pred, fill = .data$group)) +
                            ggplot2::geom_histogram(binwidth = Meat_hist_config$bin_width, boundary = Meat_hist_config$boundary) +
                            ggplot2::geom_vline(xintercept = Meat_hist_config$intercepts, linetype = Meat_hist_config$linetype) +
                            ggplot2::annotate("text", x = Meat_hist_config$annotate_positions, y = Inf, label = labels, vjust = 1.5) +
                            ggplot2::scale_fill_manual(values = Meat_hist_config$group_color_map, drop = FALSE) +
                            ggplot2::scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
                            ggplot2::labs(x = Meat_hist_config$x_label, y = Meat_hist_config$y_label, title = Meat_hist_config$title) +
                            ggplot2::theme_classic() +
                            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5), legend.position = "none")
    
    if (!is.null(plots_dir)) {
        ggsave(filename = file.path(plots_dir, Meat_hist_config$file_save_name),
               plot = histogram_plot,
               width = Meat_hist_config$width,
               height = Meat_hist_config$height)
    }

    #return(histogram_plot)
}


generate_histograms <- function(pred_scores_summary, plots_dir = NULL, log_file = NULL) {
    write_log("generating histograms for prediction scores summary...", log_file = log_file)
    generate_hist(Meat_pred_vector = pred_scores_summary$meat_pred,
                  Meat_hist_config = Meat_hist_config,
                  plots_dir = plots_dir,
                  log_file = log_file)

}