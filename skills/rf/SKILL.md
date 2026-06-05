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

2. **Read and understand the findings**
   - Parse all findings by severity: `blocking` -> `important` -> `suggestion` -> `nit`
   - Understand each issue and its suggested fix before touching any file.

3. **Apply fixes in order**
   - Start with `blocking`, then `important`, then `suggestion`.
   - Skip `nit` unless the user explicitly asked to fix everything.
   - For each fix: read the file, apply the change, and verify it looks correct.
   - Do not apply fixes that conflict with each other. Flag conflicts to the user.

4. **Report when done**
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
- Conflicting fixes: apply the safer one when clear, then flag the conflict to the user.
- Fix location not found: flag it to the user and skip that fix.
- No git repo: warn but still attempt fixes if files are accessible.
