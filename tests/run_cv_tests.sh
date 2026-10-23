#!/usr/bin/env bash
#SBATCH --job-name=blcm_tests
#SBATCH --time=12:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out


#set source dir to run tests
source_dir=/Users/B328695/Desktop/HABITAT/LCA_v1


data=$source_dir/data/synthetic_test_data/5_fold_cvs
config_file=$source_dir/src/config/config.yml
output_dir=$source_dir/5_cv_tests

test_review=$source_dir/tests/out.txt

source "$source_dir/tests/tests.sh"

run_test() {
    test="$1"
    test_name="$2"

    echo "Running test: $test_name" >> "$test_review"
    "$test"
}


mkdir -p slurm_logs
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

test_fold_1 test_fold_1 "Fold_1"
test_fold_2 test_fold_2 "Fold_2"
test_fold_3 test_fold_3 "Fold_3"
test_fold_4 test_fold_4 "Fold_4"
test_fold_5 test_fold_5 "Fold_5"
