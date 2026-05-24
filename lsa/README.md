# LSA — Living Spec Architecture

Spec-first development methodology installable as a Claude Code plugin. Specs are the permanent source of truth; every code change traces to a spec requirement; human gates at every phase. For the design rationale, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## LSA's expression of the credo

> *"LSA doesn't automate your thinking — it makes you own it."*

Every LSA User Verification is a decision asked of the human with explicit consequences; every artifact traces back to a human-owned requirement; every reconcile keeps the human in the loop. See [`../core/CLAUDE.md`](../core/CLAUDE.md) for the operating credo and [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) Rule 0 (Ownership over automation).

## What's here

| Skill | Purpose |
|---|---|
| **`new`** | Start a new feature (creates branch → selects flow → discovers). Input: feature name or description. Output: feature branch created, discovery phase running. |
| **`next`** | Pick and start the next backlog item (reads roadmap → confirms pick → creates branch → discovers). Input: none. Output: feature branch created, discovery phase running. |
| **`discover`** | Discover and specify a feature. Standard flow: 3-row context table. Extended flow: full spec artifacts with three User Verifications. Merges the former `lsa-specify` + `lsa-discover`. |
| **`plan`** | Break a spec into implementation epics. Input: approved spec artifacts. Output: tasks.md with ≤5 ordered epics, each with a `**Covers:**` line citing requirement IDs. |
| **`implement`** | Execute TDD implementation of approved epics. Input: approved tasks.md. Output: all epics implemented with passing tests via strict RED→GREEN→REFACTOR cycle, ready for `lsa:verify`. |
| **`verify`** | Verify implementation matches the spec. Dual predicates: orphan-diff + orphan-AC. Code-mode, doc-mode, or mixed (per `.lsa.yaml`). Emits per-feature `metrics.md` on clean Extended-flow PASS. |
| **`init`** | Initialize Living Spec Architecture for a project. Input: existing codebase (greenfield or brownfield). Output: .lsa.yaml + specs_root directory + module specs. |
| **`reconcile`** | Absorb a direct artifact edit into its module spec — Level 2.5 (`vision/VISION.md:138`). One delta at a time — stop and present each individually; do not proceed without explicit approval. |
| **`revise-constitution`** | Propose changes to the project constitution and standards. Input: feature decisions that should become permanent. Output: updated constitution + standards files. |

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

A SessionStart drift hook (`lsa/hooks/hooks.json`) compares each module's `artifact_paths` against the baseline SHA — the last commit that modified the module's spec file, resolved at hook runtime via `git log -1 --format=%H -- <spec-path>` — and surfaces a one-line notice when there's drift, pointing the user at `/lsa:reconcile`.

## Depends on

LSA's fact-grounding discipline is provided by the [`core`](../core/) plugin — specifically [`core/ground-rules`](../core/skills/ground-rules/SKILL.md). `ARCHITECTURE.md` §2 P4 and §7 defer to it rather than restating its content.

Install `core` first, then `lsa`:

```
/plugin install core@NVZver
/plugin install lsa@NVZver
```

The dependency is declared in [`lsa/.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) as `"dependencies": ["core"]` (since `lsa` v0.6.3). Claude Code auto-resolves and installs `core` when you install `lsa`, and refuses to disable `core` while `lsa` is enabled. The two manual install commands above still work for clarity (e.g., when bootstrapping a marketplace).

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

Invoke LSA skills directly via `/lsa:new`, `/lsa:discover`, `/lsa:plan`, `/lsa:implement`, `/lsa:verify`, etc., or let Claude trigger by description match. Core's `ground-rules` and `actor-template` apply automatically once installed.

## Install on Claude.ai

LSA writes spec files to disk and reads `/CLAUDE.md` — it depends on a filesystem. **Not recommended for Claude.ai** in v0.1.0; the skills will trigger by description but cannot complete their I/O.

## Naming note

LSA's `/specs/standards/` directory holds technical standards (`code.md`, `testing.md`) extracted from the project's `/CLAUDE.md`. It is **not** the same as the [`core/ground-rules`](../core/skills/ground-rules/) skill — Core's `ground-rules` enforces six content discipline rules (ownership, fact-grounding, no fake-confidence hedging, read-the-source, only-required-output, no-filler); Core's `output` skill enforces five format golden rules (structured, minimal, formatted, sourced, concrete). The two coexist in the marketplace and are independently installable.
