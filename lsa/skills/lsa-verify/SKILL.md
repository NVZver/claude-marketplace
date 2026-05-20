---
name: lsa-verify
description: >
  Verifies that implementation matches the feature spec and no changes exist outside
  spec scope. Use this skill whenever an epic or feature is marked as implemented,
  before any merge, when the user says "verify this", "check the implementation",
  "ready to merge", or when code/artifact changes exist on a feature branch. Mandatory
  before lsa-sync. Branches on .lsa.yaml mode (code / docs / mixed). On clean PASS for
  T3, writes a metrics.md file to the feature archive. Never skip.
---

# LSA Verify

Core contract: every change must trace to a spec requirement. No code or artifact change is acceptable if it has no corresponding item in the feature spec.

## Goal

Confirm that the implementation on the current feature branch matches the approved feature spec, every change traces to a requirement, and tests pass — and on clean PASS, emit a per-feature `metrics.md` so `lsa-sync` can aggregate it.

## Input

- The current git feature branch (assumed to be `feature/<feature-name>`).
- The feature spec at `${specs_root}/features/<feature-name>/` (requirements, test-suites, optional contract, design, tasks).
- `.lsa.yaml` (or LSA defaults) for `constitution`, `specs_root`, `mode`, and per-module `artifact_paths`.

## Steps

1. **Read sources.** Read `.lsa.yaml` (or apply defaults). Then read:
   1. `${constitution}` (mandatory)
   2. `${specs_root}/features/<feature-name>/requirements.md`
   3. `${specs_root}/features/<feature-name>/test-suites.md`
   4. `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   5. `${specs_root}/features/<feature-name>/design.md`
   6. `${specs_root}/features/<feature-name>/tasks.md`
   7. `${specs_root}/modules/<name>/spec.md` for each module in scope

   **If no `${specs_root}/features/<name>/` directory is in the diff, error out cleanly with: "no active feature — use `/lsa:reconcile` for direct-edit absorption."** Verify is feature-scoped; reconcile is drift-scoped. Do not try to verify against module specs alone.

   Observable result: read-summary printed per source.

2. **Get diffs — branched by mode.** Read `.lsa.yaml: mode` and branch:
   - **`mode: code`** (or absent — default v0.1.1 behavior): run
     ```bash
     git diff main -- ${specs_root}/features/<feature-name>/
     git diff main -- src/
     ```
   - **`mode: docs`**: for each module in `.lsa.yaml: modules.*`, run
     ```bash
     git diff main -- <artifact_paths>
     ```
     Aggregate diffs across modules. The `${specs_root}/features/<feature-name>/` diff still runs.
   - **`mode: mixed`**: run both. Either failing fails the whole verify.

   Observable result: per-mode diff blocks captured for the checklist in Step 3.

3. **Verification checklist.** For each item: ✅ PASS / ❌ FAIL / ⚠️ WARNING + reason.

   **Scope**
   - [ ] Every AC in `tasks.md` is addressed by at least one change.
   - [ ] Every change traces to a requirement in `requirements.md`. **In doc-mode**, "tracing" is satisfied if either (a) the feature spec's `requirements.md` names the file or its containing directory in an AC, or (b) the artifact's diff is wholly mechanical (rename, whitespace, formatting) — judged by the agent and reported as such in the report.
   - [ ] No files outside the epic's declared scope were modified.

   **Accuracy**
   - [ ] Implementation matches the technical approach in `design.md`.
   - [ ] Patterns match the constitution.
   - [ ] Data model changes match `design.md`.
   - [ ] API/interface changes match `design.md`.
   - [ ] API implementation matches `contract.yaml` (if contract exists).

   **Tests** (skipped or relaxed in `mode: docs` when no executable tests exist)
   - [ ] Unit tests exist for all new functions/methods (code-mode).
   - [ ] Integration tests cover module boundaries touched (code-mode).
   - [ ] E2E tests cover all journeys and paths in `test-suites.md`.
   - [ ] All tests pass (use test command from the constitution).

   **Code quality**
   - [ ] No duplicated logic.
   - [ ] No dead code.
   - [ ] No commented-out code.
   - [ ] File structure matches the constitution.

   Observable result: checklist printed with PASS/FAIL/WARN per row.

4. **Verification report.**

   ```markdown
   # Verification Report: [Feature/Epic Name]
   Date: [date]
   Branch: [branch name]
   Mode: [code / docs / mixed]

   ## Result: PASS / FAIL / PASS WITH WARNINGS

   ## Checklist
   [Each item with ✅ / ❌ / ⚠️ and reason for non-PASS items]

   ## Issues
   | Severity | Item | Description | Required Action |
   |----------|------|-------------|-----------------|
   | BLOCKER  | ...  | ...         | ... |
   | WARNING  | ...  | ...         | ... |

   ## Scope Diff
   - Spec changes: [list]
   - Artifact / code changes: [list]
   - Untraced changes: [none / list]
   ```

   Observable result: report printed.

5. **Gate.**
   - **FAIL / BLOCKER:** Stop. Report to human. Do not proceed to sync.
   - **PASS WITH WARNINGS:** Present report. Wait for human decision.
   - **PASS:** Present report. Proceed to sync on human approval.

6. **On clean PASS — write `metrics.md`.** Only on clean PASS (not FAIL, not PASS WITH WARNINGS), and only when this is a T3 feature flow (an active feature spec exists). Write `${specs_root}/archive/<feature-name>/metrics.md` with:

   ```markdown
   # Metrics — <feature-name>

   **Feature archived:** YYYY-MM-DD
   **Verified by:** lsa-verify

   ## Accuracy to the task
   - ACs declared: <N>
   - ACs satisfied: <M>
   - **Score:** M/N

   ## Proven facts with sources
   - Factual claims in feature spec: <N>
   - Claims with valid source + searchable quote: <M>
   - **Score:** M/N

   ## Only-required-changes
   - Files in artifact_paths changed: <N>
   - Files covered by an AC or spec requirement: <M>
   - **Score:** M/N (1.00 = no scope creep)
   ```

   Pass/fail counts only — no statistical eval (deferred per `vision/VISION.md` §6 adjust #3). Observable result: `metrics.md` exists when the gate is clean PASS; absent otherwise.

## Output

A verification report (PASS / FAIL / PASS WITH WARNINGS) with a per-item checklist and a scope diff. On clean PASS in a T3 flow, a `metrics.md` file at `${specs_root}/archive/<feature-name>/metrics.md`.

## Constraints

- **FAIL on any untraced change.** In doc-mode, the two-clause trace rule (a) or (b) above is what "traced" means; anything outside it fails.
- **PASS WITH WARNINGS** is allowed only with explicit warning categories in the report — never as a hand-wave.
- **No `metrics.md` write on FAIL or PASS WITH WARNINGS.** Metrics fire only on clean PASS.
- **No `metrics.md` for T2 or non-feature flows.** T2 has no feature spec and no sync step; T1 has no LSA ceremony.
- **Mark uncertainty with `[assumption: <why>]`.** Use `[cannot verify]` rather than guessing.

---

`/lsa:verify` — manual invocation.
