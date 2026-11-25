#yardstick used for metrics
# main site: https://yardstick.tidymodels.org/
# functions: https://yardstick.tidymodels.org/reference/ 

#input: vectors of predictions and truths
#output: integer accuracy score
compute_accuracy <- function(pred, true) {
  acc <- yardstick::accuracy_vec(truth = true, estimate = pred)
  sprintf("acc: %f\n", acc)
  return(acc)
}

#input: vectors of truths and preds
#output: f1 score
f1 <- function(true_source_vect, pred_source_vect) {
  f1_score <- yardstick::f_meas_vec(truth = true_source_vect, estimate = pred_source_vect)
  sprintf("f1: %f\n", f1_score)
  return(f1_score)
}

brier <- function(true, pred) {
  yardstick::brier_score_vec(truth = true, estimate = pred)
}


# accuracy
# 1. accuracy for human vs animal
# 2. accuracy for specific classes

