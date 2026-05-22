# Helper

Friendly fact-grounded assistant for the NVZver marketplace. Two surfaces:

- **`/help`** — explicit slash command. Ask a question or request a walkthrough.
- **Auto-engaging subagent** — activates on user-friction signals: two consecutive `lsa-specify` User Verification rejections, a free-form `?` / `what is X?` mid-flow, or explicit `/help`.

Inherits [`core/output`](../core/skills/output/SKILL.md) discipline: ≤1.5 screens per turn, `AskUserQuestion` for every decision, project jargon re-grounded on first turn-use. Says "I cannot verify this" rather than fabricating, per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 2.

Spec: [`vision/specs/features/2026-05-21-helper-agent/`](../vision/specs/features/2026-05-21-helper-agent/). Rationale: [`vision/VISION.md`](../vision/VISION.md).

## Status — v0.2.0 feature-complete

Built in 4 steps per [`tasks.md`](../vision/specs/features/2026-05-21-helper-agent/tasks.md). Steps 1–3 landed as v0.1.0 (the description-matched assistant + `/help` command); step 4 ships as v0.2.0 — the auto-engage path. All three invocation paths are now wired: (c) explicit `/help`, (a) two consecutive `[c] reject` selections at an `lsa-specify` User Verification, (b) free-form `?` / `what is X?` mid-flow. Per-signal-type cooldown prevents nag.

| Step | Adds | In this commit? |
|---|---|---|
| 1 | Plugin manifest, CHANGELOG, README, command + agent stubs, marketplace entry | ✓ |
| 2 | Helper agent body + two knowledge files ([`output-discipline.md`](./knowledge/output-discipline.md), [`knowledge-scope.md`](./knowledge/knowledge-scope.md)). Answers with citations, handoff to skills under explicit `AskUserQuestion`, cannot-ground fallback. | ✓ |
| 3 | `/help` command body ([`./commands/help.md`](./commands/help.md)) — free-form dispatch with `<question>` arg + empty-arg starter-topic picker (install / pick a skill / explain a concept). Thin shell that delegates to `Skill(helper)`. | ✓ |
| 4 | Friction-signal detection + per-signal-type cooldown. New knowledge file ([`friction-signals.md`](./knowledge/friction-signals.md)) defines signals (a) User-Verification-reject, (b) free-form question, (c) `/help`; agent body's Step 1 checks cooldown before responding; declined auto-engages stay declined until a different signal-type fires or the user pulls with `/help`. | ✓ |

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/plugin install helper@NVZver
/reload-plugins
```

Install `core` and `lsa` first — `helper` cites `core/output` for response discipline and observes `lsa-specify` User-Verification-reject answers for auto-engage signal (a).

## Depends on

- **`core`** — `core/output` (response discipline), `core/ground-rules` (cannot-verify fallback), `core/actor-template` (Actor shape for the Helper agent).
- **`lsa`** — `lsa-specify` for auto-engage signal (a). One-way: `lsa-specify` stays unaware of `helper`. Signals (b) and (c) work without `lsa-specify` active.
- **`context7` MCP server** (optional) — external library docs when subject is outside repo + installed-plugin scope.

Claude Code's plugin manifest does not yet expose a `dependencies` field; dependencies are prose-only here and in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) `description`. Adopt the field when Claude Code adds it (per `vision/specs/main.spec.md:23`).

## Probes — after this commit

In a fresh Claude Code session:

**V1 (install).** `/plugin marketplace add NVZver/claude-marketplace` → `/plugin install helper@NVZver` → `/plugin list` shows `helper` alongside `core` and `lsa`.

**V2 (description-match — signal c).** `/help what is the Standard flow?` → Helper responds with a definition cited to `vision/VISION.md` + `core/skills/flow-selector/SKILL.md`, ≤1.5 screens, closing `AskUserQuestion`. `/help` alone opens the 3-option starter picker.

**V3 (auto-engage — signal b).** Mid-session (no skill active), type `what is lsa-verify?` → Helper auto-engages without `/help`, cites `lsa/skills/lsa-verify/SKILL.md`, closing picker.

**V3 (auto-engage — signal a).** Run `lsa-specify` for a new feature; at any User Verification, pick `[c] reject`; on the re-presentation pick `[c] reject` again → Helper auto-engages with `AskUserQuestion`: *"Want me to explain what this User Verification is checking? — Yes / No"*. Yes → re-grounded Verification purpose. No → Helper steps back; the same Verification sequence does not re-trigger Helper (cooldown).

**Cooldown probe.** After declining a signal-(a) or signal-(b) auto-engage with No, re-trigger the same signal-type immediately → Helper does NOT re-engage. Trigger a different signal-type (or `/help`) → Helper engages again. Per [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md).

Probes follow `vision/specs/standards/testing.md` V1 → V2 → V3 progression.
