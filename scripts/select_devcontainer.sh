#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$REPO_ROOT/.devcontainer/devcontainer.json"

# Both host operating systems use the same configuration. Never replace it.
if [[ ! -f "$config" ]]; then
    echo "Missing devcontainer configuration: $config" >&2
    exit 1
fi
echo "Using the shared Linux/macOS devcontainer configuration."
