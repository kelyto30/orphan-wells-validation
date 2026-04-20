# Pre-registration — Amendment 1 (2026-04-20)

This file amends `preregistration.md`. Both amendments are data-driven and made before any hypothesis test has been performed.

---

## Amendment 1.1 — Methane scope restriction

The pre-registered outcome list is updated as follows.

### Primary outcomes

| Analyte | RQ1 (case-control) | RQ2 (distance-response) | RQ3 (tier validation) |
|---|---|---|---|
| **Chloride (Cl)** | Primary | Primary | Primary |
| **Total dissolved solids (TDS)** | Primary | Sensitivity | Sensitivity |
| **Sulfate (SO4)** | Primary | Sensitivity | Sensitivity |
| **Dissolved methane (CH4)** | Primary | **Exploratory only (was primary)** | **Exploratory only (was primary)** |

### Secondary outcomes (RQ1 only)

Added:
- **Br/Cl mass ratio** — computed only for measurements with both Cl and Br present (n ≈ 12,729 Br). Oil-brine fingerprint.
- **Specific conductance (SC)** — brine proxy, n = 63,144 measurements.

### FDR correction

Benjamini-Hochberg q = 0.05 applied across **14 tests**: 4 primary × 3 RQs (= 12) + 2 secondary × 1 RQ (= 2).

---

## Amendment 1.2 — Primary analyte column mapping

The combined dataset (Haase et al., 2024) is in wide format with analyte-specific columns. The mapping from pre-registered outcome names to dataset columns is locked here to prevent downstream ambiguity.

| Pre-registered name | Dataset column | Unit column | Priority column |
|---|---|---|---|
| Chloride | `Cl` | `Cl_Units` | `Cl_Priority` |
| Total dissolved solids | `TDS` | `TDS_Units` | `TDS_Priority` |
| Sulfate | `SO4` | `SO4_Units` | `SO4_Priority` |
| Methane | `Methane` | `Methane_Units` | `Methane_Priority` |
| Bromide | `Br` | `Br_Units` | `Br_Priority` |
| Specific conductance | `SC` | `SC_Units` | `SC_Priority` |
| Distance to nearest orphan well | `Dists_m` | meters (fixed) | — |
| Well depth | `WellDepthMeasure/MeasureValue` | `WellDepthMeasure/MeasureUnitCode` | — |
| Sample date | `ActivityStartDate` | — | — |
| NWIS site ID | `MonitoringLocationIdentifier` | — | — |
| Orphan well ID | `OW_Rec_no` | — | — |
| Aquifer name | `AquiferName` (primary), `LocalAqfrName` (fallback) | — | — |
| State | `StateCode` | — | — |

---

## Amendment 1.3 — No changes to RQ1/RQ2/RQ3 hypothesis statements

Hypotheses H1, H2, H3 as originally stated remain unchanged. Only the analyte list and the FDR count change.

---

**Amendment author:** Kelechi Wisdom Elechi
**Date:** 2026-04-20
**Data state at time of amendment:** Combined dataset downloaded, no hypothesis tests run.
