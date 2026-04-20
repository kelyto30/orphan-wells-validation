suppressPackageStartupMessages({
  library(dataRetrieval)
  library(dplyr)
  library(readr)
  library(sf)
  library(here)
  library(fs)
  library(purrr)
})

options(timeout = 300)

raw_dir       <- here("data", "raw")
processed_dir <- here("data", "processed")
log_path      <- here("docs", "controls_pull_log.txt")
dir_create(processed_dir)

log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%H:%M:%S"), "  ", sprintf(...))
  cat(msg, "\n")
  cat(msg, "\n", file = log_path, append = TRUE)
}

cat("====================================================\n", file = log_path, append = TRUE)
log_msg("PHASE A START (v2)")

dow <- read_csv(path(raw_dir, "DOW", "US_orphaned_wells.csv"),
                show_col_types = FALSE, progress = FALSE)

dow <- dow |>
  filter(!is.na(Latitude), !is.na(Longitude),
         Latitude < 50, Latitude > 24,
         Longitude < -65, Longitude > -125)

log_msg("DOW wells after CONUS filter: %d", nrow(dow))

dow_sf <- dow |>
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) |>
  st_transform(5070)

case_ids <- read_csv(path(raw_dir, "combined_wq", "All_GWQ_Data_1_61km_From_OW.csv"),
                     show_col_types = FALSE, progress = FALSE,
                     col_select = "MonitoringLocationIdentifier") |>
  pull(MonitoringLocationIdentifier) |>
  unique()

log_msg("Case NWIS site IDs to exclude: %d", length(case_ids))

state_fips <- c(
  "Alabama"="US:01", "Arkansas"="US:05", "California"="US:06",
  "Colorado"="US:08", "Florida"="US:12", "Illinois"="US:17",
  "Indiana"="US:18", "Kansas"="US:20", "Kentucky"="US:21",
  "Louisiana"="US:22", "Maryland"="US:24", "Michigan"="US:26",
  "Mississippi"="US:28", "Missouri"="US:29", "Montana"="US:30",
  "Nebraska"="US:31", "Nevada"="US:32", "New Mexico"="US:35",
  "New York"="US:36", "North Dakota"="US:38", "Ohio"="US:39",
  "Oklahoma"="US:40", "Pennsylvania"="US:42", "South Dakota"="US:46",
  "Tennessee"="US:47", "Texas"="US:48", "Utah"="US:49",
  "Virginia"="US:51", "West Virginia"="US:54", "Wyoming"="US:56"
)

dow_states <- unique(dow$State) |> sort()
missing_in_fips <- setdiff(dow_states, names(state_fips))
if (length(missing_in_fips) > 0) {
  log_msg("!! States in DOW missing from FIPS list: %s",
          paste(missing_in_fips, collapse=", "))
}

states_to_pull <- intersect(dow_states, names(state_fips))
log_msg("States to pull: %d", length(states_to_pull))

target_analytes <- c("Chloride", "Total dissolved solids",
                     "Sulfate", "Methane")

# Columns known to have mixed types across queries; coerce to character
problem_cols <- c(
  "HorizontalAccuracyMeasure.MeasureValue",
  "VerticalAccuracyMeasure.MeasureValue",
  "VerticalMeasure.MeasureValue",
  "SourceMapScaleNumeric",
  "DrainageAreaMeasure.MeasureValue",
  "ContributingDrainageAreaMeasure.MeasureValue",
  "WellDepthMeasure.MeasureValue",
  "WellHoleDepthMeasure.MeasureValue",
  "ConstructionDateText"
)

coerce_problem_cols <- function(df) {
  for (c in problem_cols) {
    if (c %in% names(df)) df[[c]] <- as.character(df[[c]])
  }
  df
}

pull_state_sites <- function(state_name) {
  code <- state_fips[[state_name]]
  out_file <- path(processed_dir, sprintf("controls_sites_%s.csv",
                                          gsub(" ", "_", state_name)))
  if (file_exists(out_file)) {
    return(read_csv(out_file, show_col_types = FALSE, progress = FALSE))
  }

  t0 <- Sys.time()
  all_sites <- list()
  for (analyte in target_analytes) {
    sites <- tryCatch({
      whatWQPsites(statecode          = code,
                   siteType           = "Well",
                   characteristicName = analyte)
    }, error = function(e) {
      log_msg("  [%s/%s] ERROR: %s", state_name, analyte, e$message)
      NULL
    })
    if (!is.null(sites) && nrow(sites) > 0) {
      sites <- coerce_problem_cols(sites)
      sites$query_analyte <- analyte
      all_sites[[analyte]] <- sites
    }
  }

  if (length(all_sites) == 0) {
    log_msg("  [%s] no sites returned", state_name)
    return(NULL)
  }

  combined <- bind_rows(all_sites) |>
    distinct(MonitoringLocationIdentifier, .keep_all = TRUE) |>
    filter(!is.na(LatitudeMeasure), !is.na(LongitudeMeasure)) |>
    mutate(state = state_name)

  write_csv(combined, out_file)
  t1 <- Sys.time()
  log_msg("  [%s] %d sites in %.0f sec",
          state_name, nrow(combined), as.numeric(t1-t0, units="secs"))
  combined
}

all_state_sites <- list()
for (st in states_to_pull) {
  sites <- pull_state_sites(st)
  if (!is.null(sites)) {
    sites <- coerce_problem_cols(sites)
    all_state_sites[[st]] <- sites
  }
}

sites_all <- bind_rows(all_state_sites)
log_msg("Total candidate sites across states: %d", nrow(sites_all))

sites_all <- sites_all |>
  filter(!MonitoringLocationIdentifier %in% case_ids)
log_msg("After dropping case site IDs: %d remain", nrow(sites_all))

log_msg("Computing distance to nearest orphan well...")
t0 <- Sys.time()

sites_sf <- sites_all |>
  st_as_sf(coords = c("LongitudeMeasure", "LatitudeMeasure"),
           crs = 4326, remove = FALSE) |>
  st_transform(5070)

nearest <- st_nearest_feature(sites_sf, dow_sf)
dists   <- st_distance(sites_sf, dow_sf[nearest, ], by_element = TRUE) |>
  as.numeric()

sites_sf$nearest_orphan_m <- dists

controls <- sites_sf |>
  filter(nearest_orphan_m >= 5000) |>
  st_drop_geometry()

t1 <- Sys.time()
log_msg("Distance computation: %.0f sec", as.numeric(t1-t0, units="secs"))
log_msg("Sites >=5 km from any orphan well: %d of %d candidates",
        nrow(controls), nrow(sites_sf))

out_path <- path(processed_dir, "controls_phaseA_candidates.csv")
write_csv(controls, out_path)
log_msg("Phase A complete. Wrote: %s", out_path)

summary_tbl <- controls |>
  count(state, sort = TRUE)
cat("\n=== CANDIDATES PER STATE ===\n")
print(summary_tbl, n = 30)

log_msg("PHASE A END")
cat("====================================================\n", file = log_path, append = TRUE)

cat("\nNext: R/02b_controls_phaseB.R will pull WQ data.\n")
