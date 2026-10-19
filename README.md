# HABITAT Bayesian Latent Class Model

This repository runs a Bayesian latent class model to attribute mobile genetic elements to their likely host source.

## Setup

Create and activate the Conda environment:

```bash
conda env create -f LCA_env_v1.yml
conda activate HABITAT_blcm
```

## Run

Input CSV files should include sample IDs, a `training` column (`1` for training and `0` for testing), class columns prefixed with `CL_`, and feature columns prefixed with `FE_`. Defaults are defined in `src/config/config.yml`.

```bash
Rscript src/run_bayesian.R \
  --input data/SB27_raw_input.csv \
  --output output/SB27 \
  --config src/config/config.yml
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

