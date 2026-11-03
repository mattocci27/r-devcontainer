#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"
export RENV_PATHS_CACHE="${RENV_PATHS_CACHE:-$HOME/renv}"
mkdir -p "$RENV_PATHS_CACHE"

menu() {
    echo "1) tar_make() on local (or inside docker)"
    echo "2) tar_make() on Apptainer"
    echo "3) Enter in the Apptainer container"
    echo "4) Enter in the Singularity container on HPC"
    read -rp "Enter number: " menu_num
    case $menu_num in
    1|2)
        # Prompt for the number of CPUs after selecting option 1 or 2
        read -rp "Enter the number of CPUs to use: " num_cpus
        if [[ "$menu_num" == "1" ]]; then
            Rscript R/run.R "$num_cpus"
        elif [[ "$menu_num" == "2" ]]; then
            apptainer exec \
            --bind "$RENV_PATHS_CACHE:$RENV_PATHS_CACHE" \
            --env "RENV_PATHS_CACHE=$RENV_PATHS_CACHE" \
            --env INSIDE_CONTAINER=true \
            apptainer.sif Rscript R/run.R "$num_cpus"
        fi
        ;;
    3)
        apptainer shell \
        --bind "$RENV_PATHS_CACHE:$RENV_PATHS_CACHE" \
        --env "RENV_PATHS_CACHE=$RENV_PATHS_CACHE" \
        --env INSIDE_CONTAINER=true \
        apptainer.sif bash
        ;;
    4)
        singularity shell \
        --bind "$RENV_PATHS_CACHE:$RENV_PATHS_CACHE" \
        --env "RENV_PATHS_CACHE=$RENV_PATHS_CACHE" \
        --env INSIDE_CONTAINER=true \
        apptainer.sif bash
        ;;
    *)
        echo "Invalid option. Please type a number from 1-4."
        ;;
    esac
}

menu "$@"
