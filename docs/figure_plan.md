# Figure plan

Locked before analysis, subject to the deviations protocol.

---

## Figure 1 — Study design and data landscape

**Layout:** Three-panel horizontal.

- **1A.** National map of the conterminous U.S. Overlay: DOW orphan well density (hexbin, 50 km), with principal aquifer boundaries. Color-coded by Woda et al. 2025 susceptibility tier (1–5).
- **1B.** Heatmap: NWIS measurement availability per case well (rows = orphan wells, cols = analyte), sorted by completeness. Shows the data-sparsity problem explicitly.
- **1C.** Flow diagram: 117,672 DOW wells → included cases → matched controls → final analytic sample per RQ.

**Purpose:** Orient the reader. Establish that we are working with the published DOW dataset, not a new sampling campaign. Honest about sparsity up-front.

---

## Figure 2 — Case-control comparison (RQ1)

**Layout:** Four-panel grid (2x2, one per analyte).

For each of {chloride, TDS, methane, sulfate}:
- Raincloud plot (violin + jitter + boxplot) of log10 concentration in cases vs matched controls.
- Cliff's delta + 95% bootstrap CI annotated.
- EPA SMCL or reference threshold shown as horizontal line.

**Purpose:** The headline empirical result. If there's a real case-control difference, this figure carries it. If null, this figure shows honest overlap.

---

## Figure 3 — Distance-response (RQ2)

**Layout:** Two-panel.

- **3A.** Scatter of log10 chloride vs log10 distance to nearest orphan well. Overlaid mixed-effects prediction line with 95% CI. Points colored by principal aquifer group.
- **3B.** Forest plot of β_{log(distance)} estimates with 95% CI, one row per principal aquifer (faceted by Woda tier).

**Purpose:** Tests whether the distance gradient exists nationally and whether it's consistent across aquifers.

---

## Figure 4 — Susceptibility tier validation (RQ3)

**Layout:** Two-panel.

- **4A.** Bar chart of aquifer-level median chloride concentration by Woda tier (1–5). Points = individual aquifers. Spearman ρ + bootstrap CI annotated.
- **4B.** ROC curve: Woda tier as classifier for "aquifer median exceeds EPA SMCL (250 mg/L)." AUC with DeLong CI.

**Purpose:** Direct validation of the Woda et al. 2025 ranking against observed data. The paper's most publishable figure.

---

## Figure 5 — Detection floor and policy implications

**Layout:** Two-panel.

- **5A.** Power curve: minimum detectable effect size (Cohen's d) as a function of NWIS sample density per aquifer. Shows where the data is/isn't adequate.
- **5B.** Map: aquifers flagged by Woda as high susceptibility but with insufficient NWIS monitoring to test contamination (the monitoring gap map).

**Purpose:** Policy hook. Directly actionable for BIL plugging prioritization: where does IIJA money need to fund water monitoring, not just plugging?

---

## Supplementary figures (planned)

- **S1.** Missingness patterns per analyte by state.
- **S2.** Sensitivity analyses: repeat RQ1 with varying distance thresholds (0.5, 1, 2 miles).
- **S3.** Censoring sensitivity: compare Kaplan-Meier vs substitution methods for non-detects.
- **S4.** Temporal stratification: pre-2010 vs post-2010 measurements.
