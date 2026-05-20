# Module Spec — `lsa`

The Living Spec Architecture plugin. Eight skills + one SessionStart hook + a config schema.

**Plugin manifest:** [`lsa/.claude-plugin/plugin.json`](../../../../lsa/.claude-plugin/plugin.json) (v0.2.1)
**Plugin README** (skill table, install, configuration): [`lsa/README.md`](../../../../lsa/README.md)
**Architecture** (directory structure, `.lsa.yaml` schema, branch management, resolved decisions): [`lsa/ARCHITECTURE.md`](../../../../lsa/ARCHITECTURE.md)
**Per-skill behavior** (source of truth per skill): [`lsa/skills/*/SKILL.md`](../../../../lsa/skills/)

## Role in the marketplace

`lsa` is the spec-first methodology pack — humans write and own specs; agents write and own artifacts; the **reconcile loop** absorbs direct artifact edits rather than blocking them (Level 2.5, `vision/VISION.md:138`). Depends on `core` (`lsa/README.md` *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy.
- `core/tier-selector` — orchestration handoff upstream of `lsa-discover` for every T2 / T3 task.
- `core/actor-template` — the Goal/Input/Steps/Output/Constraints shape every LSA skill body matches.

## State files

| File | Owner | Purpose |
|---|---|---|
| `.lsa.yaml` | Human (or `lsa-init`) | Path + mode + module config. |
| `.lsa-sync-state.json` | `lsa-sync` (write); `lsa-reconcile` (write on confirm) | Per-module last-sync SHA + ISO timestamp. Consumed by the SessionStart drift hook and by `lsa-reconcile`'s diff base. |
| `${specs_root}/archive/<feature>/metrics.md` | `lsa-verify` (write on clean T3 PASS) | Per-feature metric counts (accuracy / facts / only-required-changes). |
| `${specs_root}/metrics.md` | `lsa-sync` (append) | Aggregate row per archived T3 feature. Optional. |

## Invariants

- **Versioning.** `lsa` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*). Currently v0.2.1.
- **Markdown + small JSON / YAML / bash surface.** No `/src/`. Plugin manifest is JSON; config is YAML; hook is bash. Per `vision/specs/standards/code.md`.
- **Depends on `core` v0.2.0** for `tier-selector`. Documented in `lsa/.claude-plugin/plugin.json: description` and `lsa/README.md` *"Depends on"*.
- **Spec source-of-truth.** Each skill's behavior is owned by its `SKILL.md`; this module spec carries module-level invariants only — not a per-skill catalog (that's `lsa/README.md`).
- **Reconcile is absorptive, not blocking** (`vision/VISION.md:144`). The `lsa-reconcile` skill never blocks, reverts, or reformats artifact edits.
