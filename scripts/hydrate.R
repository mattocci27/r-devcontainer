#!/usr/bin/env Rscript

if (!requireNamespace("renv", quietly = TRUE)) {
  stop("renv must be available before hydrating project packages.")
}

# Optional developer-tool import from the current R installation.
# Use scripts/restore.R afterwards to enforce renv.lock.
base_libraries <- .Library.site

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
  sources = base_libraries
)
