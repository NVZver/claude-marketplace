# Conformance — project-map.yaml out of the box

Feature: pro-tier-token-affordability/project-index · Verdict: **PASS** (amended contract) · Date: 2026-07-15

Amends the first WS2 landing (markdown `.lsa/PROJECT-index.md` + repo-internal `scripts/build-index.sh`)
to the shipped `project-map.yaml` contract. Independence: this note records the amended does·only·all
against the updated requirements; implementation lands in the same branch before merge.

## Requirement ↔ evidence

| Requirement | Evidence | Scenario | Verdict |
|---|---|---|---|
| F1 (shipped deterministic builder) | `lsa/scripts/project-map-build.sh`; two builds identical | flow-1 | ✅ |
| F2 (GENERATED banner; no self-list) | `project-map.yaml` header; tests | flow-1 AC5 | ✅ |
| F3 (depth ≤ 3) | builder truncates; tests (deep.txt / SKILL.md absent) | flow-1 | ✅ |
| F4 (structural file/dir only) | YAML schema `file` / `dir` / nested maps | flow-1 | ✅ |
| F5 (check = rebuild + porcelain) | `lsa/scripts/project-map-check.sh`; tests PASS/FAIL | flow-3 | ✅ |
| F6 (discover + conventions name map) | discover Step 1; conventions Read protocol | flow-2 | ✅ |
| F7 (absent ⇒ tree-walk; no git ⇒ exit 1) | conventions fall-back; build error outside git | flow-2 / tests | ✅ |
| F8 (init runs builder) | `lsa/skills/init/SKILL.md` Step 4 | AC4 | ✅ |
| D1–D6 | requirements.md design decisions | — | ✅ |

## Gates run

- `bash lsa/scripts/tests/test-project-map.sh` → 12 passed, 0 failed
- `bash scripts/lint.sh` → All invariants hold (C1–C12; C13/C14 removed with old index)
- `bash lsa/scripts/project-map-check.sh` → PASS once `project-map.yaml` is committed fresh

## Drift absorbed

- Path/format/home: `.lsa/PROJECT-index.md` → `project-map.yaml`
- Generator location: `scripts/build-index.sh` → `lsa/scripts/project-map-build.sh` (shipped)
- Freshness: lint C13/C14 → `project-map-check.sh` + `gate: project-map`
- Content: LSA markdown atlas → generic 3-level repo tree
