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

# Set CRAN repository based on the OS and version
if (os_info == "Linux" && os_release == "22.04") {
  options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))
} else if (os_info %in% c("Darwin", "Windows")) {
  options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))
}

options(renv.config.repos.override = getOption("repos"))

# Docker-specific settings
if (Sys.getenv("INSIDE_DOCKER") == "true") {
  Sys.setenv(RENV_PATHS_CACHE = "/home/rstudio/renv")
}

# General settings for any container environment
if (Sys.getenv("INSIDE_CONTAINER") == "true") {
  .libPaths(new = c(.libPaths(),
                    "/home/rstudio/vscode-R/renv/library/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu/",
                    "/home/rstudio/vscode-R/renv/library/linux-ubuntu-noble/R-4.5/aarch64-unknown-linux-gnu/"))
  cmdstan_path <- Sys.getenv("CMDSTAN_PATH", unset = NA)
  if (!is.na(cmdstan_path)) {
    cmdstanr::set_cmdstan_path(cmdstan_path)
  }
}

