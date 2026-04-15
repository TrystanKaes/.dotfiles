Run the project's verification commands. Check CLAUDE.md for a "Verification" section with specific commands. If none exist, use this default sequence:
- pnpm typecheck
- pnpm lint
- pnpm build
- pnpm test

If $ARGUMENTS is provided, run only the specified gate (e.g., "typecheck", "build", "test", "lint"). Otherwise run all gates in order.

Report pass/fail for each gate. For failures, show the relevant error output.

If a gate fails, attempt to fix the errors. After fixing, re-run ONLY the failing gate. If it still fails after 2 fix attempts, stop and report the remaining errors. Do not loop more than twice — ask me for guidance instead.

If PROGRESS.md exists, append the gate results with a timestamp.
