# LSA — Living Spec Architecture

A **technology-agnostic spec layer**, installable as a Claude Code plugin. LSA authors a grounded spec and verifies it **before and after** an external implementer builds it — it is **not** the implementer. Any coding agent (Claude Code, Cursor, Copilot) or a human writes the code; LSA owns the two checks. For the one-page contract every skill follows, see [`CORE.md`](./CORE.md); for the design rationale, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## LSA's expression of the credo

> *"LSA doesn't automate your thinking — it makes you own it."*

Every gate is a decision asked of the human with explicit consequences; every artifact traces to a human-owned requirement; every reconcile keeps the human in the loop. See [`../core/CLAUDE.md`](../core/CLAUDE.md) for the operating credo and [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) Rule 0 (Ownership over automation).

## The loop

`discover → specify → verify → delegate → reconcile`, driven by the `orchestrator`. Ceremony scales to weight (Quick / Standard / Extended) — a typo skips the spec; a new feature runs the full spine. See [`CORE.md`](./CORE.md).

## Skills

| Skill | Purpose |
|---|---|
| **`discover`** | Extract user intent and gather the codebase facts the spec will rest on. Also the universal input-resolver other skills call. |
| **`specify`** | Write the grounded spec — EARS requirements, user flows, and Gherkin `.feature` acceptance scenarios. |
| **`verify`** | **Before** delegating: ground the spec against the codebase — every reference resolves to real code, every flow is buildable. Output: `GROUNDED` / `NOT-GROUNDED` + `grounding.md`. |
| **`delegate`** | Hand the grounded spec + `.feature` files to whatever implementer the developer uses; collect the returned diff. Code-writing happens outside LSA. |
| **`reconcile`** | **After** the implementer returns: run each Gherkin scenario against the diff N times (agents are stochastic; pass = ≥95% of runs); pass → done; drift → the spec absorbs reality. Also surfaced by the SessionStart drift hook. |
| **`init`** | Initialize LSA on a project (greenfield or brownfield). Output: `.lsa.yaml` + specs_root directory + module specs. |
| **`revise-constitution`** | Promote a finished feature's lessons into permanent constitution / standards rules. |

## Agent

| Agent | Purpose |
|---|---|
| **`orchestrator`** | The entry point — the conductor the user talks to. Drives `discover → specify → verify → delegate → reconcile`: extracts intent, reads each sub-agent's `## Inputs`, resolves them via `discover`, delegates, and collects the output. Routes and prepares inputs; never writes production code. |

## Standards — adopt, don't invent

LSA uses industry-standard formats rather than bespoke ones: **EARS** for requirements and **Gherkin** (Given/When/Then, from Specification by Example) for acceptance scenarios. This keeps LSA interoperable with GitHub Spec Kit, AWS Kiro, and Cursor instead of competing with them — the differentiation is the two grounding checks (`verify` before, `reconcile` after), not the workflow.

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

LSA's fact-grounding discipline is provided by the [`core`](../core/) plugin — specifically [`core/ground-rules`](../core/skills/ground-rules/SKILL.md). Install `core` first, then `lsa`:

```
/plugin install core@NVZver
/plugin install lsa@NVZver
```

The dependency is declared in [`lsa/.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) as `"dependencies": ["core"]`. Claude Code auto-resolves and installs `core` when you install `lsa`, and refuses to disable `core` while `lsa` is enabled.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

Invoke LSA skills directly via `/lsa:discover`, `/lsa:specify`, `/lsa:verify`, `/lsa:delegate`, `/lsa:reconcile`, or let Claude trigger by description match. Core's `ground-rules` and `actor-template` apply automatically once installed.

## Install on Claude.ai

LSA writes spec files to disk and reads `/CLAUDE.md` — it depends on a filesystem. **Not recommended for Claude.ai**; the skills will trigger by description but cannot complete their I/O.
