#!/bin/sh
# Installs all skills globally via npx.

set -eu

REPO="ddsakura/code-review-handoff-and-fix"

command -v npx >/dev/null 2>&1 || {
  echo "Error: npx not found. Install Node.js first: https://nodejs.org"
  exit 1
}

echo ""
echo "Installing code-review-handoff-and-fix skills..."
echo ""
npx skills add "$REPO" --global

echo ""
echo "Done."
echo ""
echo "Usage:"
echo "  /rh  - review changes and save .ai-reviews/latest.md"
echo "  /rf  - apply fixes from .ai-reviews/latest.md"
