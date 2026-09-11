# Purpose: Match facility names across two real public CMS hospital files.
# Data source and licence: Public CMS provider data files downloaded from data.cms.gov.
# Packages: tidyverse, stringdist.
# Expected runtime: < 1 minute plus initial download.

required_packages <- c("tidyverse", "stringdist")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

repo_root <- if (basename(getwd()) == "R") {
  normalizePath(file.path(getwd(), ".."), mustWork = TRUE)
} else {
  normalizePath(getwd(), mustWork = TRUE)
}

cache_dir <- normalizePath(file.path(repo_root, "data-raw"), mustWork = TRUE)
info_path <- file.path(cache_dir, "cms-hospital-general-information.csv")
address_path <- file.path(cache_dir, "cms-hospital-addresses.csv")

if (!file.exists(info_path)) {
  download.file(
    "https://data.cms.gov/provider-data/sites/default/files/resources/hospital-general-information.csv",
    destfile = info_path,
    mode = "wb"
  )
}
if (!file.exists(address_path)) {
  download.file(
    "https://data.cms.gov/provider-data/sites/default/files/resources/hospital-addresses.csv",
    destfile = address_path,
    mode = "wb"
  )
}

info <- readr::read_csv(info_path, show_col_types = FALSE)
addresses <- readr::read_csv(address_path, show_col_types = FALSE)

clean_name <- function(x) {
  x |>
    stringr::str_to_upper() |>
    stringr::str_replace_all("[^A-Z0-9 ]", " ") |>
    stringr::str_squish()
}

scored <- info |>
  transmute(
    facility_name_a = clean_name(`Facility Name`),
    state = State,
    zip_code_a = Zip_Code
  ) |>
  inner_join(
    addresses |>
      transmute(
        facility_name_b = clean_name(`Facility Name`),
        state = State,
        zip_code_b = Zip_Code
      ),
    by = c("state")
  ) |>
  mutate(name_distance = stringdist::stringdist(facility_name_a, facility_name_b, method = "jw")) |>
  filter(name_distance < 0.12 | zip_code_a == zip_code_b)

print(scored)
