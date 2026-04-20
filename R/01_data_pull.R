# ============================================================
# 01_data_pull.R
# Download raw data for orphan wells validation study.
#
# Expected runtime: 15-30 minutes depending on connection.
# Outputs: data/raw/*.{zip,csv,gpkg}
#
# Sources (verify URLs before running; ScienceBase DOIs resolve
# to metadata pages, actual downloads are linked from there):
#
#   DOW dataset:          https://doi.org/10.5066/P91PJETI
#   Combined dataset:     Haase et al. 2024 — search ScienceBase
#                         "Measurements of Water Quality Constituents
#                          in Groundwater Within 1 Mile of Orphaned Wells"
#   Principal Aquifers:   USGS National Aquifers (us_aquifers.zip)
#
# If direct URLs fail (USGS occasionally reorganizes), follow the
# MANUAL FALLBACK comments to download by hand and drop files into
# data/raw/.
# ============================================================

suppressPackageStartupMessages({
  library(here)
  library(fs)
  library(sf)
  library(readr)
  library(dplyr)
})

raw_dir <- here("data", "raw")
dir_create(raw_dir)

# ------------------------------------------------------------
# 1. DOW dataset (117,672 orphan wells)
# ------------------------------------------------------------
# The ScienceBase item page: https://doi.org/10.5066/P91PJETI
# Download the attached file (typically DOW_YYYYMMDD.zip or similar).
# Direct URL below may change — verify before running.

dow_url <- "https://www.sciencebase.gov/catalog/file/get/62ebd67bd34eacf539724c56"
dow_zip <- path(raw_dir, "DOW.zip")

if (!file_exists(dow_zip)) {
  message("Downloading DOW dataset...")
  tryCatch({
    download.file(dow_url, dow_zip, mode = "wb", timeout = 600)
    unzip(dow_zip, exdir = path(raw_dir, "DOW"))
  }, error = function(e) {
    message("!! Direct download failed. MANUAL FALLBACK:")
    message("   1. Visit https://doi.org/10.5066/P91PJETI")
    message("   2. Download the DOW data release (zipped CSV or SHP)")
    message("   3. Extract to data/raw/DOW/")
    stop(e$message)
  })
}

# ------------------------------------------------------------
# 2. Combined water-quality dataset (Haase et al. 2024)
# ------------------------------------------------------------
# USGS Orphan Wells Groundwater Quality combined dataset.
# Page:  https://www.usgs.gov/data/measurements-water-quality-constituents-groundwater-within-1-mile-161-km-orphaned-wells-united
# Expected contents (per the USGS description):
#   - individual measurements
#   - per-orphan-well averages
#   - distance-binned averages (e.g. <100 m, 100 m - 1 mi)

combined_dir <- path(raw_dir, "combined_wq")
dir_create(combined_dir)

if (length(dir_ls(combined_dir, recurse = TRUE)) == 0) {
  message("!! MANUAL DOWNLOAD REQUIRED for combined water-quality dataset.")
  message("   1. Visit the USGS data release page:")
  message("      https://www.usgs.gov/data/measurements-water-quality-constituents-groundwater-within-1-mile-161-km-orphaned-wells-united")
  message("   2. Download all child files (CSVs).")
  message("   3. Place them in: ", combined_dir)
  message("   4. Re-run this script.")
  # Do not stop — downstream scripts will error if files missing,
  # which is the correct signal. This lets the DOW download complete
  # even if combined must be fetched manually.
}

# ------------------------------------------------------------
# 3. USGS Principal Aquifers (national GIS layer)
# ------------------------------------------------------------
# Used to join each NWIS site to a principal aquifer for RQ3.

aquifer_zip <- path(raw_dir, "us_aquifers.zip")
aquifer_url <- "https://water.usgs.gov/GIS/dsdl/aquifrp025.zip"  # legacy

if (!file_exists(aquifer_zip)) {
  message("Downloading USGS Principal Aquifers...")
  tryCatch({
    download.file(aquifer_url, aquifer_zip, mode = "wb", timeout = 300)
    unzip(aquifer_zip, exdir = path(raw_dir, "aquifers"))
  }, error = function(e) {
    message("!! Aquifer download failed. MANUAL FALLBACK:")
    message("   1. Visit https://water.usgs.gov/GIS/")
    message("   2. Download 'Principal Aquifers of the 48 Conterminous United States'")
    message("   3. Extract to data/raw/aquifers/")
    message("Proceeding without aquifers — re-run when fixed.")
  })
}

# ------------------------------------------------------------
# 4. Woda et al. 2025 susceptibility tiers
# ------------------------------------------------------------
# Not programmatically downloadable — extract from supplementary
# material of Woda et al. 2025 STOTEN paper.
# DOI: https://doi.org/10.1016/j.scitotenv.2025.179246
#
# Expected format: one row per principal aquifer system with
# columns: aquifer_code, aquifer_name, susceptibility_group (1-5).

woda_path <- path(raw_dir, "woda_2025_susceptibility_tiers.csv")
if (!file_exists(woda_path)) {
  message("!! MANUAL EXTRACTION REQUIRED:")
  message("   Open Woda et al. 2025 supplementary material and extract")
  message("   the aquifer-level susceptibility group assignments.")
  message("   Save as CSV at: ", woda_path)
  message("   Columns: aquifer_code, aquifer_name, susceptibility_group")
}

# ------------------------------------------------------------
# 5. First-pass QC: what did we get?
# ------------------------------------------------------------
message("\n=== Raw data inventory ===")
inventory <- fs::dir_info(raw_dir, recurse = TRUE, type = "file") |>
  mutate(size_mb = round(as.numeric(size) / 1e6, 2)) |>
  select(path, size_mb, modification_time) |>
  arrange(desc(size_mb))

print(inventory)

# Write inventory for the pre-registration audit trail
write_csv(
  inventory |> mutate(path = as.character(path)),
  here("docs", paste0("data_inventory_", Sys.Date(), ".csv"))
)

message("\nDone. Next: R/02_controls.R")
