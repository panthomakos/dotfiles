# Pi Orchestrator Extension

Async, Pi-native subagent orchestration with a dynamic below-editor status widget and optional git worktree creation.

## Tools

- `subagent_spawn` — start an async subagent and return immediately.
- `subagents_list` — return JSON status for all known subagents.
- `subagent_continue` — start a follow-up run in the same cwd/worktree with prior output + guidance.
- `subagent_stop` — terminate a running child process.

## Commands

- `/sequence [plan-file] [extra instructions]` — create a fresh coordinator session from a markdown/text plan file (for example `/sequence document.md`) or, when no file is provided, from the latest assistant plan; it prepares a prompt containing the plan plus sequence instructions for you to review/submit, then run subagents one at a time while carrying forward only a concise handoff summary between them.
- `/subagents` — show current status and refresh the widget.

## Worktree example

```json
{
  "name": "Auth worker",
  "agent": "worker",
  "task": "Implement the auth refactor. Summarize changed files and tests.",
  "worktree": {
    "branch": "agent/auth-refactor",
    "base": "main",
    "path": "../myrepo-auth-refactor",
    "create": true
  }
}
```

The widget appears below the editor and updates while children run.

## Agent definitions

Agents are read from:

- `~/.pi/agent/agents/*.md`
- `.pi/agents/*.md` when `agentScope` is `project` or `both`

A subagent can also be spawned without an `agent`; pass `systemPrompt`, `model`, and/or `tools` directly.

## Help / waiting convention

Child agents are instructed to end with:

```text
NEEDS_INPUT: <question>
```

When detected, the run is marked `waiting` and the main session is notified. Use `subagent_continue` with guidance to start a same-worktree follow-up.
