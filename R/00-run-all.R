# Purpose: Source every standalone linkage walkthrough in reading order.
# Data source and licence: Mix of synthetic examples, package teaching data,
#   and public sources declared inside each script.
# Packages: renv-managed project library.
# Expected runtime: A few minutes once packages are restored and caches exist.

script_root <- if (basename(getwd()) == "R") {
  normalizePath(getwd(), mustWork = TRUE)
} else {
  normalizePath(file.path(getwd(), "R"), mustWork = TRUE)
}

scripts <- c(
  "01-prepare-identifiers.R",
  "02-blocking-strategies.R",
  "03-comparison-patterns.R",
  "04-fellegi-sunter.R",
  "05-threshold-decisions.R",
  "06-evaluation-metrics.R",
  "07-reporting-template.R",
  "app-01-hospital-deaths.R",
  "app-02-immunisation-disease.R",
  "app-03-cohort-admin.R",
  "app-04-facility-names.R",
  "app-05-country-names.R",
  "app-06-deduplication.R"
)

for (script in scripts) {
  message("Sourcing ", script)
  source(file.path(script_root, script), chdir = TRUE)
}
