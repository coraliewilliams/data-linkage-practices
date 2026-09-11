# Purpose: Build a compact reporting template for a linkage study.
# Data source and licence: Template only; no external data.
# Packages: tidyverse, gt.
# Expected runtime: < 5 seconds.

required_packages <- c("tidyverse", "gt")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

report_items <- tibble::tribble(
  ~section, ~detail,
  "Data sources", "Custodian, coverage dates, population, and licence",
  "Identifiers", "Raw fields, transformations, and missingness profile",
  "Blocking", "Each blocking pass and why it was chosen",
  "Comparison", "Exact and fuzzy comparisons, with tuning choices",
  "Decisions", "Thresholds, review band, one-to-one rules",
  "Evaluation", "Precision, recall, proxy checks, sensitivity analysis",
  "Governance", "Privacy, separation principle, and approvals"
)

report_items |>
  gt::gt() |>
  gt::tab_header(title = "Minimum linkage reporting template")
