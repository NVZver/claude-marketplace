# LSA — Living Spec Architecture

Spec-first development methodology installable as a Claude Code plugin. Specs are the permanent source of truth; every code change traces to a spec requirement; human gates at every phase. For the design rationale, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## LSA's expression of the credo

> *"LSA doesn't automate your thinking — it makes you own it."*

Every LSA gate is a decision asked of the human with explicit consequences; every artifact traces back to a human-owned requirement; every reconcile keeps the human in the loop. See [`../core/CLAUDE.md`](../core/CLAUDE.md) for the operating credo and [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) Rule 0 (Ownership over automation).

## What's here

| Skill | Purpose |
|---|---|
| **`lsa-init`** | Initialize the spec tree on a project. Greenfield or brownfield. |
| **`lsa-discover`** | Light three-question probe at the start of every T2 / T3 task. T2 oral; T3 scratch `discovery.md`. |
| **`lsa-specify`** | Create a feature spec from a description, with three bundled hard-confirm gates; Gate 2 renders a 6-row diagonal cross-artifact coverage check (5 with contract skipped) — including EARS-pattern + journey-shape rows per `vision/VISION.md` §2 sub-principle 2a. |
| **`lsa-plan`** | Decompose an approved spec into ≤5 parallel-safe epics. Each epic carries a `**Covers:**` line citing requirement IDs (`F<n>`, `NF<n>`, `AC<n>`) — sourced by `lsa-verify`. |
| **`lsa-verify`** | Verify every change traces to a spec requirement via dual predicates: orphan-diff (broad — every non-trivial hunk covered) + orphan-AC (narrow — every AC implemented). Code-mode, doc-mode, or mixed (per `.lsa.yaml`). Emit per-feature `metrics.md` on clean T3 PASS. |
| **`lsa-sync`** | Extract delta into permanent module specs; archive feature spec; record per-module HEAD SHA in `.lsa-sync-state.json`; append aggregate metrics row. |
| **`lsa-reconcile`** | Absorb direct artifact edits into module specs — Level 2.5 (`vision/VISION.md:138`). Per-module hard confirm. |
| **`lsa-revise-constitution`** | Propose and apply changes to the configured constitution and `${specs_root}/standards/` only. |

## Configuration

LSA is path-configurable via an optional `.lsa.yaml` at the repo root. Minimal default-overriding example:

```yaml
constitution: vision/VISION.md       # default: /CLAUDE.md
specs_root: vision/specs/            # default: /specs/
mode: docs                           # docs | code | mixed. default: code

modules:
  core:
    spec: vision/specs/modules/core/spec.md
    artifact_paths:
      - core/skills/**/SKILL.md
  lsa:
    spec: vision/specs/modules/lsa/spec.md
    artifact_paths:
      - lsa/skills/**/SKILL.md
      - lsa/hooks/**/*
```

When `.lsa.yaml` is absent, LSA falls back to v0.1.1 behavior (`/CLAUDE.md`, `/specs/`, code-mode). See [`ARCHITECTURE.md`](./ARCHITECTURE.md) §4.10 for the full schema.

A SessionStart drift hook (`lsa/hooks/hooks.json`) compares `artifact_paths` against the per-module SHA recorded in `.lsa-sync-state.json` (written by `lsa-sync`) and surfaces a one-line notice when there's drift — pointing the user at `/lsa:reconcile`.

## Depends on

LSA's fact-grounding discipline is provided by the [`core`](../core/) plugin — specifically [`core/ground-rules`](../core/skills/ground-rules/SKILL.md). `ARCHITECTURE.md` §2 P4 and §7 defer to it rather than restating its content.

Install `core` first, then `lsa`:

```
/plugin install core@NVZver
/plugin install lsa@NVZver
```

The dependency is documented in prose; the Claude Code plugin manifest does not enforce a `dependencies` field as of v0.1.1. Order matters for the discipline contract — `core/ground-rules` should be loaded when LSA skills cite it.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

Invoke LSA skills directly via `/lsa:init`, `/lsa:specify`, etc., or let Claude trigger by description match. Core's `ground-rules` and `actor-template` apply automatically once installed.

## Install on Claude.ai

LSA writes spec files to disk and reads `/CLAUDE.md` — it depends on a filesystem. **Not recommended for Claude.ai** in v0.1.0; the skills will trigger by description but cannot complete their I/O.

## Naming note

LSA's `/specs/standards/` directory holds technical standards (`code.md`, `testing.md`) extracted from the project's `/CLAUDE.md`. It is **not** the same as the [`core/ground-rules`](../core/skills/ground-rules/) skill — Core's `ground-rules` enforces six content discipline rules (ownership, fact-grounding, no fake-confidence hedging, read-the-source, only-required-output, no-filler); Core's `output` skill enforces five format golden rules (structured, minimal, formatted, sourced, concrete). The two coexist in the marketplace and are independently installable.
