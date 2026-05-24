---
name: lsa-specify
description: Creates a feature spec from a human's description (Extended flow — was `T3`). Use whenever the user describes a new feature, says "I need to build X", "add a feature", "new requirement", "let's spec this out", or provides any functional requirement that needs capturing before implementation.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-specify/SKILL.md] [lsa] ===============`


# LSA Specify

## Goal

Write the formal feature spec — `requirements.md`, `test-suites.md`, `contract.yaml` (when triggered), `design.md` — under the configured `${specs_root}/features/<feature-name>/`, with **three bundled User Verifications** (1: Requirements + Contract Trigger; 2: Test Suites + Contract + Design; 3: Final Integration). The proper-noun name reads to a first-time user as *who* (the human) and *what* (verifying); the prior `Gate N` name carried position but no meaning.

## Input

- The human's feature description.
- Optional `discovery.md` scratch file produced by `lsa-discover` for Extended flows (was `T3`). When present, the answers in `discovery.md` seed Step 2 so the clarification block becomes a deeper round, not the first round.
- `.lsa.yaml` for `constitution` path and `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

All three Verifications stop until the human explicitly approves; no implicit approval is accepted.

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/main.spec.md`
   - `${specs_root}/modules/<name>/spec.md` for each module this feature touches
   - `discovery.md` from the working feature directory, if present (Extended flow from `lsa-discover`)

   Observable result: per-source one-liner printed per the protocol.

2. **Clarify with human via assume-then-override.** Do not write any files until all answers are received. Draft a `clarification.md` scratch with assumed answers for all 9 prompts (Functional×5, Non-functional×2, Boundaries×2, Acceptance×N); human responds with overrides or `ok`. **Silence on a line = approval.** If `discovery.md` is present, seed its answers so this becomes a deeper round.

   Present: the assumed-answer scratch + decision. **Prompt voice (per [`core/output`](../../../core/skills/output/SKILL.md) Rule 5).** The picker **question** names the feature in real-world terms — e.g., *"Confirm assumed answers for `<feature-name>`?"* — not "Approve clarification scratch?". Option **labels** name the outcome:

   - `[a]` accept all assumed answers → draft requirements
   - `[b]` override some answers → I re-draft with your overrides
   - `[c]` start over with deeper discovery → I re-run `lsa-discover`

   Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code (per `core/CLAUDE.md` operational checkpoint #1 — never render `[a]/[b]/[c]` text blocks when the picker is available). Observable result: answers captured; human approval logged.

3. **Create spec directory.**

   ```
   ${specs_root}/features/<feature-name>/
     requirements.md
     test-suites.md
     contract.yaml      ← only if contract trigger = yes (determined at User Verification 1)
     design.md
     tasks.md           ← empty, filled by lsa-plan
   ```

   Feature name: kebab-case. Create git branch: `feature/<feature-name>`. Observable result: the created paths quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (add type tag) — names `${specs_root}/features/<feature-name>/` with the per-file listing, names the new `feature/<feature-name>` branch.

4. **User Verification 1: Requirements + Contract Trigger (bundled — stop and present; do not proceed without explicit approval).**

   Write `requirements.md`:
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
   <!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->
   - [ ] AC1: While <state> / when <event>, the system shall <observable behavior>.
   - [ ] AC2: ...
   ```

   Determine contract trigger by inspecting requirements (no separate human prompt). Triggered if any of: an API endpoint, a request/response schema, a DB schema/table change, a shared data type used across modules.

   Present: rendered `requirements.md` + trigger-check result per signal (yes/no with names where yes) + decision. **Prompt voice (per [`core/output`](../../../core/skills/output/SKILL.md) Rule 5).** Picker **question**: *"Approve the requirements for `<feature-name>`?"* — not *"Approve F1/F2/F3?"* (IDs stay in the rendered file, not in the picker). Option **labels** name the outcome (no `Gate N` jargon):

   - `[a]` approve → I draft test suites + design
   - `[b]` approve with corrections → I edit requirements and re-present
   - `[c]` reject → return to clarification round

   When asking about individual requirements that need clarification, ask one decision per question; resolve each `F<n>` / `NF<n>` / `AC<n>` to its subject phrase ("Add password reset endpoint?"), not the ID. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code. Observable result: `requirements.md` quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (add type tag) — full single-change block for each section (Summary / Functional Requirements / Non-Functional Requirements / Inputs & Outputs / Constraints / Out of Scope / Acceptance Criteria) when ≤10 lines, compressed inspection table when larger; contract-trigger logged; human approval logged.

5. **User Verification 2: Test Suites + Contract + Design (bundled — stop and present; do not proceed without explicit approval).**

   Before writing `test-suites.md`: verify every AC from `requirements.md` is assigned to at least one journey. Do not present until all ACs are covered.

   **`test-suites.md`** shape:
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

   One journey per distinct user goal. One path per distinct way to achieve that goal. Every AC must appear in at least one journey's **Covers** field.

   **`contract.yaml`** (skip if User Verification 1 trigger = NO): valid OpenAPI 3.x.
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

   **`design.md`** — derive from `contract.yaml` if it exists; otherwise from `requirements.md`:
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

   **Diagonal cross-artifact coverage check.** Before presenting User Verification 2, render a 4-row coverage table by reading the four (or three, if contract skipped) artifacts and checking each pair:

   | # | Pair | Compares | When contract skipped |
   |---|------|----------|----------------------|
   | 1 | AC→Journey | Each AC in `requirements.md` § Acceptance Criteria has at least one Journey in `test-suites.md` with that AC in its `**Covers:**` line. | Always evaluated. |
   | 1a | EARS-pattern | Each AC matches one of the five EARS patterns per `vision/VISION.md:201`. | Always evaluated. |
   | 1b | Journey-shape | Each AC describes a user-observable behavior at the user/system boundary per `vision/VISION.md` §2 sub-principle 2a — not a unit-test of an internal helper. Agent-judged; the human owns the call via the failing-row decision block (below). | Always evaluated. |
   | 2 | Journey→Design | Every Journey in `test-suites.md` is grounded in a section of `design.md` (module, contract, or technical-approach reference). | Always evaluated. |
   | 3 | Design→Contract | Every endpoint or schema named in `design.md` § API / Interface Changes appears in `contract.yaml`. | Renders `N/A — contract skipped`. |
   | 4 | Contract→test-suites | Every endpoint/schema in `contract.yaml` is exercised by at least one Journey path in `test-suites.md`. | Renders `N/A — contract skipped`. |

   Each row in the rendered table has three columns: pair name, status (`✓` / `✗` / `N/A`), and citation in `<file>:<line> ↔ <file>:<line>` format. Per `core/ground-rules` Rule 1, citations are searchable `file:line` pointers — never paraphrases. Row 1 (AC→Journey) is the same check named in this step's opening paragraph, now rendered as the first row of the diagonal table rather than as a separate verbal check.

   **Failing-row render.** When a row's status is `✗`, render a failing-row decision block per failing row:

   ````
   ✗ Row N (<pair>):  <fileA>:<lineA> ↔ <fileB>:<lineB>
      <lineA-content>
      <lineB-content>

      Resolution:
      [a] revise <fileA> — <suggested-edit-A>
      [b] revise <fileB> — <suggested-edit-B>
      [c] custom — free-form text
   ````

   When multiple rows fail, all decision blocks render together in a single multi-question `AskUserQuestion` call (batched — not one at a time). Approval is blocked until every `✗` row has a resolution: `[a]` or `[b]` edits the cited file in place, `[c]` returns to User Verification 1 for deeper revision.

   Present: 4-row diagonal coverage table (rendered above) + `test-suites.md` + `contract.yaml` (or skip-note) + `design.md` + any Open Questions from design.md + decision. **Prompt voice (per [`core/output`](../../../core/skills/output/SKILL.md) Rule 5).** Picker **question**: *"Approve the test suites + contract + design for `<feature-name>`?"* — not *"Approve User Verification 2?"*. Option **labels** name the outcome:

   - `[a]` approve → final integration check
   - `[b]` approve with corrections → I edit and re-present
   - `[c]` reject → return to requirements

   Failing rows surface as failing-row decision blocks (batched in one multi-question `AskUserQuestion`); approval is blocked until every `✗` row is resolved. Each failing-row picker uses subject voice — name the two artifact lines in conflict, not the row number. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code. Observable result: the three written files quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (add type tag) — `test-suites.md` / `contract.yaml` (or skip-note) / `design.md` each rendered as a compressed inspection table (one row per top-level section) given multi-file batch size, with file:line pointers; diagonal coverage table rendered (every row `✓` or `N/A`); human approval logged.

6. **User Verification 3: Final Integration — stop and present; do not proceed without explicit approval.** Cross-artifact integrity, not a re-read of files.

   Present: integrity checks (every AC has a journey covering it? design matches contract? Open Questions resolved or deferred?) + decision. **Prompt voice (per [`core/output`](../../../core/skills/output/SKILL.md) Rule 5).** Picker **question**: *"Final approval — start implementation planning for `<feature-name>`?"* — not *"Approve User Verification 3?"*. Option **labels**:

   - `[a]` approve → I invoke `lsa-plan`
   - `[b]` reject → stop; name what to change and which prior step to return to (requirements / test suites / design)

   Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code. Do not run `lsa-plan` until human gives explicit final approval. Observable result: integration check signed off.

## Output

Four (or three, when contract is skipped) approved files under `${specs_root}/features/<feature-name>/`: `requirements.md`, `test-suites.md`, optional `contract.yaml`, `design.md`. An empty `tasks.md` placeholder. Feature branch `feature/<feature-name>` exists.

## Constraints

- **Three bundled User Verifications**: 1 (Requirements + Contract Trigger), 2 (Test Suites + Contract + Design), 3 (Final Integration). Never skip a Verification.
- **Only proceed on explicit human approval.** Implicit approvals are not accepted.
- **Never write outside `${specs_root}/features/<feature-name>/`.** Module specs are written by `lsa-sync`; the constitution is edited only by `lsa-revise-constitution`.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

## Amending an approved spec

To change a spec after approval: edit the affected files, re-run the corresponding User Verification (1, 2, or 3) for the changed scope, then re-run User Verification 3.

---

`/lsa:specify` — manual invocation.
