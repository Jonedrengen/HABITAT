#!/usr/bin/env bash
#SBATCH --job-name=HABITAT_blcm
#SBATCH --output=HABITAT_blcm.out
#SBATCH --error=HABITAT_blcm.err
#SBATCH --time=04-00:00:00
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=2
#SBATCH --mem=12G


usage() {
  echo "Usage: sbatch $0 -i input_file -o output_dir -c config_file -s slurm_spec [-h]"
  echo "  -i input_file      Path to input file (.csv)"
  echo "  -o output_dir      Path to output directory"
  echo "  -c config_file     Path to config file (.yml)"
  echo "  -s slurm_spec      Path to slurm specification file (.env)"
  echo "  -h                 Show this help message"
}

while getopts "i:o:c:s:h" opt; do
  case $opt in
    i) input_file="${OPTARG}" ;;
    o) output_dir="${OPTARG}" ;;
    c) config_file="${OPTARG}" ;;
    s) slurm_spec="${OPTARG}" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

#validate input
if [[ -z "$input_file" || -z "$output_dir" || ! -r "$config_file" ]]; then
  usage
  exit 1
fi

#check for slurm specification file
if ! source "$slurm_spec"; then
  echo "Error: Failed to evaluate slurm_spec"
  echo "Slurm spec: $slurm_spec"
  exit 1
fi

#make sure slurm is used
if [[ ! ${SLURM_JOB_ID} ]]; then
  echo "Error: Not running within a SLURM job"
  echo "use 'sbatch' to submit the job"
  exit 1
fi


conda run -p "$conda_env_prefix" Rscript "$source_dir/run_bayesian.R" -i "$input_file" -o "$output_dir" -c "$config_file"