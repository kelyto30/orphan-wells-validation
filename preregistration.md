# Pre-Registration

**Project:** Empirical validation of the Woda et al. (2025) national orphan-well groundwater susceptibility model.

**Investigator:** Kelechi Wisdom Elechi (FoxBuilds)

**Date pre-registered:** 2026-04-20

**Status:** Locked before any data inspection.

---

## 1. Background and rationale

Woda et al. (2025; *Science of the Total Environment* 976:179246) produced the first national multivariate geospatial investigation of orphan well threats to U.S. aquifers, identifying five susceptibility groupings and flagging Appalachian, Gulf Coast, and California aquifer systems as highest-risk. The authors explicitly noted: "Water-quality data is extremely sparse in relation to orphan wells nationally and may not be suitable for identifying contamination from oil and gas development."

This study treats that caveat as the primary empirical question. Using the USGS combined water-quality dataset (Haase et al., 2024), which joins 117,672 DOW orphan wells with NWIS observations within 1 mile of each, we test whether observed contaminant concentrations corroborate the predicted susceptibility tiers.

## 2. Research questions and hypotheses

### RQ1: Case-control (near vs. far)

**H1:** Median concentrations of at least one of {chloride, TDS, dissolved methane, sulfate} are higher in NWIS wells within 1 mile of a DOW orphan well than in matched control wells >5 km from any documented oil/gas well, matched on principal aquifer, well depth decile, and state.

**Direction:** Case > control. Two-sided test.

**Primary outcome:** Chloride (most commonly measured, literature-supported oil-brine tracer).

**Secondary outcomes:** TDS, dissolved methane, sulfate.

### RQ2: Distance-response

**H2:** Log-transformed concentration of chloride (primary) decreases monotonically with log-distance to the nearest DOW orphan well, after adjustment for principal aquifer (random intercept), well depth, and land cover at the NWIS site.

**Functional form:** `log(concentration) ~ log(distance + 1) + well_depth + land_cover + (1 | aquifer) + (1 | state)`

**Directional prediction:** β_{log(distance)} < 0.

### RQ3: Susceptibility tier validation

**H3:** The Woda et al. (2025) susceptibility tier is rank-correlated with observed median chloride concentration across principal aquifers.

**Primary test:** Spearman rank correlation between Woda tier (1–5) and aquifer-level median chloride concentration among cases.

**Secondary test:** ROC-AUC of Woda tier as a classifier for "any exceedance" of the EPA Secondary Maximum Contaminant Level for chloride (250 mg/L).

**Directional prediction:** ρ > 0, AUC > 0.6.

## 3. Data sources (locked)

1. **USGS DOW dataset** — 117,672 unplugged orphaned wells, 27 states (Grove & Merrill, 2022; DOI 10.5066/P91PJETI).
2. **USGS Combined dataset** — NWIS water-quality measurements within 1 mile of each DOW well, three views: individual measurements, per-well averages, distance-binned averages (Haase et al., 2024).
3. **USGS Principal Aquifers** — National GIS layer.
4. **Woda et al. 2025 supplement** — susceptibility tier per principal aquifer (Table 2).
5. **NWIS** (via `dataRetrieval::readWQPqw()`) — controls, queried for wells with chloride/TDS measurements, US-wide, that are (a) not in the combined dataset and (b) ≥5 km from any well in the DOW dataset and from any well in a state O&G registry.

No proprietary data. No new sampling.

## 4. Inclusion / exclusion criteria

**Cases (near-orphan wells):**
- INCLUDE: NWIS wells in the combined dataset with ≥1 chloride measurement post-1980.
- EXCLUDE: Wells with horizontal coordinate uncertainty >500 m.
- EXCLUDE: Measurements flagged by USGS as suspect or estimated.
- EXCLUDE: Wells without principal aquifer assignment.

**Controls (far from any O&G well):**
- INCLUDE: NWIS wells with ≥1 chloride measurement post-1980, ≥5 km from any DOW well AND ≥5 km from any active/inactive well in the IHS Markit-equivalent public alternative (to be confirmed: may substitute state O&G registries).
- Matched to cases on: principal aquifer (exact), well depth decile (within aquifer), state (exact).
- Matching ratio: up to 3 controls per case.

**Measurements:**
- Primary analysis uses the per-well median of each contaminant from 1980–2024, log10-transformed, with censored values handled via Kaplan-Meier estimation (`NADA` package) where censoring fraction <50%.
- Aquifers with <10 cases or <10 matched controls are excluded from RQ3.

## 5. Analytic plan (locked)

### Pre-analysis decisions

- Log10 transformation for all concentration outcomes.
- Distance transformed as log(meters + 1).
- Multiple comparisons: Benjamini-Hochberg FDR at q = 0.05 across the 4 outcomes × 3 RQs = 12 tests.
- All models fit in R 4.4+. Primary packages: `lme4`, `NADA`, `survival`, `pROC`, `sf`, `dataRetrieval`, `MatchIt`.

### RQ1 test

Paired Wilcoxon signed-rank test on per-matched-set medians. Effect size via Cliff's delta. Sensitivity: logistic regression on exceedance of EPA SMCL thresholds.

### RQ2 test

Linear mixed-effects model, chloride primary, TDS/methane/sulfate as sensitivity outcomes. Fixed effects: `log(distance + 1)`, well depth, NLCD land-cover class. Random intercepts for principal aquifer and state. Test β_{log(distance)} = 0 via likelihood ratio test.

### RQ3 test

Spearman ρ on aquifer-level medians vs. Woda tier. Bootstrap 95% CI (1000 iterations). Secondary: ROC-AUC on exceedance, DeLong method CI.

### Power / sample size

- PSE Healthy Energy (2023) estimated 8% of DOW wells have groundwater quality within 1 km (~9,400 wells). Expected cases: 5,000–15,000 measurements.
- At α=0.05 and an effect size of Cohen's d = 0.15 (small), required n per group = ~700. Feasible.
- If methane coverage is <500 cases (likely), methane is demoted to qualitative reporting only.

### Null result handling

- If H1 is null: main paper framing shifts to "empirical validation is constrained by data sparsity — we quantify the detection floor of NWIS for this question." Still publishable: directly addresses the Woda et al. caveat.
- If H2 is null: reported as null, sensitivity analyses reported, no post-hoc transformations.
- If H3 is null: reported as null. Does not invalidate H1/H2.

## 6. Deviations protocol

Any deviation from this plan after first data inspection is logged in `docs/deviation_log.md` with:
- Date
- What changed
- Why
- What the pre-registered version would have shown

Deviations are reported in the manuscript methods as "not pre-registered."

## 7. Timeline

| Week | Deliverable |
|---|---|
| 1 | Pre-registration (this document), repo setup, data pull script |
| 2 | Raw data downloaded and QC'd |
| 3 | Control cohort built |
| 4 | Descriptive analysis + Figure 1 |
| 5 | RQ1 analysis |
| 6 | RQ2 analysis |
| 7 | RQ3 analysis + Figures 4–5 |
| 8 | Manuscript + EarthArXiv preprint + GitHub release |

## 8. Outputs

- Preprint on EarthArXiv.
- Public GitHub repository with all code and derived tables (raw data gitignored, download scripts provided).
- Submission to *Science of the Total Environment* as primary target.

## 9. Conflict of interest

None.

## 10. References

- Grove, C.A., & Merrill, M.D. (2022). United States Documented Unplugged Orphaned Oil and Gas Well Dataset. USGS Data Release. https://doi.org/10.5066/P91PJETI
- Haase, K.B., et al. (2024). Measurements of Water Quality Constituents in Groundwater Within 1 Mile of Orphaned Wells in the United States. USGS Data Release.
- Woda, J., Haase, K.B., Gianoutsos, N.J., Jahn, K., & Gutchess, K. (2025). A geospatial analysis of water-quality threats from orphan wells in principal and secondary aquifers of the United States. *Science of the Total Environment*, 976, 179246. https://doi.org/10.1016/j.scitotenv.2025.179246
- PSE Healthy Energy (2023). Potential Opportunities and Risks of Orphaned Wells.
