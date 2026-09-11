# Purpose: Walk through Fellegi-Sunter style comparison using teaching data.
# Data source and licence: RecordLinkage::RLdata500 teaching dataset (synthetic).
# Packages: RecordLinkage.
# Expected runtime: < 30 seconds.

required_packages <- c("RecordLinkage")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install missing packages with renv::restore(): ", paste(missing_packages, collapse = ", "))
}

# RLdata500 is synthetic and widely used for linkage teaching.
data("RLdata500", package = "RecordLinkage")

pairs <- RecordLinkage::compare.dedup(
  RLdata500,
  blockfld = c(1, 4),
  strcmp = c(2, 3),
  exclude = 5,
  identity = 7
)

# Expectation-maximisation estimates agreement weights when labels are limited.
pairs <- RecordLinkage::emWeights(pairs)
summary(pairs)
