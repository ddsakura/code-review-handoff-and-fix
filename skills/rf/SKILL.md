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
   - Compare the review's repository identity with the current repository. Normalize
     SSH/HTTPS remote forms and ignore credentials; local paths alone do not identify
     a cloned repository. For PRs, use the recorded head repository and head commit
     as the fix target, allowing a local branch that actually contains that head.
     If the target is demonstrably different, stop and report the mismatch.
   - Compare the recorded HEAD, index tree, and local diff SHA-256 when present.
     Recompute the hash using the same options and source defined in `rh`; unstaged
     patches are relative to the index. Branch, commit, tree, or hash differences
     signal possible staleness, not an automatic reason to discard every finding.
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
