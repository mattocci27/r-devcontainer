source("renv/activate.R")

# Detect the operating system
os_info <- Sys.info()["sysname"]
os_release <- NA  # Initialize os_release

# For Linux, further identify the version by reading from /etc/os-release
if (os_info == "Linux") {
  distro_info <- system("cat /etc/os-release", intern = TRUE)

  # Extract the version_id from distro_info
  version_line <- distro_info[grep("^VERSION_ID", distro_info)]

  if (length(version_line) > 0) {
    os_release <- sub(".*=\"?([^\"]*)\"?", "\\1", version_line)
  }
}

# Helper to register all repos we rely on (CRAN + vendor repos for Stan tooling)
set_repos <- function(cran_url) {
  repos <- c(
    rOpenSci = "https://ropensci.r-universe.dev",
    Stan = "https://mc-stan.org/r-packages/",
    CRAN = cran_url
  )
  options(repos = repos)
  options(renv.config.repos.override = repos)
}

# Set repositories based on the OS and version
if (os_info == "Linux") {
  if (os_release == "22.04") {
    set_repos("https://p3m.dev/cran/__linux__/jammy/latest")
  } else if (os_release == "24.04") {
    set_repos("https://p3m.dev/cran/__linux__/noble/latest")
  } else {
    set_repos("https://p3m.dev/cran/latest")
  }
} else if (os_info %in% c("Darwin", "Windows")) {
  set_repos("https://p3m.dev/cran/latest")
}

# Docker-specific settings
if (Sys.getenv("INSIDE_DOCKER") == "true") {
  Sys.setenv(RENV_PATHS_CACHE = "/home/rstudio/renv-cache")
}

# General settings for any container environment
if (Sys.getenv("INSIDE_CONTAINER") == "true") {
  .libPaths(new = c(.libPaths(),
                    "/home/rstudio/vscode-R/renv/library/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu/",
                    "/home/rstudio/vscode-R/renv/library/linux-ubuntu-noble/R-4.5/aarch64-unknown-linux-gnu/"))
}
