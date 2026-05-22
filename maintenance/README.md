# Maintenance

A single-skill plugin that keeps the repo slim and context-window-friendly without breaking anything. For the "why" behind this package, see [`../vision/VISION.md`](../vision/VISION.md) §3 (core + packs).

## What's here

| Skill | Purpose |
|---|---|
| **`cleanup`** | Audit every behavior-bearing Markdown file in the repo; propose token-reducing patches as a staged uncommitted diff + a report. Refuses any patch that would change one of 6 invariants. Refuses to run on `main` or with uncommitted changes. Stages but never commits. |

## How it works

Invoke `/maintenance:cleanup` on a clean feature branch. The skill produces two artifacts:

1. **A staged diff** — `git diff --staged` shows the proposed changes; you review + apply via your normal commit flow (e.g., `/commit-commands:commit`).
2. **A report** — `vision/reports/cleanup-<YYYY-MM-DD>.md` with per-file before/after token counts, aggregate delta, skipped-patch list (with `file:line` citations), and false-positive whitelist.

The skill preserves these 6 invariants on every patch (anything that would break one is **excluded** and logged):

1. Every `SKILL.md` `description:` frontmatter — byte-identical.
2. Public `name` fields in `SKILL.md` + `plugin.json` — unchanged.
3. Every cited `file:line` link — still resolves to a real file.
4. Rule IDs (Rule 0..6, golden-rule names, EARS patterns) — unchanged.
5. SemVer in `plugin.json` + first `## [X.Y.Z]` CHANGELOG entry — unchanged (version bumps are a separate concern).
6. Frontmatter `model` / `tools` / `argument-hint` on any actor — unchanged.

After staging, a 12-check verification protocol runs (frontmatter intact, descriptions byte-identical, JSON parses, etc.). Any FAIL → `git restore` on every staged file + the report names the failing check with a `file:line` citation. Working tree returns to pre-run state.

## Per-class token budgets

The skill flags files exceeding these budgets (it does not auto-fix; it surfaces the candidate):

| Class | Budget |
|-------|--------|
| skill body (`SKILL.md`) | ≤ 2,000 tokens |
| knowledge file | ≤ 3,000 tokens |
| per-plugin README | ≤ 1,500 tokens |
| per-plugin `CLAUDE.md` | ≤ 1,000 tokens |
| module `spec.md` | ≤ 1,500 tokens |
| `VISION.md` (constitution) | ≤ 6,000 tokens |
| `main.spec.md` | ≤ 1,500 tokens |

Budgets are chosen so all routinely-loaded artifacts fit a 32k-token context window even when several load together — keeping the repo performant on smaller / local models (Ollama, Mistral).

## Depends on

[`core`](../core/) — specifically [`core/actor-template`](../core/skills/actor-template/SKILL.md) for the skill body shape and [`core/output`](../core/skills/output/SKILL.md) Rule 5 (Concrete) for prompt voice on every user-facing picker.

`maintenance` does **not** depend on `lsa`. The skill is orthogonal to the spec lifecycle — it operates on content discipline (slimness, citation integrity), not spec-grounding. You can run `/lsa:verify` and `/maintenance:cleanup` serially, but they don't compose.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install maintenance@NVZver
/reload-plugins
```

Install `core` first — `maintenance` cites it. Invoke directly via `/maintenance:cleanup`, or let Claude trigger by description match ("cleanup the repo", "trim the repo", "run /maintenance:cleanup").

## Install on Claude.ai

The cleanup skill writes a report to disk + manipulates the git index — it depends on a filesystem + git CLI. **Not recommended for Claude.ai**; the skill will trigger by description but cannot complete its I/O.

## Verification probes

Per [`vision/specs/standards/testing.md`](../vision/specs/standards/testing.md):

- **V1 — installs cleanly.** `/plugin install maintenance@NVZver`; `/help` lists `/maintenance:cleanup`.
- **V2 — description-match triggers reliably.** Probes in a fresh session: *"cleanup the repo"*, *"trim repo for smaller models"*, *"run a maintenance pass"*. Target ≥ 90% trigger rate.
- **V3 — behavior observable.** Run on a clean feature branch with known bloat candidates; expect a non-empty staged diff + report showing token reduction; verify all 6 invariants intact via the 12-check protocol.
