---
name: verify
description: Ground the spec against the codebase BEFORE delegating. Output: GROUNDED / NOT-GROUNDED + grounding.md.
---

# LSA Verify (before — grounding)

See [CORE.md](../../CORE.md) §6 (the two checks). This is the *before* check; `reconcile` is the *after* check.

## Role

Grounding checker.

## Goal

Confirm the spec is grounded in real code and buildable, before any handoff.

## Inputs

| Input | Source |
|-------|--------|
| The spec (`requirements.md`, `<flow>.feature`) | `specify` |
| The codebase | `self` |

## Steps

1. For each module / function / type the spec names: resolve it in the codebase (cite `file:line`) or mark it `new`. (→ reference map)
2. For each user flow: confirm it is buildable on what exists; infeasible → flag. (→ feasibility)
3. Confirm every claim is cited and every `[ASSUMPTION]` is visible. (→ grounding verdict)

## Output

**GROUNDED** or **NOT-GROUNDED** with `grounding.md` (per reference: `exists @ file:line` | `new` | `[ASSUMPTION]`) and any blockers.

## Constraints

- **Never delegate an ungrounded spec.** A `NOT-GROUNDED` verdict blocks `delegate`.

---

`/lsa:verify` — manual invocation.
