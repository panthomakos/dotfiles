---
name: handoff
description: Use when compressing context for another session, agent, fork, subagent, queued item, or future continuation. Defines handoff content standards, not file/session mechanics.
---

# Handoff Content Standard

Use this skill when producing compressed context for another agent or future session.

A good handoff is short, concrete, and continuation-oriented. It should let a fresh agent continue without replaying the full conversation. Be brief by default; expand only for load-bearing details.

## Include

- **Goal / current objective** — what the user is trying to accomplish.
- **Current status** — what is done, in progress, blocked, or undecided.
- **Key decisions** — decisions made and the reasoning only where it matters.
- **Important artifacts** — paths to plans, docs, ADRs, PRDs, commits, branches, temp reports, session files, or URLs.
- **Repository state** — relevant changed files, uncommitted work, branches/worktrees, and commits if known.
- **Verification** — commands/tests/checks run and their results.
- **Known risks / caveats** — assumptions, fragile areas, user preferences, blockers, or things not to redo.
- **Next recommended actions** — ordered, specific next steps.
- **Suggested skills/tools** — skills, prompts, commands, or subagent roles the next agent should use.

## Avoid

- Do not paste long transcripts or full diffs unless essential.
- Do not duplicate content already captured in artifacts; reference paths/URLs instead.
- Do not include secrets, API keys, credentials, private tokens, or unnecessary personal data.
- Do not invent certainty. Mark unknowns explicitly.
- Do not include file/session mechanics unless the caller asked for a handoff artifact.

## Style

- Prefer bullets and paths over prose.
- Be concise but not cryptic.
- Optimize for restart speed: what does the next agent need to know first?
- If the handoff has a requested focus, include only context relevant to that focus plus essential dependencies/caveats.
