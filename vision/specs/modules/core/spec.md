> **Trace.** On load, print first: `=============== [vision/specs/modules/core/spec.md] [vision] ===============`

# Module Spec — `core`

The domain-neutral discipline plugin. Ships three skills + one always-on `CLAUDE.md` fragment.

**Plugin manifest:** [`core/.claude-plugin/plugin.json`](../../../../core/.claude-plugin/plugin.json) (v0.7.0)
**Plugin README** (skill list, install): [`core/README.md`](../../../../core/README.md)
**Always-on fragment** (canonical source): [`core/CLAUDE.md`](../../../../core/CLAUDE.md)
**Per-skill behavior** (source of truth per skill): [`core/skills/*/SKILL.md`](../../../../core/skills/)
**Verification probes:** [`core/VERIFICATION.md`](../../../../core/VERIFICATION.md) and [`core/tests/repo-anchored.md`](../../../../core/tests/repo-anchored.md)

## Role in the marketplace

`core` is the spine for any pack — domain-neutral discipline that applies regardless of whether `/src/` exists. Per `vision/VISION.md:73`: *"core/ (domain-neutral — always loaded; the spine for any pack)"*.

Four skills:

- `core/ground-rules` — four discipline rules every output follows.
- `core/output` — five format golden rules every human-facing output follows. **Single marketplace-wide source-of-truth** — see Invariants below. Canonical clause + list at `core/skills/output/SKILL.md`.
- `core/actor-template` — the Goal / Input / Steps / Output / Constraints shape any Actor must follow.
- `core/flow-selector` (renamed from `core/tier-selector` in core v0.5.2) — pre-task chain-of-thought Quick / Standard / Extended classifier with visible reasoning.

The `core/CLAUDE.md` fragment is the **canonical source** for the always-on rules block (`ground-rules` + `output` + `flow-selector` invocation). Other locations (repo `CLAUDE.md`, READMEs) point to it rather than restating.

## Invariants

- **Versioning.** `core` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*).
- **Markdown-only.** No `/src/`; skills are pure Markdown. Per `vision/specs/standards/code.md` *"Markdown-only"*.
- **Always-loadable on Claude.ai.** Skills upload one-by-one as zips per `core/README.md` *"Install on Claude.ai"*.
- **Spec source-of-truth.** Each skill's behavior is owned by its `SKILL.md`; this module spec carries module-level invariants only — not a per-skill catalog (that's `core/README.md`).
- **Output discipline canonical.** `core/skills/output/SKILL.md` is the marketplace-wide source-of-truth for output discipline. Every plugin cites it by markdown link; no plugin outside `core/` restates the rule count or rule names. Re-grounded summaries are permitted only when they cite the canonical file at the top (per `helper/knowledge/output-discipline.md:5` precedent). Enforced by `core/tests/repo-anchored.md` D2.
- **Rule 5 — Genuine-fork test.** A picker is justified only when at least one holds: (a) destructive write, (b) two named designs in scope and neither overrides the other, (c) a fact required by the next step is absent from working context and cannot be derived, (d) per-row triage. If none apply, deliver the cited answer directly and offer at most ONE closing picker for the user to override. Substrate selection (which primitive) is governed by `vision/VISION.md:66` Principle 9 — orthogonal to fork existence. Canonical statement at `core/skills/output/SKILL.md:39`; the `core/CLAUDE.md` Substrate-native checkpoint cites it as upstream gate.
- **Rule 6 — What-and-why preamble.** Every emission of a verdict label from `core/knowledge/output-vocabulary.md` §"Verdicts" is preceded in the same paragraph by a one-sentence preamble naming (a) the action in plain English in the user's frame, and (b) the concrete consequence if the human does not act. Canonical format: `<context sentence>. <VERDICT> verdict + <details>.` A bare verdict line fails this rule. Canonical statement at `core/skills/output/SKILL.md:42`; cited by all 5 LSA skills that emit verdicts (lsa-init, lsa-reconcile, lsa-sync, lsa-revise-constitution, lsa-verify).
