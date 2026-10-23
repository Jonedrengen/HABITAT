#!/usr/bin/env bash

test_SB27_raw_input() {
    echo
    echo "Running test_SB27_raw_input"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/SB27_and_15_validation.csv" \
        -o "$output_dir/SB27_raw_input_output/" \
        -c "$config_file"
    echo
}

test_quoted_input() {
    echo
    echo "Running test_quoted_input"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/quoted_data.csv" \
        -o "$output_dir/quoted_input_output/" \
        -c "$config_file"
    echo
}

test_duplicate_ids() {
    echo
    echo "Running test_duplicate_ids"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/duplicate_id.csv" \
        -o "$output_dir/duplicate_ids_output/" \
        -c "$config_file"
    echo
}

test_non_01_training() {
    echo
    echo "Running test_non_01_training"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/non_01_training.csv" \
        -o "$output_dir/non_01_training_output/" \
        -c "$config_file"
    echo
}

test_class_columns_wrong() {
    echo
    echo "Running test_class_columns_wrong"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/class_columns_wrong.csv" \
        -o "$output_dir/class_columns_wrong_output/" \
        -c "$config_file"
    echo
}

test_feature_columns_wrong() {
    echo
    echo "Running test_feature_columns_wrong"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fixtures/feature_columns_wrong.csv" \
        -o "$output_dir/feature_columns_wrong_output/" \
        -c "$config_file"
    echo
}

test_danmap_2713_input() {
    echo
    echo "Running danmap_2713_input"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/danmap_2713_input.csv" \
        -o "$output_dir/danmap_2713_input_output/" \
        -c "$config_file"
    echo
}

test_fold_1() {
    echo
    echo "Running fold_1"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fold_1.csv" \
        -o "$output_dir/fold_1_output/" \
        -c "$config_file"
    echo
}

test_fold_2() {
    echo
    echo "Running fold_2"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fold_2.csv" \
        -o "$output_dir/fold_2_output/" \
        -c "$config_file"
    echo
}

test_fold_3() {
    echo
    echo "Running fold_3"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fold_3.csv" \
        -o "$output_dir/fold_3_output/" \
        -c "$config_file"
    echo
}

test_fold_4() {
    echo
    echo "Running fold_4"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fold_4.csv" \
        -o "$output_dir/fold_4_output/" \
        -c "$config_file"
    echo
}

test_fold_5() {
    echo
    echo "Running fold_5"
    Rscript "$source_dir/src/run_bayesian.R" \
        -i "$data/fold_5.csv" \
        -o "$output_dir/fold_5_output/" \
        -c "$config_file"
    echo
}