# Interface Design

When the user wants to explore alternative interfaces for a chosen deepening candidate, use this parallel sub-agent pattern. Based on "Design It Twice": your first idea is unlikely to be the best.

Uses the vocabulary in `LANGUAGE.md` — **module**, **interface**, **seam**, **adapter**, **leverage**.

## Process

### 1. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the problem space for the chosen candidate:

- constraints any new interface would need to satisfy
- dependencies it would rely on, and which category they fall into from `DEEPENING.md`
- a rough illustrative code sketch to ground the constraints — not a proposal, just a way to make constraints concrete

Show this to the user, then proceed to step 2. The user can read while sub-agents work in parallel.

### 2. Spawn sub-agents

Spawn three or more sub-agents in parallel. Each must produce a radically different interface for the deepened module.

Prompt each sub-agent with a separate technical brief: file paths, coupling details, dependency category from `DEEPENING.md`, and what sits behind the seam. The brief is independent of the user-facing problem-space explanation in step 1. Give each agent a different design constraint:

- Agent 1: minimize the interface — aim for 1–3 entry points max. Maximize leverage per entry point.
- Agent 2: maximize flexibility — support many use cases and extension.
- Agent 3: optimize for the most common caller — make the default case trivial.
- Agent 4, if applicable: design around ports and adapters for cross-seam dependencies.

Include both `LANGUAGE.md` vocabulary and `CONTEXT.md` vocabulary in each brief so each sub-agent names things consistently.

Each sub-agent outputs:

1. Interface: types, methods, params, invariants, ordering, error modes.
2. Usage example showing how callers use it.
3. What the implementation hides behind the seam.
4. Dependency strategy and adapters.
5. Trade-offs: where leverage is high, where it is thin.

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **depth**, **locality**, and **seam** placement.

After comparing, give your own recommendation: which design is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.
