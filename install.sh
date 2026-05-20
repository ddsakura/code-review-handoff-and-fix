#!/bin/sh
# dotfiles-ai install script
# Works both locally (after git clone) and remotely (curl | sh)

BASE="https://raw.githubusercontent.com/yourname/dotfiles-ai/main"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

# Detect local vs remote install
if [ -f "$SCRIPT_DIR/claude/commands/rh.md" ]; then
  put() { mkdir -p "$(dirname "$2")" && cp "$SCRIPT_DIR/$1" "$2" && echo "  ✓ $2"; }
else
  put() { mkdir -p "$(dirname "$2")" && curl -fsSL "$BASE/$1" -o "$2" && echo "  ✓ $2"; }
fi

echo ""
echo "Installing dotfiles-ai..."
echo ""

echo "→ Claude commands"
put "claude/commands/rh.md" "$HOME/.claude/commands/rh.md"
put "claude/commands/rf.md" "$HOME/.claude/commands/rf.md"

echo ""
echo "→ Codex skills"
put "codex/skills/rf/SKILL.md" "$HOME/.codex/skills/rf/SKILL.md"

echo ""
echo "✅ Done!"
echo ""
echo "Usage:"
echo "  Claude:  /rh   — review staged changes, save to .ai-reviews/latest.md"
echo "           /rf   — apply fixes from latest review"
echo "  Codex:   \$rf   — apply fixes from latest review"
