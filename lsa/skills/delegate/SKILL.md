---
name: delegate
description: Hand the grounded spec to any implementer and collect the returned diff. The implementer is external to LSA.
allowed-tools: Read, Write, Bash, Agent, AskUserQuestion
---

# LSA Delegate

See [CORE.md](../../CORE.md). The handoff boundary — LSA writes no production code.

## Role

Handoff.

## Goal

Get a grounded spec built by the implementer the developer already uses, and collect the result.

## Inputs

| Input | Source |
|-------|--------|
| The grounded spec + `<flow>.feature` files | `verify` (GROUNDED) |
| The chosen implementer (Claude Code / Cursor / Copilot / human) | `user` |

## Steps

1. Package the spec + `.feature` files as repo files — the self-contained handoff. (→ handoff)
2. Dispatch to the developer's implementer. This runs **outside** LSA. (→ delegated)
3. Await the returned diff. (→ diff)

## Output

The implementer's diff, ready for `reconcile`.

## Constraints

- **LSA writes no production code** — the implementer is external.
- Only delegate a `GROUNDED` spec (CORE §6).

---

`/lsa:delegate` — manual invocation.
