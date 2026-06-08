---
name: reconcile
description: Verify the implementer's diff against the spec (after delegation), and absorb drift. Output: PASS or a drift report + updated spec.
---

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

## Steps

1. Run each Gherkin scenario against the diff **N times** (agents are stochastic); pass = succeeds on ≥95% of runs. (→ scenario results)
2. Check every changed hunk traces to a requirement. (→ trace check)
3. Pass → done. A scenario fails or the code diverged → edit the spec in place to match reality; present the drift; take approval. (→ verdict + updated spec)

## Output

**PASS**, or a drift report + the spec updated to reality.

## Constraints

- **Run N times**, not once. **The spec absorbs reality** — never revert the code, never silently accept a failing scenario.

---

`/lsa:reconcile` — manual invocation. Also surfaced by the SessionStart drift hook.
