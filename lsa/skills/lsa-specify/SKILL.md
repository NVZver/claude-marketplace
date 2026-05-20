---
name: lsa-specify
description: >
  Creates a feature spec from a human's description using the Living Spec Architecture.
  Use this skill whenever the user describes a new feature, says "I need to build X",
  "add a feature", "new requirement", "let's spec this out", or provides any functional
  requirement that needs to be captured before implementation. Always use this skill
  before planning or implementing anything (T3 path). May consume a discovery.md scratch
  file from lsa-discover if present. Never assume intent — always ask.
---

# LSA Specify

## Goal

Write the formal feature spec — `requirements.md`, `test-suites.md`, `contract.yaml` (when triggered), `design.md` — under the configured `${specs_root}/features/<feature-name>/`, with explicit per-artifact human confirmation gates between each step.

## Input

- The human's feature description.
- Optional `discovery.md` scratch file produced by `lsa-discover` for T3 flows. When present, the answers in `discovery.md` seed Step 4 (`requirements.md`) so the clarification block becomes a deeper round, not the first round.
- `.lsa.yaml` (or LSA defaults) for `constitution` path and `specs_root`.

## Confirm gate definitions

- **Hard Confirm:** Stop completely. Present the artifact. Do not proceed until the human explicitly approves. No implicit approval accepted.
- **Soft Confirm:** Present the artifact. Wait for approval or corrections. Human may approve, correct inline, or delegate corrections to agent. Proceed once satisfied.

## Steps

1. **Read sources.** Read `.lsa.yaml` (or apply defaults). Then read:
   1. `${constitution}` (mandatory)
   2. `${specs_root}/main.spec.md`
   3. `${specs_root}/modules/<name>/spec.md` for each module this feature touches
   4. `discovery.md` from the working feature directory, if present (T3 from `lsa-discover`)

   If a source does not exist, note the gap and proceed without it. Observable result: a one-line read-summary printed per source.

2. **Clarify with human.** Do not write any files until all answers are received. If `discovery.md` is present, treat its answers as the first round and ask deeper follow-ups rather than re-asking from scratch.

   **Functional**
   - What does this feature do?
   - Who uses it and in what context?
   - What are the inputs and outputs?
   - What are the edge cases?

   **Non-Functional**
   - Performance requirements?
   - Security requirements?

   **Boundaries**
   - Which existing modules does this touch?
   - What must NOT change?

   **Acceptance**
   - What are the exact conditions for this feature to be considered done?

   Observable result: all answers captured in the working scratch.

3. **Create spec directory.**

   ```
   ${specs_root}/features/<feature-name>/
     requirements.md
     test-suites.md
     contract.yaml      ← only if contract trigger = yes (determined at end of Step 4)
     design.md
     tasks.md           ← empty, filled by lsa-plan
   ```

   Feature name: kebab-case. Create git branch: `feature/<feature-name>`. Observable result: directory and branch both exist.

4. **Write `requirements.md` → Hard Confirm.**

   ```markdown
   # Feature: [Name]

   ## Summary
   [What and why — max 1 paragraph]

   ## Functional Requirements
   | ID | Requirement | Priority |
   |----|-------------|----------|
   | F1 | ... | Must / Should / Could / Won't |

   ## Non-Functional Requirements
   | ID | Requirement |
   |----|-------------|
   | NF1 | ... |

   ## Inputs & Outputs
   - Input: ...
   - Output: ...
   - Side effects: ...

   ## Constraints
   [Applicable rules from the constitution]

   ## Out of Scope
   [What this feature explicitly does NOT cover]

   ## Acceptance Criteria
   - [ ] AC1: [binary pass/fail condition]
   - [ ] AC2: ...
   ```

   Present to human. Ask: **"Does requirements.md capture the full scope? Confirm to continue."** Do not proceed until explicit confirmation.

   **After confirmation — evaluate contract trigger.** Ask the human explicitly: does this feature introduce or modify any of the following?
   - An API endpoint (path, method, request, response)
   - A request or response schema
   - A database schema or table structure
   - A shared data type used across modules

   Answer determines whether Step 6 (contract.yaml) is required (yes) or skipped (no). Observable result: requirements.md file exists; contract trigger logged.

5. **Write `test-suites.md` → Hard Confirm.** Before writing: verify that every AC from `requirements.md` is assigned to at least one journey. Do not present until all ACs are covered.

   ```markdown
   # Test Suites: [Feature Name]

   ## Journey: [Name]

   **Goal:** [What problem/task the user is trying to solve]
   **Covers:** AC1, AC2

   **Paths:**
   | # | Path | Actions |
   |---|------|---------|
   | 1 | Happy | action → action → success |
   | 2 | Alternate | action → action → success (different route) |
   | 3 | Error | action → system rejects → user sees feedback |

   **Expected outcome:** [What success looks like for happy paths. What feedback the user sees for error paths.]
   ```

   One journey per distinct user goal. One path per distinct way to achieve that goal. Every AC must appear in at least one journey's **Covers** field. Present to human. Ask: **"Do these journeys cover all user interactions correctly? Confirm to continue."** Do not proceed until explicit confirmation. Observable result: test-suites.md file exists; AC coverage verified.

6. **Write `contract.yaml` → Soft Confirm (skip if contract trigger = no).** Write a valid OpenAPI 3.x YAML file covering all endpoints, schemas, and data types introduced or modified by this feature.

   ```yaml
   openapi: 3.1.0
   info:
     title: [Feature Name] Contract
     version: 0.1.0
   paths:
     /[path]:
       [method]:
         summary: ...
         requestBody: ...
         responses: ...
   components:
     schemas:
       [ModelName]:
         type: object
         properties: ...
   ```

   Present to human. Ask: **"Does this contract look correct? Confirm or describe corrections — I can apply them."** Human may delegate all corrections to agent. Observable result: contract.yaml exists (or skip note logged).

7. **Write `design.md` → Soft Confirm.** Derive from `contract.yaml` if it exists. Otherwise derive from `requirements.md`.

   ```markdown
   # Design: [Feature Name]

   ## Modules Affected
   | Module | Change Type |
   |--------|-------------|
   | ...    | new / modify / read-only |

   ## Technical Approach
   [Patterns and structure per the constitution]

   ## Data Model Changes
   [If none, write "none"]

   ## API / Interface Changes
   [Reference contract.yaml if applicable, otherwise write "none"]

   ## Cross-Module Contracts
   [New or modified contracts. If none, write "none"]

   ## Open Questions
   [Unresolved items requiring human input. If none, write "none"]
   ```

   Present to human. Ask: **"Does this design look correct? Any concerns before finalizing?"** Observable result: design.md exists.

8. **Final review gate.** This is an integration check, not a re-read of individual files. If `design.md` contains Open Questions, list each one explicitly. Require the human to resolve or explicitly defer each before proceeding. Ask: **"Full spec ready. Verify consistency before approving: Does every AC have a journey covering it? Does the design match the contract? Are all Open Questions resolved or deferred? Approve to proceed to planning, or tell me what to change."** Do not run `lsa-plan` until human gives explicit final approval. Observable result: integration check signed off.

## Output

Four (or three, when contract is skipped) approved files under `${specs_root}/features/<feature-name>/`: `requirements.md`, `test-suites.md`, optional `contract.yaml`, `design.md`. An empty `tasks.md` placeholder. Feature branch `feature/<feature-name>` exists.

## Constraints

- **Hard-confirm on every artifact**: `requirements.md`, `test-suites.md`. Soft-confirm on `contract.yaml` (if applicable) and `design.md`. Never skip a gate.
- **Only proceed on explicit human approval.** Implicit approvals are not accepted.
- **Never write outside `${specs_root}/features/<feature-name>/`.** Module specs are written by `lsa-sync`; the constitution is edited only by `lsa-revise-constitution`.
- **Mark uncertainty with `[assumption: <why>]`.** Use `[cannot verify]` rather than guessing when a source is genuinely absent.

## Amending an approved spec

To change a spec after approval: edit the affected files, re-run the Hard or Soft Confirm gate for each changed file, then re-run Step 8.

---

`/lsa:specify` — manual invocation.
