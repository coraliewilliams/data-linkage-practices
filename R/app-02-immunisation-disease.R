# Purpose: Link synthetic immunisation and disease-notification records with sparse identifiers.
# Data source and licence: Synthetic person-level records generated in-script; no external data.
# Packages: tidyverse, fastLink.
# Expected runtime: < 30 seconds.

required_packages <- c("tidyverse", "fastLink")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

set.seed(84)

vaccination <- tibble(
  first = sample(c("ANNA", "BEN", "CHEN", "DIYA"), 50, replace = TRUE),
  last = sample(c("LEE", "PATEL", "SMITH", "NGUYEN"), 50, replace = TRUE),
  dob = sample(seq.Date(as.Date("1980-01-01"), as.Date("2015-12-31"), by = "day"), 50, replace = TRUE),
  sex = sample(c("F", "M"), 50, replace = TRUE),
  suburb = sample(c("NORTH", "SOUTH", "EAST", "WEST"), 50, replace = TRUE)
)

notifications <- vaccination |>
  sample_frac(0.5) |>
  mutate(
    first = if_else(row_number() %% 4 == 0, paste0(first, "A"), first),
    suburb = if_else(row_number() %% 3 == 0, NA_character_, suburb)
  )

# fastLink expects data frames with matching column names across files.
fastlink_fit <- fastLink::fastLink(
  dfA = as.data.frame(vaccination),
  dfB = as.data.frame(notifications),
  varnames = c("first", "last", "dob", "sex", "suburb"),
  stringdist.match = c("first", "last")
)

print(fastlink_fit$matches)
