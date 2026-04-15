Read PROGRESS.md at the project root. Find the plan file path listed at the top and read that plan file completely. Then:

1. Read the "Resume from" section to understand where execution left off.
2. Read all files listed under the next incomplete step, plus the files from the most recently completed step (for convention context).
3. Reset the "Files read since last checkpoint" counter to the number of files you just read, and reset "Steps completed since last checkpoint" to 0.
4. Give a brief orientation: which step you're resuming from, what's already done, and what you're about to do.
5. Continue execution with the same rules as /autopilot by default: sequential steps, verify after each, update PROGRESS.md, follow the codebase over the plan on conflicts, and honor the auto-checkpoint triggers documented in `.claude/commands/autopilot.md`. If I was previously running under `/launch` (per-step approval gate), honor that mode instead and ask for approval before each step. You can tell which mode was active by checking PROGRESS.md for recent `[LAUNCH]` prompts; when in doubt, ask me which mode to resume in.

If $ARGUMENTS is provided, use that as the plan file path instead of the one in PROGRESS.md.
