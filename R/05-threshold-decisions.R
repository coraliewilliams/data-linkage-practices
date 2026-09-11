# Purpose: Turn linkage scores into accept, review, and reject decisions.
# Data source and licence: Synthetic score table created in-script; no external data.
# Packages: tidyverse.
# Expected runtime: < 5 seconds.

required_packages <- c("tidyverse")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

score_table <- tibble::tribble(
  ~pair_id, ~score,
  "A1_B1", 0.98,
  "A2_B2", 0.84,
  "A3_B3", 0.61,
  "A4_B4", 0.22
)

review_band <- c(lower = 0.70, upper = 0.95)

decisions <- score_table |>
  mutate(
    decision = dplyr::case_when(
      score >= review_band[["upper"]] ~ "accept",
      score >= review_band[["lower"]] ~ "clerical review",
      TRUE ~ "reject"
    )
  )

print(decisions)
