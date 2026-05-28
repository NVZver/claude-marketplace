# Feature: Diagonal Cross-Artifact Analysis at `lsa-specify` Gate 2

## Summary

Extend `lsa-specify` Gate 2 from the single AC→Journey coverage check (current at `lsa/skills/lsa-specify/SKILL.md:154`) to a 4-row diagonal coverage table covering AC→Journey, Journey→Design, Design→Contract, and Contract→test-suites. Each row cites the two specific artifact lines compared. Failing rows surface as Rule 6 decision blocks that block approval until the human picks `[a] revise X / [b] revise Y / [c] custom`. Adopted via the 2026-05-20 Tech Picture (`.lsa/roadmap.md:64-75`).

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | Gate 2 prints a 4-row coverage table — one row per artifact pair: AC→Journey, Journey→Design, Design→Contract, Contract→test-suites. | Must |
| F2 | Each row contains: pair name, status (`✓` / `✗` / `N/A`), and citation of the two specific artifact lines compared (`file:line` format). | Must |
| F3 | Any `✗` row surfaces as a Rule 6 decision block — `[a] revise X / [b] revise Y / [c] custom` — and blocks approval until the human picks. | Must |
| F4 | When Gate 1 contract-trigger = no, the two contract-touching rows (Design→Contract, Contract→test-suites) render as `N/A — contract skipped`, not `✗`. | Must |
| F5 | The 4-row check runs in addition to the existing AC-coverage check; AC→Journey appears as the first row of the new table (the existing check is preserved as that row). | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Citations use absolute-from-repo-root `file:line` format so the reader can navigate in seconds. Per `core/skills/ground-rules/SKILL.md` Rule 1 ("a searchable quote — a short verbatim snippet the reader can locate in the source in seconds"). |
| NF2 | All failing rows are surfaced together in a single Gate 2 presentation (batch), with the human picking per row via a multi-question `AskUserQuestion` call. No drip-feed of one failure at a time. |

## Inputs & Outputs

- **Input:** the four (or three, if contract skipped) approved artifacts at Gate 2 fire time: `requirements.md` (AC block), `test-suites.md` (journey list), `design.md`, optional `contract.yaml`.
- **Output:** a 4-row markdown coverage table rendered inside the Gate 2 presentation, plus zero-to-four Rule 6 decision blocks (one per failing row).
- **Side effects:** none on the artifact files themselves — the gate reads them and renders a check. Files are only edited if the human picks `[a] revise X` or `[b] revise Y` in a decision block.

## Constraints

- **NFR1 — Fact-grounding** (`.lsa/main.spec.md:28`): every citation in the coverage table is a verifiable `file:line` pointer.
- **NFR5 — Knowledge vs Actor separation** (`.lsa/main.spec.md:32`): the new check is execution flow → lives in `lsa-specify`'s SKILL.md Steps, not in a Knowledge file.
- **`lsa` invariant — markdown + small JSON / YAML / bash surface only** (`.lsa/modules/lsa/spec.md:30`): no `/src/`. The gate logic is prose inside the SKILL body, not executable code.
- **Rule 6 of `core/ground-rules`**: the gate never auto-resolves a failed row — the human owns the reconciliation (`.lsa/roadmap.md:75`).

## Out of Scope

- **Live cross-artifact validation during edits.** The check is static at Gate 2 time only — not re-run on later edits unless Gate 2 fires again (B2 in clarification).
- **New sections in the artifact file templates.** `requirements.md`, `test-suites.md`, `contract.yaml`, `design.md` get no new sub-sections — the gate reads them more carefully, doesn't ask them to carry more (B1 in clarification).
- **Coverage diagonals beyond the four named pairs.** Other pairs (e.g., AC→Contract, AC→Design) are deferred to a future feature if pain materializes.
- **Changes to Gate 1 or Gate 3** of `lsa-specify`.
- **Backporting the check to archived features.** This feature changes future Gate 2 invocations only.

## Acceptance Criteria

- [ ] **AC1:** When `lsa-specify` reaches Gate 2 on any T3 feature, the gate output prints a 4-row coverage table — one row per artifact pair (AC→Journey, Journey→Design, Design→Contract, Contract→test-suites).
- [ ] **AC2:** Every passing row cites the two specific artifact lines compared in `file:line` format.
- [ ] **AC3:** Every failing row surfaces as a Rule 6 decision block with `[a] revise X / [b] revise Y / [c] custom`; approval is blocked until the human chooses.
- [ ] **AC4:** When `contract.yaml` is skipped (Gate 1 contract-trigger = no), the two contract-touching rows render as `N/A — contract skipped`, not `✗`.
- [ ] **AC5:** Both `lsa/skills/lsa-specify/SKILL.md` (Gate 2 step) and `.lsa/modules/lsa/spec.md` (Invariants section) document the new 4-row coverage shape.
- [ ] **AC6:** A `.lsa/features/diagonal-cross-artifact-analysis/findings.md` log is written capturing every dogfood finding surfaced during the loop, with each finding classified as either closed-in-feature or deferred. Added retroactively per the lsa-verify W1 warning (this feature is also a dogfood test of LSA itself; findings.md is the natural artifact of that test).

## Contract trigger check (per `lsa/skills/lsa-specify/SKILL.md:75`)

| Signal | Triggered? | Notes |
|---|---|---|
| API endpoint | no | No HTTP/REST surface. |
| Request/response schema | no | No wire-format schema. |
| DB schema/table change | no | No persistence. |
| Shared data type used across modules | no | The 4-row coverage table is a markdown render shape inside one skill's output; not a structured type consumed by other code. `lsa-plan` and `lsa-verify` read the approved artifacts, not the Gate 2 render. |

**Contract trigger = NO.** `contract.yaml` will be skipped at Gate 2.
