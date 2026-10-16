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
   Capture its exact bytes once and compute their full SHA-256 digest; use that
   snapshot throughout this run even if a new review replaces `latest.md`.
   Leave the original review and its archive unchanged. Any existing outcome
   record belongs to this review only when its recorded digest matches.
   If the review explicitly contains no findings, report that there is nothing
   to apply and stop without editing files or running fix validation.

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
   - Read `Type: bug | improvement` independently of severity and use it to select
     the bug-confirmation or improvement-relevance checks below. For older reviews
     without Type, use the issue description and supporting context; never infer
     type from severity alone. If the type remains ambiguous, defer that finding
     and report why instead of guessing.
   - Understand each issue and its suggested fix before touching any file.
   - Use each finding's `ID` as its key, scoped to the review digest. For legacy
     reviews without IDs, use the file path plus exact finding heading and its
     occurrence number within that file; line numbers alone are not stable keys.
   - Read `.ai-reviews/<sha256>.outcomes.md` if present. Prior outcomes are
     history, not proof: recheck every finding against current code on every
     run, including findings previously marked fixed or already resolved.

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
   - Apply the smallest fix within the reviewed scope and inspect the resulting diff.
     Avoid unrelated refactoring and preserve existing user changes.
   - If fixes conflict, defer all findings involved in that unresolved conflict and
     report why; continue independent fixes. Do not choose a "safer" fix by guesswork.

5. **Validate the fixes**
   - Run available tests, lint, or build checks relevant to the changed behavior,
     proportionate to the scope and risk. Add a regression test when it meaningfully
     verifies a behavior change; prose-only edits do not require tests that merely
     match wording. Tests covering the changed behavior are within scope even
     when their files were not part of the reviewed diff.
   - Prefer read-only check modes: no automatic fixes, snapshot updates, or
     regeneration of tracked files. Inspect the resulting diff after checks;
     report unexpected tracked-file changes and remove only changes attributable
     to the check, preserving all pre-existing edits and intended fixes. If those
     changes cannot be separated safely, stop further modifying checks and report
     the conflict rather than discarding user work.
   - Record each check as passed, failed, or not run, with the command and relevant
     result or reason it could not run. If a failure appears pre-existing, label it
     that way only when baseline results or other concrete evidence support it;
     otherwise leave its cause unresolved.
   - Resolve failures caused by the fixes within the requested scope. If relevant
     validation still fails or cannot run, report the change as applied with
     validation failed or incomplete, rather than claiming the finding is fixed.

6. **Record outcomes, then report**
   Save outcomes separately to `.ai-reviews/<sha256>.outcomes.md`, with the full
   review digest, UTC run timestamp, and one entry per finding key. Record its
   current disposition (`fixed`, `already resolved`, `skipped`, or `unresolved`),
   reason, and verification performed. If verification fails or is incomplete,
   record `unresolved` with any edits applied rather than label the finding fixed.
   Preserve earlier run entries. Publish the complete updated sidecar through a
   unique temporary file and atomic rename in the same directory; if saving fails, report that fixes may have
   been applied but their outcomes were not saved. Do not claim they were saved.
   A repeated ID or ambiguous legacy key must be disambiguated in the record,
   never silently overwrite another finding's result.
   ```text
   Applied changes for X / Y findings from .ai-reviews/latest.md

   Applied:
   - [blocking] <title> -> <file>:<line>
   - [important] <title> -> <file>:<line>

   Skipped:
   - [nit] <title> - skipped (nit)
   - [suggestion] <title> - reason if any

   Validation:
   - [passed | failed | not run] <command> - <result or reason>
   - <findings whose validation failed or remains incomplete, if any>
   ```

## Edge cases

- `latest.md` not found: tell the user to run `/rh` first.
- Conflicting fixes: defer the conflicting findings and report them; continue independent fixes.
- Fix location not found: flag it to the user and skip that fix.
- No git repo: if metadata requires a Git target that cannot be verified, stop;
  for legacy reviews, proceed only when the intended files and findings can be confirmed.
