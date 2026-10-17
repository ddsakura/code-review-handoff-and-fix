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
   - Record credential-free repository identities (host/owner/name): use the
     current branch's upstream remote, else `origin`, else all configured remotes.
     If there is no remote, use the absolute Git common directory. Normalize SSH
     and HTTPS forms. Record branch or detached state; record full `HEAD` (or
     `unborn`) only for local sources, since local HEAD is unrelated to a PR diff.
   - For a PR, record its URL, base/head repository identities, branches, and full
     base/head commit IDs from GitHub, independently of local remotes. Capture
     `gh pr view <N> --json baseRefOid,headRefOid` before and after saving
     `gh pr diff <N>` to a temporary file. If either commit changes, retry the
     capture or stop. Review that saved diff and PR head contents, not local files.
   - For local changes, save the exact patch to a uniquely created temporary file
     outside the working tree. Generate it with
     `git diff --no-ext-diff --no-textconv --binary --full-index --no-color
     --src-prefix=a/ --dst-prefix=b/` (add `--staged` for staged mode).
     Check the diff command's exit status before hashing; use
     `shasum -a 256 /path/to/saved.patch` and record the digest as `Diff SHA-256`.
     Review those same saved bytes, not a second live diff; clean up only this
     run's temporary files after the review is saved or capture fails.
   - `staged` means HEAD to index; `unstaged` means index to working tree. Capture
     `git ls-files --stage -z` to a separate temporary file and hash its exact bytes
     as `Index SHA-256`. This is read-only and includes unmerged stage entries;
     do not require `git write-tree`, which fails on an unmerged index and writes
     Git objects. Compare index fingerprints and local HEAD before/after patch
     capture. If they changed, retry or stop; do not hash output of failed commands.
     With unmerged entries, retain the combined diff and report any context limits
     without forcing a tree snapshot or modifying the conflict resolution.
   - These fields identify a snapshot, not permission to overwrite later edits.

3. **Run a code review** on the detected changes.
   - Read relevant surrounding code, callers, and tests to check the changed behavior.
     If needed context is unavailable, state the limitation instead of asserting a bug.
   - Report a bug only when the changes introduce or expose an actionable issue with
     a concrete trigger, impact, and supporting code evidence. Do not turn speculative
     risks or personal style preferences into bugs, and do not invent findings to
     meet a quota. A review with no findings is valid.
   - Group findings by file, then severity: `blocking` | `important` | `suggestion` | `nit`.
     Label optional improvements and style comments as `suggestion` or `nit` and
     distinguish them explicitly from bugs using `Type: bug | improvement`.
     Type is independent of severity; a minor bug may be a `suggestion`.
   - Each finding must include file path, line number, severity, type, issue, and suggested
     fix. For bugs, also include the trigger, impact, and evidence (such as the
     relevant code path or an observed test result); distinguish inference from
     behavior actually reproduced.
   - Assign each finding a unique ID within this review (`F001`, `F002`, ...);
     preserve these IDs in the saved review and use them when reporting outcomes.

4. **Save the review**
   ```bash
   mkdir -p .ai-reviews
   grep -q '.ai-reviews/' .gitignore 2>/dev/null || echo '.ai-reviews/' >> .gitignore
   ```
   Complete the review before publishing it:
   - Choose an archive name such as
     `.ai-reviews/<source>-<YYYYMMDDTHHMMSS-subsecondsZ>-<random>.md`.
     Use UTC, a safe source label (`staged`, `unstaged`, or `pr-42`), and a
     random suffix. Never use raw user input as a path component.
   - Write the complete content to a uniquely created temporary file in
     `.ai-reviews/`, then publish the archive without replacing any existing
     file (for example, create a hard link to the completed temp file with
     exclusive destination semantics). On a name collision, choose another name.
   - Copy the complete archive into a second uniquely created temporary file in
     the same directory, then atomically rename that file to `latest.md`.
     Never truncate or write `latest.md` in place, and never edit an archive.
   - Clean up only this run's temporary files. If any write or publication fails,
     stop and report the failure; preserve the previous `latest.md` and any
     completed archive. Report success only after both publications succeed.

   If there are no findings, put `No findings.` directly under `## Findings`
   instead of emitting placeholder findings.

   File format:
   ```markdown
   # Code Review - <source> - <timestamp>
   Reviewer: <agent name>
   Target: <what was reviewed>
   Repository: <credential-free remote identity/identities or local Git common directory>
   Source: <staged | unstaged | pr>
   Branch: <branch or detached>
   HEAD: <full commit ID or unborn; local sources only>
   Index SHA-256: <SHA-256 of git ls-files --stage -z bytes; local sources only>
   Diff SHA-256: <SHA-256 of saved patch bytes; local sources only>
   PR: <URL; PR sources only>
   PR base: <repository identity, branch, full commit ID; PR sources only>
   PR head: <repository identity, branch, full commit ID; PR sources only>

   ## Summary
   <2-3 sentences>

   ## Findings

   ### <file-path>
   #### [blocking] <title>
   Type: <bug | improvement>
   ID: F001
   Line: <N>
   Issue: <description; identify bugs versus optional improvements>
   Trigger: <input or condition that causes the bug; omit for optional improvements>
   Impact: <observable consequence; omit for optional improvements>
   Evidence: <supporting code path or observed result; omit for optional improvements>
   Fix: <suggested fix>
   ```

5. **Report**
   ```text
   Review saved: .ai-reviews/latest.md

   Findings: X blocking, X important, X suggestions, X nits

   Ready - run /rf or ask another AI agent to apply fixes from the review file.
   ```
   When the total is zero, replace the Ready line with
   `No findings - nothing for /rf to apply.`

## Edge cases

- Nothing to review: report which source was checked. For an automatic selection,
  suggest staging changes or providing a PR number; for an explicit selection,
  stop without switching sources.
- No git repo: tell the user this skill requires git.
- PR not found: ask the user to check the PR number and `gh auth status`.
- `.ai-reviews/` unwritable: stop and tell the user the review file could not be saved.
