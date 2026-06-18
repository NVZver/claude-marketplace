---
name: separation-of-concerns
description: Classification table and boundary violations for plugin file categories (Knowledge vs Actor)
---

> **Trace.** On load, print first: `=============== [prompt-engineer/knowledge/separation-of-concerns.md] [prompt-engineer] ===============`

# Separation of Concerns

All plugin files fall into exactly one of two categories. These categories never overlap.

**Knowledge** — knows **what** (patterns, rules, best practices, examples, resources).
**Actor** — knows **how** (Goal, Input, Steps, Output — operates on knowledge).

An actor references knowledge files but never restates their content. A knowledge file defines rules but never describes execution flow. If content belongs in both, it belongs in knowledge — the actor references it.

## How to classify

Classify by **content**, not file location. A SKILL.md with Goal/Steps/Output is an actor; a SKILL.md with only rules/patterns is knowledge.

| Content shape | Category | Contains |
|--------------|----------|----------|
| Has Goal, Input, Steps, Output | Actor | Execution flow — applies rules from knowledge files |
| Has numbered rules, no Steps | Knowledge | Rules, quality criteria, patterns, examples |

Common locations (default category, overridden by content shape):

| File location | Default | Examples |
|--------------|---------|----------|
| `agents/*.md` | Actor | `developer.md`, `helper.md` |
| `commands/*.md` | Actor | `prompt-review.md`, `prompt-create.md` |
| `skills/*/SKILL.md` | Either | Actor: `discover`, `verify`, `plan`. Knowledge: `ground-rules`, `output` |
| `knowledge/*.md` | Knowledge | `conventions.md`, `quality-gate-contract.md` |
| `rules/*.md` | Knowledge | `plugin-development.md` |

## Boundary violations (always HIGH severity)

- Actor restates a rule from a knowledge file → remove from actor, reference the knowledge file
- Actor inlines examples or patterns from a knowledge file → remove, let knowledge file provide them
- Actor constraint restates a quality rule → rewrite as behavioral boundary
- Knowledge file contains execution steps, Goal, or Output format → move to actor
- Same rule appears in two knowledge files → consolidate into one, other references it
