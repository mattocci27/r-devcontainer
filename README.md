[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# Reproducible R Project Template

This template is designed to streamline the setup of reproducible R projects, particularly for data analysis and research purposes.
It leverages the power of Podman, Quarto, and other tools to create a consistent and portable development environment, making it easier for teams to collaborate and for individuals to replicate results.
The container images used in this template can be found at <https://github.com/mattocci27/r-containers>.

*Note: This README was written with the assistance of ChatGPT.*


## Features

- **Podman**:
Rootless, Docker-compatible container runtime for local and remote work.

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
    It prepares the Podman-backed VSCode dev container, updates environment settings for renv, links the appropriate devcontainer JSON for your host, fixes macOS permissions when needed, and builds an Apptainer image if applicable. Running it once per machine keeps the environment consistent and reproducible.

3. **Start VSCode Dev Container**: Open the project in Visual Studio Code and start the development container. The dev container definition assumes the Podman engine (or Podman Desktop) is available to the VSCode Dev Containers / Remote Containers extension.

4. **Run the Project**:
    ```bash
    ./run.sh
    ```

## Prerequisites

Before setting up the development environment, ensure that the following prerequisites are met:

### Podman Configuration

Install Podman (or Podman Desktop) and ensure VSCode is configured to use it for Dev Containers. On macOS you can install via Homebrew (`brew install podman podman-desktop`) and start the Podman machine with `podman machine init && podman machine start`.

When VSCode prompts for the container runtime, choose Podman.

### Renv Configuration

[`renv`](https://rstudio.github.io/renv/articles/renv.html) is a dependency management tool for R that helps you create reproducible environments for your R projects.
To use `renv` with this development environment, create a directory at `$HOME/renv` on your host system:

```bash
mkdir -p $HOME/renv
```

This directory will be used to store `renv` caches, which can be shared across multiple projects to save disk space and reduce the time required to install R packages.

### SSH Configuration

If you need to access private Git repositories or other services using SSH keys from within the dev container, you'll need to set up SSH key forwarding.
This allows the container to use your host's SSH keys without copying them into the container, which is more secure.

Follow the [SSH Setup Instructions](./templates/ssh_setup.md) to configure SSH key forwarding for the development environment.

By following these prerequisites, you'll ensure that the development environment is set up correctly and securely, with proper permissions and access to necessary tools and services.

### `.Renviron` and `GITHUB_PAT`

The `.Renviron` file at the project root is committed so shared environment defaults are available. It currently defines:

```bash
#renv settings
RENV_PATHS_PREFIX_AUTO=TRUE
RENV_CONFIG_PAK_ENABLED=TRUE
OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
GITHUB_PAT=github_pat_XXXXXXXXXXXXXXXXXXXXXXXX
```

- `RENV_PATHS_PREFIX_AUTO=TRUE` keeps per-project libraries inside the repo even when a shared cache is mounted, which prevents cross-project contamination.  
- `RENV_CONFIG_PAK_ENABLED=TRUE` tells `renv` to use `pak` for faster installs and downloads.  
- `OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` avoids macOS fork protections that can break GUI-linked R packages launched from VS Code.

Replace the placeholder `github_pat_...` value with your own [GitHub personal access token](https://github.com/settings/tokens) that has at least `read:packages` scope. Packages such as `pak` use this token to authenticate against GitHub's API and to stay within higher rate limits. Keep the token scoped narrowly and rotate it if it leaks.

## Utility Scripts

- `scripts/fixperms.sh`: macOS tends to mark new files as user-only, which causes permission conflicts when the Podman container runs as a group-shared user. Run `scripts/fixperms.sh /path/to/project` to recursively switch ownership to the `staff` group (gid 20) and grant group write access. `setup.sh` runs this automatically on macOS, but you can rerun it any time bind-mounted folders become read-only.

- `scripts/select-devcontainer.sh`: swaps `.devcontainer/devcontainer.json` between the macOS-optimized and Linux-optimized definitions. On macOS it symlinks to `devcontainer_mac.json`; otherwise it points to `devcontainer_linux.json`. `setup.sh` invokes this so VSCode always loads the right configuration, but you can run it manually if you move the repo between hosts.

## Project Structure

- `./_targets`: Metadata for the `targets` package.
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
