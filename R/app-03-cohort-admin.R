# Purpose: Link synthetic cohort participants to synthetic administrative records with partial identifiers.
# Data source and licence: Synthetic person-level records generated in-script; no external data.
# Packages: tidyverse, RecordLinkage.
# Expected runtime: < 30 seconds.

required_packages <- c("tidyverse", "RecordLinkage")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

set.seed(126)

cohort <- tibble(
  given_name = sample(c("AMY", "BO", "CARA", "DAN"), 40, replace = TRUE),
  family_name = sample(c("KHAN", "JONES", "BROWN", "SMITH"), 40, replace = TRUE),
  birth_year = sample(1960:2000, 40, replace = TRUE),
  sex = sample(c("F", "M"), 40, replace = TRUE),
  postcode = sample(sprintf("%04d", 4000:4010), 40, replace = TRUE)
)

admin <- cohort |>
  sample_frac(0.8) |>
  mutate(
    given_name = if_else(row_number() %% 6 == 0, substr(given_name, 1, 2), given_name),
    postcode = if_else(row_number() %% 5 == 0, NA_character_, postcode)
  )

pairs <- RecordLinkage::compare.linkage(
  dataset1 = as.data.frame(cohort),
  dataset2 = as.data.frame(admin),
  blockfld = c(3, 4),
  strcmp = c(1, 2, 5)
)

pairs <- RecordLinkage::epiWeights(pairs)
summary(pairs)
