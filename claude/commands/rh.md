Review staged changes (or PR diff) using Claude's built-in review, then save
findings to `.ai-reviews/latest.md` so another AI agent can run `/rf` to apply the fixes.

## Steps

1. **Detect what to review** — check in order:
   - `git diff --staged` (staged changes)
   - `git diff` (unstaged tracked changes)
   - `gh pr diff $ARGUMENTS` (if a PR number was passed, e.g. `/rh 42`)
   - If nothing found, tell the user and stop.

2. **Run built-in review** on the detected changes.
   Group findings by file, then severity: `blocking` | `important` | `suggestion` | `nit`
   Each finding: file path, line number, severity, issue, suggested fix.

3. **Save to file**
   ```bash
   mkdir -p .ai-reviews
   grep -q '.ai-reviews/' .gitignore 2>/dev/null || echo '.ai-reviews/' >> .gitignore
   ```
   Always save to `.ai-reviews/latest.md` (overwrite if exists).
   Also save a timestamped copy: `.ai-reviews/<source>-<YYYY-MM-DD-HH-MM>.md`

   File format:
   ```
   # Code Review — <source> — <timestamp>
   Reviewer: Claude Code
   Target: <what was reviewed>

   ## Summary
   <2-3 sentences>

   ## Findings

   ### <file-path>
   #### [blocking] <title>
   Line: <N>
   Issue: <description>
   Fix: <suggested fix>
   ```

4. **Report**
   ```
   Review saved → .ai-reviews/latest.md

   Findings: X blocking, X important, X suggestions

   Ready — run /rf in the other AI to apply fixes.
   ```

## Edge cases
- Nothing to review → tell user to `git add` first
- No git repo → tell user this command requires git
- PR not found → check `gh auth status`
- `.ai-reviews/` unwritable → fall back to `/tmp/ai-reviews/` and warn
