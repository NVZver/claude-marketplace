---
name: specify
description: Write the grounded spec — EARS requirements, user flows, and Gherkin acceptance scenarios. Output: requirements.md + <flow>.feature files.
---

> **Trace.** On load, print first: `=============== [lsa/skills/specify/SKILL.md] [lsa] ===============`

# LSA Specify

See [CORE.md](../../CORE.md) §5 (standards) and §8 (templates).

## Role

Spec author.

## Goal

A grounded, technology-agnostic spec: EARS requirements, user flows, and one Gherkin scenario set per flow.

## Inputs

| Input | Source |
|-------|--------|
| Intent + cited codebase facts | `discover` |

## Steps

1. For each user flow, answer Flow / Success / I/O / Test (CORE §3). (→ user flows)
2. Write EARS requirements — "While/when … the system shall …" (CORE §5). No mechanism (CORE §7). (→ requirements.md)
3. Write one Gherkin `.feature` per flow; each `Given` grounded in a fact from `discover` (CORE §8). (→ `<flow>.feature` files)
4. Show the spec inline; take human approval. (→ approved spec)

## Output

`${specs_root}/features/<name>/requirements.md` + `<flow>.feature` files.

## Constraints

- Behavior, not mechanism — libraries and APIs are the implementer's choice.
- Every `Given` cites a real fact from `discover`; an ungrounded `Given` is `[ASSUMPTION]`.

---

`/lsa:specify` — manual invocation.
