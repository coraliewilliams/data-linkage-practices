# Purpose: Compute simple linkage quality metrics and a sensitivity scenario.
# Data source and licence: Synthetic counts created in-script; no external data.
# Packages: tidyverse.
# Expected runtime: < 5 seconds.

required_packages <- c("tidyverse")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)

metrics <- tibble::tibble(
  true_positive = 92,
  false_positive = 8,
  false_negative = 15
) |>
  mutate(
    precision = true_positive / (true_positive + false_positive),
    recall = true_positive / (true_positive + false_negative),
    f1 = 2 * precision * recall / (precision + recall)
  )

sensitivity <- tibble::tibble(
  missed_link_rate = c(0.02, 0.05, 0.10),
  observed_risk_ratio = 1.40,
  attenuated_risk_ratio = observed_risk_ratio * (1 - missed_link_rate)
)

print(metrics)
print(sensitivity)
