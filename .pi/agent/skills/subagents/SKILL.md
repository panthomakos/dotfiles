---
name: subagents
description: "Use to delegate context-heavy or independent work to an isolated worker: broad code search, web research, multi-file exploration, long-running implementation, testing/log investigation, review, parallel analysis, or concise summarization of noisy work."
---

# Subagent Delegation

Subagents are isolated workers. Use them when a bounded task would otherwise fill the main context with searches, file reads, logs, exploratory notes, or multi-step execution details. The parent should receive only the useful distilled result.

Good uses include:

- research that scans many sources and returns a concise synthesis;
- code exploration that traces flows or finds relevant files/tests without dumping the search trail;
- review from a focused perspective such as security, performance, architecture, or test gaps;
- testing or log investigation where the raw output is noisy;
- implementation work that may touch many files but can report only key interfaces changed, files modified, tests run, and follow-up risks;
- independent parallel work where tasks do not overlap or conflict.

Avoid subagents for trivial one-step work, tiny edits, or tasks where the parent must retain all intermediate reasoning/state.

## Task Prompts

Give each subagent:

- a clear goal and bounded scope;
- relevant files, commands, constraints, and what not to change;
- the expected output format, usually a short summary with files changed/read, tests run, blockers, and key findings.

For behavior-changing implementation, ask the subagent to use TDD when practical.

## Rules

- Prefer small, focused delegations.
- Do not poll after `subagent_spawn`; results arrive as follow-up messages.
- Keep returned summaries concise; do not paste transcripts or raw tool output.
- Do not run parallel subagents that edit the same files unless using separate worktrees and planning a merge.
