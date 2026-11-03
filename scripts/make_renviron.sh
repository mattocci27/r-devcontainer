#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
renviron_file="$REPO_ROOT/.Renviron"

# Preserve existing values and secrets; append only missing defaults.
touch "$renviron_file"
for setting in \
    RENV_PATHS_PREFIX_AUTO=TRUE \
    RENV_CONFIG_PAK_ENABLED=FALSE \
    OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES; do
    key="${setting%%=*}"
    if ! grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$renviron_file"; then
        printf '\n%s\n' "$setting" >> "$renviron_file"
    fi
done

echo ".Renviron defaults are ready (existing settings preserved)."
