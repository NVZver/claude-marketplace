> **Trace.** On load, print first: `=============== [vision/specs/modules/lsa/spec.md] [vision] ===============`

# Module Spec — `lsa`

The Living Spec Architecture plugin. Eight skills + one SessionStart hook + a config schema.

**Plugin manifest:** [`lsa/.claude-plugin/plugin.json`](../../../../lsa/.claude-plugin/plugin.json) (v0.7.1)
**Plugin README** (skill table, install, configuration): [`lsa/README.md`](../../../../lsa/README.md)
**Architecture** (directory structure, `.lsa.yaml` schema, branch management, resolved decisions): [`lsa/ARCHITECTURE.md`](../../../../lsa/ARCHITECTURE.md)
**Per-skill behavior** (source of truth per skill): [`lsa/skills/*/SKILL.md`](../../../../lsa/skills/)

## Role in the marketplace

`lsa` is the spec-first methodology pack — humans write and own specs; agents write and own artifacts; the **reconcile loop** absorbs direct artifact edits rather than blocking them (Level 2.5, `vision/VISION.md:138`). Depends on `core` (`lsa/README.md` *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy.
- `core/flow-selector` (renamed from `core/tier-selector` in core v0.5.2) — orchestration handoff upstream of `lsa-discover` for every Standard / Extended task (was `T2 / T3`).
- `core/actor-template` — the Goal/Input/Steps/Output/Constraints shape every LSA skill body matches.

## State files

| File | Owner | Purpose |
|---|---|---|
| `.lsa.yaml` | Human (or `lsa-init`) | Path + mode + module config. |
| `.lsa-sync-state.json` | `lsa-sync` (write); `lsa-reconcile` (write on confirm) | Per-module last-sync SHA + ISO timestamp. Consumed by the SessionStart drift hook and by `lsa-reconcile`'s diff base. |
| `${specs_root}/archive/<feature>/metrics.md` | `lsa-verify` (write on clean Extended-flow PASS — was `T3`) | Per-feature metric counts (accuracy / facts / only-required-changes). |
| `${specs_root}/metrics.md` | `lsa-sync` (append) | Aggregate row per archived Extended-flow feature (was `T3`). Optional. |

## Invariants

- **Versioning.** `lsa` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*). Currently v0.7.1.
- **Markdown + small JSON / YAML / bash surface.** No `/src/`. Plugin manifest is JSON; config is YAML; hook is bash. Per `vision/specs/standards/code.md`.
- **Depends on `core` v0.5.2+** for `flow-selector` (added as `tier-selector` v0.2.0; renamed v0.5.2) and `core/output` (added v0.4.0; cited from every LSA skill per `lsa/CHANGELOG.md` [0.4.0]). Documented in `lsa/.claude-plugin/plugin.json: description` and `lsa/README.md` *"Depends on"*.
- **Spec source-of-truth.** Each skill's behavior is owned by its `SKILL.md`; this module spec carries module-level invariants only — not a per-skill catalog (that's `lsa/README.md`).
- **Reconcile is absorptive, not blocking** (`vision/VISION.md:144`). The `lsa-reconcile` skill never blocks, reverts, or reformats artifact edits.
- **`lsa-specify` User Verification 2 — diagonal cross-artifact coverage.** User Verification 2 renders a 4-row coverage table (AC→Journey, Journey→Design, Design→Contract, Contract→test-suites). Each row cites two artifact lines in `file:line` format; `✗` rows surface as Rule 6 decision blocks that block approval until resolved. Per `lsa/skills/lsa-specify/SKILL.md:154` (Step 5 body) and `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/`.
- **`lsa-specify` User Verification 2 — EARS + journey-shape rows.** User Verification 2 evaluates two additional rows: **1a** (EARS-pattern, per `vision/VISION.md:201`) and **1b** (Journey-shape, per `vision/VISION.md` §2 sub-principle 2a). Failing rows surface as Rule 6 decision blocks per the existing render. `lsa-plan` epics carry a `**Covers:** <ID>` line citing requirement IDs each epic implements; `lsa-verify` runs an orphan-diff predicate (broad — any requirement ID) and an orphan-AC predicate (narrow — behavior coverage). Per `lsa/skills/lsa-specify/SKILL.md` User Verification 2 body, `lsa/skills/lsa-plan/SKILL.md` epic template, `lsa/skills/lsa-verify/SKILL.md` Scope checklist, and `vision/specs/archive/2026-05-21-ears-journey-shape-ac/`.
- **Genuine-fork test applied to LSA pickers.** Three LSA skills apply `core/output` Rule 5 Genuine-fork test: `lsa-discover` skips the per-line picker when Step 1 yields a single unambiguous candidate AND no `custom` is requested; `lsa-sync`'s post-completion PR-or-hold picker is an optional closing offer with silent-default = `hold`; `lsa-verify`'s verdict-picker prompts name the verdict in the subject (*"Verdict: PASS — sync now?"* etc). Per `lsa/skills/lsa-discover/SKILL.md` Step 2, `lsa/skills/lsa-sync/SKILL.md` Step 8, `lsa/skills/lsa-verify/SKILL.md` Step 4–5.
