---
name: discover
description: Discover and specify a feature. Input: confirmed flow type from flow-selector. Output: [Standard] 3-row context table; [Extended] full spec artifacts (requirements.md, test-suites.md, design.md, tasks.md).
---

> **Trace.** On load, print first: `=============== [lsa/skills/discover/SKILL.md] [lsa] ===============`


# LSA Discover

Three internal phases — **specify** (user describes intent), **discover** (agent reads codebase, infers answers), **confirm** (user approves) — unified under one command. Standard flow stops after the 3-row context table. Extended flow continues into full spec authoring with three User Verifications.

## Goal

Establish context for a task (module, change, acceptance criterion), then — for Extended flow only — author the complete feature spec under `${specs_root}/features/<feature-name>/`.

## Input

- The task description from `core/flow-selector`'s confirmed handoff, including the confirmed flow (Standard or Extended).
- `.lsa.yaml` at repo root (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults") for the list of candidate module names.

## Steps

### Phase 1: Discovery (both flows)

1. **Read `.lsa.yaml` and build module context.** Read `modules.*` keys (names + `artifact_paths` + spec paths); if `.lsa.yaml` is absent, list module directories under `${specs_root}/modules/` instead. Observable result: the candidate-module list available for Step 2's inference.

1.5. **Refine the task prompt.** Analyze the user's original description for ambiguities, missing context, and implicit assumptions. Present the refined version alongside the original:

   ```
   **Original:** [user's prompt]
   **Refined:** [clearer, more specific version]
   ```

   The human confirms or adjusts before proceeding. Observable result: refined prompt captured.

2. **Infer all three discovery answers — then confirm.** For each answer, cross-reference the task description (refined from Step 1.5) against the module context from Step 1:

   - **Module** — match against each module's `artifact_paths` globs and spec content; if none match, capture as `new module: <name>`.
   - **Change** — one-sentence framing grounded in the task description and the matched module spec's current state.
   - **AC** — one-sentence criterion grounded in the task description and the module spec's existing invariants or gaps.

   Present all three in a single `AskUserQuestion` as a confirmation, not a quiz. The human overrides any line that is wrong; silence = approval. Observable result: three answers captured (module + change + AC).

3. **Standard flow → hand off to implement.** Render the discovery as a 3-row table (Module / Change / Acceptance) per [`core/output`](../../../core/skills/output/SKILL.md). Then invoke `lsa:implement` with the discovery context (module, change, acceptance criterion). No files written to `${specs_root}/`. Observable result: the table printed back to the human; `lsa:implement` executing.

### Phase 2: Specification (Extended flow only)

4. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/main.spec.md`
   - `${specs_root}/modules/<name>/spec.md` for each module this feature touches

   Observable result: per-source one-liner printed per the protocol.

5. **Clarify with human via assume-then-override.** Do not write any files until all answers are received. Draft a `clarification.md` scratch with assumed answers for all 9 prompts (Functional×5, Non-functional×2, Boundaries×2, Acceptance×N); human responds with overrides or `ok`. **Silence on a line = approval.** The discovery answers from Step 2 seed this round — so clarification becomes deeper context, not first contact.

   Present: the assumed-answer scratch + decision. Prompt voice per [conventions.md](../../knowledge/conventions.md) §"Prompt voice convention" — e.g., *"Confirm assumed answers for `<feature-name>`?"*. Options:

   - `[a]` accept all assumed answers → draft requirements
   - `[b]` override some answers → I re-draft with your overrides
   - `[c]` start over with deeper discovery → I re-run Step 2

   `AskUserQuestion` per [conventions.md](../../knowledge/conventions.md) §"AskUserQuestion convention". Observable result: answers captured; human approval logged.

6. **Create spec directory + branch (if not already on a feature branch).**

   ```
   ${specs_root}/features/<feature-name>/
     requirements.md
     test-suites.md
     contract.yaml      ← only if contract trigger = yes (determined at User Verification 1)
     design.md
     tasks.md           ← empty, filled by lsa:plan
   ```

   Feature name: kebab-case. Create git branch `feature/<feature-name>` if not already on one (skip if invoked from `lsa:new` or `lsa:next` which already created the branch). Observable result: directory and branch both exist.

7. **User Verification 1: Requirements + Contract Trigger → Hard Confirm (bundled).**

   Write `requirements.md` using the template from [`../../knowledge/spec-templates.md`](../../knowledge/spec-templates.md) §"requirements.md template".

   Determine contract trigger by inspecting requirements (no separate human prompt). Triggered if any of: an API endpoint, a request/response schema, a DB schema/table change, a shared data type used across modules.

   Present: rendered `requirements.md` + trigger-check result per signal (yes/no with names where yes) + decision. Prompt voice per [conventions.md](../../knowledge/conventions.md) §"Prompt voice convention" — e.g., *"Approve the requirements for `<feature-name>`?"* (IDs stay in the rendered file, not in the picker). Options:

   - `[a]` approve → I draft test suites + design
   - `[b]` approve with corrections → I edit requirements and re-present
   - `[c]` reject → return to clarification round

   When asking about individual requirements that need clarification, ask one decision per question; resolve each `F<n>` / `NF<n>` / `AC<n>` to its subject phrase ("Add password reset endpoint?"), not the ID. `AskUserQuestion` per [conventions.md](../../knowledge/conventions.md) §"AskUserQuestion convention". Observable result: `requirements.md` exists; contract-trigger logged; human approval logged.

8. **User Verification 2: Test Suites + Contract + Design → Hard Confirm (bundled).**

   Before writing `test-suites.md`: verify every AC from `requirements.md` is assigned to at least one journey. Do not present until all ACs are covered.

   Write **`test-suites.md`** using the template from [`../../knowledge/spec-templates.md`](../../knowledge/spec-templates.md) §"test-suites.md template". One journey per distinct user goal. One path per distinct way to achieve that goal. Every AC must appear in at least one journey's **Covers** field.

   **`contract.yaml`** (skip if User Verification 1 trigger = NO): valid OpenAPI 3.x.

   Write **`design.md`** — derive from `contract.yaml` if it exists; otherwise from `requirements.md` — using the template from [`../../knowledge/spec-templates.md`](../../knowledge/spec-templates.md) §"design.md template".

   **Diagonal cross-artifact coverage check.** Before presenting User Verification 2, render a 4-row coverage table:

   | # | Pair | Compares | When contract skipped |
   |---|------|----------|----------------------|
   | 1 | AC→Journey | Each AC has at least one Journey with that AC in its `**Covers:**` line. | Always evaluated. |
   | 1a | EARS-pattern | Each AC matches one of the five EARS patterns per `vision/VISION.md:201`. | Always evaluated. |
   | 1b | Journey-shape | Each AC describes user-observable behavior at the user/system boundary per `vision/VISION.md` §2 sub-principle 2a. | Always evaluated. |
   | 2 | Journey→Design | Every Journey is grounded in a section of `design.md`. | Always evaluated. |
   | 3 | Design→Contract | Every endpoint/schema in `design.md` appears in `contract.yaml`. | Renders `N/A — contract skipped`. |
   | 4 | Contract→test-suites | Every endpoint/schema in `contract.yaml` is exercised by at least one Journey path. | Renders `N/A — contract skipped`. |

   Each row: pair name, status (`✓` / `✗` / `N/A`), citation in `<file>:<line> ↔ <file>:<line>` format.

   **Failing-row render.** When a row's status is `✗`, render a Rule 6 decision block:
   ```
   ✗ Row N (<pair>):  <fileA>:<lineA> ↔ <fileB>:<lineB>
      Resolution:
      [a] revise <fileA> — <suggested-edit-A>
      [b] revise <fileB> — <suggested-edit-B>
      [c] custom — free-form text
   ```

   When multiple rows fail, all decision blocks render in a single multi-question `AskUserQuestion` call. Approval blocked until every `✗` row resolved.

   Present: coverage table + `test-suites.md` + `contract.yaml` (or skip-note) + `design.md` + decision. Prompt voice per [conventions.md](../../knowledge/conventions.md) §"Prompt voice convention" — e.g., *"Approve the test suites + contract + design for `<feature-name>`?"*. Options:

   - `[a]` approve → final integration check
   - `[b]` approve with corrections → I edit and re-present
   - `[c]` reject → return to requirements

   Observable result: files exist; diagonal coverage all `✓` or `N/A`; human approval logged.

9. **User Verification 3: Final Integration → Hard Confirm.**

   Present: integrity checks (every AC has a journey? design matches contract? Open Questions resolved or deferred?) + decision. Prompt voice per [conventions.md](../../knowledge/conventions.md) §"Prompt voice convention" — e.g., *"Final approval — start implementation planning for `<feature-name>`?"*. Options:

   - `[a]` approve → I invoke `lsa:plan`
   - `[b]` reject → stop; name what to change and which prior step to return to

   Do not run `lsa:plan` until human gives explicit final approval. Observable result: integration check signed off.

## Output

- **Standard** — 3-row context table (Module / Change / Acceptance). No files written.
- **Extended** — four (or three, when contract is skipped) approved files under `${specs_root}/features/<feature-name>/`: `requirements.md`, `test-suites.md`, optional `contract.yaml`, `design.md`. An empty `tasks.md` placeholder. Feature branch `feature/<feature-name>` exists.

## Constraints

- **Infer, don't ask.** Never ask the human for information derivable from repo state. Present inferred answers for confirmation.
- **Do not invent module names** not present in `.lsa.yaml`. If the module does not exist, capture as `new module: <name>`.
- **Three bundled User Verifications (Extended only)**: 1 (Requirements + Contract Trigger), 2 (Test Suites + Contract + Design), 3 (Final Integration). Never skip a Verification.
- **Only proceed on explicit human approval.** Implicit approvals are not accepted.
- **Never write outside `${specs_root}/features/<feature-name>/`** (Extended). Module specs are written by `lsa:reconcile`; the constitution is edited only by `lsa:revise-constitution`.
- Outputs follow [conventions.md](../../knowledge/conventions.md) §"Output discipline".

## Amending an approved spec

To change a spec after approval: edit the affected files, re-run the corresponding User Verification (1, 2, or 3) for the changed scope, then re-run User Verification 3.

---

`/lsa:discover` — manual invocation.
