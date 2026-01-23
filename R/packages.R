#!/usr/bin/env Rscript

if (!requireNamespace("renv", quietly = TRUE)) {
  stop("renv must be available before hydrating project packages.")
}

base_library <- "/usr/local/lib/R/site-library"

packages <- c(
  "remotes",
  "renv",
  "devtools",
  "yaml",
  "languageserver",
  # GitHub remotes are resolved via renv.lock; hydrate just needs package names.
  "unigd",
  "httpgd"
)

renv::hydrate(
  packages = packages,
  library = base_library
)
