---
description: Start or continue a long-running coding orchestration with subagents while keeping coordinator context small
argument-hint: "[plan, task, file, or focus]"
---
Use the orchestration skill.

Coordinate this as a long-running coding effort. Keep the main thread as coordinator, not implementer: track the plan, decisions, blockers, rolling handoff, and next actions.

Treat provided arguments as the plan or focus:

$ARGUMENTS

## Constraints

- Delegate exploration, implementation, testing, merges/integration, verification, and review to subagents.
- Let subagents work; don’t interrupt them; wait for responses.
- Use the subagents, handoff, review, and TDD skills as applicable.
- Use subagents for hands-on work; you should only make tiny glue or verification edits.
- Have subagents use commits/checkpoints when they help isolate coherent work, enable review, or reduce recovery risk.

## Loop

1. Derive or update the task list and identify blockers.
2. Choose the next reasonably bounded tasks for subagents.
3. Spawn/continue subagents with bounded prompts and expected deliverables.
4. Compress results into the rolling handoff.
5. Continue until complete or blocked.

When finished, summarize completed work, files/areas changed, checks run, branches/commits if any, and remaining risks.
