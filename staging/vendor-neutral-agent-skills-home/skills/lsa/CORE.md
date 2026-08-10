# LSA — Core

A technology-agnostic spec is worthless unless it is **grounded in the real codebase before you build** and **verified against the real diff after**. LSA builds those two checks. Any tool writes the spec; any agent writes the code.

## What LSA is — and is not

- **Is:** extract intent → write a grounded spec (EARS + Gherkin) → **verify it against the codebase** → hand off → **reconcile the result against the spec**.
- **Is not:** the implementer. The coding agent (Claude Code, Cursor, Copilot, a human) lives outside the boundary. LSA never writes production code.

## 1. Principle — facts only

The spec is living documentation: as reliable as code, the source of truth. State only facts you can cite — `file:line`, command output, docs. A missing fact is tagged `[ASSUMPTION]`; never promote an assumption to fact silently. An ungrounded spec is the failure mode LSA exists to prevent.

## 2. The loop

```text
      │←──────────── LSA owns ────────────→│   external   │←─ LSA ─→│
you ▶ discover ▶ specify ▶ verify ──────▶ delegate ▶ [ agent ] ▶ reconcile
      intent+    EARS+     ground          hand off    writes      does · only ·
      facts      Gherkin   (BEFORE)                    the code    all (AFTER)
```

1. **Discover** — extract intent from the user; gather the codebase facts the spec will rest on.
2. **Specify** — write the spec: EARS requirements · user flows · Gherkin acceptance scenarios.
3. **Verify (before)** — ground the spec: every reference resolves to real code; every flow is buildable. ← *differentiator 1*
4. **Delegate** — hand the spec + `.feature` files to any implementer. Out of the system.
5. **Reconcile (after)** — run the scenarios against the returned diff; pass → done; drift → the spec absorbs reality. ← *differentiator 2*

The **orchestrator** drives this loop (§9). It runs the spec-authoring hops — `discover`, `specify`, `verify` — **inline in one context**, reusing accumulated facts rather than re-reading; it crosses a context boundary only at `delegate` (the external implementer) and `reconcile` (an independent grader). One context floor and one file-read pass instead of N — the flow stays affordable on the Pro-tier model (see `.lsa/standards/code.md` §"Model policy").

**Ceremony scales to weight.** Not every task runs the full loop — the orchestrator picks by the size of the change:
- **Quick** (typo, rename, a question): skip the spec — ground the change, reconcile after.
- **Standard** (a bug, a small change): light requirements + one Gherkin scenario, then verify → delegate → reconcile.
- **Extended** (new feature or module): the full loop above (EARS + user flows + Gherkin).

Start at the lowest flow; escalate the moment the work crosses a boundary — new module, new contract, data-model change.

## 3. User flows — the unit of work

Every task answers four questions; a missing answer means it is not ready to build:

1. **Flow** — which user flow does this add or fix?
2. **Success** — what does success look like, as observable behavior?
3. **I/O** — the inputs and outputs of the flow.
4. **Test** — the Gherkin scenario(s) that prove it.

## 4. Instruction pattern

Every skill and agent is written as **Role · Goal · Inputs (each sourced `user` or `discover`) · Steps (1:1 input → `(→ …)` → output) · Output**. Minimal. This is what makes each instruction a test case.

## 5. Standards — adopt, don't invent

- **Requirements:** EARS — "While `<state>` / when `<event>`, the system shall `<observable behavior>`."
- **Acceptance tests:** Gherkin — `Given / When / Then`. Authored tech-agnostically; the implementer wires execution.
- **Philosophy:** Specification by Example / Living Documentation.
- Using these formats keeps LSA interoperable with Spec Kit, Kiro, and Cursor instead of competing with them.

## 6. The two checks — this is the product

**Verify — before delegating (grounding):**
- Every module / function / type the spec names exists in the codebase, cited `file:line`, or is explicitly marked `new`.
- Every user flow is buildable on what exists; infeasible → flag, do not delegate.
- Every claim cited; every `[ASSUMPTION]` visible.

**Reconcile — after the implementer returns (correctness). Three questions — does · only · all:**
- **Does** it work — run each Gherkin scenario against the diff. Agents are stochastic — run **N times**, N = 3 by default (`.lsa.yaml` `reconcile.runs` raises it for high-stakes epics); pass = ≥95% of runs — at the default N = 3 that is all 3 runs.
- **Only** what's needed — every changed hunk traces to a requirement (untraced = over-delivery).
- **All** of the plan — every requirement, including non-scenario ones, maps to a change or a covering test (uncovered = under-delivery).
- Output `conformance.md` (requirement → satisfying change/test). Any check fails or the code diverged → the spec absorbs reality (edit in place); never silently accept, never revert the code.

## 7. Simplicity

- The simplest spec that captures the flows. No requirement states mechanism — *how* is the implementer's choice.
- Only what was asked. One human approval per spec and per reconcile verdict, shown inline.

## 8. Templates

- **requirements.md** — Summary · User Flows (`Flow | Success | I/O | Scenario`) · Functional (EARS) · Out of Scope.
- **`<flow>.feature`** — Gherkin:
  ```gherkin
  Feature: <flow>
    Scenario: <case>
      Given <state grounded in the codebase>
      When <event>
      Then <observable outcome>
  ```
- **grounding.md** (verify output) — per spec reference: `exists @ file:line` | `new` | `[ASSUMPTION]`.

## 9. Worked example — inputs → CoT → output

Request (`user`): *"add a `/lsa:status` command that lists in-flight features."*

- **orchestrator** — in: request → CoT: a feature; enter the loop at `discover` → out: run the loop.
- **discover** — in: request + repo → CoT: `.lsa.yaml` → `roadmap.yaml` holds feature status; one read-only flow → out: intent + facts (`roadmap.yaml exists @ .lsa/roadmap.yaml`).
- **specify** — in: intent + facts → CoT: one flow; success = table printed; I/O = `∅ → stdout` → out: EARS F1 + `status.feature` (Given the roadmap has in-flight rows / When status runs / Then a table is printed).
- **verify (before)** — in: spec + codebase → CoT: `roadmap.yaml` exists ✓; a command surface exists to extend ✓; flow buildable ✓ → out: **GROUNDED** + `grounding.md`.
- **delegate** — in: spec + `status.feature` → CoT: hand to the dev's implementer → out: *(external)* a diff returns.
- **reconcile (after)** — in: diff + `status.feature` → CoT: scenario 5/5 *(does)*; every hunk traces to F1 *(only)*; F1 covered *(all)* → out: **PASS** + `conformance.md`.

Each hop is one `Inputs` → one CoT → one `Output` — testable, and standard-aligned (EARS + Gherkin).
