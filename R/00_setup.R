# ============================================================
# 00_setup.R
# Install and load all required packages for orphan wells validation.
# Run once. Tested on base R 4.4+ on macOS.
# ============================================================

# Packages needed across the pipeline
pkgs <- c(
  # Core tidyverse-adjacent
  "dplyr", "tidyr", "readr", "stringr", "purrr", "lubridate",
  # Spatial
  "sf", "terra", "nngeo",
  # USGS data access
  "dataRetrieval",
  # Stats
  "lme4", "lmerTest", "MatchIt", "NADA", "survival", "pROC", "boot",
  # Tables and plots
  "ggplot2", "patchwork", "scales", "knitr",
  # Utilities
  "here", "janitor", "arrow", "fs"
)

# Install any missing packages from CRAN
installed <- rownames(installed.packages())
to_install <- setdiff(pkgs, installed)

if (length(to_install) > 0) {
  message("Installing: ", paste(to_install, collapse = ", "))
  install.packages(to_install, dependencies = TRUE)
}

# Load and print versions for reproducibility
loaded <- sapply(pkgs, function(p) {
  suppressPackageStartupMessages(library(p, character.only = TRUE, logical.return = TRUE))
})

if (!all(loaded)) {
  stop("Failed to load: ", paste(names(loaded)[!loaded], collapse = ", "))
}

# Session info snapshot for the pre-registration record
session_path <- file.path("docs", paste0("session_info_", Sys.Date(), ".txt"))
dir.create("docs", showWarnings = FALSE, recursive = TRUE)
capture.output(sessionInfo(), file = session_path)

message("Setup complete. Session info written to: ", session_path)
message("R version: ", R.version.string)
