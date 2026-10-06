#!/usr/bin/env bash


#set source dir to run tests
source_dir=/Users/B328695/Desktop/Latent_class_analysis_v1/LCA_v1


data=$source_dir/data
config_file=$source_dir/src/config/config.yml
output_dir=$source_dir/test_output

test_review=$source_dir/tests/out.txt

source "$source_dir/tests/tests.sh"

run_test() {
    test="$1"
    test_name="$2"

    echo "Running test: $test_name" >> "$test_review"
    "$test"
}

###################
#### run tests ####
###################

while getopts "r:" opt; do
  case $opt in
    r) remove="${OPTARG:-F}" ;;
    *) echo "Invalid option: -$OPTARG" ;;
  esac
done

if [ "$remove" = "T" ]; then
    rm -rf "$output_dir"
fi

: > "$test_review"

# run duplicate_ids test
run_test test_duplicate_ids "duplicate_ids"
# run non_01_training test
run_test test_non_01_training "non_01_training"
# run quoted_input test
run_test test_quoted_input "quoted_input"
# run class_columns_wrong test
run_test test_class_columns_wrong "class_columns_wrong"
# run feature_columns_wrong test
run_test test_feature_columns_wrong "feature_columns_wrong"
# run 15 validation with ~3500 sb27
run_test test_SB27_raw_input "SB27_raw_input"
# run danmap 2713 input test
run_test test_danmap_2713_input "danmap_2713_input"
