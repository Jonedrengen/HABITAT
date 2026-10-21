# HABITAT Bayesian Latent Class Model

This repository runs a Bayesian latent class model to attribute mobile genetic elements to their likely host source.

## Setup

Create and activate the Conda environment:

```bash
conda env create -f LCA_env_v1.yml
conda activate HABITAT_blcm
```

## Run

Run the analysis with:

```bash
Rscript path/to/run_bayesian.R \
  --input path/to/input.csv \
  --output path/to/output_dir \
  --config path/to/config.yml
```

## Run Slurm

Use `path/to/slurmarize.sh` to run on SLURM HPC systems.

1. Edit [src/config/slurm_spec.env](src/config/slurm_spec.env) with your Conda and source paths.
2. Specify the SBATCH variables to match your system. Submit the job:

```bash
sbatch path/to/slurmarize.sh \
  -i path/to/input.csv \
  -o path/to/output_dir \
  -c path/to/config.yml \
  -s path/to/slurm_spec.env
```

## Config

Settings are in [src/config/config.yml](src/config/config.yml). See [src/config/README.md](src/config/README.md) for details.

Leave `JAGS_DATA` as it is. The most important setting is `DATA_META`, which tells the script how your data is structured: Example dataset in `src/base_training/example`

```yaml
DATA_META:
  id_column_name        : "id_column_header"        # default: "Sample_Name"
  training_column_name  : "training_column_header"  # default: "training"
  class_column_prefix   : "some_prefix"             # default: "CL_"
  feature_column_prefix : "some_prefix"             # default: "FE_"
```

`ANALYSIS.groups` sets the host groups used in summaries and plots. Each entry is a substring that identifies columns:

```yaml
  ANALYSIS:
    groups: 
      human:        # human group
        - "human"    # columns containing "human" grouped to 'human'
      meat:         # meat group
        - "chicken"  # columns containing "chicken" grouped to 'meat'
        - "pork"     # columns containing "pork" grouped to 'meat'
        - "beef"     # ...
        - "turkey"
```

## Where to find things

```text
LCA_v1/
├── README.md
├── LCA_env_v1.yml                  # Conda environment
├── src/
│   ├── run_bayesian.R              # entry point
│   ├── slurmarize.sh               # Slurm wrapper
│   ├── config/                     # config.yml, slurm_spec.env
│   ├── blcm/                       # input checks, JAGS data, summaries, plots
│   ├── model/model.bug             # the JAGS model
│   ├── utils/                      # logging and output folder helpers
│   └── base_training/example/      # example input
│
├──
```

## Output

```text
output/
├── logs/
│   └── blcm.log
├── results/
│   ├── pred_scores_raw.csv
│   ├── pred_scores.csv
│   └── plots/
│       └── histogram.png
└── temp/
    ├── input_data.csv
    ├── training_data.csv
    ├── test_data.csv
    ├── eta_vector.csv
    ├── feature_matrix.csv
    ├── bugs_summary_table.csv
    └── <timestamp>_config.yml
```

