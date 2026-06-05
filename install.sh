#!/bin/sh
# code-review-handoff-and-fix install script
# Works both locally after git clone and remotely via curl | sh.

BASE="https://raw.githubusercontent.com/ddsakura/code-review-handoff-and-fix/main"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

if [ -f "$SCRIPT_DIR/skills/rh/SKILL.md" ]; then
  put() { mkdir -p "$(dirname "$2")" && cp "$SCRIPT_DIR/$1" "$2" && echo "  copied $2"; }
else
  put() { mkdir -p "$(dirname "$2")" && curl -fsSL "$BASE/$1" -o "$2" && echo "  copied $2"; }
fi

echo ""
echo "Installing code-review-handoff-and-fix skills..."
echo ""

echo "Claude Code skills"
put "skills/rh/SKILL.md" "$HOME/.claude/skills/rh/SKILL.md"
put "skills/rf/SKILL.md" "$HOME/.claude/skills/rf/SKILL.md"

echo ""
echo "Codex skills"
put "skills/rh/SKILL.md" "$HOME/.codex/skills/rh/SKILL.md"
put "skills/rf/SKILL.md" "$HOME/.codex/skills/rf/SKILL.md"

echo ""
echo "Done."
echo ""
echo "Usage:"
echo "  /rh  - review changes and save .ai-reviews/latest.md"
echo "  /rf  - apply fixes from .ai-reviews/latest.md"
