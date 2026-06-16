---
name: subagents
description: Use when a coding task is large, multi-step, parallelizable, spans multiple files or domains, needs codebase exploration, implementation work, verification, or separate workers/reviewers. Guides Pi subagent orchestration with subagent_spawn, subagents_list, and subagent_continue.
---

# Subagent Orchestration

Use subagents to break down coding work when the task is too broad for one focused pass, has independent subtasks, needs exploration before implementation, or benefits from review/verification in a separate context.

This includes both:

- **Exploration subagents**: inspect unfamiliar areas of the codebase, trace flows, identify tests, map APIs, or summarize risks without changing files.
- **Implementation subagents**: make bounded code changes, preferably with TDD for behavior changes, then report files changed and tests run.

Do **not** spawn subagents for tiny single-file edits or simple questions.

## Relation to /orchestrate, /carry, and /queue

This skill is subagent delegation policy: when to split work, how to scope subagents, and how to summarize results. The `orchestration` skill and `/orchestrate` command cover long-running coordinator workflows. `/carry` and `/queue` are interactive/session-management commands. When acting autonomously, prefer the available subagent tools such as `subagent_spawn` instead of trying to run slash commands.

## Default Workflow

1. Read the relevant plan/request and identify separable subtasks.
2. Decide whether tasks can run in parallel or should be sequential.
3. Spawn subagents with clear, bounded instructions using `subagent_spawn`.
4. Keep the main thread as coordinator: track outcomes, blockers, tests, and handoff summaries.
5. Use `subagents_list` to check status.
6. When a subagent completes, summarize only the useful results and integrate/continue.
7. If a subagent reports `NEEDS_INPUT`, ask the user or continue it with `subagent_continue` once guidance is available.

## Good Subagent Task Prompts

Each subagent prompt should include:

- The goal and exact scope of responsibility.
- Relevant files, plan paths, or commands to inspect.
- Clear constraints, including what not to change.
- Expected deliverables: brief task summary, files changed, tests run, findings, blockers.
- Any required skills or workflows, such as TDD for implementation work.

For implementation subtasks, tell the subagent to use TDD when behavior changes are involved: write one failing behavior test, make it pass, then repeat/refactor.

## When to Use Worktrees

Use `worktree` for risky or parallel code changes that might conflict with the main working tree. Prefer no worktree for read-only research or tightly sequential edits in the current tree.

## Coordination Rules

- Prefer small, cleanly scoped subtasks.
- Avoid dumping long transcripts back into the main thread; keep concise handoff summaries and 1-2 sentence status updates.
- Do not run parallel subagents that edit the same files unless using separate worktrees and planning a merge.
- Verify final integrated behavior in the main session before reporting done.
