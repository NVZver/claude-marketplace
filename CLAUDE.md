# CLAUDE.md

This repository is the **nz-vision claude-marketplace** — a personal, model-agnostic agentic engineering system distributed via Claude Code's plugin marketplace.

For the design rationale (the "why"), see [`vision/VISION.md`](./vision/VISION.md).

## Default plugins

Two plugins ship from this marketplace and together form the development discipline for working in this repo. **Install both:**

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
/plugin install lsa@nz-vision
/reload-plugins
```

Install `core` first — `lsa` cites it for fact-grounding (see [`lsa/README.md`](./lsa/README.md) → "Depends on").

### `core` — domain-neutral discipline

[`core/README.md`](./core/README.md) for details. Two skills:

- **`core/ground-rules`** — four rules enforced on every substantive task:
  1. Every factual claim carries a source + searchable quote.
  2. No fake confidence, no disguised facts.
  3. Read the real source before answering.
  4. Deliver only what was asked — no scope creep.
- **`core/actor-template`** — Goal / Input / Steps / Output / Constraints shape for any skill, slash command, or workflow you author.

### `lsa` — Living Spec Architecture

[`lsa/README.md`](./lsa/README.md) and [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) for details. Six skills enforcing spec-first development with explicit human gates:

| Skill | Phase |
|---|---|
| `lsa-init` | Initialize spec structure (greenfield or brownfield) |
| `lsa-specify` | Create a feature spec from a description |
| `lsa-plan` | Decompose an approved spec into ≤5 parallel-safe epics |
| `lsa-verify` | Verify every code change traces to a spec requirement |
| `lsa-sync` | Merge delta into permanent module specs; archive feature spec |
| `lsa-revise-constitution` | Propose changes to `/CLAUDE.md` and `/specs/standards/` |

## Working in this repo

Apply `core/ground-rules` on every substantive task. Use `core/actor-template` when authoring or editing any skill, slash command, or workflow.

LSA is **not yet usable on this repo as-is** — see "Known gaps" below.

## Where things live

| Path | What |
|---|---|
| [`vision/VISION.md`](./vision/VISION.md) | Source of truth for design rationale |
| [`vision/specs/`](./vision/specs/) | Permanent design specs (per LSA: never deleted) |
| [`vision/plans/`](./vision/plans/) | Implementation plans (per LSA: temporary, archived after sync) |
| [`vision/experience/`](./vision/experience/) | Source documents the vision distills from (`.docx`) |
| [`core/`](./core/) | The `core` plugin |
| [`lsa/`](./lsa/) | The `lsa` plugin |
| [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json) | Marketplace catalog |

## Discipline

- **Per-plugin SemVer + CHANGELOG.** Every plugin maintains `<plugin>/CHANGELOG.md` (Keep a Changelog format) paired with a SemVer in `<plugin>/.claude-plugin/plugin.json`. **Bump version in the same commit as the changelog entry.** See [`vision/VISION.md`](./vision/VISION.md) §1 "Distribution + versioning".
- **Spec-grounding.** Every code/spec/skill change should trace to a spec or plan. Currently aspirational — LSA v0.1.1 doesn't yet adapt to this repo's `vision/specs/` layout; see [`lsa/CHANGELOG.md`](./lsa/CHANGELOG.md) `[Unreleased]` for v0.2.0 work.
- **Fact-grounding.** Every claim with a path:line + quote. No hedging in place of sourcing.
- **GitHub account.** This repo lives at `github.com/NVZver/claude-marketplace`. Push under the `NVZver` GitHub account (`gh auth switch` if needed) — not the work account.

## Known gaps

This CLAUDE.md is a **bridge**, not yet the LSA constitution. LSA's `lsa-init` expects a `/CLAUDE.md` and writes to `/specs/` at repo root; this repo's truth source is `vision/VISION.md` and specs live under `vision/specs/`. LSA v0.2.0 will accept overrides so the two reconcile cleanly. Until then:

- **Do not run `/lsa:init` against this repo.** It would create a parallel `/specs/` shadow that drifts from `vision/specs/`.
- `core/ground-rules` and `core/actor-template` apply freely — they're filesystem-agnostic.
- The other LSA skills (`lsa-specify`, `lsa-plan`, etc.) will trigger by description match but their I/O assumes the standard LSA layout. Treat their output as advisory until v0.2.0.

For the migration history that produced this state, see [`lsa/CHANGELOG.md`](./lsa/CHANGELOG.md) v0.1.0 entry.
