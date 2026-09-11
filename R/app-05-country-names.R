# Purpose: Align country names across World Bank and WHO public datasets.
# Data source and licence: Public World Bank and WHO API endpoints cached in data-raw/.
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
world_bank_path <- file.path(cache_dir, "world-bank-countries.json")
who_path <- file.path(cache_dir, "who-countries.json")

if (!file.exists(world_bank_path)) {
  download.file(
    "https://api.worldbank.org/v2/country?format=json&per_page=400",
    destfile = world_bank_path,
    mode = "wb"
  )
}
if (!file.exists(who_path)) {
  download.file(
    "https://ghoapi.azureedge.net/api/DIMENSION/COUNTRY/DimensionValues",
    destfile = who_path,
    mode = "wb"
  )
}

world_bank <- jsonlite::fromJSON(world_bank_path)[[2]] |>
  tibble::as_tibble() |>
  transmute(iso2 = id, country_wb = name)

who <- jsonlite::fromJSON(who_path)$value |>
  tibble::as_tibble() |>
  transmute(iso2 = CODE, country_who = TITLE)

linked <- full_join(world_bank, who, by = "iso2") |>
  mutate(name_distance = if_else(
    is.na(country_wb) | is.na(country_who),
    NA_real_,
    stringdist::stringdist(country_wb, country_who, method = "jw")
  )) |>
  arrange(desc(is.na(iso2)), name_distance)

print(linked)
