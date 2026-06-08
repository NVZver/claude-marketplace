---
name: discover
description: Extract user intent and gather the codebase facts a spec will rest on. Output: intent + cited facts, handed to specify. Also the universal input-resolver for other skills.
---

# LSA Discover

See [CORE.md](../../CORE.md). Step 1 of the loop, and the input-resolver other skills call.

## Role

Requirements analyst.

## Goal

Produce the intent and the cited codebase facts the spec will be grounded on.

## Inputs

| Input | Source |
|-------|--------|
| The request | `user` (free text) |
| `.lsa.yaml`, constitution, the code/specs the request touches | `self` |

## Steps

1. Read `.lsa.yaml`, the constitution, and the code/specs the request touches. Cite each `file:line`; tag any gap `[ASSUMPTION]` (CORE §1). (→ codebase facts)
2. Extract intent — which user flow, for which module. Ask only what isn't derivable from the facts. (→ intent)
3. Hand intent + facts to `specify`. (→ handoff)

## Output

Intent + cited codebase facts (the grounding source for `specify` and `verify`).

## Constraints

- Infer from repo state; never ask for what's derivable. Don't invent module names absent from `.lsa.yaml`.

---

`/lsa:discover` — manual invocation.
