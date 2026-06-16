---
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "[scope/focus for the next session]"
---

Use the handoff skill for the content standard.

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

Save the handoff to a conflict-resistant temporary filename. If this prompt includes an exact handoff path in additional invocation instructions, use that path. Otherwise, generate one yourself, for example by running `mktemp /tmp/pi-handoff-XXXXXX`. Do not use a fixed path like `/tmp/pi-handoff.md`, and do not save it in the current workspace.

If the user passed arguments (`$ARGUMENTS`), treat them as the desired scope/focus for the next session. Tailor the handoff to that part of the overall session: include only relevant context, decisions, files, caveats, and next steps, while preserving essential dependencies from the broader session.

When finished, briefly report the saved path.
