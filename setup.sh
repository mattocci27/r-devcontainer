#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Renviron defaults exist
"$REPO_ROOT/scripts/make_renviron.sh"

# Pick the matching devcontainer definition for the host OS
"$REPO_ROOT/scripts/select_devcontainer.sh"

# macOS-specific: keep permissions container-friendly
if [[ "$(uname -s)" == "Darwin" ]]; then
    "$REPO_ROOT/scripts/fixperms.sh" "$REPO_ROOT"
fi

# Define the path to the apptainer.sif file
sif_file="$REPO_ROOT/apptainer.sif"

# Check conditions and build apptainer.sif from apptainer.def if applicable
if [ ! -f "/.dockerenv" ] && [ ! -f "$sif_file" ] && which apptainer > /dev/null; then
    echo "Building apptainer.sif from apptainer.def..."
    sudo apptainer build "$sif_file" "$REPO_ROOT/apptainer.def"
else
    echo "Conditions not met for building apptainer.sif."
fi
