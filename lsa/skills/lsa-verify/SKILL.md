---
name: lsa-verify
description: Verifies that the implementation on a feature branch matches the approved feature spec, with every change traced to a requirement. Use whenever an epic or feature is marked implemented, before any merge — when the user says "verify this", "check the implementation", or "ready to merge". Mandatory before `lsa-sync`.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-verify/SKILL.md] [lsa] ===============`


# LSA Verify

Core contract: every change must trace to a spec requirement. No code or artifact change is acceptable if it has no corresponding item in the feature spec.

## Goal

Confirm that the implementation on the current feature branch matches the approved feature spec, every change traces to a requirement, and tests pass — and on clean PASS, emit a per-feature `metrics.md` so `lsa-sync` can aggregate it.

## Input

- The current git feature branch (assumed to be `feature/<feature-name>`).
- The feature spec at `${specs_root}/features/<feature-name>/` (requirements, test-suites, optional contract, design, tasks).
- `.lsa.yaml` for `constitution`, `specs_root`, `mode`, and per-module `artifact_paths` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/features/<feature-name>/requirements.md`
   - `${specs_root}/features/<feature-name>/test-suites.md`
   - `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   - `${specs_root}/features/<feature-name>/design.md`
   - `${specs_root}/features/<feature-name>/tasks.md`
   - `${specs_root}/modules/<name>/spec.md` for each module in scope

   **If no `${specs_root}/features/<name>/` directory is in the diff, error out cleanly with: "no active feature — use `/lsa:reconcile` for direct-edit absorption."** Verify is feature-scoped; reconcile is drift-scoped. Do not try to verify against module specs alone.

   Observable result: per-source one-liner printed per the protocol.

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
   - [ ] Every epic-level AC in `tasks.md`'s `### Acceptance Criteria` blocks is satisfied by the implementation.
   - [ ] **Orphan-diff predicate.** Every non-trivial diff hunk has an epic in `tasks.md` whose `### Scope` covers the hunk and whose `**Covers:**` line cites ≥1 requirement ID (`F<n>`, `NF<n>`, or `AC<n>`). FAIL: `<artifact-file>:<line> has no requirement trace`. Mechanical hunks (whitespace, rename, formatting) are filtered before this check, judged by the agent and reported.
   - [ ] **Orphan-AC predicate.** Every AC ID in feature `requirements.md` § Acceptance Criteria is cited by ≥1 epic's `**Covers:**` line in `tasks.md`. FAIL: `requirements.md:<AC-line> has no covering implementation`.
   - [ ] No files outside the union of all epics' `### Scope` are modified.

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

4. **Verification report — verdict-first.** Three variants by checklist outcome. Each variant's `AskUserQuestion` prompt names the verdict in the subject — the human is picking a *next action given the verdict*, not re-issuing it. Apply [`core/output`](../../../core/skills/output/SKILL.md) Rule 5 *Genuine-fork test*: the verdict is already settled by the checklist; the picker resolves the next-action fork the verdict creates. Each variant's verdict line carries a one-sentence preamble per [`core/output`](../../../core/skills/output/SKILL.md) Rule 6 — naming what the verdict means and the concrete consequence in the user's frame, before the verdict header.

   - **PASS:** Preamble *"Every checklist item passed; no untraced changes; tests green — the implementation matches the approved spec and is safe to merge."* PASS verdict + 1-sentence headline + per-check-group results table (Scope / Accuracy / Tests / Code quality, m/n per row) + decision. **Prompt:** *"Verdict: PASS — sync now? — Yes (run `lsa-sync`) / No (hold; verify later)"*. Metadata (branch / mode / date) + full checklist below the fold.
   - **FAIL:** Preamble *"Two code changes in this branch have no matching epic in tasks.md — merging now would ship code that no requirement covers, breaking the trace chain."* (adapt the count + cause to the actual failure). FAIL verdict + 1-sentence headline naming the failed groups + Issues table (BLOCKER rows: Item / Required action) + decision. **Prompt:** *"Verdict: FAIL — block merge? — Yes (fix and re-verify) / Reduce scope (re-run `lsa-specify`) / Escalate (human review)"*. Metadata + full checklist below the fold.
   - **PASS WITH WARNINGS:** Preamble *"All blockers cleared but `<N>` non-blocking issues remain — merging now ships the feature with the warnings logged in the archive; ignoring them means the next contributor inherits the same issues."* PASS WITH WARNINGS verdict + 1-sentence headline + Issues table (WARNING rows: Item / Reason) + decision. **Prompt:** *"Verdict: PASS WITH WARNINGS — accept the warnings and sync? — Yes (sync; warning logged in archive) / Fix first (re-verify) / Hold (stop)"*. Metadata + full checklist below the fold.

   Format per [`core/output`](../../../core/skills/output/SKILL.md); verdict labels (`PASS` / `FAIL` / `PASS WITH WARNINGS`) cite [`core/knowledge/output-vocabulary.md`](../../../core/knowledge/output-vocabulary.md). `AskUserQuestion` for the decision in Claude Code — the picker prompt names the verdict in the subject (per the three variants above), not a generic *"Approve?"*. Observable result: report printed in the variant matching the verdict; picker prompt names the verdict.

5. **Gate.** Decision is part of the report (Step 4) — the report's decision block IS the gate. In Claude Code, use `AskUserQuestion` with the verdict-named prompt from Step 4 (the prompt always starts *"Verdict: <PASS|FAIL|PASS WITH WARNINGS> — …"*). Branch on the verdict:
   - **FAIL:** no `metrics.md` write; no sync handoff regardless of the decision (only re-verify / scope-reduce / escalate are valid).
   - **PASS WITH WARNINGS:** sync handoff only on `[a] accept and sync`; warning logged in archive.
   - **PASS:** sync handoff on `[a] proceed`; proceed to Step 6.

6. **On clean PASS — write `metrics.md`.** Only on clean PASS (not FAIL, not PASS WITH WARNINGS), and only when this is an Extended feature flow (was `T3`; an active feature spec exists). Write `${specs_root}/archive/<feature-name>/metrics.md` with:

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

   Pass/fail counts only — no statistical eval (deferred per `vision/VISION.md` §6 adjust #3). Observable result: when the gate is clean PASS, the written `${specs_root}/archive/<feature-name>/metrics.md` body quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (add type tag) — full single-change block of the three score sections when ≤10 lines, compressed inspection table when larger; absent (no write) otherwise.

## Output

A verification report (PASS / FAIL / PASS WITH WARNINGS) with a per-item checklist and a scope diff. On clean PASS in an Extended flow (was `T3`), a `metrics.md` file at `${specs_root}/archive/<feature-name>/metrics.md`.

## Constraints

- **FAIL on any untraced change.** The orphan-diff predicate above defines "traced"; the mechanical-hunk filter is the only exception.
- **PASS WITH WARNINGS** is allowed only with explicit warning categories in the report — never as a hand-wave.
- **No `metrics.md` write on FAIL or PASS WITH WARNINGS.** Metrics fire only on clean PASS.
- **No `metrics.md` for Standard or non-feature flows.** Standard (was `T2`) has no feature spec and no sync step; Quick (was `T1`) has no LSA ceremony.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:verify` — manual invocation.
