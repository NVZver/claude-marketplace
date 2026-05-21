# claude-marketplace

> **Ownership over automation.** A personal, model-agnostic agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**.

**Proven · Owned · No Fluff · Spec First.**

A Claude Code marketplace shipping two composable plugins:

- **`core`** — three always-on skills that keep the agent honest: `ground-rules` (content discipline), `output` (format discipline), and `tier-selector` (process ceremony — one-pass for a typo, full spec lifecycle for a new module).
- **`lsa`** — **L**iving **S**pec **A**rchitecture: spec-first development where every change traces to a requirement, and hand-edits to code are *absorbed* into the spec instead of forbidden.

---

## The problem — devs don't own their projects anymore

Agents make silent decisions. Hedged claims (*"probably"*, *"typically"*, *"based on convention"*) pass for facts. Code drifts from intent. Specs rot the moment the code lands. Six months in, nobody — human or agent — knows why the system is the way it is.

The system was supposed to make you faster. Instead it made you a passenger.

## The solution — discipline, not magic

Two plugins working together. They don't add features; they constrain the agent until output is *grounded* and ownership stays with the human.

### `core` — always-on discipline

Canonical list in [`core/CLAUDE.md`](./core/CLAUDE.md):

- **`ground-rules`** — six content rules applied to every substantive task:
  - **Ownership over automation** — the human owns the thinking; the system surfaces facts, lays out options, and demands a choice. No silent auto-decisions.
  - **Fact-grounding** — every claim carries a source + searchable quote.
  - **No fake confidence** — no *"probably / typically / based on convention"* to dodge sourcing. Assumptions are marked explicitly.
  - **Read the real source** — check before guessing; ask the human only after in-repo + external sources are exhausted.
  - **Deliver only what was asked** — no padding, no unrequested extras.
  - **No filler** — every sentence carries a fact, an owned opinion, or an action.

- **`output`** — four format golden rules applied to every human-facing output:
  - **Structured** — verdict line first; result/decision block second; detail below the fold.
  - **Minimal** — no banned phrasings, no filler.
  - **Formatted** — code spans, tables, quotes used where they earn their place.
  - **Sourced** — every claim cites `path + verbatim quote`.

- **`tier-selector`** — before any non-trivial task, classifies the work and waits for your confirmation:
  - **T1 — Quick.** One-pass. Typos, renames, one-line fixes.
  - **T2 — Standard.** Discover → implement (TDD) → verify. Bugs in modules with a spec.
  - **T3 — Full.** Full spec lifecycle. New features, new contracts, new modules.

- **`actor-template`** — the Goal / Input / Steps / Output / Constraints shape every skill or command must follow; every Step produces an observable result.

### `lsa` — Living Spec Architecture

> *"LSA doesn't automate your thinking — it makes you own it."*

Specs are the permanent source of truth; every change traces to a spec requirement. Eight skills enforce the lifecycle:

| Skill | What it does |
|---|---|
| `lsa-init` | Stand up the spec tree on a project (greenfield or brownfield). |
| `lsa-discover` | Light three-question probe at the start of every standard/full task. |
| `lsa-specify` | Capture a new feature spec, with hard/soft confirm gates per file. |
| `lsa-plan` | Decompose an approved spec into ≤ 5 parallel-safe epics. |
| `lsa-verify` | Block any change that doesn't trace to a requirement. |
| `lsa-sync` | Merge feature delta into permanent module specs at merge time. |
| `lsa-reconcile` | Absorb direct code/artifact edits into the spec — never block. |
| `lsa-revise-constitution` | Promote feature decisions into permanent standards. |

**The developer may edit code by hand.** When the spec and the code diverge, `lsa-reconcile` detects the delta and offers to update the spec to match. Drift becomes a conversation, not a violation. The goal is to improve devs' lives, not retrain how they work.

---

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

Install `core` first — `lsa` cites it for fact-grounding and tier selection. Then merge the [`core/CLAUDE.md`](./core/CLAUDE.md) fragment into your project's `CLAUDE.md` to wire up the always-on rules.

## How it works in 30 seconds

1. Every task fires `ground-rules` + `output` automatically. Sources, no hedging, no padding, verdict-first.
2. Non-trivial tasks fire the tier selector first. The agent proposes Quick / Standard / Full with reasoning; you confirm.
3. Standard and Full tasks run through LSA: discover → (specify → plan →) implement → verify → sync. Every line of code traces back to a requirement.
4. If you hand-edit code, `lsa-reconcile` offers to update the spec — it never blocks the edit.

The single test the whole system answers: **what is the minimum ceremony that still guarantees grounded, spec-anchored output for *this* task?**

---

## Status + substrate

Personal-use first; open-sourced for visibility. Substrate is Claude Code today — that's a v1 expedient, not a permanent stance. Ports to other agentic IDEs are on the table if traction warrants.

## Further reading

- [`vision/VISION.md`](./vision/VISION.md) — the full design rationale (the constitution).
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — how to build, contribute, verify.
- [`core/README.md`](./core/README.md), [`lsa/README.md`](./lsa/README.md) — per-plugin docs.
- [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) — directory layout, `.lsa.yaml` schema, branch management.

Licensed under [`LICENSE`](./LICENSE).
