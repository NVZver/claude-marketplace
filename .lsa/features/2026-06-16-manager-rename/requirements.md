# Epic 2 — Atomic `management` → `manager` rename

## Summary
The critical-path epic of `function-command-naming-and-manager-rename`: rename the plugin
directory, namespace, manifests, module spec, and all live cross-references in one atomic pass
(clean break, no aliases). Keep `roadmap` 3-in-1 for now (Epic 4 splits it); rename
`start-feature` → `shape`. Pre-1.0 breaking change → **minor** bump (0.7.0 → 0.8.0).
Parent: `.lsa/pitches/function-command-naming-and-manager-rename.md` (Epic 2)

## Functional requirements (doc-mode — about the artifacts)
- R1. `management/` SHALL be renamed to `manager/` (history-preserving `git mv`); `management/` gone.
- R2. `manager/.claude-plugin/plugin.json` `name` SHALL be `manager`; version `0.7.0` → `0.8.0`.
- R3. `.claude-plugin/marketplace.json` + `.lsa.yaml` (module key + artifact_paths) SHALL read `manager`.
- R4. `.lsa/modules/management/spec.md` SHALL move to `.lsa/modules/manager/spec.md`; `.lsa/main.spec.md` index updated.
- R5. `skills/start-feature/` SHALL become `skills/shape/`; command `manager:shape`. `roadmap` kept as `manager:roadmap`.
- R6. Every trace header under `manager/` SHALL read `[manager]` with the `manager/...` path.
- R7. All LIVE cross-references SHALL read `manager` (identity tokens); generic domain prose ("management discipline") and historical records (CHANGELOG history, `.lsa/archive/**`, shipped roadmap rows, the rename-narrative pitch) stay.
- R8. Per-plugin CHANGELOG `[0.8.0]` entry + README deltas in the same commit.

## Acceptance
- Reference check: zero broken `management:*` / `management/` refs in LIVE artifacts (history excluded).
- `scripts/lint.sh` passes C1–C6. Plugin loads under the `manager` namespace.

## Out of scope
- `roadmap` 3-in-1 split (Epic 4); `manager:implement` stub (Epic 3).
