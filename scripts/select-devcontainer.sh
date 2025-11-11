# scripts/select-devcontainer.sh
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../.devcontainer"

if [[ "$(uname -s)" == "Darwin" ]]; then
  ln -sf devcontainer_mac.json devcontainer.json
  echo "🧠 Selected macOS devcontainer"
else
  ln -sf devcontainer_linux.json devcontainer.json
  echo "🐧 Selected Linux devcontainer"
fi
