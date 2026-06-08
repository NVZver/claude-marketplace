> **Trace.** On load, print first: `=============== [core/knowledge/fast-path-source-of-truth.md] [core] ===============`

# Fast-path: single-source-of-truth navigation — knowledge

A navigation-class question maps deterministically to **one** source-of-truth file at a known path with **one** canonical answer (e.g., "what's next" → the roadmap's Feature Backlog table; "how do I get started" → a named README section). For these, the agent reads the file directly and quotes the answer back with a citation — it does **not** spawn a sub-agent, run a `context7` lookup, or do multi-round `Grep`. This is the shared contract every fast-path caller cites.

This file is the canonical statement of the pattern. The first shipped instance — Helper's onboarding catalog at [`../../helper/knowledge/onboarding-fast-path.md`](../../helper/knowledge/onboarding-fast-path.md) — predates this file and is the worked reference for the matching/fall-through discipline below.

## The pattern shape

1. **Detect** a navigation-class question by exact-phrase shape (see §"Question-shape detection").
2. **Resolve** it to its single source-of-truth file + the specific anchor inside that file (a heading anchor, a named table, a column position).
3. **Read** that file directly with the substrate's `Read` primitive. One bounded read — do not exhaust the codebase.
4. **Quote** the answer back inline with a `file:line` citation (see §"Citation format").
5. **Close** the turn in seconds. No sub-agent dispatch, no `context7`, no multi-round `Grep`, no caching/indexing — the read happens on every call.

If any step cannot complete, fall through (see §"Fall-through rule"). Never fabricate an answer from a partial read.

## Question-shape detection — exact-phrase first, NOT semantic similarity

Match on the **shape of the question**, anchored to a small set of exact phrases, before any semantic interpretation:

- "what's next" / "what should I work on next" / "what's the next backlog item" → roadmap fast-path.
- "how do I get started" / "what is X" (for a canonical subject) → onboarding fast-path (Helper).

The discipline is: **a near-miss falls through; it does not get force-fit.** Misclassifying a deep-research question as a fast-path returns a cheap wrong answer, which is worse than a slow correct one. When the phrasing is unknown, ambiguous, or carries extra intent the source-of-truth file cannot answer ("what's next **and why that order**", "recommend an ordering"), do not fast-path — fall through to the deep-research path. One bounded classification pass: match or no-match, no chain-of-thought scaffolding.

## Fall-through rule — any failure routes to the deep-research path, no regression

The fast-path **adds**; it never narrows. Fall through to the caller's existing deep-research logic — unchanged — when ANY of:

- **No shape match.** The question does not match a known navigation phrase.
- **Source-of-truth file missing or empty.** The expected file does not exist or holds no answer.
- **Anchor missing at runtime.** The cited heading/table/column no longer resolves (renamed, deleted, format drift). Emit an observable note ("`## Feature Backlog` not found — falling through") rather than guessing.
- **Question carries extra intent.** The phrasing matches but asks for reasoning, ordering, or analysis the single file cannot supply.

Fall-through is silent to the user except for the observable note on anchor-missing. The deep-research path (sub-agent dispatch, `context7`, multi-round `Grep`) is the backstop and is never modified by adopting this pattern.

## Citation format — `file:line` quote-back

Every fast-path answer carries the source inline: a verbatim quote of the answering line(s) plus a `file:line` (or `file#heading-anchor`) citation the reader can locate in seconds. This inherits [`../skills/output/SKILL.md`](../skills/output/SKILL.md) Rule 4 (Sourced) and Rule 7 (Show changes inline — quote before commentary), and [`../skills/ground-rules/SKILL.md`](../skills/ground-rules/SKILL.md) Rule 1 (every factual claim carries a source + searchable quote). A fast-path answer without a verbatim quote-back fails the pattern.

## Callers

| Caller | Source-of-truth file | Trigger shape |
|---|---|---|
| [`../../lsa/skills/next/SKILL.md`](../../lsa/skills/next/SKILL.md) | `${specs_root}/roadmap.md` §`## Feature Backlog` | "what's next" |
| [`../../management/skills/roadmap/SKILL.md`](../../management/skills/roadmap/SKILL.md) | `${specs_root}/roadmap.md` §`## Feature Backlog` | "what's next" (reserves full dispatch for "recommend an order") |
| [`../../management/agents/project-manager.md`](../../management/agents/project-manager.md) | `${specs_root}/roadmap.md` §`## Feature Backlog` | "what's next" (early-exit on direct invocation) |
| [`../../helper/knowledge/onboarding-fast-path.md`](../../helper/knowledge/onboarding-fast-path.md) | named `README.md` heading anchors | install / start / what-is-X |
