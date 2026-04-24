---
description: Resume plan execution from PROGRESS.md
agent: build
---
Read PROGRESS.md at project root. Find plan file path listed at top, read plan file completely. Then:

1. Read "Resume from" section.
2. Read all files listed under next incomplete step, plus files from most recently completed step.
3. Reset counters: Files read since last checkpoint = number of files just read; Steps completed since last checkpoint = 0.
4. Give brief orientation.
5. Continue execution: default like `/autopilot`. If previously running under `/launch`, honor per-step approval gate.

If $ARGUMENTS provided, use it as plan file path instead.
