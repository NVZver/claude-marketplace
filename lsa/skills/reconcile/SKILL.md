---
name: reconcile
description: Verify the implementer's diff against the spec (after delegation) — does it work, only what's needed, and all of the plan — then absorb drift. Output: conformance.md + PASS, or a drift report + updated spec.
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
| Quality-gate checks (optional) | `.lsa.yaml` `gate:` — see [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md) |

## Steps

Three questions — **does · only · all**:

1. **Does it work** — run each Gherkin scenario against the diff **N times** (agents are stochastic); pass = succeeds on ≥95% of runs. Where `.lsa.yaml` defines a `gate:` block, run each configured check and cite its command + exit/output as the proof (the Rule 7 gate artifact). (→ scenario results + gate results)
2. **Only what's needed** — every changed hunk traces to a requirement; an untraced hunk is over-delivery. (→ scope check)
3. **All of the plan** — every requirement (F1…, including non-scenario ones) maps to a change in the diff or a covering test; an uncovered requirement is under-delivery. (→ completeness check)
4. Write `conformance.md` (each requirement → the change/test that satisfies it). Pass → done. Any check fails or the code diverged → present the drift (per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 *Delivery test* — never only in a subagent transcript or pre-tool-call text), take approval, and edit the spec in place to match reality. (→ verdict + conformance.md + any spec update)

## Output

`conformance.md` (requirement → satisfying change/test) + **PASS**, or a drift report + the spec updated to reality.

## Constraints

- **Run N times**, not once. **Check does · only · all** — a passing-but-incomplete diff is not done. **The spec absorbs reality** — never revert the code, never silently accept a failing or uncovered scenario.
- **Independent grader.** reconcile is the grader the work cannot edit. Run it in a context with no write access to the tests, acceptance `.feature` scenarios, or quality-gate config (`.lsa.yaml` `gate:`) it grades — those are not editable within the same epic's change they judge. The implementer's diff never includes an edit to its own grader. (Reward-hacking defense — see [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md) §"Independence rule"; `.lsa/pitches/parallel-agent-delivery.md:51`.)

---

`/lsa:reconcile` — manual invocation. Also surfaced by the SessionStart drift hook.
