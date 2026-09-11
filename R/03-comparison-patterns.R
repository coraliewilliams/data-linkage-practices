# Purpose: Compare identifier fields and summarise simple agreement patterns.
# Data source and licence: Synthetic toy data created in-script; no external data.
# Packages: tidyverse, stringdist.
# Expected runtime: < 5 seconds.

required_packages <- c("tidyverse", "stringdist")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

pairs <- tibble::tribble(
  ~id_a, ~id_b, ~name_a, ~name_b, ~dob_a, ~dob_b, ~postcode_a, ~postcode_b,
  "A1", "B1", "ANNA NGUYEN", "ANA NGUYEN", as.Date("1984-05-11"), as.Date("1984-05-11"), "2000", "2000",
  "A2", "B2", "ROBERT OCONNOR", "ROB OCONNOR", as.Date("1978-09-03"), as.Date("1978-09-03"), "3000", "3000",
  "A3", "B3", "AISHA KHAN", "AISHA KHAN", as.Date("1990-06-20"), as.Date("1991-06-20"), "5000", "5001"
)

comparison_table <- pairs |>
  mutate(
    name_distance = stringdist::stringdist(name_a, name_b, method = "jw"),
    dob_agree = dob_a == dob_b,
    postcode_agree = postcode_a == postcode_b,
    agreement_pattern = paste0(as.integer(name_distance < 0.1), as.integer(dob_agree), as.integer(postcode_agree))
  )

print(comparison_table)
