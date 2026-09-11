# Purpose: Show how to standardise noisy identifier fields before linkage.
# Data source and licence: Synthetic toy data created in-script; no external data.
# Packages: tidyverse, stringdist.
# Expected runtime: < 5 seconds.

required_packages <- c("tidyverse", "stringdist")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

# Start with deliberately inconsistent identifiers so the cleaning choices are obvious.
raw_people <- tibble::tribble(
  ~record_id, ~given_name, ~family_name, ~date_of_birth, ~postcode, ~medicare_id,
  1L, " Ana ", "Nguyen", "1984/05/11", "2000 ", " 5551234A ",
  2L, "ANNA", "Nguyén", "11-05-1984", "02000", NA,
  3L, "Rob", "O'Connor", "1978-09-03", "3000", "7788990",
  4L, "Robert", "OCONNOR", "1978-03-09", "3000", "7788990"
)

clean_people <- raw_people |>
  mutate(
    given_name_clean = given_name |> stringr::str_squish() |> stringr::str_to_upper(),
    family_name_clean = family_name |> iconv(to = "ASCII//TRANSLIT") |> stringr::str_to_upper() |> stringr::str_replace_all("[^A-Z]", ""),
    dob_clean = c("1984-05-11", "1984-05-11", "1978-09-03", "1978-03-09") |> as.Date(),
    postcode_clean = postcode |> stringr::str_replace_all("[^0-9]", "") |> stringr::str_pad(width = 4, side = "left", pad = "0"),
    medicare_clean = medicare_id |> tidyr::replace_na("") |> stringr::str_replace_all("[^A-Za-z0-9]", "") |> stringr::str_to_upper(),
    has_missing_id = medicare_clean == ""
  )

# Keep raw and cleaned values side by side; auditors often need both.
print(clean_people)

# Quick string-distance check to show why standardisation matters before matching.
stringdist::stringdist(clean_people$family_name[1], clean_people$family_name[2], method = "jw")
