---
name: verify
description: Ground the spec against the codebase BEFORE delegating. Output: GROUNDED / NOT-GROUNDED + grounding.md.
---

> **Trace.** On load, print first: `=============== [lsa/skills/verify/SKILL.md] [lsa] ===============`

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
| Quality-gate checks (optional) | `.lsa.yaml` `gate:` — see [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md) |

## Steps

1. Identify the modules / functions / types the spec names (your judgment — never scripted), then pass them as arguments to `bash scripts/resolve-refs.sh <symbol>…` and cite its per-symbol resolution (`exists @ file:line` | `new` | `MISSING` | `OUT-OF-RANGE`) as the reference map — instead of multi-round `Grep`. Resolving each symbol is deterministic lookup (`.lsa/VISION.md` §2 principle 10); the GROUNDED / NOT-GROUNDED judgment stays yours. (→ reference map)
2. For each user flow: confirm it is buildable on what exists; infeasible → flag. (→ feasibility)
3. Confirm every claim is cited and every `[ASSUMPTION]` is visible. (→ grounding verdict)
4. Where `.lsa.yaml` defines a `gate:` block, run each configured check and cite its command + exit code as the grounding evidence — do **not** re-derive the checks by hand. Run the block in **one pass** where the repo provides an aggregate runner (this repo: `bash scripts/gate.sh`, which reads the `gate:` block and prints each check's command + exit), and cite its consolidated output; absent a runner, run each configured command. A non-zero exit is a real defect (a broken citation, dangling link, or violated invariant) and yields `NOT-GROUNDED`. (→ gate results)

## Output

**GROUNDED** or **NOT-GROUNDED** with `grounding.md` (per reference: `exists @ file:line` | `new` | `[ASSUMPTION]`), the cited `gate:` command + exit for each configured check, and any blockers.

## Constraints

- **Never delegate an ungrounded spec.** A `NOT-GROUNDED` verdict blocks `delegate`.
- **A non-zero `gate:` check BLOCKS the GROUNDED verdict.** The gate is the Rule-7 artifact (per [`knowledge/quality-gate-contract.md`](../../knowledge/quality-gate-contract.md)); "grounded" is claimed only with each command + exit `0` cited, never asserted.

---

`/lsa:verify` — manual invocation.
