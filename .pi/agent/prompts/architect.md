---
description: Find deepening opportunities that improve codebase architecture, testability, and AI-navigability
argument-hint: "[area, module, path, or architectural concern]"
---
Find architectural deepening opportunities in this codebase.

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability, locality, leverage, and AI-navigability.

If the user passed arguments, treat them as the focus area for the architecture review:

$ARGUMENTS

## Source Influence

This global Pi prompt is adapted from Matt Pocock's `improve-codebase-architecture` skill:

- https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture

## Required Vocabulary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." Full definitions are in:

`~/.pi/agent/prompts/architect/LANGUAGE.md`

- **Module** — anything with an interface and an implementation: function, class, package, slice.
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. Use this, not "boundary."
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge, and verification concentrated in one place.

Key principles:

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This prompt is informed by the project's domain model. Domain language gives names to good seams; ADRs record decisions the review should not re-litigate.

## Process

### 1. Explore

Read the project's domain glossary and relevant decisions before judging architecture:

- `CONTEXT.md`, or the nearest context file for the focused area.
- `CONTEXT-MAP.md`, if present, to identify multiple contexts.
- Relevant `docs/adr/` records.
- Project instructions such as `AGENTS.md`, if present.

Then explore the codebase organically. Use sub-agents for broad codebase exploration when useful, but do not outsource final judgment. Note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, while the real bugs hide in how they are called, giving no **locality**?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything that seems shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

Classify each candidate's dependencies using:

`~/.pi/agent/prompts/architect/DEEPENING.md`

Do not edit implementation files during this review unless the user explicitly asks you to implement a chosen change.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp directory from `$TMPDIR`, falling back to `/tmp` on Unix-like systems or `%TEMP%` on Windows. Write to:

`<tmpdir>/architecture-review-<timestamp>.html`

Open it for the user:

- macOS: `open <path>`
- Linux: `xdg-open <path>`
- Windows: `start <path>`

Then tell the user the absolute path.

The report uses Tailwind via CDN for layout and Mermaid via CDN for diagrams where graph, flow, or sequence visuals communicate the structure. Mix Mermaid with hand-crafted CSS/SVG visuals. Each candidate gets a before/after visualisation. Be visual.

Follow the full report guidance in:

`~/.pi/agent/prompts/architect/HTML-REPORT.md`

For each candidate card include:

- **Files** — which files/modules are involved.
- **Problem** — why the current architecture is causing friction.
- **Solution** — plain English description of what would change.
- **Benefits** — explained in terms of locality and leverage, and how tests would improve.
- **Before / After diagram** — side-by-side, custom-drawn where useful, illustrating the shallowness and the deepening.
- **Recommendation strength** — one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge.

End the report with a **Top recommendation** section: which candidate you would tackle first and why.

Use `CONTEXT.md` vocabulary for the domain, and `~/.pi/agent/prompts/architect/LANGUAGE.md` vocabulary for the architecture. If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not implementation-only names unless the file/module names are necessary.

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card, for example: _"Contradicts ADR-0007 — but worth reopening because…"_ Do not list every theoretical refactor an ADR forbids.

Do **not** propose detailed interfaces yet. After the file is written and opened, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, and what tests survive.

Ask one question at a time. For each question, provide your recommended answer. If a question can be answered by exploring the codebase, explore the codebase instead.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md`. Create the file lazily if it does not exist. Before creating or editing `CONTEXT.md`, read: `~/.pi/agent/prompts/grill/CONTEXT-FORMAT.md`.
- **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually help future reviews avoid the same suggestion. Skip ephemeral reasons like "not worth it right now." Before creating an ADR, read: `~/.pi/agent/prompts/grill/ADR-FORMAT.md`.
- **User wants to explore alternative interfaces for the deepened module?** Follow: `~/.pi/agent/prompts/architect/INTERFACE-DESIGN.md`.

## Deliverable Discipline

- Default deliverable: HTML architecture review report plus a concise path in chat.
- Do not make code changes unless explicitly asked.
- Do not bury the user in prose; put the architecture review in the report.
- Do not propose interfaces until the user chooses a candidate.
