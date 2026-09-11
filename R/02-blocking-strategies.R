# Purpose: Demonstrate why broad, multi-pass blocking beats a single brittle rule.
# Data source and licence: Synthetic toy data created in-script; no external data.
# Packages: tidyverse.
# Expected runtime: < 5 seconds.

required_packages <- c("tidyverse")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

file_a <- tibble::tribble(
  ~id_a, ~surname_key, ~yob, ~sex, ~postcode_prefix,
  "A1", "NGYN", 1984L, "F", "20",
  "A2", "OCNN", 1978L, "M", "30",
  "A3", "KHAN", 1990L, "F", "50"
)

file_b <- tibble::tribble(
  ~id_b, ~surname_key, ~yob, ~sex, ~postcode_prefix,
  "B1", "NGYN", 1984L, "F", "20",
  "B2", "OCON", 1978L, "M", "30",
  "B3", "KHAN", 1991L, "F", "50"
)

# A tight one-pass block is fast, but it can exclude plausible pairs too early.
block_one <- inner_join(file_a, file_b, by = c("yob", "sex"))

# A second pass lets us recover records that miss on one coarse field.
block_two <- inner_join(file_a, file_b, by = c("sex", "postcode_prefix"))

candidate_pairs <- bind_rows(block_one, block_two) |>
  distinct(id_a, id_b, .keep_all = TRUE)

print(candidate_pairs)
