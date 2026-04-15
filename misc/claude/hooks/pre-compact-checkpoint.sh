#!/usr/bin/env bash
# PreCompact hook: fires just before Claude Code auto-compacts the context.
#
# Hooks cannot directly invoke slash commands, but they can emit
# "additionalContext" that gets injected into the next model turn. We use that
# to force a checkpoint write BEFORE the compactor mangles context.
#
# The additionalContext is read from stdout of this script when it exits 0.

set -euo pipefail

PROGRESS_FILE="PROGRESS.md"

# If there's no active execution, there's nothing to protect. Exit silently.
if [ ! -f "$PROGRESS_FILE" ]; then
  exit 0
fi

# Emit instructions that will be injected into the next turn. Claude should
# see this immediately, before the compactor finishes its lossy pass.
cat <<'EOF'
[PRECOMPACT HOOK] Claude Code is about to auto-compact the context. This is
lossy and will damage your ability to resume cleanly from PROGRESS.md.

Before doing anything else — before responding to the user, before continuing
any in-progress step — you MUST:

1. Read .claude/workflow/checkpoint-impl.md
2. Follow those instructions exactly to update PROGRESS.md with a full
   checkpoint, including the "Resume from" section and partial progress notes
   for the current step.
3. After the checkpoint is written, tell the user: "PreCompact hook fired. I
   have written a full checkpoint to PROGRESS.md. Auto-compaction is about to
   happen — I recommend running `/clear` and `/resume` instead of trusting
   the compacted context, since compaction is lossy."
4. Then stop and wait for the user.

Do NOT skip the checkpoint. Do NOT write an abbreviated version. Do NOT
continue executing the current step. The entire point of PROGRESS.md is that
it survives context loss, so it must be current before context gets damaged.
EOF
