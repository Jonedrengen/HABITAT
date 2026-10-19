# HABITAT Bayesian Latent Class Model

This repository runs a Bayesian latent class model to attribute mobile genetic elements to their likely host source.

## Setup

Create and activate the Conda environment:

```bash
conda env create -f LCA_env_v1.yml
conda activate HABITAT_blcm
```

## Run

Basic run command for the R script. see the `config` section in this readme for config specifics

```bash
Rscript src/run_bayesian.R \
  --input data/SB27_raw_input.csv \
  --output output/SB27 \
  --config src/config/config.yml
```

## Run Slurm

Use `src/slurmarize.sh` to wrap the run for SLURM HPC systems. Before submitting, edit `src/slurm_spec.env`. see `config/slurm_spec.env`

Pass the run options after the script name; `sbatch` forwards them to the script. Run from the `LCA_v1` directory so the relative paths resolve:

```bash
sbatch src/slurmarize.sh \
  -i data/SB27_raw_input.csv \
  -o output/SB27 \
  -c src/config/config.yml \
  -s src/slurm_spec.env
```

## config

config file at `config/config.yml`. See `config/README.md` for detailed config info. It is recommended to not change anything in `JAGS_DATA`

most importantly, specify Data structure by changing values in DATA_META. This allows the script to understand your data.
```yaml
DATA_META:
  id_column_name        : "id_column_header"        # default: "Sample_Name"
  training_column_name  : "training_column_header"  # default: "training"
  class_column_prefix   : "some_prefix"             # default: "CL_"
  feature_column_prefix : "some_prefix"             # default: "FE_"
```
___
For now, ANALYSIS, is used to group data for plots and summaries. It does this by using substrings to identify columns.
```yaml
  ANALYSIS:
    groups: 
      human:        # human group
        - "_human"    # columns containing "_human" grouped to 'human'
      meat:         # meat group
        - "_chicken"  # columns containing "_chicken" grouped to 'meat'
        - "_pork"     # columns containing "_pork" grouped to 'meat'
        - "_beef"     # ...
        - "_turkey"
```

## Output

```text
output/SB27/
├── logs/
│   └── blcm.log
├── results/
│   ├── pred_scores_raw.csv
│   ├── pred_scores_summary.csv
│   └── plots/
│       └── main_histogram.png
└── temp/
    ├── input_data.csv
    ├── training_data.csv
    ├── test_data.csv
    ├── eta_vector.csv
    ├── feature_matrix.csv
    ├── bugs_summary_table.csv
    └── <timestamp>_config.yml
```

