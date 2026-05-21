---
name: lsa-specify
description: Creates a feature spec from a human's description (T3 path). Use whenever the user describes a new feature, says "I need to build X", "add a feature", "new requirement", "let's spec this out", or provides any functional requirement that needs capturing before implementation.
---

# LSA Specify

## Goal

Write the formal feature spec — `requirements.md`, `test-suites.md`, `contract.yaml` (when triggered), `design.md` — under the configured `${specs_root}/features/<feature-name>/`, with **three bundled human confirmation gates** (Gate 1 requirements + contract-trigger; Gate 2 test-suites + contract + design; Gate 3 final integration).

## Input

- The human's feature description.
- Optional `discovery.md` scratch file produced by `lsa-discover` for T3 flows. When present, the answers in `discovery.md` seed Step 2 so the clarification block becomes a deeper round, not the first round.
- `.lsa.yaml` for `constitution` path and `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

Confirm gate types (Hard / Soft) are defined in [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Confirm gate types".

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/main.spec.md`
   - `${specs_root}/modules/<name>/spec.md` for each module this feature touches
   - `discovery.md` from the working feature directory, if present (T3 from `lsa-discover`)

   Observable result: per-source one-liner printed per the protocol.

2. **Clarify with human via assume-then-override.** Do not write any files until all answers are received. Draft a `clarification.md` scratch with assumed answers for all 9 prompts (Functional×5, Non-functional×2, Boundaries×2, Acceptance×N); human responds with overrides or `ok`. **Silence on a line = approval.** If `discovery.md` is present, seed its answers so this becomes a deeper round.

   Present: the assumed-answer scratch + decision `[a] approve all → Gate 1` / `[b] approve with overrides → re-draft, re-present` / `[c] reject → stop, re-run lsa-discover`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision in Claude Code. Observable result: answers captured; human approval logged.

3. **Create spec directory.**

   ```
   ${specs_root}/features/<feature-name>/
     requirements.md
     test-suites.md
     contract.yaml      ← only if contract trigger = yes (determined at Gate 1)
     design.md
     tasks.md           ← empty, filled by lsa-plan
   ```

   Feature name: kebab-case. Create git branch: `feature/<feature-name>`. Observable result: directory and branch both exist.

4. **Gate 1 — `requirements.md` + contract-trigger check → Hard Confirm (bundled).**

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
   - [ ] AC1: [binary pass/fail condition]
   - [ ] AC2: ...
   ```

   Determine contract trigger by inspecting requirements (no separate human prompt). Triggered if any of: an API endpoint, a request/response schema, a DB schema/table change, a shared data type used across modules.

   Present: rendered `requirements.md` + trigger-check result per signal (yes/no with names where yes) + decision `[a] approve → Gate 2` / `[b] approve with corrections → re-present Gate 1` / `[c] reject → return to Step 2`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision. Observable result: `requirements.md` exists; contract-trigger logged; human approval logged.

5. **Gate 2 — `test-suites.md` + `contract.yaml` (if triggered) + `design.md` → Hard Confirm (bundled).**

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

   **`contract.yaml`** (skip if Gate 1 trigger = NO): valid OpenAPI 3.x.
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

   Present: AC coverage check (every AC → at least one journey) + rendered `test-suites.md` + `contract.yaml` (or skip-note) + `design.md` + any Open Questions from design.md + decision `[a] approve → Gate 3` / `[b] approve with corrections → re-present Gate 2` / `[c] reject → return to Gate 1`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision. Observable result: three files exist (or contract skip-note logged); AC coverage verified; human approval logged.

6. **Gate 3 — final integration check → Hard Confirm.** Cross-artifact integrity, not a re-read of files.

   Present: integrity checks (every AC has a journey covering it? design matches contract? Open Questions resolved or deferred?) + decision `[a] approve → lsa-plan invoked` / `[b] reject → stop; name what to change and which Gate to return to`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision. Do not run `lsa-plan` until human gives explicit final approval. Observable result: integration check signed off.

## Output

Four (or three, when contract is skipped) approved files under `${specs_root}/features/<feature-name>/`: `requirements.md`, `test-suites.md`, optional `contract.yaml`, `design.md`. An empty `tasks.md` placeholder. Feature branch `feature/<feature-name>` exists.

## Constraints

- **Three bundled gates**: Gate 1 (requirements + contract-trigger), Gate 2 (test-suites + contract + design), Gate 3 (final integration). Never skip a gate.
- **Only proceed on explicit human approval.** Implicit approvals are not accepted.
- **Never write outside `${specs_root}/features/<feature-name>/`.** Module specs are written by `lsa-sync`; the constitution is edited only by `lsa-revise-constitution`.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) golden rules (structured, minimal, formatted, sourced).

## Amending an approved spec

To change a spec after approval: edit the affected files, re-run the corresponding Gate (1, 2, or 3) for the changed scope, then re-run Gate 3.

---

`/lsa:specify` — manual invocation.
