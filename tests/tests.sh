#!/usr/bin/env bash

test_SB27_raw_input() {
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/SB27_raw_input.csv" \
        -o "$output_dir/SB27_raw_input_output/" \
        -c "$config_file"
}

test_quoted_input() {
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/quoted_data.csv" \
        -o "$output_dir/quoted_input_output/" \
        -c "$config_file"
}

test_duplicate_ids() {
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/duplicate_id.csv" \
        -o "$output_dir/duplicate_ids_output/" \
        -c "$config_file"
}

test_non_01_training() {
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/non_01_training.csv" \
        -o "$output_dir/non_01_training_output/" \
        -c "$config_file"
}

test_class_columns_wrong() {
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/class_columns_wrong.csv" \
        -o "$output_dir/class_columns_wrong_output/" \
        -c "$config_file"
}

test_feature_columns_wrong() {
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/feature_columns_wrong.csv" \
        -o "$output_dir/feature_columns_wrong_output/" \
        -c "$config_file"
}