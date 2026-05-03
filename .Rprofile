source("renv/activate.R")

# 1. Global Configuration: Freeze the CRAN snapshot date to ensure reproducibility
# across different operating systems (Linux vs macOS).
P3M_DATE <- "2026-05-01"

# Detect the basic OS name
os_info <- Sys.info()["sysname"]

# 2. Helper function to register all required repositories.
# This ensures consistency between CRAN, rOpenSci, and Stan tooling.
set_repos <- function(cran_url) {
  repos <- c(
    rOpenSci = "https://ropensci.r-universe.dev",
    Stan     = "https://mc-stan.org/r-packages/",
    CRAN     = cran_url
  )
  options(repos = repos)

  # Force renv to use these specific repositories regardless of the lockfile.
  options(renv.config.repos.override = repos)
}

# 3. OS-specific repository logic.
if (os_info == "Linux") {
  # Parse /etc/os-release to identify distribution and codename (e.g., noble, jammy).
  if (file.exists("/etc/os-release")) {
    os_release_data <- readLines("/etc/os-release")

    get_val <- function(key) {
      line <- os_release_data[grep(paste0("^", key, "="), os_release_data)]
      if (length(line) > 0) {
        return(gsub('"', '', sub(paste0("^", key, "="), "", line)))
      }
      return(NULL)
    }

    distro   <- get_val("ID")             # e.g., "ubuntu"
    codename <- get_val("VERSION_CODENAME") # e.g., "noble"

    # Use Posit Package Manager (P3M) binary URLs for Ubuntu to speed up installation.
    if (!is.null(distro) && distro == "ubuntu" && !is.null(codename)) {
      set_repos(sprintf("https://p3m.dev/cran/__linux__/%s/%s", codename, P3M_DATE))
    } else {
      # Fallback to source-based P3M for other Linux distributions.
      set_repos(sprintf("https://p3m.dev/cran/%s", P3M_DATE))
    }
  } else {
    set_repos(sprintf("https://p3m.dev/cran/%s", P3M_DATE))
  }
} else {
  # For macOS (Darwin) and Windows, use source-based P3M snapshot.
  set_repos(sprintf("https://p3m.dev/cran/%s", P3M_DATE))
}

# 4. Environment-specific settings.
if (Sys.getenv("INSIDE_DOCKER") == "true") {
  # Ensure the renv cache is isolated within the Docker container.
  Sys.setenv(RENV_PATHS_CACHE = "/renv")
}

# 5. Path handling for Containerized Environments.
# 5. Utility packages pre-installed in the container (e.g., httpgd for plot viewing).
if (Sys.getenv("INSIDE_CONTAINER") == "true") {
  arch <- switch(Sys.info()[["machine"]],
    "x86_64"  = "x86_64-pc-linux-gnu",
    "aarch64" = "aarch64-unknown-linux-gnu",
    paste0(Sys.info()[["machine"]], "-unknown-linux-gnu")
  )
  r_ver <- paste0("R-", R.version$major, ".", strsplit(R.version$minor, "\\.")[[1]][1])
  codename <- tryCatch({
    lines <- readLines("/etc/os-release")
    line  <- grep("^VERSION_CODENAME=", lines, value = TRUE)
    gsub('"', "", sub("^VERSION_CODENAME=", "", line[1]))
  }, error = function(e) "noble")

  lib_path <- file.path("/home/rstudio/vscode-R/renv/library",
                        paste0("linux-ubuntu-", codename), r_ver, arch)
  if (dir.exists(lib_path)) .libPaths(new = c(.libPaths(), lib_path))
}
