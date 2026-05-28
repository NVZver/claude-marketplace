# Metrics — diagonal-cross-artifact-analysis

**Feature archived:** 2026-05-21
**Verified by:** lsa-verify (clean PASS at commit 9fb2e65)
**Branch at verify time:** feature/diagonal-cross-artifact-analysis

## Accuracy to the task

- ACs declared: 6 (`.lsa/features/diagonal-cross-artifact-analysis/requirements.md` § Acceptance Criteria — AC1 through AC6, AC6 added retroactively at commit 16b2a6f to close lsa-verify W1)
- ACs satisfied: 6 (every AC implemented and traced — AC1–AC4 by E1, AC5 by E1+E2, AC6 by the findings.md commit 70437d0)
- **Score:** 6/6 = 1.00

## Proven facts with sources

- Factual claims in feature spec: ~60 (estimated across `requirements.md`, `test-suites.md`, `design.md`, `tasks.md`, `findings.md`, `discovery.md` — counts every substantive fact-claim about repo state, external SemVer/Keep-a-Changelog conventions, or in-repo file paths)
- Claims with valid source + searchable quote: 57 (46 `file:line` citations + 7 `Per …` / `Source:` references + 4 honest-fallback markers `[illustrative]` / `[unverified]`)
- **Score:** 57/60 ≈ 0.95
- **Note:** the 3-claim gap is approximate — a rigorous count would re-grep each file and adjudicate per-sentence; deferred per the test-skill `.lsa/standards/testing.md` *"Statistical eval explicitly deferred"*. Pass/fail count is honest.

## Only-required-changes

- Files in `artifact_paths` changed: 3 (`lsa/skills/lsa-specify/SKILL.md`, `lsa/.claude-plugin/plugin.json`, `lsa/README.md`)
- Files covered by an AC or `tasks.md` epic: 3 (`lsa/skills/lsa-specify/SKILL.md` ← E1; `lsa/.claude-plugin/plugin.json` ← E3.AC3.1; `lsa/README.md` ← E3.AC3.3)
- **Score:** 3/3 = 1.00

### Off-metric: scope-creep observation (for transparency)

The strict metric above counts only `artifact_paths`-resident files (per `.lsa.yaml:9-26`). The full feature-branch diff included 13 files; 10 fall outside `artifact_paths` (feature spec dir × 7, `.lsa/main.spec.md`, `.lsa/modules/lsa/spec.md`, root `README.md`). Of these 10:

- 9 are covered by tasks.md (feature spec dir is written by `lsa-specify`/`lsa-plan`; main.spec.md + module spec edits are explicit E3 + E2 deliverables).
- 1 (root `README.md`) is from user direct commit `ea820a1` — kept on branch per user choice (`docs(readme): drop overclaim, fix core skill count, sharpen substrate`). Out of this feature's declared scope; will be noted in the PR description.

Across the full diff: 12/13 covered = 0.923. This wider measure surfaces what the strict artifact_paths metric hides (see Finding #12 in `findings.md`).

## Loop telemetry (dogfood meta)

| Phase | Cost | Notes |
|---|---|---|
| `core/tier-selector` | 1 question | T3 confirmed on first proposal |
| `lsa-discover` | 2 questions (change framing + AC framing) | discovery.md path contradiction surfaced (Finding #1) |
| `lsa-specify` Gate 1 | 1 question | requirements.md approved first try |
| `lsa-specify` Gate 2 | 1 question | test-suites.md + design.md approved first try; bonus diagonal probe ran inline |
| `lsa-specify` Gate 3 | 1 question | integration check approved first try |
| `lsa-plan` | 2 questions (plan approval + commit spec) | 3-epic decomposition; all parallel-safe; SemVer + staleness questions surfaced |
| E1 implementation | 0 questions | clean prose edit; commit + merge |
| E2 implementation | 0 questions | clean prose edit + version refresh; commit + merge |
| E3 implementation | 0 questions | SemVer + CHANGELOG + README + main.spec.md sync; commit + merge |
| `lsa-verify` round 1 | 1 question | PASS WITH WARNINGS (W1, W2); user picked "fix W1" |
| `lsa-verify` round 2 (post-AC6) | 1 question | PASS WITH WARNINGS (W2 only); user picked "fix W2" per zero-tech-debt feedback |
| `lsa-verify` round 3 (post-Probes A/B/C) | 1 question (+ ea820a1 handling) | clean PASS |
| **Total questions** | **11** | All gates confirmed by `AskUserQuestion`; zero auto-approvals |

13 findings + 2 verify warnings logged in `findings.md`. Closed in-feature: 3 findings (#3, #4, #7) + 2 warnings (W1, W2) = 5 items. Deferred to follow-up PRs: 10 findings (#1, #2, #5, #6, #8, #9, #10, #11, #12, #13).
