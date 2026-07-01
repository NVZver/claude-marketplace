# Grounding — `reuse-first`

Verdict: **GROUNDED** — every cited reference resolves to a real `file:line`; no requirement
depends on a mechanism that does not exist. No blockers. Safe to delegate.

## Reference map

| Reference | Status |
|-----------|--------|
| `core` module artifact_paths (skills/CLAUDE.md/README/plugin.json/tests) | exists @ `.lsa.yaml:10-19` |
| `core` current version `0.14.1` | exists @ `core/.claude-plugin/plugin.json:4` |
| Actor-template shape (Goal/Input/Steps/Output/Constraints, observable results) | exists @ `core/skills/actor-template/SKILL.md:14-21` (cross-confirmed `.lsa/modules/core/spec.md:21`, `core/tests/repo-anchored.md:99-107`) |
| Trace directive + description-auto-trigger pattern to mirror | exists @ `core/skills/flow-selector/SKILL.md:3,6` |
| ground-rules R3 "Read the real source" | exists @ `core/skills/ground-rules/SKILL.md:67` |
| ground-rules R4 "Deliver only what was asked" | exists @ `core/skills/ground-rules/SKILL.md:77` |
| reconcile "only" check | exists @ `lsa/skills/reconcile/SKILL.md:33` |
| Always-on block (3 rules today) | exists @ `core/CLAUDE.md:24-33` |
| Stale "Two…discipline skills" count | exists @ `core/README.md:3` (lists four at `:7-10`) |
| Module spec "four skills" | exists @ `.lsa/modules/core/spec.md:5,17` |
| Falsifiable threshold model for tests | exists @ `core/tests/repo-anchored.md:209` |
| MINOR-bump rule for a new skill | exists @ `.claude/rules/plugin-development.md` §Version Management |
| `core/skills/reuse-first/SKILL.md` | **new** |
| `core/tests/repo-anchored.md` Set E (E1/E2) | **new** |
| `core/CHANGELOG.md` `[Unreleased]` entry | **new** (file exists per `core/tests/repo-anchored.md:27`) |

## Feasibility

The `reuse-ladder` flow is buildable on what exists — it is pure Markdown skill authoring in an
established pattern (description-based auto-trigger already used by `flow-selector`), plus
same-commit packaging deltas. No new runtime mechanism is required. All `[ASSUMPTION]` markers
from `discover` (the stale `core/README.md:3` count) are visible and folded into F-scope, not
expanded.
