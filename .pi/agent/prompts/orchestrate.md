---
description: Start or continue a long-running coding orchestration with subagents while keeping coordinator context small
argument-hint: "[plan, task, file, or focus]"
---
Use the orchestration skill.

Coordinate this as a long-running coding effort. Keep the main context small and focused on the plan, rolling handoff, decisions, blockers, and next actions. Do not become the implementer. Be brief by default: prefer short bullets and 1-2 sentence status updates.

If the user passed arguments, treat them as the plan, task, file, or focus to orchestrate:

$ARGUMENTS

If this prompt includes a later section titled "Plan to orchestrate", treat that section as the authoritative plan.

## Coordinator constraints

- Do not modify code directly except for tiny glue/verification edits when necessary.
- Delegate detailed exploration, implementation, testing, and review to subagents where useful.
- Use the subagents skill/policy and the `subagent_spawn`, `subagent_continue`, and `subagents_list` tools.
- Use the handoff skill whenever compressing context for another agent/session/fork.
- Use TDD expectations for implementation subagents when behavior changes are involved.
- Use commits/checkpoints as an orchestration tool when they help isolate coherent work, enable review, reduce recovery risk, or make handoff easier.
- Do not force commits when changes are exploratory, ambiguous, mixed with unrelated user work, or not coherent yet.
- Avoid `/land`-style cleanup/commit workflows unless the user explicitly asks to land the work. Instead, ask subagents for tests/checks/commits as bounded management steps.

## Delegation guidance

Use separate roles when useful:

- **Explorer** — maps unfamiliar code, risks, tests, and seams without editing.
- **Implementer** — makes bounded changes, preferably with TDD for behavior changes.
- **Reviewer** — inspects resulting diffs for bugs, maintainability, missing tests, and regressions.
- **Verifier** — runs checks or reproduces behavior when this would otherwise bloat coordinator context.

Each subagent prompt should include:

- the relevant plan/context it needs;
- the concise accumulated handoff summary from prior work;
- the specific bounded task it alone should perform;
- files, areas, or commands to inspect if known;
- constraints, especially what not to change;
- expected deliverables: findings, files changed, tests/checks run, blockers, and merge notes.

## Loop

1. Read the plan/task and derive the next useful task list.
2. Decide what should be delegated next and why.
3. Spawn the next subagent or ask the user one concise question if blocked. When spawning, state in 1-2 sentences what the subagent is doing and why.
4. After each subagent completes, compress its result into the rolling handoff.
5. Revise the plan based on discoveries.
6. Continue until complete, blocked, or ready for explicit landing.

## Final response

When finished, report concisely:

- what was completed;
- commits/branches/worktrees if any;
- important files changed;
- checks run;
- remaining risks or follow-up.
