Begin unattended execution of $ARGUMENTS (a plan file path, or empty to continue from PROGRESS.md).

`/autopilot` is the fire-and-forget execution mode. It trusts the plan, runs through steps without asking for approval between them, and only stops when an auto-checkpoint trigger fires or the plan is complete. Use it when you have reviewed the plan thoroughly and want minimum interruptions. Use `/launch` instead when you want a per-step approval gate.

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
- Do NOT ask for approval between steps. Continue straight through until a trigger fires or the plan is complete.

## Auto-checkpoint triggers

Context-full self-assessment is unreliable, so use these concrete proxies instead. After completing each step (not mid-step), check all of the following. If ANY are true, stop and auto-checkpoint:

1. `Steps completed since last checkpoint` is 3 or more.
2. `Files read since last checkpoint` is 15 or more.
3. The step you just completed involved reading files totaling more than ~2000 lines.
4. You have edited 10 or more distinct files since the last checkpoint.
5. You have made 30 or more tool calls since the last checkpoint.
6. You notice obvious degradation signs: forgetting earlier decisions, re-reading files you already read, asking yourself questions the plan already answered, or producing inconsistent naming from what you established in earlier steps.

When any trigger fires:
- Read `~/.claude/workflow/checkpoint-impl.md` and follow those instructions exactly to write the checkpoint. Do not improvise an abbreviated version.
- Reset the "Files read" and "Steps completed" counters to 0 after the checkpoint is written.
- Tell me: "Auto-checkpoint triggered by [which rule]. Run `/clear` then `/resume` to continue with a fresh context." Then stop. Do not begin the next step. Do not continue in the degraded session.

## Honest limitation

Claude cannot execute `/clear` on itself from inside a session — `/clear` is a user action. So "autopilot" here means "run through the plan without asking, checkpoint aggressively, and stop cleanly when a trigger fires so a manual `/clear` and `/resume` is always safe." It does not mean unattended execution across clear boundaries. For additional protection against Claude Code's native auto-compactor, the PreCompact hook in `.claude/settings.json` will force a checkpoint before compaction happens.

## Why this exists

`/autopilot` is optimized for throughput, not oversight. The numeric triggers are deliberately conservative — it is much cheaper to checkpoint slightly too early than to enter a death-spiral of degraded reasoning. If you want tighter oversight with a per-step approval gate, use `/launch` instead.
