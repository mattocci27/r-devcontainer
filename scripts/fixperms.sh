#!/usr/bin/env bash
# fixperms.sh — make a project directory group-writable for container workflows on macOS
# Usage:  fixperms /path/to/project

set -euo pipefail

# --- check arguments ---
if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <directory>"
  exit 1
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "Error: $TARGET is not a directory"
  exit 1
fi

echo "📁 Fixing permissions for: $TARGET"
echo "→ Setting group to 'staff' (gid 20)..."
sudo chgrp -R staff "$TARGET"

echo "→ Making group writable (g+rwX)..."
sudo chmod -R g+rwX "$TARGET"

# optional: clear macOS ACLs if they exist
if ls -le "$TARGET" | grep -q "+"; then
  echo "→ Clearing macOS ACLs..."
  sudo chmod -RN "$TARGET"
fi

echo "✅ Done."
