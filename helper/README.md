# Helper

Friendly fact-grounded assistant for the NVZver marketplace. Two surfaces:

- **`/help`** — explicit slash command. Ask a question or request a walkthrough.
- **Auto-engaging subagent** — activates on user-friction signals: two consecutive `lsa-specify` gate rejections, a free-form `?` / `what is X?` mid-flow, or explicit `/help`.

Inherits [`core/output`](../core/skills/output/SKILL.md) discipline: ≤1.5 screens per turn, `AskUserQuestion` for every decision, project jargon re-grounded on first turn-use. Says "I cannot verify this" rather than fabricating, per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 2.

Spec: [`vision/specs/features/2026-05-21-helper-agent/`](../vision/specs/features/2026-05-21-helper-agent/). Rationale: [`vision/VISION.md`](../vision/VISION.md).

## Status — under construction

Being built in 4 steps per [`tasks.md`](../vision/specs/features/2026-05-21-helper-agent/tasks.md). **Current commit: step 2 (agent body)** — the assistant answers questions with citations and can hand off to other skills under confirmation. The `/help` command and auto-engage detection still pending.

| Step | Adds | In this commit? |
|---|---|---|
| 1 | Plugin manifest, CHANGELOG, README, command + agent stubs, marketplace entry | ✓ |
| 2 | Helper agent body + two knowledge files ([`output-discipline.md`](./knowledge/output-discipline.md), [`knowledge-scope.md`](./knowledge/knowledge-scope.md)). Answers with citations, handoff to skills under explicit `AskUserQuestion`, cannot-ground fallback. | ✓ |
| 3 | `/help` command body — free-form dispatch + starter-topic picker | pending |
| 4 | Friction-signal detection + per-signal-type cooldown | pending |

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/plugin install helper@NVZver
/reload-plugins
```

Install `core` and `lsa` first — `helper` cites `core/output` for response discipline and observes `lsa-specify` gate-reject answers for auto-engage signal (a).

## Depends on

- **`core`** — `core/output` (response discipline), `core/ground-rules` (cannot-verify fallback), `core/actor-template` (Actor shape for the Helper agent).
- **`lsa`** — `lsa-specify` for auto-engage signal (a). One-way: `lsa-specify` stays unaware of `helper`. Signals (b) and (c) work without `lsa-specify` active.
- **`context7` MCP server** (optional) — external library docs when subject is outside repo + installed-plugin scope.

Claude Code's plugin manifest does not yet expose a `dependencies` field; dependencies are prose-only here and in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) `description`. Adopt the field when Claude Code adds it (per `vision/specs/main.spec.md:23`).

## V1 probe — after this commit

In a fresh Claude Code session:

1. `/plugin marketplace add NVZver/claude-marketplace`
2. `/plugin install helper@NVZver`
3. `/plugin list` → `helper` appears alongside `core` and `lsa`.
4. `/help` (no argument) → stub response pointing to this README and the spec.
5. Description-match the `helper` agent → stub response pointing to step 2.

V2 (description-match triggers reliably) and V3 (behavior change vs `core` + `lsa` alone) land after steps 2–4 per [`vision/specs/standards/testing.md`](../vision/specs/standards/testing.md).
