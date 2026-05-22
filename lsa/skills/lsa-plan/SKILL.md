---
name: lsa-plan
description: Breaks an approved feature spec into independent implementation epics. Use whenever a feature spec has been approved and needs decomposing into tasks — when the user says "plan this feature", "break this into tasks", "ready to implement", or when `requirements.md` + `design.md` exist but `tasks.md` is empty.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-plan/SKILL.md] [lsa] ===============`


# LSA Plan

## Goal

Decompose an approved feature spec into ≤5 parallel-safe epics with self-verification, and write the result to `${specs_root}/features/<feature-name>/tasks.md` for human approval before implementation begins.

## Input

- Approved `${specs_root}/features/<feature-name>/{requirements,test-suites,design}.md` and (if present) `contract.yaml`.
- `.lsa.yaml` for `constitution` path and `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/features/<feature-name>/requirements.md`
   - `${specs_root}/features/<feature-name>/test-suites.md`
   - `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   - `${specs_root}/features/<feature-name>/design.md`
   - `${specs_root}/modules/<name>/spec.md` for each affected module
   - `${specs_root}/standards/testing.md`

   Observable result: per-source one-liner printed per the protocol.

2. **Decompose into epics.** Rules:
   - Maximum 5 epics — chosen to keep epic-level human review tractable; if the work cannot be decomposed in five, the feature is too large and should be split at the spec level rather than at the plan level (escalate back to `lsa-specify` for scope reduction).
   - Each epic has zero runtime dependency on another epic
   - Each epic runs on its own branch
   - If a dependency is unavoidable, mark it explicitly in the Epic Overview table

   For each epic:

   ```markdown
   ## Epic [N]: [Name]

   ### Description
   [What this epic implements]

   ### Scope
   - Files/modules touched: ...
   - Creates / modifies / deletes: ...
   - Does NOT touch: ...

   **Covers:** <ID>, <ID>     <!-- requirement IDs from requirements.md the epic implements: F<n>, NF<n>, or AC<n>. Parallel to test-suites.md Journey **Covers:** line. Sourced by lsa-verify trace predicates. -->

   ### Technical Details
   [Implementation patterns per the constitution]

   ### Acceptance Criteria
   - [ ] AC1: [binary pass/fail]
   - [ ] AC2: ...

   ### Testing Plan
   | Test Type | What to Cover | Priority |
   |-----------|--------------|----------|
   | Unit | ... | Must |
   | Integration | ... | Should |
   | E2E | [All journeys and paths in test-suites.md] | Must |

   ### Definition of Done
   - [ ] All ACs pass
   - [ ] Tests written and passing
   - [ ] No code smells per the constitution
   - [ ] lsa-verify passed
   ```

   Observable result: a per-epic block written to the working scratch.

3. **Self-verification.** Run before presenting to human. Flag every issue found — do not omit any.

   | Check | Question |
   |-------|----------|
   | Traceability | Does every epic map to at least one requirement in `requirements.md`? |
   | Accuracy | Does the technical approach match `design.md`? |
   | Consistency | Do any epics overlap in scope or contradict each other? |
   | Test coverage | Is every AC covered by at least one test in the testing plan? |
   | AC coverage | Does every AC in `requirements.md` appear in at least one epic's `**Covers:**` line? |
   | Completeness | Are there requirements with no corresponding epic? |

   Observable result: each row marked PASS / FAIL with a one-line reason.

4. **Write `tasks.md`.**

   ```markdown
   # Tasks: [Feature Name]

   ## Epic Overview
   | Epic | Branch | Status | Dependency |
   |------|--------|--------|------------|
   | E1: [name] | feature/[name]-e1 | pending | none |
   | E2: [name] | feature/[name]-e2 | pending | E1 |

   ## Epics
   [Full epic detail]

   ## Integration Checklist
   - [ ] All epics merged into feature branch
   - [ ] E2E tests pass on feature branch
   - [ ] Integration tests pass on feature branch
   - [ ] lsa-verify passed on feature branch
   - [ ] lsa-sync completed
   - [ ] PR to main created
   ```

   Observable result: `${specs_root}/features/<feature-name>/tasks.md` exists.

5. **Human review gate.** Present rendered `tasks.md` + the 5-row self-verification table (Traceability / Accuracy / Consistency / Test coverage / Completeness — PASS / FAIL per row with reason on FAIL) + decision. **Prompt voice (per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 5).** Picker **question**: *"Approve the `<N>` epics for `<feature-name>` and start implementation?"* — not *"Approve tasks.md?"* or *"Approve epic decomposition?"* (`epic decomposition` is project jargon — name the count and the feature). Option **labels**:

   - `[a]` approve → I start TDD per epic (parallel where safe)
   - `[b]` adjust → I re-decompose with your feedback and re-present
   - `[c]` reject → return to `lsa-specify` to reduce scope

   Format per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code (per `core/CLAUDE.md` operational checkpoint #1). Do not start implementation until human gives explicit approval. Observable result: human approval logged.

## Output

`${specs_root}/features/<feature-name>/tasks.md` containing ≤5 epics, each independently runnable, with explicit dependency annotations where unavoidable; self-verification table attached.

## Constraints

- **Maximum five epics.** If the work cannot be decomposed in five parallel-safe slices, escalate back to `lsa-specify` for scope reduction before planning.
- **Each epic is independent (or its dependency is explicit).** Implicit ordering is not permitted.
- **Do not start implementation** until human approves `tasks.md`.
- Outputs follow the five golden rules in [`core/output`](../../../core/skills/output/SKILL.md).

---

`/lsa:plan` — manual invocation.
