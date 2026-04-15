Begin execution of $ARGUMENTS (a plan file path, or empty to continue from PROGRESS.md).

`/launch` is the careful, human-in-the-loop execution mode. It checkpoints aggressively and stops at every step boundary to ask for approval before continuing. Use it when you want tight oversight. Use `/autopilot` instead when you trust the plan and want fewer interruptions.

## Initial read phase

If $ARGUMENTS is a plan file path:

1. Read the plan file completely.
2. Identify every file path mentioned in the plan — look in sections like "Critical files", "Modify", "Create", "Reference", and in code blocks and inline backticks. Read every file that exists on disk to understand the current codebase state.
3. If the plan references external codebases (paths starting with ~/ or absolute paths outside this repo), read those for reference patterns but never modify them.
4. Create PROGRESS.md at the project root with:
   - The plan file path
   - A "Started" timestamp
   - A numbered checklist mirroring the plan's implementation sequence. If the plan has no explicit sequence, derive one from the plan's structure (schema changes before code, code before tests, tests before verification).
   - Under each checklist item, list the specific files to create or modify
   - A "Current: Step 1" indicator
   - A "Files read since last checkpoint" counter initialized to the number of files you just read
   - A "Steps completed since last checkpoint" counter initialized to 0

If $ARGUMENTS is empty, behave like `/resume`: read PROGRESS.md, find the plan file path, read the plan, read files for the next incomplete step plus the most recently completed step, and reset the counters.

## Execution rules

- Follow the plan's sequence. Do not skip or reorder steps.
- After completing each step, run the verification commands from CLAUDE.md (look for a "Verification" section). If none exist, run: pnpm typecheck. Fix errors before proceeding.
- After each step passes verification, update PROGRESS.md: mark the step `[x]` with a timestamp, advance the "Current" indicator, increment the "Steps completed since last checkpoint" counter, and update the "Files read since last checkpoint" counter.
- If the plan's code snippets conflict with conventions you observe in the actual codebase (different import paths, different patterns, different naming), follow the codebase. Note the conflict in a "Conflicts" section in PROGRESS.md.
- Do NOT create files not specified in the plan.
- Do NOT install packages not specified in the plan.
- Do NOT commit to git.

## Per-step approval gate

Before starting step N+1 (that is, after step N has passed verification and PROGRESS.md has been updated), output this exact format:

```
[LAUNCH] Completed step N: <step title>. Gates: <pass/fail>.
Next: step N+1: <step title>. Files to touch: <list>.
Reply "go" to continue, "checkpoint" to stop and checkpoint now, or "stop" to halt.
```

Then stop and wait for my response. Do not proceed without an explicit "go". The first step runs without an approval gate (you just got the plan and are kicking things off), but every subsequent step requires one.

Handling responses:
- "go" — continue with step N+1.
- "checkpoint" — follow `.claude/workflow/checkpoint-impl.md` exactly, then tell me to `/clear` and `/resume`. Do not continue.
- "stop" — follow `.claude/workflow/checkpoint-impl.md` exactly, then halt without recommending a resume.
- Anything else — treat as a question or instruction, answer it or apply it, then ask the approval question again.

## Auto-checkpoint triggers (tight)

Even with the per-step gate, the automatic triggers still apply. After any step, if ANY of the following are true, checkpoint via `.claude/workflow/checkpoint-impl.md` immediately and then tell me to `/clear` and `/resume`. Do not ask for approval to continue — stop unconditionally:

1. `Steps completed since last checkpoint` is 2 or more.
2. `Files read since last checkpoint` is 10 or more.
3. The step you just completed involved reading files totaling more than ~1200 lines.
4. You have edited 7 or more distinct files since the last checkpoint.
5. You have made 20 or more tool calls since the last checkpoint.
6. You notice obvious degradation signs: forgetting earlier decisions, re-reading files you already read, asking yourself questions the plan already answered, or producing inconsistent naming from what you established in earlier steps.

Reset the counters to 0 after any checkpoint is written.

## Why these rules exist

`/launch` is optimized for safety, not speed. The per-step approval gate turns every step boundary into an explicit decision point, which lets you kill a run the moment you see it going sideways — exactly when you want to kill a run. The tight numeric triggers exist because models cannot reliably self-assess context fullness; counting files and steps is arithmetic you can actually trust. Together they make silent degradation very hard.

If the per-step gate and the manual `/checkpoint` command wrote different state, later resumes would be inconsistent. That is why both paths route through `.claude/workflow/checkpoint-impl.md`.
