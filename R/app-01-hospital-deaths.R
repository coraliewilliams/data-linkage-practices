# Purpose: Link synthetic hospital admissions to synthetic death registrations.
# Data source and licence: Synthetic person-level records generated in-script; no external data.
# Packages: tidyverse, reclin2, stringdist.
# Expected runtime: < 30 seconds.

required_packages <- c("tidyverse", "reclin2", "stringdist")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

set.seed(42)

make_people <- function(n = 40) {
  tibble(
    person_id = seq_len(n),
    given_name = sample(c("ANNA", "JAMES", "AISHA", "LIAM", "MARIA"), n, replace = TRUE),
    family_name = sample(c("NGUYEN", "SMITH", "KHAN", "WILLIAMS", "BROWN"), n, replace = TRUE),
    dob = as.Date("1950-01-01") + sample(0:20000, n, replace = TRUE),
    sex = sample(c("F", "M"), n, replace = TRUE),
    postcode = sample(sprintf("%04d", 2000:2010), n, replace = TRUE)
  )
}

base_people <- make_people()

admissions <- base_people |>
  transmute(
    admission_id = paste0("ADM", stringr::str_pad(person_id, 4, pad = "0")),
    given_name,
    family_name,
    dob,
    sex,
    postcode,
    admit_date = as.Date("2023-01-01") + sample(0:365, dplyr::n(), replace = TRUE)
  )

deaths <- base_people |>
  sample_frac(0.6) |>
  transmute(
    death_id = paste0("DTH", stringr::str_pad(person_id, 4, pad = "0")),
    given_name = if_else(row_number() %% 5 == 0, stringr::str_sub(given_name, 1, 3), given_name),
    family_name = if_else(row_number() %% 6 == 0, paste0(family_name, "S"), family_name),
    dob = if_else(row_number() %% 7 == 0, dob + 1, dob),
    sex,
    postcode = if_else(row_number() %% 4 == 0, NA_character_, postcode),
    death_date = as.Date("2023-06-01") + sample(0:365, dplyr::n(), replace = TRUE)
  )

# Broad blocking keeps plausible candidates even when one field is slightly wrong.
pairs <- reclin2::pair_blocking(admissions, deaths, on = c("sex"))
comparisons <- reclin2::compare_pairs(
  pairs,
  on = c("given_name", "family_name", "dob", "postcode"),
  default_comparator = reclin2::cmp_jarowinkler()
)

print(comparisons)
