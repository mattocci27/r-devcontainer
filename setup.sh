#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Renviron defaults exist
"$REPO_ROOT/scripts/make_renviron.sh"

# Linux and macOS share the same devcontainer definition.
if [[ ! -f "$REPO_ROOT/.devcontainer/devcontainer.json" ]]; then
    echo "Missing .devcontainer/devcontainer.json" >&2
    exit 1
fi

# The same host cache is used by Docker and Apptainer.
mkdir -p "$HOME/renv"

# Define the path to the apptainer.sif file
sif_file="$REPO_ROOT/apptainer.sif"

# Check conditions and build apptainer.sif from apptainer.def if applicable
if [ ! -f "/.dockerenv" ] && [ ! -f "$sif_file" ] && command -v apptainer > /dev/null; then
    echo "Building apptainer.sif from apptainer.def..."
    apptainer build "$sif_file" "$REPO_ROOT/apptainer.def"
else
    echo "Conditions not met for building apptainer.sif."
fi

echo "Inside the dev container, packages are restored automatically."
echo "For native R or Apptainer, run Rscript scripts/restore.R in that environment."
