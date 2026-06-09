> **Trace.** On load, print first: `=============== [.lsa/modules/core/spec.md] [vision] ===============`

# Module Spec — `core`

The domain-neutral discipline plugin. Ships four skills + one always-on `CLAUDE.md` fragment.

**Plugin manifest:** [`core/.claude-plugin/plugin.json`](../../../core/.claude-plugin/plugin.json) (v0.11.2)
**Plugin README** (skill list, install): [`core/README.md`](../../../core/README.md)
**Always-on fragment** (canonical source): [`core/CLAUDE.md`](../../../core/CLAUDE.md)
**Per-skill behavior** (source of truth per skill): [`core/skills/*/SKILL.md`](../../../core/skills/)
**Verification probes:** [`core/VERIFICATION.md`](../../../core/VERIFICATION.md) and [`core/tests/repo-anchored.md`](../../../core/tests/repo-anchored.md)

## Role in the marketplace

`core` is the spine for any pack — domain-neutral discipline that applies regardless of whether `/src/` exists. Per `.lsa/VISION.md:73`: *"core/ (domain-neutral — always loaded; the spine for any pack)"*.

Four skills:

- `core/ground-rules` — four discipline rules every output follows.
- `core/output` — seven format rules in two postures: one **HARD** (Rule 4, Sourced / fact-grounding) + six **GUIDANCE** (Rules 1-3, 5-7, applied when they serve the answer). **Single marketplace-wide source-of-truth** — see Invariants below. Canonical clause + list at `core/skills/output/SKILL.md`.
- `core/actor-template` — the Goal / Input / Steps / Output / Constraints shape any Actor must follow.
- `core/flow-selector` (renamed from `core/tier-selector` in core v0.5.2) — pre-task chain-of-thought Quick / Standard / Extended classifier with visible reasoning.

The `core/CLAUDE.md` fragment is the **canonical source** for the always-on rules block (`ground-rules` + `output` + `flow-selector` invocation). Other locations (repo `CLAUDE.md`, READMEs) point to it rather than restating.

## Invariants

- **Versioning.** `core` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*).
- **Markdown-only.** No `/src/`; skills are pure Markdown. Per `.lsa/standards/code.md` *"Markdown-only"*.
- **Always-loadable on Claude.ai.** Skills upload one-by-one as zips per `core/README.md` *"Install on Claude.ai"*.
- **Spec source-of-truth.** Each skill's behavior is owned by its `SKILL.md`; this module spec carries module-level invariants only — not a per-skill catalog (that's `core/README.md`).
- **Output discipline canonical.** `core/skills/output/SKILL.md` is the marketplace-wide source-of-truth for output discipline. Every plugin cites it by markdown link; no plugin outside `core/` restates the rule count or rule names. Re-grounded summaries are permitted only when they cite the canonical file at the top (per `helper/knowledge/output-discipline.md:5` precedent). Enforced by `core/tests/repo-anchored.md` D2.
- **Rule 5 — Genuine-fork test.** A picker is justified only when at least one holds: (a) destructive write, (b) two named designs in scope and neither overrides the other, (c) a fact required by the next step is absent from working context and cannot be derived, (d) per-row triage. If none apply, deliver the cited answer directly and offer at most ONE closing picker for the user to override. Substrate selection (which primitive) is governed by `.lsa/VISION.md:66` Principle 9 — orthogonal to fork existence. Canonical statement at `core/skills/output/SKILL.md:39`; the `core/CLAUDE.md` Substrate-native checkpoint cites it as upstream gate.
- **Rule 6 — What-and-why preamble.** Every emission of a verdict label from `core/knowledge/output-vocabulary.md` §"Verdicts" is preceded in the same paragraph by a one-sentence preamble naming (a) the action in plain English in the user's frame, and (b) the concrete consequence if the human does not act. Canonical format: `<context sentence>. <VERDICT> verdict + <details>.` A bare verdict line fails this rule. Canonical statement at `core/skills/output/SKILL.md:42`; cited by all 4 LSA skills that emit verdicts (`lsa:init`, `lsa:reconcile`, `lsa:revise-constitution`, `lsa:verify`).
- **Rule 7 — Show changes inline.** Every write/edit/mark performed by an agent is echoed back inline before any commentary — *write → show → comment*. Generalizes the 8-element drift block from `lsa-reconcile` (user-endorsed gold standard 2026-05-22). 7-element single-change template (what / where / previous / new / reason / source / type tag) for ≤10-line changes; compressed inspection table for batches >5 files or >10 lines. Canonical statement at `core/skills/output/SKILL.md:51`; cited by 7 LSA skills across 16 Observable-result lines. The `core/CLAUDE.md` Operational checkpoint #4 cites this rule. **Enforcement-backed (core v0.10.0):** a *How this gets enforced* sub-section names two warning-only regression checks — `prompt-engineer:prompt-review` (author-time, scans prompt sources) and `lsa:verify` (PR-time, scans runtime artifacts) — plus the `lsa:reconcile` 8-element gold standard. LSA skill **step bodies** (not only Observable-result lines) now carry the quote-the-change instruction.

- **Hard vs guidance posture (core v0.11.0).** Only Rule 4 (Sourced — fact-grounding + file-load trace + citation format) is **hard** on every human-facing output. Rules 1-3, 5-7 are **guidance** — outcomes to aim for when they serve the answer, not a per-response checklist. Rule numbering is preserved (cross-files cite by number); a plugin MAY cite a guidance rule as load-bearing for its own output but MUST NOT re-promote it to a marketplace-wide hard requirement. Canonical split at `core/skills/output/SKILL.md` (HARD RULE / GUIDANCE sections); the `core/CLAUDE.md` checkpoints are re-tagged accordingly (file-load trace stays hard).

- **Fast-path navigation contract (core v0.9.0).** `core/knowledge/fast-path-source-of-truth.md` is the marketplace-wide single-source-of-truth navigation fast-path pattern: a navigation-class question resolves to one source-of-truth file → direct `Read` + cited `file:line` quote-back, no sub-agent / `context7` / multi-round `Grep`; exact-phrase detection (not semantic similarity); fall-through to the deep-research path on any miss. Cited by `lsa:next`, `management:roadmap`, the `project-manager` agent, and Helper's onboarding catalog.
