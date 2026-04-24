---
description: Summarize PROGRESS.md status
agent: build
---
Read PROGRESS.md at project root. Output summary:
- plan file path
- total steps / completed / current / remaining
- last checkpoint timestamp
- last gate results
- open conflicts/questions

If PROGRESS.md missing, say: "No active execution. Use /plan to create plan, or /launch <plan-file> to begin executing one."
