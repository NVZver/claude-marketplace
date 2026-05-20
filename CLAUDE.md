# CLAUDE.md

This repository is the **nz-vision claude-marketplace** — a personal, model-agnostic agentic engineering system distributed via Claude Code's plugin marketplace.

Operating rules live in [`vision/VISION.md`](./vision/VISION.md) — that file is the constitution. LSA configuration is at [`./.lsa.yaml`](./.lsa.yaml). This file is the slim Claude Code entry point.

## Default plugins

Two plugins ship from this marketplace and together form the development discipline. **Install both:**

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
/plugin install lsa@nz-vision
/reload-plugins
```

Install `core` first — `lsa` cites it for fact-grounding and tier-selection (see [`lsa/README.md`](./lsa/README.md) → "Depends on").

## Always-on rules

The canonical always-on fragment lives at [`core/CLAUDE.md`](./core/CLAUDE.md): apply `core/ground-rules` to every substantive task; invoke `core/tier-selector` before any non-trivial task. The tier flow (T1 / T2 / T3) and boundary signals are at [`vision/VISION.md`](./vision/VISION.md) §4.

## Discipline (sourced)

- **Per-plugin SemVer + CHANGELOG** — every plugin maintains its own `CHANGELOG.md` (Keep a Changelog) and SemVer in `plugin.json`. Bump version in the same commit as the changelog entry. Per [`vision/VISION.md`](./vision/VISION.md) §1 *"Distribution + versioning"*.
- **Spec-grounding + Fact-grounding** — every artifact change traces to a spec; every claim carries a source + searchable quote. Direct artifact edits are absorbed via `lsa-reconcile` (Level 2.5). Per [`vision/VISION.md:35-36`](./vision/VISION.md).
- **GitHub account.** Repo lives at `github.com/NVZver/claude-marketplace`. Push under the `NVZver` GitHub account (`gh auth switch` if needed) — not the work account.

## Further reading

- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — how to build / contribute / verify (start here if you're touching code or specs).
- [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) — directory structure, `.lsa.yaml` schema, branch management.
- [`vision/specs/main.spec.md`](./vision/specs/main.spec.md) — module index + cross-module contracts + NFRs.
- [`lsa/README.md`](./lsa/README.md), [`core/README.md`](./core/README.md) — per-plugin skill tables.
