# Deviation log

Any change from the locked pre-registration is recorded here with date, what changed, why, and what the pre-registered version would have shown.

---

## 2026-04-20 — Week 1 amendments following first data inspection

After pulling the USGS combined dataset (Haase et al., 2024) and inspecting sample sizes across primary outcomes, two amendments are made.

### Amendment 1 — Methane demoted to exploratory for RQ2 and RQ3

**Pre-registered position.** Methane was a secondary outcome for all three RQs, with a written contingency: "If methane coverage is <500 cases, methane is demoted to qualitative reporting only."

**Observed.** The combined dataset has 1,207 methane measurements from 221 unique NWIS monitoring sites. Across 38 distinct principal/local aquifer names, this averages ~6 sites per aquifer, below any reasonable floor for per-aquifer inference (RQ3) or distance-response modeling (RQ2).

**Change.** Methane remains a primary outcome for RQ1 (case-control). For RQ2 and RQ3, methane is reported descriptively only, with no p-values and no tier-validation statistic. The manuscript will explicitly note this as a direct illustration of the Woda et al. (2025) data-sparsity caveat.

**Why this is consistent.** The pre-registered contingency anticipated this case. The only refinement is clarifying that the decision rule operates at the site level, not the measurement level — more appropriate given NWIS structure.

### Amendment 2 — Add Br/Cl ratio and Specific Conductance as secondary outcomes for RQ1

**Pre-registered position.** The pre-reg named Cl, TDS, CH4, and SO4 as primary/secondary outcomes and allowed additional secondary outcomes to be specified after data inspection.

**Observed.** The combined dataset provides 12,729 bromide measurements and 63,144 specific conductance measurements. In the hydrogeochemistry literature, Br/Cl mass ratio is the standard fingerprint distinguishing oil-field brine (low Br/Cl, typically <0.003) from road salt or other Cl sources (higher Br/Cl). Specific conductance is a rapid brine proxy.

**Change.** Added to RQ1 secondary outcomes:
- **Br/Cl mass ratio** (restricted to measurements with both Cl and Br non-missing).
- **Specific conductance.**

These are included in the FDR correction (now 14 tests total: 4 primary outcomes × 3 RQs + 2 additional secondary × 1 RQ = 14).

**Why this is consistent.** The pre-registration explicitly allowed naming additional secondary outcomes contingent on data availability. These are named now, before any hypothesis test is run.

---

## Sample-size snapshot as of 2026-04-20

| Analyte | Measurements | Orphan wells | NWIS sites | Role |
|---|---|---|---|---|
| Cl | 69,927 | 17,903 | 7,355 | Primary — all RQs |
| TDS | 38,413 | 14,211 | 5,537 | Primary — all RQs |
| SO4 | 46,244 | 16,587 | 6,303 | Primary — all RQs |
| Methane | 1,207 | 901 | 221 | Primary RQ1 only |
| SC | 63,144 | — | — | Secondary RQ1 |
| Br (for Br/Cl) | 12,729 | — | — | Secondary RQ1 |

Geographic spread: 27 states, 38 distinct aquifer names. Date range 1915–2023, with 37,898 measurements post-1980 (pre-reg filter retained).
