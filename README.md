[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# Reproducible R Project Template

This template is designed to streamline the setup of reproducible R projects, particularly for data analysis and research purposes.
It leverages the power of Docker, Quarto, and other tools to create a consistent and portable development environment, making it easier for teams to collaborate and for individuals to replicate results.
The container images used in this template can be found at <https://github.com/mattocci27/r-containers>.

*Note: This README was written with the assistance of ChatGPT.*


## Features

- **Docker**:
Widely supported container runtime for local and remote work.

- **Quarto**:
Dynamic and reproducible reports.

- **VSCode Dev Container**:
Containerized development in Visual Studio Code.

- **Apptainer**:
Containerization in high-performance computing (HPC) environments.

- **`renv`** with cache:
Dependency management with a shared cache for faster builds.

- **`targets` package**:
Robust, maintainable, and scalable workflows.


## Getting Started

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/your-repo-name.git
    ```

2. **Setup Development Environment**:
    ```bash
    ./setup.sh
    ```
    The `setup.sh` script automates the configuration of the development environment for the R project.
    It adds missing `.Renviron` defaults without overwriting existing values, validates the shared Linux/macOS devcontainer configuration, creates `$HOME/renv`, and builds an Apptainer image if applicable. It does not change ownership or permissions recursively.

3. **Start VSCode Dev Container**: Open the project in Visual Studio Code and run **Dev Containers: Rebuild and Reopen in Container**. Both devcontainer definitions use `mattocci/cmdstan-zsh:4.6.1`. The initial creation runs `Rscript scripts/restore.R`, which checks R 4.6.1 and cache write access, then restores packages from `renv.lock`. This first restore may take time. After changing the lockfile, rerun that command inside the container.

4. **Run the Project**:
    ```bash
    ./run.sh
    ```

## Prerequisites

Before setting up the development environment, ensure that the following prerequisites are met:

### Docker Configuration

Install Docker Engine (Linux) or Docker Desktop (macOS/Windows) and ensure VSCode is configured to use it for Dev Containers. On macOS, install Docker Desktop from <https://www.docker.com/products/docker-desktop/> and start it before opening VSCode.

### Renv Configuration

[`renv`](https://rstudio.github.io/renv/articles/renv.html) is a dependency management tool for R that helps you create reproducible environments for your R projects.
Both Docker and Apptainer use the host's `$HOME/renv` cache. `setup.sh` creates it; Dev Containers also creates it before starting the container.

```text
Linux/macOS host: $HOME/renv  ->  Docker: /renv
                                      RENV_PATHS_CACHE=/renv
Apptainer/Singularity: $HOME/renv (bound at the same absolute path)
```

The Linux host's cache is used when Docker runs on Linux. On macOS the source is the Mac's `$HOME/renv`. Both devcontainer JSON files use this bind mount; the public variant only has fewer editor extensions.

`renv` separates installed packages by OS, R major/minor version, and architecture. R 4.5 packages are not reused as R 4.6 packages. R 4.6.0 and 4.6.1 normally share an R-4.6 cache branch. macOS native packages and Linux container packages also have separate branches.

On Linux, Dev Containers updates the `rstudio` UID/GID to match the host user. Existing cache directories must still be writable by that user, or by one of its groups. If restoring reports a permission error, fix ownership or group permissions for the affected cache directory; setup does not recursively modify an existing shared cache.

For **native R 4.6.1**, restore from the project root:

```bash
Rscript scripts/restore.R
```

For **Apptainer**, build with `./setup.sh`, then restore in the container:

```bash
apptainer exec --bind "$HOME/renv:$HOME/renv" \
  --env "RENV_PATHS_CACHE=$HOME/renv" --env INSIDE_CONTAINER=true \
  apptainer.sif Rscript scripts/restore.R
```

`run.sh` passes the same cache path and bind mount to Apptainer/Singularity. An explicit `RENV_PATHS_CACHE` overrides the default for native R and `run.sh`. Docker uses `/renv` as configured in its JSON.

If `apptainer.sif` already exists from an older template version, rebuild it explicitly with `apptainer build --force apptainer.sif apptainer.def` before restoring. Setup preserves existing images.

The project uses an isolated renv library; packages from the container's site library are not automatically exposed. The example targets pipeline stores results locally. Configure your own AWS bucket and credentials explicitly if you want remote storage.

### SSH Configuration

If you need to access private Git repositories or other services using SSH keys from within the dev container, you'll need to set up SSH key forwarding.
This allows the container to use your host's SSH keys without copying them into the container, which is more secure.

Follow the [SSH Setup Instructions](./docs/ssh_setup.md) to configure SSH key forwarding for the development environment.

By following these prerequisites, you'll ensure that the development environment is set up correctly and securely, with proper permissions and access to necessary tools and services.

### `.Renviron` and `GITHUB_PAT`

The project `.Renviron` is git-ignored. `scripts/make_renviron.sh` adds these defaults only when each key is missing, preserving existing values and secrets even when setup is rerun from another directory:

```bash
RENV_PATHS_PREFIX_AUTO=TRUE
RENV_CONFIG_PAK_ENABLED=FALSE
OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

- `RENV_PATHS_PREFIX_AUTO=TRUE` separates library and cache paths by OS/distribution.
- `RENV_CONFIG_PAK_ENABLED=FALSE` uses renv's standard installer and installed-package cache. `.Rprofile` also disables pak to cover existing `.Renviron` files that still set it to `TRUE`; the existing file is preserved.
- `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` is a workaround for macOS fork protection with GUI-linked R packages.

A GitHub token is optional for public packages. If you need one for private repositories or API rate limits, add `GITHUB_PAT` to your ignored `.Renviron` with permissions appropriate to those repositories.

No private dotfiles or secrets files are required. The template does not install personal dotfiles or set a fixed editor proxy. Configure those separately if needed. Proxy environment variables can be supplied by the host.

## Utility Scripts

- `scripts/restore.R`: verifies R 4.6.1 and cache write access, then restores the lockfile. Run from the project root in the intended R environment.
- `scripts/make_renviron.sh`: appends missing defaults without overwriting existing settings.
- `scripts/select_devcontainer.sh`: compatibility entry point that validates the common configuration; it no longer creates OS-specific symlinks.
- `scripts/fixperms.sh`: optional legacy macOS permission helper. It recursively changes project permissions and is no longer called automatically.

## Project Structure

- `./_targets`: Generated, git-ignored execution state for `targets`. Old template metadata is not carried into new projects.
- `./_targets.R`: Target pipeline definition.
- `./_targets_packages.R`: Required packages for the pipeline.
- `./apptainer.def`: Apptainer container definition file.
- `./data`: Processed data.
- `./data-raw`: Raw data.
- `./docs`: Documentation.
- `./figs`: Figures.
- `./ms`: Manuscript files, including Quarto markdown and bibliography.
- `./R`: R scripts for functions, package loading, and pipeline execution.
- `./report.qmd`: Quarto markdown file for the report.
- `./run.sh`: Bash script to run the pipeline.
- `./scripts`: Setup scripts for the development environment.
- `./setup.sh`: Environment setup script.
- `./stan`: Stan model files.
- `./templates`: Template files for devcontainer, container orchestrations, and SSH setup.
