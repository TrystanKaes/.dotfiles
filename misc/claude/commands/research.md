---
description: Deep codebase research. Produces findings-only doc, no recommendations.
argument-hint: <research question>
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*), Bash(rg:*), Bash(fd:*)
model: claude-opus-4-5
---

Research mode. Investigate deeply, document findings, propose nothing.

## Question
$ARGUMENTS

## Rules
- Read relevant files completely and trace every intricacy. Do not skim.
- No code changes. Only write to `research/[slug].md`.
- Observations only. If you catch yourself writing "we should" or "a fix would be", stop — that's for the plan, not research.
- Every claim needs a `file.ts:line` citation.
- Flag anomalies explicitly: dead code, duplicated logic, surprising patterns, recent churn.
- Prefer `rg` over `find`. Read whole files when under ~500 lines.

## Output
Write `research/[slug].md` with sections: Scope, Findings (with citations), Anomalies, Open questions.

When done, print the path and a 5-bullet summary. Do not suggest next steps.
