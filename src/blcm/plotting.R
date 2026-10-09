#generates a histogram of predicted food-animal origin for isolates
#dependencies: ggplot2, dplyr

Meat_hist_config <- list(
    bin_width = 0.1,
    x_label = "Predicted Food-Animal Origin",
    y_label = "Frequency",
    title = "Histogram of Predicted Food-Animal Origin",
    human_threshold = 0.2,
    food_animal_threshold = 0.8,
    groups = c("Human", "Indeterminate", "Animal"),
    group_color_map = list(
        Human = "goldenrod1",
        Indeterminate = "grey70",
        Animal = "red3"
  ),
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
    group <- ifelse(Meat_pred_vector <= Meat_hist_config$human_threshold, Meat_hist_config$groups[1], 
             ifelse(Meat_pred_vector >= Meat_hist_config$food_animal_threshold, Meat_hist_config$groups[3], Meat_hist_config$groups[2]))

    plot_data <- data.frame(
        Meat_pred       = Meat_pred_vector,
        group           = factor(group, levels = Meat_hist_config$groups),
        group_counts    = as.integer(table(group)),
        group_color      = Meat_hist_config$group_color_map[group]

}
