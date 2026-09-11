# Purpose: Deduplicate a small public OpenAlex bibliographic export.
# Data source and licence: Public OpenAlex API response cached in data-raw/.
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
openalex_path <- file.path(cache_dir, "openalex-data-linkage-works.json")

if (!file.exists(openalex_path)) {
  download.file(
    "https://api.openalex.org/works?search=data%20linkage&per-page=100",
    destfile = openalex_path,
    mode = "wb"
  )
}

works <- jsonlite::fromJSON(openalex_path)$results |>
  tibble::as_tibble() |>
  transmute(
    work_id = id,
    title = display_name,
    publication_year,
    source = purrr::map_chr(
      primary_location,
      ~ if (is.null(.x$source$display_name)) NA_character_ else .x$source$display_name
    )
  )

candidate_duplicates <- works |>
  mutate(title_key = stringr::str_to_upper(title)) |>
  inner_join(works, by = "publication_year", suffix = c("_a", "_b")) |>
  filter(work_id_a < work_id_b) |>
  mutate(title_distance = stringdist::stringdist(title_key_a, title_key_b, method = "jw")) |>
  filter(title_distance < 0.08)

print(candidate_duplicates)
