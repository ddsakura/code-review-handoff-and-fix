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

1. **Select what to review**:
   - If the user specifies a source, review only that source. For a PR number,
     such as `/rh 42`, use `gh pr diff 42`, even if local changes exist.
     For an explicit staged or unstaged request, use `git diff --staged` or
     `git diff`, respectively.
   - If no source is specified, check `git diff --staged` first. If it is empty,
     check `git diff` for unstaged tracked changes.
   - If the selected source is empty or cannot be read, report that and stop.
     Do not fall back to a different source after an explicit selection.

2. **Capture the reviewed source** before reviewing:
   - Record the repository identity (remote host/owner/name with credentials removed;
     for a repository without a remote, record its local Git common directory),
     branch or detached state, and full `HEAD` commit (or `unborn` before the
     first commit).
   - For a PR, also record its URL, base/head repository identities, branches, and
     full base/head commit IDs. Review the PR head contents, not unrelated local
     files. Check that the PR commits did not change while fetching its diff.
   - For local changes, save the exact reviewed patch's SHA-256 as `Diff SHA-256`.
     Generate it with `git diff --no-ext-diff --no-textconv --binary --full-index
     --no-color --src-prefix=a/ --dst-prefix=b/` (add `--staged` for staged mode).
     `staged` means HEAD to index; `unstaged` means index to working tree, not
     HEAD to working tree. Hash the saved patch bytes and review that snapshot;
     record the index tree ID (`git write-tree`) as `Index tree` so unstaged
     baselines can also be identified. If capture fails or the baseline changes
     during capture, report it and retry a consistent snapshot or stop.
   - These fields identify a snapshot, not permission to overwrite later edits.

3. **Run a code review** on the detected changes.
   Group findings by file, then severity: `blocking` | `important` | `suggestion` | `nit`.
   Each finding must include: file path, line number, severity, issue, and suggested fix.

4. **Save the review**
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
   Repository: <credential-free remote identity or local Git common directory>
   Source: <staged | unstaged | pr>
   Branch: <branch or detached>
   HEAD: <full commit ID or unborn>
   Index tree: <tree ID; local sources only>
   Diff SHA-256: <SHA-256 of saved patch bytes; local sources only>
   PR: <URL; PR sources only>
   PR base: <repository identity, branch, full commit ID; PR sources only>
   PR head: <repository identity, branch, full commit ID; PR sources only>

   ## Summary
   <2-3 sentences>

   ## Findings

   ### <file-path>
   #### [blocking] <title>
   Line: <N>
   Issue: <description>
   Fix: <suggested fix>
   ```

5. **Report**
   ```text
   Review saved: .ai-reviews/latest.md

   Findings: X blocking, X important, X suggestions

   Ready - run /rf or ask another AI agent to apply fixes from the review file.
   ```

## Edge cases

- Nothing to review: report which source was checked. For an automatic selection,
  suggest staging changes or providing a PR number; for an explicit selection,
  stop without switching sources.
- No git repo: tell the user this skill requires git.
- PR not found: ask the user to check the PR number and `gh auth status`.
- `.ai-reviews/` unwritable: stop and tell the user the review file could not be saved.
