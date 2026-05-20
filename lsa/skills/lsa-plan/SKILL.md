---
name: lsa-plan
description: >
  Breaks an approved feature spec into independent implementation epics for parallel
  agent execution. Use this skill whenever a feature spec has been approved by the human
  and needs to be broken into tasks, when the user says "plan this feature", "break this
  into tasks", "ready to implement", or when requirements.md and design.md exist but
  tasks.md is empty. Always run after lsa-specify and before implementation.
---

# LSA Plan

## Goal

Decompose an approved feature spec into ≤5 parallel-safe epics with self-verification, and write the result to `${specs_root}/features/<feature-name>/tasks.md` for human approval before implementation begins.

## Input

- Approved `${specs_root}/features/<feature-name>/{requirements,test-suites,design}.md` and (if present) `contract.yaml`.
- `.lsa.yaml` (or LSA defaults) for `constitution` path and `specs_root`.

## Steps

1. **Read sources.** Read `.lsa.yaml` (or apply defaults). Then read:
   1. `${constitution}` (mandatory)
   2. `${specs_root}/features/<feature-name>/requirements.md`
   3. `${specs_root}/features/<feature-name>/test-suites.md`
   4. `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   5. `${specs_root}/features/<feature-name>/design.md`
   6. `${specs_root}/modules/<name>/spec.md` for each affected module
   7. `${specs_root}/standards/testing.md`

   Observable result: a one-line read-summary printed per source.

2. **Decompose into epics.** Rules:
   - Maximum 5 epics
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

5. **Human review gate.** Present `tasks.md`. Ask: **"Does this plan look correct? Approve to start implementation, or tell me what to adjust."** Do not start implementation until human gives explicit approval. Observable result: human approval logged.

## Output

`${specs_root}/features/<feature-name>/tasks.md` containing ≤5 epics, each independently runnable, with explicit dependency annotations where unavoidable; self-verification table attached.

## Constraints

- **Maximum five epics.** If the work cannot be decomposed in five parallel-safe slices, escalate back to `lsa-specify` for scope reduction before planning.
- **Each epic is independent (or its dependency is explicit).** Implicit ordering is not permitted.
- **Do not start implementation** until human approves `tasks.md`.
- **Mark uncertainty with `[assumption: <why>]`.** Use `[cannot verify]` rather than guessing.

---

`/lsa:plan` — manual invocation.
