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
| **`implement`** | Orchestrate TDD implementation of approved epics. Dispatches each epic to the `developer` agent for principal-engineer-level execution (design → test strategy → TDD → self-review), manages inter-epic human gates. Input: approved tasks.md (or Standard-flow discovery context). Output: all epics implemented with passing tests, ready for `lsa:verify`. |
| **`verify`** | Verify implementation matches the spec. Dual predicates: orphan-diff + orphan-AC. Code-mode, doc-mode, or mixed (per `.lsa.yaml`). Emits per-feature `metrics.md` on clean Extended-flow PASS. Also runs a warning-only show-changes-inline scan over the feature's runtime artifacts / PR diff — flags banned "go check the file" phrasing and bare change-claims without an inline quote (the PR-time half of `core/output` Rule 7; the author-time half lives in `prompt-engineer:prompt-review`). |
| **`init`** | Initialize Living Spec Architecture for a project. Input: existing codebase (greenfield or brownfield). Output: .lsa.yaml + specs_root directory + module specs. |
| **`reconcile`** | Absorb a direct artifact edit into its module spec — Level 2.5 (`.lsa/VISION.md:138`). One delta at a time — stop and present each individually; do not proceed without explicit approval. |
| **`revise-constitution`** | Propose changes to the project constitution and standards. Input: feature decisions that should become permanent. Output: updated constitution + standards files. |

## Agents

| Agent | Purpose |
|---|---|
| **`developer`** | Principal-engineer implementation agent. Dispatched by `implement` once per epic. Four phases: (1) Design brief — conventions, user flow, e2e data flow with reuse analysis, risks + mitigations, dependencies, migration safety, trade-offs; (2) Test plan — testing-pyramid selection with per-behavior justification; (3) TDD — RED→GREEN→REFACTOR; (4) Self-review — run suite, diff-review against design brief, present. Flags spec/plan divergence instead of silently deviating. |

## Configuration

LSA is path-configurable via an optional `.lsa.yaml` at the repo root. Minimal default-overriding example:

```yaml
constitution: .lsa/VISION.md         # default: .lsa/VISION.md
specs_root: .lsa/                    # default: .lsa/
mode: docs                           # docs | code | mixed. default: code

modules:
  core:
    spec: .lsa/modules/core/spec.md
    artifact_paths:
      - core/skills/**/SKILL.md
  lsa:
    spec: .lsa/modules/lsa/spec.md
    artifact_paths:
      - lsa/skills/**/SKILL.md
      - lsa/hooks/**/*
```

When `.lsa.yaml` is absent, LSA applies the defaults documented in [`knowledge/conventions.md`](./knowledge/conventions.md) §"`.lsa.yaml` defaults" — `constitution: .lsa/VISION.md`, `specs_root: .lsa/`, `mode: code`, `modules: {}`. The default workspace lives entirely under `.lsa/` so a user can `rm -rf .lsa/` to fully detach from LSA. Projects with a pre-existing `/CLAUDE.md` constitution or `/specs/` tree should set both keys explicitly. See [`ARCHITECTURE.md`](./ARCHITECTURE.md) §3 for the full schema.

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

LSA's `${specs_root}/standards/` directory (default: `.lsa/standards/`) holds technical standards (`code.md`, `testing.md`) extracted from the project's constitution. It is **not** the same as the [`core/ground-rules`](../core/skills/ground-rules/) skill — Core's `ground-rules` enforces six content discipline rules (ownership, fact-grounding, no fake-confidence hedging, read-the-source, only-required-output, no-filler); Core's `output` skill enforces five format golden rules (structured, minimal, formatted, sourced, concrete). The two coexist in the marketplace and are independently installable.
