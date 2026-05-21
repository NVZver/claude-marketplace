# Feature: EARS + Journey-shape AC Discipline

## Summary

Tighten the LSA acceptance-criterion discipline along two axes — **pattern conformance** (EARS, five fixed patterns per `vision/VISION.md:201`) and **journey-shape** (each AC describes a user-observable behavior at the user/system boundary, not a unit-testable internal). `lsa-specify` Gate 2 surfaces violations as Rule 6 decision blocks; `lsa-verify` enforces 1:1 trace from every implementation diff to a specific EARS AC ID. Forward-only — existing specs under `vision/specs/archive/**/` are untouched. Implements the verdict at `vision/VISION.md:201` (*"A tightening, not a replacement"*) and the user constraint stated 2026-05-21 (*"ACs must reflect user flow or user journey; specific functionality checks are unit-testing"*).

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | `lsa-specify` Gate 1's `requirements.md` template writes the `## Acceptance Criteria` sub-block in EARS form per `vision/VISION.md:201`. | Must |
| F2 | `lsa-specify` Gate 2's diagonal coverage table gains two new rows: an **EARS-pattern row** (per F1) and a **journey-shape row** (per sub-principle 2a). | Must |
| F3 | When either new row fails (`✗`), Gate 2 renders a Rule 6 decision block per failing AC line with three resolutions: `[a]` rewrite in EARS / journey-shape, `[b]` move to unit-test scope, `[c]` custom. Approval is blocked until every `✗` is resolved — same pattern as the existing diagonal-coverage failing-row render (`lsa/skills/lsa-specify/SKILL.md:162-176`). | Must |
| F4 | `lsa-verify` FAILs if any non-trivial implementation diff hunk has no covering task→requirement-ID trace in `tasks.md` (field defined by F8). | Must |
| F5 | `lsa-verify` FAILs if any AC ID in `requirements.md` has zero covering implementation or test in the feature branch. | Must |
| F6 | `vision/VISION.md` carries a standing principle (added under §2 First Principles) that ACs in `requirements.md` are journey-shaped — observable at the user/system boundary, not unit-test scope. §6 Adjust #1 is marked **RESOLVED**, citing the new principle and this feature. | Must |
| F7 | The EARS + journey-shape rule applies **only** to `lsa-specify`'s AC sub-block. Other LSA skills (`lsa-revise-constitution`, `lsa-reconcile`, `lsa-init`, etc.) and other sub-blocks of `requirements.md` (Functional Requirements narrative, Non-Functional Requirements, Constraints) are unchanged. | Must |
| F8 | `lsa-plan`'s epic template gains a `**Covers:** <ID>, <ID>` line under each epic's `### Scope` section, citing any `requirements.md` requirement IDs (`F<n>`, `NF<n>`, or `AC<n>`) the epic implements. Parallel to the `**Covers:**` line on `test-suites.md` Journeys at `lsa/skills/lsa-specify/SKILL.md:93`. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | **Forward-only.** No `requirements.md` under `vision/specs/archive/**/` is modified. Existing archived specs keep their GWT-style ACs. (Per `vision/specs/main.spec.md` NFR2 spec-grounding, the rule applies to new specs only.) |
| NF2 | **Fact-grounding** (`vision/specs/main.spec.md` NFR1). Every Gate 2 `✗` row cites the offending AC line in `file:line` format per `core/ground-rules` Rule 1. |
| NF3 | **Per-plugin SemVer + CHANGELOG** (`vision/specs/main.spec.md` NFR3). `lsa` plugin bumps v0.5.0 → v0.6.0 (minor — new gate behavior, no breaking surface) in the same commit as the `lsa/CHANGELOG.md` entry. |
| NF4 | **Knowledge vs Actor** (`vision/specs/main.spec.md` NFR5). The EARS pattern list and the journey-shape definition live in `vision/VISION.md` (Knowledge / constitution); `lsa-specify` and `lsa-verify` SKILL bodies cite the principle by `file:line` rather than restating it. |

## Inputs & Outputs

- **Input:** Human-authored `requirements.md` AC sub-block in any candidate form (EARS-conformant or not; journey-shaped or unit-shaped). Implementation diff on a feature branch.
- **Output:** Approved `requirements.md` whose AC sub-block is 100% EARS-form and 100% journey-shaped; `lsa-verify` reports that trace every non-trivial diff hunk to a specific AC ID and that flag every AC missing implementation/test coverage.
- **Side effects:** see `design.md` § Modules Affected + § Technical Approach.

## Constraints

- **Substrate-native first** (`vision/VISION.md:63` principle 9). Gate 2 decision blocks use `AskUserQuestion`; failing rows batch into a single multi-question call per the existing pattern in `lsa/skills/lsa-specify/SKILL.md:174`.
- **Ownership over automation** (`vision/VISION.md:55` principle 1a). Gate 2's pattern + shape check is agent-judged but human-confirmed via Rule 6; no automated rewriter or auto-pass.
- **Read before write** (`vision/VISION.md:60` principle 6). `lsa-verify` consumes the existing task→AC-ID mapping in `tasks.md`; no new schema or migration.
- **Level 2.5 reconcile** (`vision/VISION.md:144`). The rule is forward-only; no existing artifact is blocked or reverted by this feature.

## Out of Scope

- Retrofit of `vision/specs/archive/**/requirements.md` (and any active feature spec authored before merge).
- Extraction of EARS into a separate `core` skill — only `lsa-specify` uses it; lives inline per F7.
- Automated EARS-pattern linter — pattern conformance is agent-judged at Gate 2.
- Schema change to `tasks.md` — only the single-line `**Covers:**` field is added per F8; existing fields untouched.
- Conversion of GWT prose outside the AC sub-block — `## Functional Requirements` narrative and elsewhere stays GWT-friendly per `vision/VISION.md:201` (*"A tightening, not a replacement"*).

## Acceptance Criteria

- [ ] **AC1.** While a human authors a new feature spec in `lsa-specify`, when the `## Acceptance Criteria` sub-block of `requirements.md` contains a line that does not match one of the five EARS patterns, the system shall surface the offending line at Gate 2 in a Rule 6 decision block (`[a]` rewrite in EARS / `[b]` move to unit-test scope / `[c]` custom) and block approval until the human resolves the line.
- [ ] **AC2.** While a human authors a new feature spec in `lsa-specify`, when the `## Acceptance Criteria` sub-block contains a line that names an internal function/method or describes correctness of a non-user-observable computation (failing the journey-shape rule), the system shall surface the offending line at Gate 2 in a Rule 6 decision block (`[a]` rewrite in journey-shape / `[b]` move to unit-test scope / `[c]` custom) and block approval until the human resolves the line.
- [ ] **AC3.** When a human runs `lsa-verify` on a completed feature branch and any non-trivial implementation diff hunk has no task→requirement-ID trace in `tasks.md` (per F8), the system shall FAIL the verification with a `file:line` citation per `core/ground-rules` Rule 1.
- [ ] **AC4.** When a human runs `lsa-verify` on a completed feature branch and any AC ID in `requirements.md` has zero covering implementation or test, the system shall FAIL the verification with a `file:line` citation per `core/ground-rules` Rule 1.
