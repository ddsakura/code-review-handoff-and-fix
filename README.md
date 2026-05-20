# dotfiles-ai

Personal AI tool configurations for Claude Code and Codex.

## Install

**One-liner (no clone needed):**
```sh
curl -fsSL https://raw.githubusercontent.com/yourname/dotfiles-ai/main/install.sh | sh
```

**Or clone first:**
```sh
git clone https://github.com/yourname/dotfiles-ai
cd dotfiles-ai && sh install.sh
```

## Commands

### `/rh` — Review Handoff (Claude Code)
Reviews staged changes or a PR diff using Claude's built-in review,
then saves findings to `.ai-reviews/latest.md` for another AI to fix.

```
/rh          # review staged changes
/rh 42       # review PR #42
```

### `/rf` — Review Fix (Claude Code)
Reads `.ai-reviews/latest.md` and applies all the fixes.

```
/rf
```

### `$rf` — Review Fix (Codex)
Same as `/rf` but for Codex. Reads `.ai-reviews/latest.md` and applies fixes.

```
$rf
```

## Workflow

```
# 1. Stage your changes
git add .

# 2. Claude reviews and saves findings
/rh

# 3. Codex (or another Claude) applies the fixes
$rf
```

No copy-paste. No switching windows to read comments.

## Structure

```
dotfiles-ai/
├── install.sh
├── README.md
├── claude/
│   └── commands/
│       ├── rh.md       # /rh — review and save
│       └── rf.md       # /rf — read and fix
└── codex/
    └── skills/
        └── rf/
            └── SKILL.md  # $rf — read and fix
```
