---
name: rf
description: >
  Read the latest AI review file from .ai-reviews/latest.md and apply all the
  fixes. Use when the user says "apply fixes", "fix from review", "rf", or
  after /rh generated a review file.
---

# Review Fix (rf)

Read `.ai-reviews/latest.md` and apply the fixes listed there.

## Steps

1. **Find the review file**
   ```bash
   cat .ai-reviews/latest.md
   ```
   If the file does not exist, tell the user to run `/rh` first and stop.

2. **Check the target and snapshot** before editing:
   - For local sources, compare recorded credential-free repository identities
     against all configured remotes, normalizing SSH/HTTPS forms. A match with any
     remote is sufficient; do not assume `origin` is the only identity. For local
     repositories without remotes, compare the absolute Git common directory.
     If the repository is demonstrably different, stop and report the mismatch.
   - For PR sources with a recorded head commit, check
     `git merge-base --is-ancestor <recorded-PR-head> HEAD`. Exit 0 confirms the
     target even for a fork PR in an upstream clone with no fork remote; remote
     names or a head-repository mismatch alone must not reject this checkout.
     If the head is absent, is not an ancestor, or the check fails, stop before
     editing and tell the user to check out the PR branch, for example with
     `gh pr checkout <N>`. Do not automatically switch branches. A matching base
     repository or PR URL alone does not override this commit-containment check.
   - For PRs, compare current HEAD with `PR head`, not the review's local `HEAD`.
     Descendant commits and local edits signal possible staleness: reconfirm each
     finding. An older or divergent checkout is a wrong target under the rule above,
     not merely stale. Ignore legacy local HEAD/index fields for PR reviews.
   - For local sources, compare recorded HEAD, `Index SHA-256`, and `Diff SHA-256`
     when present. Recompute fingerprints with the same commands and source as
     `rh`; unstaged patches are relative to the index. Differences signal possible
     staleness, not an automatic reason to discard every finding. Older `Index tree`
     metadata is optional: if it cannot be compared without writing Git objects,
     note the limitation and use available fingerprints plus per-finding checks.
   - Missing metadata (including older review files) is supported: identify the
     intended target from available paths and context, and check each finding in
     current code. If repository identity remains ambiguous, request clarification
     before editing. Never reset, switch branches, or checkout reviewed versions
     over existing changes to make metadata match.
   - Inspect staged and unstaged changes before editing and preserve them, including
     staged/unstaged separation. If a fix would overwrite user work, skip that
     finding and explain the conflict; do not stash, reset, or stage files implicitly.

3. **Read and understand the findings**
   - Parse all findings by severity: `blocking` -> `important` -> `suggestion` -> `nit`
   - Understand each issue and its suggested fix before touching any file.

4. **Apply fixes in order**
   - Start with `blocking`, then `important`, then `suggestion`.
   - Skip `nit` unless the user explicitly asked to fix everything.
   - For each finding, locate the current code by context rather than trusting old
     line numbers. Independently confirm bug claims and their triggers; for optional
     improvements, confirm relevance to the reviewed scope and requested intent.
     The suggested fix is guidance, not an instruction to apply blindly.
   - Skip findings that are already fixed, no longer applicable, unsupported by
     current evidence, or cannot be located confidently; report a specific reason.
     A stale snapshot may still contain a valid finding: apply it only after
     reconfirming its relevance.
   - Apply the smallest fix within the reviewed scope and verify it looks correct.
     Avoid unrelated refactoring and preserve existing user changes.
   - If fixes conflict, defer all findings involved in that unresolved conflict and
     report why; continue independent fixes. Do not choose a "safer" fix by guesswork.

5. **Report when done**
   ```text
   Fixed X / Y findings from .ai-reviews/latest.md

   Applied:
   - [blocking] <title> -> <file>:<line>
   - [important] <title> -> <file>:<line>

   Skipped:
   - [nit] <title> - skipped (nit)
   - [suggestion] <title> - reason if any
   ```

## Edge cases

- `latest.md` not found: tell the user to run `/rh` first.
- Conflicting fixes: defer the conflicting findings and report them; continue independent fixes.
- Fix location not found: flag it to the user and skip that fix.
- No git repo: if metadata requires a Git target that cannot be verified, stop;
  for legacy reviews, proceed only when the intended files and findings can be confirmed.
