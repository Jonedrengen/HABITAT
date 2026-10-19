# Config

Configuration lives in two files: `config.yml` (model and analysis settings) and `slurm_spec.env` (Slurm environment). Pass `config.yml` with `--config` (or `-c`).

## config.yml

It is recommended not to change anything in `JAGS_DATA`.

```yaml
JAGS_DATA:
  seed: 69              # set NULL for a random seed
  chains: 3             
  iterations: 10000     # per chain, includes burn_in
  burn_in: 5000
  thin: 1
  save_parameters:      # eta is used for prediction scores
    - "pi"
    - "p"
    - "eta"
```

Most importantly, specify your data structure in `DATA_META`. This tells the script how to read your input CSV.

```yaml
DATA_META:
  id_column_name        : "Sample_Name"   # unique sample ID column
  training_column_name  : "training"      # 1 = training row, 0 = test row
  class_column_prefix   : "CL_"           # prefix for class (source) columns
  feature_column_prefix : "FE_"           # prefix for feature columns
```

___

`ANALYSIS` groups columns for summaries. Each entry is a substring, matched case-insensitively against column names. Only `human` and `meat` are used to map test isolates to hosts.

```yaml
ANALYSIS:
  groups:
    human:
      - "_human"      # columns containing "_human" grouped to 'human'
    meat:
      - "_chicken"    # columns containing "_chicken" grouped to 'meat'
      - "_pork"
      - "_beef"
      - "_turkey"
```

___

`OPTIONS`

```yaml
OPTIONS:
  delete_temp_files: FALSE   # TRUE deletes the temp/ folder after the run
```

## slurm_spec.env

Slurm environment settings for [slurmarize.sh](/Users/B328695/Desktop/HABITAT/LCA_v1/src/slurmarize.sh). Pass it with `-s`. Edit these before submitting:

```bash
conda_env_prefix=/path/to/conda/env   # full path to the Conda env, not the env name
source_dir=/path/to/src               # path to the src/ folder
module_to_load=path/to/module         # leave empty unless you need it, example: module_to_load=miniconda/23.11.0-2
```
