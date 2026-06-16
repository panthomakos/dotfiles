---
name: orchestration
description: Use when coordinating a long-running coding effort through plans, subagents, handoffs, reviews, queues, and checkpoints while keeping the main context small.
---

# Long-Running Coding Orchestration

Use this skill when the task is bigger than one focused implementation pass and should be coordinated over many steps, sessions, agents, forks, or handoffs.

## Coordinator Role

The coordinator keeps the plan on track. It should not become the implementer.

- Preserve the main context for plan state, decisions, handoff summaries, blockers, and next actions.
- Delegate detailed exploration, implementation, verification, and review to subagents where useful.
- Do not modify code directly except for tiny glue/verification edits when necessary.
- Ask the user about product-significant, irreversible, or ambiguous decisions.
- Keep outputs concise; prefer short bullets, 1-2 sentence status updates, and rolling summaries over pasted transcripts.

## Use Other Skills

- Use the `subagents` skill for delegation policy and subagent prompt quality.
- Use the `handoff` skill whenever compressing context for another session, subagent, fork, queued item, or continuation.
- Use the `tdd` skill for behavior changes, bug fixes, and implementation subtasks.
- Use review-oriented prompts/subagents when a completed chunk needs independent scrutiny.

## Orchestration Loop

1. Identify the objective, constraints, and current plan.
2. Keep an ordered task list, but revise it as discoveries arrive.
3. Choose the next smallest useful delegation or coordinator decision.
4. Spawn focused subagents for exploration, implementation, review, or verification. When spawning, briefly state what each subagent is doing and why.
5. Compress each result into a rolling handoff:
   - outcome;
   - important files read/changed;
   - checks/tests run;
   - blockers;
   - implications for the next step.
6. Use queued items to remember follow-ups that should not derail the current thread.
7. Use commits/checkpoints as a management tool when they help isolate coherent work, enable review, reduce recovery risk, or make handoff easier.
8. Do not force commits when changes are exploratory, ambiguous, mixed with unrelated user work, or not coherent yet.
9. Continue until the plan is complete, blocked, or ready for explicit landing.

## Completion

Before declaring completion, ensure there is a clear verification story. Prefer delegating final review or verification to subagents when doing it in the coordinator would bloat context.

Final summaries should include:

- what was completed;
- important files/areas changed;
- checks/tests run;
- commits/branches/worktrees if any;
- remaining risks or follow-up.
