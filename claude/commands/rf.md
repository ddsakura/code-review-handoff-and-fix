Read the latest review file from `.ai-reviews/latest.md` and apply all the fixes.

## Steps

1. **Find the review file**
   ```bash
   cat .ai-reviews/latest.md
   ```
   If file doesn't exist, tell the user to run `/rh` first and stop.

2. **Read and understand the findings**
   - Parse all findings by severity: `blocking` → `important` → `suggestion` → `nit`
   - Understand each issue and its suggested fix before touching any file

3. **Apply fixes in order**
   - Start with `blocking`, then `important`, then `suggestion`
   - Skip `nit` unless the user explicitly asked to fix everything
   - For each fix: read the file, apply the change, verify it looks correct
   - Do not apply fixes that conflict with each other — flag them to the user

4. **Report when done**
   ```
   Fixed X / Y findings from .ai-reviews/latest.md

   Applied:
   - [blocking] <title> → <file>:<line>
   - [important] <title> → <file>:<line>
   ...

   Skipped:
   - [nit] <title> — skipped (nit)
   - [suggestion] <title> — reason if any
   ```

## Edge cases
- `latest.md` not found → tell user to run `/rh` first
- Conflicting fixes → apply the safer one, flag the conflict to the user
- Fix location not found (line number changed) → flag to user, skip that fix
- No git repo → warn but still attempt fixes
