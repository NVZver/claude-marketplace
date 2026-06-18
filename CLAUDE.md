# CLAUDE.md

This repository is the **NVZver claude-marketplace** — a personal, model-agnostic agentic engineering system distributed via Claude Code's plugin marketplace.

Operating rules live in [`.lsa/VISION.md`](./.lsa/VISION.md) — that file is the constitution. LSA configuration is at [`./.lsa.yaml`](./.lsa.yaml). This file is the slim Claude Code entry point.

## Default plugins

Five plugins ship from this marketplace ([`README.md#the-five-plugins`](./README.md#the-five-plugins) lists all of them). Two — `core` and `lsa` — form the required development discipline; the other three (`helper`, `manager`, `prompt-engineer`) are optional. **Install at least the required pair:**

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

Install `core` first — `lsa` cites it for fact-grounding and flow-selection (see [`lsa/README.md`](./lsa/README.md) → "Depends on"). For the full install (all five plugins) see [`README.md#install`](./README.md#install).

## Always-on rules

The canonical always-on fragment lives at [`core/CLAUDE.md`](./core/CLAUDE.md): apply `core/ground-rules` to every substantive task (8 content rules); apply [`core/output`](./core/skills/output/SKILL.md) to every human-facing output (format discipline — one hard rule plus guidance; see the skill); invoke `core/flow-selector` (renamed from `core/tier-selector` in `core` v0.5.2) before any non-trivial task. The flow types (Quick / Standard / Extended — was T1/T2/T3) and boundary signals are at [`.lsa/VISION.md`](./.lsa/VISION.md) §4. The operating credo is **ownership over automation** — see [`core/CLAUDE.md`](./core/CLAUDE.md) Rule 0.

## Discipline (sourced)

- **Per-plugin SemVer + CHANGELOG** — every plugin maintains its own `CHANGELOG.md` (Keep a Changelog) and SemVer in `plugin.json`. Bump version in the same commit as the changelog entry. Per [`.lsa/VISION.md`](./.lsa/VISION.md) §1 *"Distribution + versioning"*.
- **Spec-grounding + Fact-grounding** — every artifact change traces to a spec; every claim carries a source + searchable quote. Direct artifact edits are absorbed via `reconcile` (Level 2.5). Per [`.lsa/VISION.md:35-36`](./.lsa/VISION.md).
- **READMEs are living documents.** Any functional change to a plugin — new/removed skill, behavior change to an existing skill, new install/usage step, version bump that affects user-facing surface — updates the relevant README ([`README.md`](./README.md) at the repo root, plus [`core/README.md`](./core/README.md) or [`lsa/README.md`](./lsa/README.md)) in the **same commit**, if any user-visible aspect changed. Pure refactors with no user-visible delta are exempt. README delta lands alongside the CHANGELOG entry and the SemVer bump.
- **GitHub account.** Repo lives at `github.com/NVZver/claude-marketplace`. Push under the `NVZver` GitHub account (`gh auth switch` if needed) — not the work account.

## Further reading

- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — how to build / contribute / verify (start here if you're touching code or specs).
- [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) — directory structure, `.lsa.yaml` schema, branch management.
- [`.lsa/main.spec.md`](./.lsa/main.spec.md) — module index + cross-module contracts + NFRs.
- [`lsa/README.md`](./lsa/README.md), [`core/README.md`](./core/README.md) — per-plugin skill tables.
