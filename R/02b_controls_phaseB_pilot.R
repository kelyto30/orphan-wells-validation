# ============================================================
# 02b_controls_phaseB_pilot.R  (v3)
# PILOT: Pull water-quality data for Pennsylvania control candidates.
# v3 changes:
#   - NULL-safe progress counting (sum failed on lists with NULLs)
#   - 5 retries instead of 3, with jitter to avoid sync with WQP load
#   - Per-analyte checkpointing: save partial data even if crash
# ============================================================

suppressPackageStartupMessages({
  library(dataRetrieval)
  library(dplyr)
  library(readr)
  library(here)
  library(fs)
})

options(timeout = 600)

processed_dir <- here("data", "processed")
log_path      <- here("docs", "controls_pull_log.txt")

log_msg <- function(...) {
  msg <- paste0(format(Sys.time(), "%H:%M:%S"), "  ", sprintf(...))
  cat(msg, "\n")
  cat(msg, "\n", file = log_path, append = TRUE)
}

cat("====================================================\n", file = log_path, append = TRUE)
log_msg("PHASE B PILOT START v3 (Pennsylvania)")

to_character_df <- function(df) {
  df[] <- lapply(df, as.character)
  df
}

# Safe row-count for a list that may contain NULLs or non-df objects
count_rows <- function(lst) {
  lst <- Filter(function(x) is.data.frame(x) && nrow(x) > 0, lst)
  if (length(lst) == 0) return(0L)
  sum(vapply(lst, nrow, integer(1)))
}

candidates <- read_csv(path(processed_dir, "controls_phaseA_candidates.csv"),
                       show_col_types = FALSE, progress = FALSE) |>
  filter(state == "Pennsylvania")

log_msg("PA candidate control sites: %d", nrow(candidates))
pa_ids <- unique(candidates$MonitoringLocationIdentifier)
log_msg("Unique site IDs to query: %d", length(pa_ids))

# ------------------------------------------------------------
# 5-retry exponential backoff with jitter
# ------------------------------------------------------------
pull_with_retry <- function(site_batch, analyte, max_retries = 5) {
  base_waits <- c(15, 30, 60, 120, 240)
  for (attempt in seq_len(max_retries)) {
    result <- tryCatch({
      readWQPqw(siteNumbers = site_batch, parameterCd = analyte)
    }, error = function(e) list(err = e$message))
    if (is.data.frame(result)) return(result)
    if (attempt < max_retries) {
      jitter  <- runif(1, 0.7, 1.3)
      wait    <- round(base_waits[attempt] * jitter)
      log_msg("    retry %d after %ds (err: %s)",
              attempt, wait, substr(result$err, 1, 60))
      Sys.sleep(wait)
    } else {
      log_msg("    FAIL after %d attempts: %s",
              max_retries, substr(result$err, 1, 100))
      return(NULL)
    }
  }
}

target_analytes <- c("Chloride", "Total dissolved solids",
                     "Sulfate", "Methane")
batch_size <- 200
site_batches <- split(pa_ids, ceiling(seq_along(pa_ids) / batch_size))
log_msg("Batches per analyte: %d (size %d)", length(site_batches), batch_size)

all_measurements <- list()
t_total <- Sys.time()

for (analyte in target_analytes) {
  log_msg("--- Pulling %s (%d batches) ---", analyte, length(site_batches))
  t_analyte <- Sys.time()
  analyte_data <- vector("list", length(site_batches))
  n_fail <- 0

  for (i in seq_along(site_batches)) {
    t0 <- Sys.time()
    wq <- pull_with_retry(site_batches[[i]], analyte)
    t1 <- Sys.time()

    if (!is.null(wq) && nrow(wq) > 0) {
      analyte_data[[i]] <- to_character_df(wq)
    } else {
      n_fail <- n_fail + 1
    }

    if (i %% 5 == 0 || i == length(site_batches)) {
      log_msg("  batch %d/%d: cumulative %d rows, fails %d, last batch %.1fs",
              i, length(site_batches), count_rows(analyte_data),
              n_fail, as.numeric(t1-t0, units="secs"))
    }
  }

  # Per-analyte checkpoint: save partial data even if something crashes
  good <- Filter(function(x) is.data.frame(x) && nrow(x) > 0, analyte_data)
  if (length(good) > 0) {
    combined <- bind_rows(good)
    combined$query_analyte <- analyte
    all_measurements[[analyte]] <- combined

    # Write per-analyte checkpoint
    ckpt_path <- path(processed_dir,
                      sprintf("controls_wq_PA_%s.csv",
                              gsub(" ", "_", analyte)))
    write_csv(combined, ckpt_path)

    t_a1 <- Sys.time()
    log_msg("  %s done: %d rows, %d failed batches, %.1f min  [checkpoint saved]",
            analyte, nrow(combined), n_fail,
            as.numeric(t_a1-t_analyte, units="mins"))
  } else {
    log_msg("  %s: NO DATA returned after all batches", analyte)
  }
}

# ------------------------------------------------------------
# Final combined output
# ------------------------------------------------------------
if (length(all_measurements) == 0) {
  log_msg("!! No data for any analyte. Aborting.")
  stop("Pilot failed: no data.")
}

wq_all <- bind_rows(all_measurements)
log_msg("Total raw measurements (all analytes): %d", nrow(wq_all))

keep_cols <- c(
  "MonitoringLocationIdentifier", "ActivityStartDate", "CharacteristicName",
  "ResultMeasureValue", "ResultMeasure.MeasureUnitCode",
  "ResultDetectionConditionText",
  "DetectionQuantitationLimitMeasure.MeasureValue",
  "DetectionQuantitationLimitMeasure.MeasureUnitCode",
  "query_analyte"
)
keep_cols <- keep_cols[keep_cols %in% names(wq_all)]
wq_slim <- wq_all[, keep_cols]

wq_slim$censored <- !is.na(wq_slim$ResultDetectionConditionText) &
  grepl("[Nn]ot [Dd]etected|[Bb]elow", wq_slim$ResultDetectionConditionText)

log_msg("Censored (below detection): %d of %d (%.1f%%)",
        sum(wq_slim$censored), nrow(wq_slim),
        100 * sum(wq_slim$censored) / nrow(wq_slim))

out_path <- path(processed_dir, "controls_wq_Pennsylvania.csv")
write_csv(wq_slim, out_path)
t_end <- Sys.time()

log_msg("Pilot complete: %.1f min total", as.numeric(t_end-t_total, units="mins"))
log_msg("Wrote: %s", out_path)

cat("\n=== PILOT RESULTS: PENNSYLVANIA ===\n")
summary_tbl <- wq_slim |>
  group_by(query_analyte) |>
  summarise(
    n_measurements = n(),
    n_sites        = n_distinct(MonitoringLocationIdentifier),
    n_censored     = sum(censored, na.rm = TRUE),
    pct_censored   = round(100 * n_censored / n_measurements, 1),
    .groups = "drop"
  )
print(summary_tbl)

cat(sprintf("\nUnique control sites with WQ data: %d (of %d candidates)\n",
            n_distinct(wq_slim$MonitoringLocationIdentifier), length(pa_ids)))

log_msg("PHASE B PILOT END v3")
cat("====================================================\n", file = log_path, append = TRUE)
