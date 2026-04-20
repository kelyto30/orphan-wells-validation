# Orphan Wells Validation

Empirical validation of the Woda et al. (2025) national orphan-well groundwater susceptibility model using observed water-quality data from the USGS National Water Information System.

## Status

Week 1 of 8. Pre-registered, pre-data-pull.

## Research question

Does observed groundwater chemistry near documented unplugged orphan oil and gas wells statistically differ from background conditions, and do the observed patterns corroborate the predicted susceptibility tiers in Woda et al. (*Science of the Total Environment*, 2025)?

Three nested sub-questions:

1. **Case-control.** Are observed contaminant concentrations (chloride, TDS, methane, sulfate) in NWIS wells within 1 mile of orphan wells higher than in matched distant-control wells?
2. **Distance-response.** Is there a log-linear distance-response gradient in concentration vs. distance to the nearest orphan well, adjusting for aquifer, depth, and land use?
3. **Susceptibility validation.** Does observed contamination track the Woda et al. susceptibility tier by aquifer group (Spearman rank + ROC AUC)?

## Why it matters

Woda et al. (2025) published the first national multivariate susceptibility analysis but explicitly noted that water-quality data was too sparse to directly test contamination levels. This project is the empirical counterpart: using the pre-joined USGS combined water-quality dataset released by Haase et al. (2024), we test whether the susceptibility predictions are borne out in observed chemistry.

## Repository structure

```
orphan-wells-validation/
├── README.md                  # You are here
├── preregistration.md         # Locked pre-analysis plan
├── .gitignore
├── R/
│   ├── 00_setup.R             # Package installation, session init
│   ├── 01_data_pull.R         # Download DOW + combined dataset + aquifers
│   ├── 02_controls.R          # Build control cohort (>5 km from O&G wells)
│   ├── 03_descriptive.R       # EDA, missingness, Figure 1
│   ├── 04_case_control.R      # Analysis 1: near vs far
│   ├── 05_distance_response.R # Analysis 2: distance gradient
│   ├── 06_validation.R        # Analysis 3: Woda tier validation
│   └── utils.R
├── data/
│   ├── raw/                   # Downloaded files (gitignored)
│   └── processed/             # Derived tables (gitignored)
├── figures/                   # Outputs
├── manuscript/
│   └── draft.qmd              # Quarto manuscript
└── docs/                      # Notes, references
```

## Reproducibility

Tested on macOS 14, base R 4.4.x. Sonoma/Sequoia. No RStudio required.

```bash
cd orphan-wells-validation
R --no-save < R/00_setup.R        # Install packages
R --no-save < R/01_data_pull.R    # Pull data (takes ~20 min)
```

Data downloads are gitignored. Scripts and outputs are tracked.

## Data sources

| Source | Description | Access |
|---|---|---|
| USGS DOW dataset | 117,672 documented orphan wells, 27 states | ScienceBase DOI 10.5066/P91PJETI |
| USGS Combined dataset | NWIS water quality within 1 mile of DOW wells | ScienceBase (Haase et al. 2024) |
| USGS Principal Aquifers | National aquifer GIS layer | USGS Water Resources |
| Woda et al. 2025 Table 2 | Susceptibility tier per principal aquifer | STOTEN supplement |
| NWIS (via `dataRetrieval`) | Control wells far from any O&G well | `dataRetrieval::readWQPqw()` |

## Target journals

1. *Science of the Total Environment* (same journal as Woda et al.)
2. *Environmental Science & Technology*
3. *Water Resources Research*

## Citation

Pre-print forthcoming. For now:

> Elechi, K.W. (2026). Orphan Wells Validation: Empirical assessment of the Woda et al. (2025) national groundwater susceptibility model. GitHub repository.

## License

Code: MIT. Manuscript text: CC-BY-4.0.
