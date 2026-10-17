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
findings to `.ai-reviews/latest.md` for another AI agent to fix. Bug findings
include a concrete trigger, impact, and code evidence; optional improvements
are labeled separately. Reviews may have no findings.

```
/rh          # review staged changes, or unstaged tracked changes if none are staged
/rh 42       # review only PR #42, even if local changes exist
```

An explicit source takes priority over automatic selection. You can also ask
to review only staged or only unstaged changes. If the selected source is empty
or cannot be read, `rh` reports that and stops without switching sources.

### `rf` - Review Fix

Reads `.ai-reviews/latest.md`, confirms findings against the current code, and
applies relevant fixes while preserving existing changes. Reviews record repository
and snapshot metadata so `rf` can detect a wrong target or stale review. Older
review files remain supported through context checks; skipped or conflicting
findings are reported with reasons.

Runs relevant tests, lint, or build checks proportionate to the changes. Reports
checks as passed, failed, or not run, and identifies fixes whose validation
is incomplete.

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

Reviews retain an immutable archive with unique UTC filenames and finding IDs.
`latest.md` is replaced atomically after the archive is saved. Fix outcomes live
in separate immutable files under `.ai-reviews/<review-sha256>.outcomes/`, one
per run, so overlapping saves preserve each run's history. The review stays
unchanged; rerunning `/rf` checks current code again even for previously fixed
findings. Reports include finding IDs, deferred reasons, and outcome-save status.
Legacy reviews without finding IDs and older outcomes sidecars remain readable.

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
