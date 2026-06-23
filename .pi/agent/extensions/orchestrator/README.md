# Pi Orchestrator Extension

Async, Pi-native subagent orchestration with a dynamic below-editor status widget and optional git worktree creation.

## Tools

- `subagent_spawn` — start an async subagent; results arrive as follow-up messages.
- `subagents_list` — compact status snapshot for explicit status requests or recovery.
- `subagent_continue` — start a follow-up run in the same cwd/worktree with prior output + guidance.
- `/subagent-stop` — break-glass command to terminate a child process.

## Commands

- `/orchestrate [plan-file] [extra instructions]` — create a fresh coordinator session from a markdown/text plan file (for example `/orchestrate document.md`) or, when no file is provided, from the latest assistant plan; it prepares the `/orchestrate` workflow prompt plus the plan for you to review/submit. The prompt/skill own the workflow instructions; this command is the fresh-session launcher.
- `/subagents` — show current status and refresh the widget.
- `/watch [id-or-exact-name]` — open a small live overlay for a subagent. With no argument, watches the first active subagent, or the first known subagent if none are active.

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

The widget appears below the editor and updates while children run. The parent session is notified when children complete, fail, or need input.

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
