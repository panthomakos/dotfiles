# HTML Report Format

The architecture review is rendered as a single self-contained HTML file in the OS temp directory. Tailwind and Mermaid both come from CDNs. Mermaid handles graph-shaped diagrams reliably; hand-built divs and inline SVG handle more editorial visuals like mass diagrams and cross-sections. Mix them; don't lean on Mermaid for everything.

## Scaffold

Use a complete HTML document. Include Tailwind via CDN and Mermaid via CDN. The report is static apart from Mermaid rendering.

## Header

Repo name, date, and a compact legend:

- solid box = module
- dashed line = seam
- red arrow = leakage
- thick dark box = deep module

No introduction paragraph. Go straight into the candidates.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the glossary terms from `LANGUAGE.md` without ceremony.

Each candidate is one card:

- **Title** — short, names the deepening, e.g. "Collapse the Order intake pipeline".
- **Badge row** — recommendation strength: `Strong` = emerald, `Worth exploring` = amber, `Speculative` = slate; plus a tag for dependency category: `in-process`, `local-substitutable`, `ports & adapters`, `mock`.
- **Files** — monospaced list, `font-mono text-sm`.
- **Before / After diagram** — the centrepiece. Two columns, side by side.
- **Problem** — one sentence. What hurts.
- **Solution** — one sentence. What changes.
- **Wins** — bullets, six words or fewer where possible.
- **ADR callout** if applicable — one line in an amber-tinted box.

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Mix them. Don't make every diagram look the same.

### Mermaid graph

Use Mermaid `flowchart`, `graph`, or sequence diagrams when the point is dependency or call flow. Wrap it in a Tailwind-styled card. Use red leakage edges and a dark deep module.

### Hand-built boxes-and-arrows

Modules as `div`s with borders and labels. Arrows as inline SVG positioned over a relative container. Use this when the after diagram should look like one thick-bordered deep module with greyed-out internals.

### Cross-section

Stack horizontal bands to show layers a call passes through. Before: many thin layers each doing little. After: one thick band labelled with the consolidated responsibility.

### Mass diagram

Two rectangles per module — one for interface surface area, one for implementation. Before: interface rectangle is nearly as tall as implementation, showing shallow depth. After: interface rectangle is short, implementation rectangle is tall.

### Call-graph collapse

Before: a tree of function calls rendered as nested boxes. After: the same tree collapsed into one box, with now-internal calls faded inside it.

## Top recommendation section

One larger card. Candidate name, one sentence on why, anchor link to its card.

## Tone

Plain English, concise — but architectural nouns and verbs come straight from `LANGUAGE.md`.

Use exactly: module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

Never substitute: component, service, unit for module; API or signature for interface; boundary for seam; layer or wrapper for module when you mean module.

Phrasings that fit:

- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

Wins bullets name the gain in glossary terms:

- "locality: bugs concentrate"
- "leverage: one interface, N callers"
- "interface shrinks; implementation absorbs pass-throughs"

No hedging. No throat-clearing. If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it.
