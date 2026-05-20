# Module Spec — `core`

The domain-neutral discipline plugin. Ships three skills + one always-on `CLAUDE.md` fragment.

**Plugin manifest:** [`core/.claude-plugin/plugin.json`](../../../../core/.claude-plugin/plugin.json) (v0.2.0)
**Plugin README** (skill list, install): [`core/README.md`](../../../../core/README.md)
**Always-on fragment** (canonical source): [`core/CLAUDE.md`](../../../../core/CLAUDE.md)
**Per-skill behavior** (source of truth per skill): [`core/skills/*/SKILL.md`](../../../../core/skills/)
**Verification probes:** [`core/VERIFICATION.md`](../../../../core/VERIFICATION.md) and [`core/tests/repo-anchored.md`](../../../../core/tests/repo-anchored.md)

## Role in the marketplace

`core` is the spine for any pack — domain-neutral discipline that applies regardless of whether `/src/` exists. Per `vision/VISION.md:73`: *"core/ (domain-neutral — always loaded; the spine for any pack)"*.

Three skills:

- `core/ground-rules` — four discipline rules every output follows.
- `core/actor-template` — the Goal / Input / Steps / Output / Constraints shape any Actor must follow.
- `core/tier-selector` — pre-task chain-of-thought T1 / T2 / T3 classifier with visible reasoning.

The `core/CLAUDE.md` fragment is the **canonical source** for the always-on rules block (`ground-rules` + `tier-selector` invocation). Other locations (repo `CLAUDE.md`, READMEs) point to it rather than restating.

## Invariants

- **Versioning.** `core` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*).
- **Markdown-only.** No `/src/`; skills are pure Markdown. Per `vision/specs/standards/code.md` *"Markdown-only"*.
- **Always-loadable on Claude.ai.** Skills upload one-by-one as zips per `core/README.md` *"Install on Claude.ai"*.
- **Spec source-of-truth.** Each skill's behavior is owned by its `SKILL.md`; this module spec carries module-level invariants only — not a per-skill catalog (that's `core/README.md`).
