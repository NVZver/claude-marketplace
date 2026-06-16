# Conformance — Epic 4 roadmap verb split

Verdict: **PASS** (doc-mode) — verified on branch `feature/roadmap-verb-split`.

| Requirement | Satisfied by (verified) |
|---|---|
| R1 | `manager/knowledge/roadmap-orchestration.md` — shared dispatch→gate→re-render contract; cited by the 3 skills |
| R2 | `manager/skills/next/SKILL.md` (`manager:next`) — Step 0 fast-path + dispatch (intent recommend/sequence); no handoff |
| R3 | `manager/skills/decompose/SKILL.md` (`manager:decompose <pitch>`) — dispatch (intent decompose) + staged `lsa:discover` handoff |
| R4 | `manager/skills/check/SKILL.md` (`manager:check`) — dispatch (intent hygiene), gates row diffs; no handoff |
| R5 | `manager/skills/roadmap/SKILL.md` removed (`git rm`; empty dir gone) |
| R6 | one `project-manager` agent shared; each skill passes explicit intent; agent behavior unchanged |
| R7 | zero live `manager:roadmap` refs (verified by grep); shape handoff → `manager:decompose`; README, module spec, marketplace.json, knowledge/index.md, helper onboarding-fast-path, core fast-path-source-of-truth + README all updated to the context-correct verb |
| R8 | `command-naming.md` anti-pattern reframed as realized before→after (now resolved) |
| R9 | `manager/CHANGELOG.md` `[0.9.0]`; version 0.8.0 → 0.9.0; READMEs same commit |

## Acceptance
- Reference check: zero live `manager:roadmap` references. `scripts/lint.sh`: **PASS** C1–C6.
- Verb-style descriptions confirmed (Recommend / Decompose / Check).

## Extras folded in (verified, beyond R-list)
- Closed a pre-existing gap the implementer flagged: `command-naming.md` (Epic 1) was missing from
  `knowledge/index.md` — added it; catalog count 16 → 17.
- `core/README.md` + `.lsa/modules/core/spec.md` fast-path caller refs → `manager:next` (live refs, not in R7's enumerated set).
