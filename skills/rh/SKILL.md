---
name: rh
description: >
  Review staged changes, unstaged changes, or a GitHub PR diff, then save the
  findings to .ai-reviews/latest.md so another AI agent can apply the fixes.
  Use when the user says "review handoff", "rh", asks to review changes and
  save findings for later, or wants to generate a review file for /rf.
---

# Review Handoff (rh)

Review staged changes, unstaged tracked changes, or a PR diff, then save the
findings to `.ai-reviews/latest.md` so another AI agent can apply the fixes.

## Steps

1. **Detect what to review** - check in order:
   - `git diff --staged` for staged changes
   - `git diff` for unstaged tracked changes
   - `gh pr diff $ARGUMENTS` if a PR number was passed, such as `/rh 42`
   - If nothing is found, tell the user and stop.

2. **Run a code review** on the detected changes.
   Group findings by file, then severity: `blocking` | `important` | `suggestion` | `nit`.
   Each finding must include: file path, line number, severity, issue, and suggested fix.

3. **Save the review**
   ```bash
   mkdir -p .ai-reviews
   grep -q '.ai-reviews/' .gitignore 2>/dev/null || echo '.ai-reviews/' >> .gitignore
   ```
   Always save to `.ai-reviews/latest.md`, overwriting it if it exists.
   Also save a timestamped copy: `.ai-reviews/<source>-<YYYY-MM-DD-HH-MM>.md`.
   If `.ai-reviews/` cannot be created or written, stop and tell the user that
   the review could not be saved.

   File format:
   ```markdown
   # Code Review - <source> - <timestamp>
   Reviewer: <agent name>
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
   ```text
   Review saved: .ai-reviews/latest.md

   Findings: X blocking, X important, X suggestions

   Ready - run /rf or ask another AI agent to apply fixes from the review file.
   ```

## Edge cases

- Nothing to review: tell the user to stage changes or provide a PR number.
- No git repo: tell the user this skill requires git.
- PR not found: ask the user to check the PR number and `gh auth status`.
- `.ai-reviews/` unwritable: stop and tell the user the review file could not be saved.
