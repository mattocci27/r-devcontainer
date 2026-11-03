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

Native macOS R uses renv's default user cache, normally `~/Library/Caches/org.R-project.R/R/renv/cache`. This avoids the Linux UID ownership of the Docker bind cache. Native Linux R and Apptainer use `$HOME/renv`; an explicit `RENV_PATHS_CACHE` overrides native defaults. If an existing R session still points at the old path, restart R or run `Sys.unsetenv("RENV_PATHS_CACHE")` before restoring.

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

- `scripts/restore.R`: verifies R 4.6.1 and cache write access, then restores `renv.lock`.
- `scripts/run.R`: runs the targets pipeline; `run.sh` calls it in the selected environment.
- `scripts/hydrate.R`: optional import of developer tools from the current R installation's site libraries into the project library. This does not replace restoring the lockfile; run `scripts/restore.R` afterwards to enforce pinned versions.
- `scripts/make_renviron.sh`: appends missing defaults without overwriting existing settings.

Run R scripts from the project root. `setup.sh` and `run.sh` locate the project relative to their own paths.

## Project Structure

```text
.devcontainer/        Docker development environment (R 4.6.1)
R/                    Analysis functions
stan/                 Stan source files
scripts/              Setup, dependency management, and pipeline runners
data-raw/             Private source data (ignored, except .gitkeep)
data/                 Generated data exports (ignored, except .gitkeep)
figs/                 Generated figures (ignored, except .gitkeep)
build/stan/<platform>/  Compiled Stan executables (ignored)
outputs/cmdstan/<platform>/<target>/  Stan CSV output (ignored)
_targets/             targets results and execution metadata (ignored)
renv/                 renv activation and settings; local library is ignored
ms/                   Quarto manuscripts, bibliography, styles, and retained TeX
report.qmd            Exploratory report
_targets.R            Pipeline definition
_targets_packages.R   Package references generated by targets::tar_renv()
renv.lock             Pinned R and package versions
apptainer.def         Apptainer image definition
setup.sh              Host setup
run.sh                Execution environment menu
```

`data-raw/` is for non-public source data in any format, including CSV, Excel, and RDS. Only `.gitkeep` is tracked. Back up and transfer these files separately, retaining the same relative paths on each machine. Generated data and figures are also ignored by directory; CSV and PNG files outside these directories can be versioned intentionally.

Native macOS and Linux executables are separated by `R.version$platform` under `build/stan/`. Both models compile under `build/stan/<platform>/`. The simulation compilation target uses `tar_stan_compile()` to track both its source and executable. Each simulation branch retains CSV output under its target name in `outputs/cmdstan/`. The pinned `tar_stan_mcmc()` factory for the main fit caches draws, summaries, and diagnostics in `_targets/` and removes its intermediate CSV files after reading them; its `outputs/cmdstan/<platform>/fit/` path is staging storage, not a raw-CSV archive.

Keep `_targets/`, `build/`, `outputs/`, and any file-target outputs on persistent host storage across container restarts. Git does not transfer these directories to another checkout. Removing generated files can require their targets to rerun. Run the production pipeline from one stable Linux workspace and use Remote SSH from the Mac when you want to reuse the same results. Do not run two pipelines against the same store at once.

This layout change moves compiled models and CSV output. When applying it to an existing analysis, affected model targets may run once to populate the new paths. Existing results are not automatically deleted. This template's full example pipeline is not executed by setup or dependency restore.

The `.qmd` files are manuscript sources. Existing `.tex` files are retained for submission/export workflows; LaTeX auxiliary files such as `.aux` are generated and ignored. `docs/` contains project documentation, including SSH setup.
