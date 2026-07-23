---
name: reconcile
description: Verify the implementer's diff against the spec (after delegation) — does it work, only what's needed, and all of the plan — then absorb drift. Output — conformance.md + PASS, or a drift report + updated spec.
---

> **Trace.** On load, print first: `=============== [lsa/skills/reconcile/SKILL.md] [lsa] ===============`

# LSA Reconcile (after — correctness)

See [CORE.md](../../CORE.md) §6 (the two checks). This is the *after* check; `verify` is the *before* check.

## Role

Result verifier + spec maintainer.

## Goal

Confirm the returned diff satisfies the spec; where reality diverged, the spec absorbs it.

## Inputs

| Input | Source |
|-------|--------|
| The implementer's diff | `delegate` |
| The spec + `<flow>.feature` files | `specify` |
| Quality-gate checks (required input) | `.lsa.yaml` `gate:` — see [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md). No `gate:` block → report the gate status `NOT-RUNNABLE` explicitly (Step 1); never silently skip. |
| Scenario-run count N | `.lsa.yaml` `reconcile.runs` — **default 3 when the key (or the file) is absent** |

## Steps

Three questions — **does · only · all**:

1. **Does it work** — run each Gherkin scenario against the diff **N times**, where **N = `.lsa.yaml` `reconcile.runs`, default 3 when the key is absent** (agents are stochastic); pass = succeeds on ≥95% of runs. **At the default N = 3, ≥95% means all 3 runs pass (3/3); a 2/3 scenario fails.** When `reconcile.runs` raises N for a high-stakes epic, pass stays ≥95% of runs (e.g. N = 20 → at least 19 passing). Then run the `.lsa.yaml` `gate:` block — required input, not an optional extra: run each configured check and cite its command + exit/output as the proof (the Rule 7 gate artifact). Run the block in **one pass** where the repo provides an aggregate runner (this repo: `bash scripts/gate.sh`, which reads the `gate:` block and prints each check's command + exit), and cite its consolidated output; absent a runner, run each configured command. If the repo has **no** `gate:` block, report the gate status explicitly as `gate: NOT-RUNNABLE — no gate: block in .lsa.yaml` in `conformance.md` and alongside the verdict — never silently skip the gate step. (→ scenario results + per-check gate results, or an explicit `NOT-RUNNABLE` gate status)
2. **Only what's needed** — every changed hunk traces to a requirement; an untraced hunk is over-delivery. Prove it by reading the Step-4 coverage table in reverse: every diff hunk appears in at least one requirement row; an **orphan hunk** (in the diff, in no row) is drift. (→ scope check)
3. **All of the plan** — every requirement (F1…, including non-scenario ones) maps to a change in the diff or a covering test; an uncovered requirement is under-delivery. Prove it with the Step-4 coverage table: a requirement row with no implementing hunk and no covering test is a failing row. (→ completeness check)
4. First run `bash scripts/coverage-skeleton.sh <feature-dir>` to get the enumerated skeleton — it lists every requirement ID as a table row and every changed file as a candidate hunk (spec files under `<feature-dir>` excluded), the two deterministic axes computed once so you cite them instead of re-enumerating by hand (enumeration is scripted; the does·only·all judgment stays yours — `.lsa/VISION.md:67` §2 principle 10). Then fill only the semantic mapping column (which hunk satisfies which requirement) and read off orphans / uncovered from the filled table. Write `conformance.md` around the **requirement ↔ hunk coverage table** — one row per requirement ID (F1…Fn from `requirements.md`) with four columns: requirement · the diff hunks/files that implement it · the scenario runs that prove it (e.g. `3/3`) · a per-row verdict. Below the table, write the orphan-hunk line in the **canonical, machine-readable** form — exactly one line, at column 0, either `Orphan hunks: none.` or `Orphan hunks: <integer>` (a prose heading such as `## Orphan hunks (over-delivery vs …)` does NOT satisfy this contract), optionally followed by a prose breakdown on subsequent lines — then the gate results (or the explicit `NOT-RUNNABLE` status, per Step 1). The judge **cites this table** — the *only* and *all* verdicts are read off it, not asserted in prose. Pass → done. Any check fails or the code diverged → present the drift (per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 *Delivery test* — never only in a subagent transcript or pre-tool-call text), take approval, and edit the spec in place to match reality. (→ verdict + conformance.md + any spec update)
5. **Metrics emit step — PASS verdicts only.** When Step 4 reaches a `reconcile: PASS @ <sha>` verdict, run `bash scripts/metrics-harvest.sh <feature-dir>/conformance.md`, quote its four-line output as the cited source, and append one row to `.lsa/metrics.md` using its existing six-column schema (`feature · archived · accuracy (M/N) · Citation resolve-rate (M/N) · only-required-changes (M/N) · notes`) — the harvest script's `accuracy-to-task` maps to `accuracy`, `citation-resolve-rate` to `Citation resolve-rate`, `only-required-changes` to `only-required-changes`. On a FAIL verdict, append no row. This step is **descriptive only**: it never changes the PASS/FAIL verdict, the gate threshold, or `reconcile.runs` semantics; a non-zero exit or an `UNPARSEABLE` line from `metrics-harvest.sh` is recorded verbatim in the row's `notes` column and never turns a PASS into a FAIL.

**One exception, and it is a format rule, not a metric rule.** If `only-required-changes` comes back `UNPARSEABLE (non-canonical orphan-hunk line)`, that is not a measurement failure — it is proof that the `conformance.md` you just wrote violates Step 4's output contract. Fix the orphan line to the canonical column-0 form and re-run the harvest before appending the row. The verdict is untouched either way; you are repairing your own artifact, not letting a metric gate a grade. Lint **C19** enforces the same contract on every post-contract `conformance.md`, so a file that skips this fails the gate on the next run regardless.

Harvest with **no diff-range argument** while the cycle is still uncommitted — that is the live path the default range is correct for. Once the cycle is committed, pass its explicit range (`<base>..<sha>`); with no range, a committed cycle reports `UNPARSEABLE (committed cycle, no explicit diff range given)` rather than a ratio computed from unrelated later work. (→ `.lsa/metrics.md` row, or none on FAIL)

## Output

`conformance.md` — its core is the **requirement ↔ hunk coverage table** (one row per requirement ID: requirement · implementing diff hunks/files · proving scenario runs · verdict), followed by the canonical orphan-hunk line (`Orphan hunks: none.` or `Orphan hunks: <integer>` — see Step 4; empty count on PASS) and the per-check gate results (or an explicit `gate: NOT-RUNNABLE — no gate: block in .lsa.yaml` status) — + a verdict line `reconcile: PASS @ <graded-sha>` — emitted as a distinct gate artifact in a context the implementer cannot author (see Constraints, *Independence must be observable*) — or a drift report + the spec updated to reality. On PASS, Step 5 additionally runs `scripts/metrics-harvest.sh` against that `conformance.md` and appends one row to `.lsa/metrics.md`, citing the script's output as the source.

Coverage-table shape (synthetic):

```markdown
| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | `src/status.ts` (new command) | `status.feature` Scenario 1 — 3/3 | ✅ |
| F2 | `README.md` §Usage | — (doc requirement, no scenario) | ✅ |

Orphan hunks: none.
Gate: lint ✓ (exit 0) · test ✓ (exit 0)   — or —   gate: NOT-RUNNABLE — no gate: block in .lsa.yaml
```

## Constraints

- **Run N times** (N and the pass threshold per Step 1), never once. **Check does · only · all** — a passing-but-incomplete diff is not done. **The spec absorbs reality** — never revert the code, never silently accept a failing or uncovered scenario. **Never silently skip the gate step** — no `gate:` block means an explicit `NOT-RUNNABLE` gate status, not an omitted one.
- **Independent grader.** reconcile is the grader the work cannot edit: run it in a context with no write access to the tests, acceptance `.feature` scenarios, or quality-gate config (`.lsa.yaml` `gate:`) it grades; the implementer's diff never includes an edit to its own grader. (Reward-hacking defense — [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md) §"Independence rule".)
- **Never routed down.** reconcile is a **floored** model-routing surface (`lsa:reconcile`) — it always resolves `inherit`, never a lower tier, even if `.lsa.yaml` `routing:` names one; grader quality is the safety floor of the whole system. Per [`../../knowledge/model-routing.md`](../../knowledge/model-routing.md).
- **Independence must be observable, not asserted.** The verdict (`conformance.md` + `reconcile: PASS|FAIL @ <graded-sha>`, naming the SHA it graded) is authored in a **separate context** from the implementer and emitted in a **commit separate from the implementation commit** (or, where a single commit is unavoidable, as a record whose authoring context is provably not the implementer's); a run where reconcile is folded inline into the implementation commit fails this rule. Full rationale + the observed TripAnchor-1 failure: [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md) §"Independence rule".

---

`/lsa:reconcile` — manual invocation. Also surfaced by the SessionStart drift hook.
