> **Trace.** On load, print first: `=============== [vision/specs/main.spec.md] [vision] ===============`

# Main Spec — claude-marketplace

The top-level spec for this repo. Sources the constitution at [`vision/VISION.md`](../VISION.md) and maps to the module specs under [`vision/specs/modules/`](./modules/).

## Purpose

Build a personal, model-agnostic agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code (or any other behavior-bearing artifact) traces to a spec — and whose **ceremony scales to the weight of the task**. Per `vision/VISION.md:11`.

The marketplace ships two domain-neutral plugins (`core` and `lsa`) installable natively via Claude Code. Both evolve independently with their own SemVer + CHANGELOG (per `vision/VISION.md` §1 *"per-plugin SemVer + CHANGELOG"*).

## Module Index

| Module | Spec | Status |
|---|---|---|
| `core` | [`vision/specs/modules/core/spec.md`](./modules/core/spec.md) | active — v0.5.2 |
| `lsa` | [`vision/specs/modules/lsa/spec.md`](./modules/lsa/spec.md) | active — v0.8.0 |

## Cross-Module Contracts

- **`lsa` depends on `core`.** Documented in [`lsa/README.md`](../../lsa/README.md) "Depends on". Specifically:
  - `core/ground-rules` is the source of LSA's fact-grounding policy (`lsa/ARCHITECTURE.md` §2 P4 and §7).
  - `core/flow-selector` (added as `core/tier-selector` in core v0.2.0; renamed to `core/flow-selector` in core v0.5.2) is invoked upstream of `discover` for every Standard / Extended task (was `T2 / T3`) — its confirmed flow hand-off is the input to `discover`.
  - Claude Code's plugin manifest does not (as of this release) expose a `dependencies` field; the dependency is prose-only in `lsa/README.md` and `lsa/.claude-plugin/plugin.json`'s `description`. Adopt the field when Claude Code adds it.
- **`core/actor-template` is the shape any actor in this repo must follow.** Every LSA skill body in `lsa/skills/*/SKILL.md` matches Goal / Input / Steps / Output / Constraints. Boundary violation = highest-severity defect (`vision/VISION.md:57`).

## Non-Functional Requirements

- **NFR1 — Fact-grounding.** Every factual claim in any artifact this repo ships carries a source + searchable quote. No silent hedging. Marker convention: lowercase `[assumption: <why>]` and `[cannot verify]`. Source: `core/skills/ground-rules/SKILL.md`.
- **NFR2 — Spec-grounding.** Every artifact change traces to a spec requirement. Direct edits are absorbed (Level 2.5) rather than blocked — via `reconcile`. Source: `vision/VISION.md:135`.
- **NFR3 — Per-plugin SemVer + CHANGELOG.** Every plugin in this marketplace maintains its own `CHANGELOG.md` (Keep a Changelog) plus a SemVer in `.claude-plugin/plugin.json`. The version is bumped in the same commit as the changelog entry. Source: `vision/VISION.md` §1 *"Distribution + versioning"*.
- **NFR4 — Read before write.** In-repo config → in-repo docs → the artifact itself → external sources → ask the human. In that order. Source: `vision/VISION.md:59` (first principle 6).
- **NFR5 — Knowledge vs Actor separation.** Every file is either *what is true* (rules, patterns, checklists) or *how to act* (Goal / Input / Steps / Output / Constraints). Never both. Source: `vision/VISION.md:40` and `core/skills/actor-template/SKILL.md`.
- **NFR6 — Level 2.5 reconcile.** Direct artifact edits are detected, surfaced via the SessionStart drift hook, and absorbed into the spec via `reconcile` — never blocked or reverted. Source: `vision/VISION.md:144`.

## Repo-level config files

Files tracked by git but not LSA-verified (catalog/configuration, not behavior-bearing):

| File | Why excluded |
|---|---|
| `.claude-plugin/marketplace.json` | Marketplace catalog. Listing the plugins; not behavior. |
| `.lsa.yaml` | LSA's own configuration. Read by the skills; not their target. |
| `.lsa-sync-state.json` | LSA's per-module last-sync state. Orphaned — `lsa-sync` was removed in lsa v0.8.0. |
| `.gitignore`, `.editorconfig`, etc. | Repo plumbing. |

Changes here are tracked by git but do not trigger `verify`. If marketplace.json or .lsa.yaml introduce *behavioral* changes (e.g., adding a new plugin, changing `mode`), the change appears in the main.spec.md module index and is reviewed there.
