---
name: lsa-specify
description: Creates a feature spec from a human's description (T3 path). Use whenever the user describes a new feature, says "I need to build X", "add a feature", "new requirement", "let's spec this out", or provides any functional requirement that needs capturing before implementation.
---

# LSA Specify

## Goal

Write the formal feature spec — `requirements.md`, `test-suites.md`, `contract.yaml` (when triggered), `design.md` — under the configured `${specs_root}/features/<feature-name>/`, with explicit per-artifact human confirmation gates between each step.

## Input

- The human's feature description.
- Optional `discovery.md` scratch file produced by `lsa-discover` for T3 flows. When present, the answers in `discovery.md` seed Step 4 (`requirements.md`) so the clarification block becomes a deeper round, not the first round.
- `.lsa.yaml` for `constitution` path and `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

Confirm gate types (Hard / Soft) are defined in [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Confirm gate types".

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/main.spec.md`
   - `${specs_root}/modules/<name>/spec.md` for each module this feature touches
   - `discovery.md` from the working feature directory, if present (T3 from `lsa-discover`)

   Observable result: per-source one-liner printed per the protocol.

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
     contract.yaml      ← only if contract trigger = yes (determined at Step 5)
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

   Present to human. Ask: **"Does requirements.md capture the full scope? Confirm to continue."** Do not proceed until explicit confirmation. Observable result: `requirements.md` exists.

5. **Determine contract requirement.** Ask the human explicitly: does this feature introduce or modify any of the following?
   - An API endpoint (path, method, request, response)
   - A request or response schema
   - A database schema or table structure
   - A shared data type used across modules

   Answer determines whether Step 7 (`contract.yaml`) is required (yes) or skipped (no). Observable result: contract trigger logged.

6. **Write `test-suites.md` → Hard Confirm.** Before writing: verify that every AC from `requirements.md` is assigned to at least one journey. Do not present until all ACs are covered.

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

7. **Write `contract.yaml` → Soft Confirm (skip if contract trigger = no).** Write a valid OpenAPI 3.x YAML file covering all endpoints, schemas, and data types introduced or modified by this feature.

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

8. **Write `design.md` → Soft Confirm.** Derive from `contract.yaml` if it exists. Otherwise derive from `requirements.md`.

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

9. **Final review gate.** This is an integration check, not a re-read of individual files. If `design.md` contains Open Questions, list each one explicitly. Require the human to resolve or explicitly defer each before proceeding. Ask: **"Full spec ready. Verify consistency before approving: Does every AC have a journey covering it? Does the design match the contract? Are all Open Questions resolved or deferred? Approve to proceed to planning, or tell me what to change."** Do not run `lsa-plan` until human gives explicit final approval. Observable result: integration check signed off.

## Output

Four (or three, when contract is skipped) approved files under `${specs_root}/features/<feature-name>/`: `requirements.md`, `test-suites.md`, optional `contract.yaml`, `design.md`. An empty `tasks.md` placeholder. Feature branch `feature/<feature-name>` exists.

## Constraints

- **Hard-confirm on every artifact**: `requirements.md`, `test-suites.md`. Soft-confirm on `contract.yaml` (if applicable) and `design.md`. Never skip a gate.
- **Only proceed on explicit human approval.** Implicit approvals are not accepted.
- **Never write outside `${specs_root}/features/<feature-name>/`.** Module specs are written by `lsa-sync`; the constitution is edited only by `lsa-revise-constitution`.

## Amending an approved spec

To change a spec after approval: edit the affected files, re-run the Hard or Soft Confirm gate for each changed file, then re-run Step 9.

---

`/lsa:specify` — manual invocation.
