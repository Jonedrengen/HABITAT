#yardstick used for metrics
# main site: https://yardstick.tidymodels.org/
# functions: https://yardstick.tidymodels.org/reference/ 



#input: vectors of predictions and truths
#output: integer accuracy score
compute_accuracy <- function(pred, true) {
  acc <- character()
  acc <- yardstick::accuracy_vec(truth = true, estimate = pred)
  sprintf("acc: %f\n", acc)
  return(acc)
}

#input: vectors of truths and preds
#output: f1 score
f1 <- function(true_source_vect, pred_source_vect) {
  #inverse of brier
  f1_score <- yardstick::f_meas_vec(truth = true_source_vect, estimate = pred_source_vect)
  return(f1_score)
}

brier <- function(true, pred) {
  brier_score <- yardstick::brier_class_vec(truth = true, estimate = pred)
  return(brier_score)
}

#TODO: make a confusion matrix?
confusion_matrix <- function(true, pred) {
  cm <- yardstick::conf_mat_vec(truth = true, estimate = pred)
  return(cm)
}


# accuracy
# 1. accuracy for human vs animal
# 2. accuracy for specific classes

#utils

#wrapper for metrics
run_paper_metrics <- function(input_data, pred_scores_raw, temp_dir = NULL) {
  # this function takes in class input and prediction scores, to compute metrics
  class_column_names <- names(input_data)[startsWith(names(input_data), config$DATA_META$class_column_prefix)]
  test_data_indices <- which(input_data[[config$DATA_META$training_column_name]] == 0)

  truth_matrix <- matrix(NA, nrow = nrow(input_data), ncol = length(class_column_names))
  truth_matrix <- input_data[test_data_indices, class_column_names]

}

