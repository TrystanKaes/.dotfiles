You are in planning mode. Do NOT modify any files except the plan file you will create.

Task: $ARGUMENTS

If the argument is a file path (starts with / or ./ or contains .md), read that file for the task description. Otherwise treat the argument text as the task description.

Deeply read all code relevant to this task. Read every file that touches the feature area. Read related tests. Read related utilities and shared code. Read the schema if database changes are involved. Be thorough — skim nothing.

Write a plan file to plans/plan-[slugified-task-name].md with these sections:

## Context
What exists today. Current file structure, current data model, current behavior.

## Design goals
Numbered list of what the implementation must achieve.

## Non-goals
What is explicitly out of scope.

## Critical files
### Modify
Files that need changes, with line numbers or section descriptions for what changes.
### Create
New files to create, with their purpose.
### Reference (read-only)
Files to read for patterns or context, not to modify.

## Implementation sequence
Numbered steps in dependency order. Each step should list:
- What to do
- Which files to touch
- What to verify before moving to the next step

## Verification
### Automated
Commands to run: typecheck, lint, build, test.
### Manual smoke test
Numbered steps a developer would follow to verify the feature works.

## Risks & notes
Anything that could go wrong, edge cases, race conditions, things the implementation might miss.

After writing the plan, output: "Plan written to [path]. Review and edit it, then run /launch [path] to execute."

Do NOT begin implementation.
