# 5-fold cross-validation splits (synthetic data)

Five train/test splits of the same synthetic dataset, for testing the model with cross-validation.

## Files

| File | Samples | Training rows | Test rows |
|------|---------|---------------|-----------|
| `fold_1.csv` | 8,623 | 6,897 | 1,726 |
| `fold_2.csv` | 8,623 | 6,897 | 1,726 |
| `fold_3.csv` | 8,623 | 6,897 | 1,726 |
| `fold_4.csv` | 8,623 | 6,899 | 1,724 |
| `fold_5.csv` | 8,623 | 6,902 | 1,721 |

Each sample is in the test set of exactly one fold, so across the five folds every sample is tested once.

## Columns

- `Sample_Name`: sample ID (for example `31_CN_03_B27_M3_C8_P1`).
- `training`: `1` for training rows, `0` for test rows.
- `MLST`: sequence type. Not used by the model.
- `CL_*`: host class columns (`CL_Human_CL1`, `CL_Human_CL2`, `CL_Chicken_CL1`, `CL_Chicken_CL2`, `CL_Turkey_CL1`, `CL_Turkey_CL2`, `CL_Pork_`, `CL_Beef_`). Each row has exactly one class set to `1`. Test rows keep their true class, so they can be used for scoring.
- `FE_*`: 19 MGE feature columns (`FE_CL1`, `FE_CL2`, `FE_EL18` to `FE_EL50`), values `0` or `1`.

Features and classes are the same in every fold. Only the `training` column changes.
