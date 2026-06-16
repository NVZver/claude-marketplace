# Conformance — Epic 2 manager rename

Verdict: **PASS** (doc-mode) — verified on branch `feature/manager-rename` independently of the implementer's report.

| Requirement | Satisfied by (verified) |
|---|---|
| R1 | `manager/` exists; `management/` gone (`git mv`, ≥74% rename similarity) |
| R2 | `manager/.claude-plugin/plugin.json` name=`manager`, version=`0.8.0` |
| R3 | `marketplace.json:22-24` `manager`; `.lsa.yaml:42` key `manager:` + artifact_paths under `manager/` |
| R4 | `.lsa/modules/manager/spec.md` exists; `.lsa/main.spec.md` index updated |
| R5 | `manager/skills/shape/SKILL.md` (name: shape, `/manager:shape`); `start-feature/` gone; `manager:roadmap` kept |
| R6 | zero `[management]` trace tags under `manager/`; headers read `[manager]` + `manager/...` |
| R7 | reference check: zero live `management/` path refs; remaining `management:` refs are all historical (shipped roadmap rows, 2026-05-26 backlog detail, one backlog-pitch problem-snapshot, rename-narrative) — excluded per No-go 3 |
| R8 | `manager/CHANGELOG.md:5` `[0.8.0]` entry; root + plugin + core + helper READMEs updated in the same commit |

## Acceptance
- Reference check (live artifacts): **clean**.
- `scripts/lint.sh`: **PASS** C1–C6.

## Notes
- Pre-1.0 minor bump for a breaking change (0.7.0 → 0.8.0), per the corrected versioning rule.
- Implementer ambiguities reviewed and accepted: `command-naming.md` anti-pattern now cites the live `manager:roadmap` (still a noun — the debt Epic 4 resolves); README anchor `#management` → `#manager` with dependent citations updated.
