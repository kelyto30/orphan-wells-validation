# ============================================================
# 01_data_pull.R  (v2 - updated 2026-04-20)
# Download raw data for orphan wells validation study.
# Sources verified 2026-04-20 against live ScienceBase catalog.
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

fetch_sb_bundle <- function(item_id, zip_path, extract_dir, label) {
  url <- paste0("https://www.sciencebase.gov/catalog/file/get/", item_id)
  if (!file_exists(zip_path) && !dir_exists(extract_dir)) {
    dir_create(extract_dir)
    message("Downloading ", label, " from ScienceBase...")
    tryCatch({
      download.file(url, zip_path, mode = "wb", timeout = 600)
      unzip(zip_path, exdir = extract_dir)
      message("  [ok] ", label, " extracted to ", extract_dir)
    }, error = function(e) {
      message("  [fail] ", label, " download failed.")
      message("     Manual fallback: visit")
      message("       https://www.sciencebase.gov/catalog/item/", item_id)
      message("     and download all files into ", extract_dir)
    })
  } else {
    message("  [skip] ", label, " already present.")
  }
}

fetch_sb_bundle(
  item_id     = "62ebd67bd34eacf539724c56",
  zip_path    = path(raw_dir, "DOW.zip"),
  extract_dir = path(raw_dir, "DOW"),
  label       = "DOW orphan wells dataset"
)

fetch_sb_bundle(
  item_id     = "64e79b1ed34eeb681137f4ff",
  zip_path    = path(raw_dir, "combined_wq", "combined_wq.zip"),
  extract_dir = path(raw_dir, "combined_wq"),
  label       = "Haase et al. 2024 combined water-quality dataset"
)

fetch_sb_bundle(
  item_id     = "63140610d34e36012efa385d",
  zip_path    = path(raw_dir, "us_aquifers.zip"),
  extract_dir = path(raw_dir, "aquifers"),
  label       = "USGS Principal Aquifers"
)

woda_path <- path(raw_dir, "woda_2025_susceptibility_tiers.csv")
if (!file_exists(woda_path)) {
  message("")
  message("!! MANUAL EXTRACTION REQUIRED:")
  message("   Open Woda et al. 2025 (STOTEN 976:179246) supplement.")
  message("   DOI: https://doi.org/10.1016/j.scitotenv.2025.179246")
  message("   Save tier table as: ", woda_path)
  message("   Columns: aquifer_code, aquifer_name, susceptibility_group")
}

message("")
message("=== Raw data inventory ===")
inventory <- fs::dir_info(raw_dir, recurse = TRUE, type = "file") |>
  mutate(size_mb = round(as.numeric(size) / 1e6, 2)) |>
  select(path, size_mb, modification_time) |>
  arrange(desc(size_mb))

print(inventory, n = 50)

write_csv(
  inventory |> mutate(path = as.character(path)),
  here("docs", paste0("data_inventory_", Sys.Date(), ".csv"))
)

message("")
message("Done. Next: R/02_controls.R")
