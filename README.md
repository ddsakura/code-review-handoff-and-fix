# code-review-handoff-and-fix

Agent skills for handing code review findings from one AI agent to another.

## Install

Install all skills for the current project:

```sh
npx skills add ddsakura/code-review-handoff-and-fix
```

Install only `rf` for the current project:

```sh
npx skills add ddsakura/code-review-handoff-and-fix --skill rf
```

Install for a specific agent:

```sh
npx skills add ddsakura/code-review-handoff-and-fix --agent claude-code
npx skills add ddsakura/code-review-handoff-and-fix --agent codex
```

Install globally with `npx`:

```sh
npx skills add ddsakura/code-review-handoff-and-fix --global
```

Manual global install without `npx`:

```sh
curl -fsSL https://raw.githubusercontent.com/ddsakura/code-review-handoff-and-fix/main/install.sh | sh
```

## Skills

Claude Code exposes installed skills as slash commands, so you can use `/rh`
and `/rf`. Other agents can invoke the same skills by name or natural language.

### `rh` - Review Handoff

Reviews staged changes, unstaged tracked changes, or a PR diff, then saves
findings to `.ai-reviews/latest.md` for another AI agent to fix.

```
/rh          # review staged changes
/rh 42       # review PR #42
```

### `rf` - Review Fix

Reads `.ai-reviews/latest.md` and applies the fixes.

```
/rf
```

## Workflow

```
# 1. Stage your changes
git add .

# 2. Review and save findings
/rh

# 3. Apply fixes with another AI agent
/rf
```

No copy-paste. No switching windows to read comments.

## Structure

```
code-review-handoff-and-fix/
├── README.md
├── install.sh
└── skills/
    ├── rh/
    │   └── SKILL.md    # review and save findings
    └── rf/
        └── SKILL.md    # read and fix findings
```
