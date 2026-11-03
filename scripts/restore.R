# Run from the project root, using the R installation that will run the project.
if (getRversion() != "4.6.1") {
  stop("This template requires R 4.6.1; found ", getRversion(), ".")
}

# .Rprofile activates the project's pinned renv before this script runs.
cache <- renv::paths$cache()
dir.create(cache, recursive = TRUE, showWarnings = FALSE)
probe <- tempfile(".renv-write-check-", tmpdir = cache)
if (!isTRUE(suppressWarnings(file.create(probe)))) {
  stop(
    "Cannot write to the renv cache: ", cache,
    "\nEnsure the container user owns the host cache, or has group write access."
  )
}
unlink(probe)
message("Using renv cache: ", cache)
renv::restore(prompt = FALSE)
