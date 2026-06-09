# Prompt Engineer

Prompt engineering discipline for Claude Code plugins. An agent enforces quality rules across prompt files (agents, commands, skills, knowledge); commands provide review, optimize, and create workflows.

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install prompt-engineer@NVZver
/reload-plugins
```

## Commands

| Command | What it does |
|---|---|
| `prompt-engineer:prompt-review` | Scan prompts for ground rule, KISS/DRY, AI sweep, context budget, and show-changes-inline violations. Reports findings as a table with severity and rule citation. The show-changes-inline check (warning-only) flags any step body in a prompt source (`**/SKILL.md`, `**/agents/*.md`) that writes/edits/marks an artifact without a directive to quote the change inline — the author-time half of `core/output` Rule 7 enforcement (the PR-time half lives in `lsa:verify`). |
| `prompt-engineer:prompt-optimize` | Apply fixes for issues found by prompt-review. Groups by severity, re-verifies after fixes. |
| `prompt-engineer:prompt-create` | Scaffold a new agent or command file with all required sections, then verify compliance. |

## Agent

| Agent | What it does |
|---|---|
| `prompt-engineer` | Principal prompt engineer. Auto-engages on prompt review, optimization, creation, and analysis requests. Enforces six rule categories: actor ground rules (10), knowledge quality checks (6), separation of concerns (5 boundary violations), KISS/DRY audit (5), AI over-engineering checks (5), context budget checks (4). |

## Rule categories

| Category | Rules | Catches |
|---|---|---|
| Actor ground rules | 10 | Missing sections, vague steps, unverifiable output, wording issues |
| Knowledge quality checks | 6 | Non-actionable rules, duplication, broken cross-references, execution logic in knowledge |
| Separation of concerns | 5 | Actor restating knowledge, knowledge containing steps, cross-boundary violations |
| KISS / DRY audit | 5 | Redundant abstraction, duplicate content, hardcoded formats, multi-concern files |
| AI over-engineering | 5 | Formalized common sense, reinvented paradigms, arbitrary thresholds, example bloat |
| Context budget | 4 | Goal restating description, mergeable constraints, over-constraining examples, padding |
| Show-changes-inline (author-time) | 1 (warning-only) | Step body that writes/edits/marks an artifact with no directive to quote the change inline (`core/output` Rule 7) |
