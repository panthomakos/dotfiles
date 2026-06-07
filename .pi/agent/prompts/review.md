---
description: Run a strict code-quality review for local changes, commits/ranges, or GitHub PRs
argument-hint: "[--staged|--unstaged|--commit <rev>|--range <range>|pr <number>|PR-URL]"
---
Run a strict code-quality review.

# Code Quality Review

Use this skill for a demanding code review of a local diff, a commit/range, or a GitHub PR. It is optimized for maintainability and structural quality, with secondary checks for correctness, security, performance, tests, and verification.

Do not edit implementation files while performing the review unless the user explicitly asks you to fix issues. The default deliverable is review findings, not code changes.

## Source Influences

This global Pi skill is adapted from:

- Cursor `thermo-nuclear-code-quality-review`: strict maintainability, abstraction quality, file-size, and spaghetti-growth review.
- Addy Osmani `code-review-and-quality`: multi-axis review covering correctness, readability, architecture, security, performance, tests, and verification.

## Target Selection

Infer the review target from the user's `/review` arguments:

1. **No arguments**: review all uncommitted local changes, including staged and unstaged changes.
2. **`--staged` / `staged`**: review staged changes only (`git diff --cached`).
3. **`--unstaged` / `unstaged`**: review unstaged changes only (`git diff`).
4. **`--commit <rev>` / `commit <rev>`**: review one commit (`git show --stat --find-renames <rev>` and `git show --find-renames --format=fuller <rev>`).
5. **`--range <range>` / `range <range>`**: review a commit range (`git diff --stat <range>` and `git diff --find-renames <range>`). Examples: `main...HEAD`, `HEAD~3..HEAD`.
6. **PR URL or `pr <number>` / `--pr <number>`**: review a GitHub PR using `gh` when available:
   - `gh pr view <number-or-url> --json number,title,body,author,baseRefName,headRefName,mergeable,additions,deletions,changedFiles,commits,files,reviews,comments`
   - `gh pr diff <number-or-url> --patch`
   - If `gh` is unavailable or unauthenticated, ask the user for a diff or fetch the PR through available means.
7. **Plain git rev/range**: if an argument looks like a rev or range, inspect with `git rev-parse` / `git diff` and use the best matching mode.

If the target is ambiguous in a way that changes the review materially, ask one concise clarifying question.

## Required Context Gathering

Before reviewing, gather enough context to understand intent and risk:

- `git status --short --branch`
- For local changes: relevant `git diff --stat`, staged/unstaged stats, and patch.
- For commits/ranges: commit messages plus diff stats and patch.
- For PRs: PR title/body, base/head, changed files, diff, and any available test/verification notes.
- Read nearby files when a diff hunk lacks enough architectural context.
- Read project instructions (`AGENTS.md`, equivalent) when present.
- Check file sizes for changed files, especially files near or over 1000 lines.

Do not rely only on diff snippets when a finding depends on surrounding code or ownership boundaries.

## Core Review Standard

Perform a deep code-quality audit of the target changes. Rethink how to structure or implement the changes to meaningfully improve code quality without changing behavior. Work to improve abstractions, modularity, succinctness, legibility, and maintainability.

Be ambitious: actively search for "code judo" moves that preserve behavior while making the implementation dramatically simpler, smaller, more direct, and more inevitable in hindsight.

## Non-Negotiable Standards

1. **Be ambitious about structural simplification.**
   - Do not stop at "this could be a bit cleaner."
   - Look for ways to make whole branches, helpers, modes, conditionals, or layers disappear.
   - Prefer deleting complexity over rearranging it.

2. **Block spaghetti growth.**
   - Treat ad-hoc conditionals, scattered special cases, nullable modes, and one-off flags in unrelated flows as design problems.
   - Prefer dedicated abstractions, state models, policy objects, pure helpers, or better ownership boundaries.

3. **Watch file-size cliffs.**
   - A change pushing a file from under 1000 lines to over 1000 lines is a presumptive blocker unless strongly justified.
   - Prefer decomposition into focused helpers, modules, or components.

4. **Prefer direct, boring, maintainable code.**
   - Flag brittle magic, generic handling that hides simple assumptions, pass-through wrappers, identity abstractions, and cleverness that obscures intent.

5. **Push type and boundary cleanliness.**
   - Question unnecessary optionality, `any`, `unknown`, casts, untyped maps, and silent fallbacks that paper over unclear invariants.
   - Prefer explicit models and canonical contracts.

6. **Keep logic in the canonical layer.**
   - Flag feature logic leaking into shared paths, bespoke helpers duplicating existing utilities, and package/layer drift.

7. **Prefer simple orchestration and atomic updates.**
   - Flag unnecessary serialization of independent work when parallelism would simplify the flow.
   - Flag partial-update paths that can leave state half-applied.

8. **Review tests and verification as behavior evidence.**
   - Tests should cover behavior, edge cases, and regressions, not just implementation details.
   - Passing tests are necessary but not sufficient for approval when behavior was not actually exercised.

## Multi-Axis Checks

Evaluate each meaningful change across:

- **Correctness**: requirements match, edge cases, error paths, state consistency, races, off-by-one errors.
- **Maintainability/readability**: directness, naming, scanability, local reasoning, dead code, comments that explain non-obvious intent.
- **Architecture**: ownership, boundaries, cohesion, dependencies, consistency with existing patterns.
- **Security**: secrets, injection, authz/authn, input validation, unsafe deserialization, external data trust boundaries.
- **Performance**: N+1 patterns, unbounded loops/fetches, avoidable hot-path allocation, UI rerender traps, unnecessary sequential async.
- **Verification**: regression tests, builds, manual checks, screenshots/API evidence when relevant.

## What to Flag Aggressively

- A complicated implementation where a cleaner reframing could delete categories of complexity.
- Refactors that move code around without reducing concepts a reader must hold.
- New conditionals bolted onto already busy paths.
- Feature-specific logic scattered through shared modules.
- Thin wrappers, identity abstractions, cast-heavy contracts, and optionality churn.
- Duplicated logic or bespoke utilities where canonical helpers exist.
- Large files/components growing instead of being decomposed.
- Error handling that silently falls back rather than making invariants explicit.
- Tests that assert mocks/internal calls but not user-visible behavior.
- Missing migration/legacy/empty-state handling for stateful changes.
- Missing verification story for risky behavior.

## Preferred Remedies

Prefer actionable suggestions such as:

- Delete a layer of indirection rather than polishing it.
- Reframe the state model so conditionals disappear.
- Move logic to the package/module/layer that owns the concept.
- Extract a pure helper or focused component.
- Replace condition chains with an explicit model or dispatcher.
- Collapse duplicate branches into a single clearer flow.
- Delete wrappers that do not clarify the API.
- Reuse existing canonical helpers.
- Make type boundaries explicit.
- Separate orchestration from business logic.
- Make related updates atomic or simplify independent parallel work.

## Review Tone

Be direct, serious, and demanding about quality. Do not be rude, but do not soften real maintainability issues into mild suggestions.

Useful phrasing:

- `this pushes the file past 1k lines. can we decompose this first?`
- `this adds another special-case branch into an already busy flow. can we move this behind its own abstraction?`
- `this works, but it makes the surrounding code more spaghetti. let's keep the behavior and restructure the implementation.`
- `this feels like feature logic leaking into a shared path. can we isolate it?`
- `this abstraction seems unnecessary. can we keep the direct flow?`
- `why does this need a cast/optional here? can we make the boundary explicit instead?`
- `this looks like a bespoke helper for something we already have elsewhere. can we reuse the canonical one?`
- `there may be a code-judo move here: can we reframe this so these branches disappear?`

## Output Format

Return a concise but rigorous review:

```markdown
## Review target
- Target: <uncommitted|staged|unstaged|commit|range|PR>
- Base/head or rev: <details>
- Files changed: <count/list summary>

## Verdict
<Request changes | Approve with comments | Looks good>

## Highest-impact findings

### 1. <required finding title>
- Severity: <Critical|Required|Important|Suggestion|Nit>
- Location: `<path>:<line or hunk>`
- Issue: <what is wrong and why it matters>
- Remedy: <specific structural/code-judo suggestion>
- Confidence: <High|Medium|Low>

## Secondary findings
<Only include if valuable; avoid cosmetic noise.>

## Verification gaps
- <tests/manual checks/builds missing or inadequate>

## Positive notes
- <briefly note strong structural choices, if any>
```

### Severity Rules

- **Critical**: likely production bug, data loss, security issue, or severe architectural regression.
- **Required**: must address before merge; includes structural regressions and obvious code-judo opportunities.
- **Important**: should address unless explicitly deferred with a good reason.
- **Suggestion**: optional improvement.
- **Nit**: cosmetic; avoid these unless the review is otherwise clean.

Do not flood the review with low-value nits when larger structural issues exist. Prefer a smaller number of high-conviction, actionable comments.

## Approval Bar

Do not approve merely because behavior seems correct or tests pass. Approval requires:

- no clear structural regression;
- no obvious missed dramatic simplification;
- no unjustified file-size explosion;
- no obvious spaghetti-growth from special-case branching;
- no hacky/magical abstraction that worsens reasoning;
- no unnecessary wrapper/cast/optionality churn obscuring the real design;
- no clear layer-boundary leak or canonical-helper duplication;
- adequate behavior-focused verification for the risk level.

If these conditions are not met, request changes with explicit, actionable feedback.


Review target arguments from the user:
$ARGUMENTS
