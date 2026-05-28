# Helper

Friendly fact-grounded assistant for the NVZver marketplace. Two surfaces:

- **`/help`** — explicit slash command. Ask a question or request a walkthrough.
- **Auto-engaging subagent** — activates on user-friction signals: two consecutive `lsa:discover` User Verification rejections, a free-form `?` / `what is X?` mid-flow, or explicit `/help`.

Inherits [`core/output`](../core/skills/output/SKILL.md) discipline: ≤1.5 screens per turn, `AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs — project jargon re-grounded on first turn-use. Says "I cannot verify this" rather than fabricating, per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 2.

Spec: [`.lsa/features/2026-05-21-helper-agent/`](../.lsa/features/2026-05-21-helper-agent/). Rationale: [`.lsa/VISION.md`](../.lsa/VISION.md).

## Status — v0.2.0 feature-complete

Built in 4 steps per [`tasks.md`](../.lsa/features/2026-05-21-helper-agent/tasks.md). Steps 1–3 landed as v0.1.0 (the description-matched assistant + `/help` command); step 4 ships as v0.2.0 — the auto-engage path. All three invocation paths are now wired: (c) explicit `/help`, (a) two consecutive `[c] reject` selections at an `lsa:discover` User Verification, (b) free-form `?` / `what is X?` mid-flow. Per-signal-type cooldown prevents nag.

| Step | Adds | In this commit? |
|---|---|---|
| 1 | Plugin manifest, CHANGELOG, README, command + agent stubs, marketplace entry | ✓ |
| 2 | Helper agent body + two knowledge files ([`output-discipline.md`](./knowledge/output-discipline.md), [`knowledge-scope.md`](./knowledge/knowledge-scope.md)). Answers with citations, handoff to skills under explicit `AskUserQuestion`, cannot-ground fallback. | ✓ |
| 3 | `/help` command body ([`./commands/help.md`](./commands/help.md)) — free-form dispatch with `<question>` arg + empty-arg starter-topic picker (install / pick a skill / explain a concept). Thin shell that delegates to `Skill(helper)`. | ✓ |
| 4 | Friction-signal detection + per-signal-type cooldown. New knowledge file ([`friction-signals.md`](./knowledge/friction-signals.md)) defines signals (a) User-Verification-reject, (b) free-form question, (c) `/help`; agent body's Step 1 checks cooldown before responding; declined auto-engages stay declined until a different signal-type fires or the user pulls with `/help`. | ✓ |
| v0.3.0 | Answer-first refactor — Helper from command-router to assistant. Agent body Steps 1/3/5 reshaped: Step 1 adds a goal-restatement sub-step; Step 3 prefixes the answer with the goal sentence; Step 5 becomes conditional (clean exit OR fork-only `AskUserQuestion`). Bare `/help` now prompts inline in Helper's voice instead of opening a 3-option starter-topic picker; the starter topics live in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md) as examples, not runtime forks. Adds the "Genuine fork — operating definition" rule. Per [`.lsa/features/2026-05-22-helper-assistant-refactor/`](../.lsa/features/2026-05-22-helper-assistant-refactor/). **v0.3.0 also adds onboarding fast-path** — README-cited answer in seconds for install / start / what-is questions; deep-research path unchanged for everything else. New Knowledge file [`./knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md) holds the 6-row catalog; new Step 1.5 in [`./agents/helper.md`](./agents/helper.md) wires it in. Per [`.lsa/features/2026-05-22-helper-onboarding-fast-path/`](../.lsa/features/2026-05-22-helper-onboarding-fast-path/). | ✓ |
| v0.3.1 | Step 5 citation upgraded to point at canonical [`core/output`](../core/skills/output/SKILL.md) Rule 5 (*Genuine-fork test*); local § *Genuine fork — operating definition* referenced as re-grounded summary. Step 5 wording unchanged. Per [`.lsa/features/2026-05-22-askuserquestion-audit/`](../.lsa/features/2026-05-22-askuserquestion-audit/) Epic C. | ✓ |

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/plugin install helper@NVZver
/reload-plugins
```

Install `core` and `lsa` first — `helper` cites `core/output` for response discipline and observes `lsa:discover` User-Verification-reject answers for auto-engage signal (a).

## Depends on

- **`core`** — `core/output` (response discipline), `core/ground-rules` (cannot-verify fallback), `core/actor-template` (Actor shape for the Helper agent).
- **`lsa`** — `lsa:discover` for auto-engage signal (a). One-way: `lsa:discover` stays unaware of `helper`. Signals (b) and (c) work without `lsa:discover` active.
- **`context7` MCP server** (optional) — external library docs when subject is outside repo + installed-plugin scope.

Claude Code's plugin manifest does not yet expose a `dependencies` field; dependencies are prose-only here and in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) `description`. Adopt the field when Claude Code adds it (per `.lsa/main.spec.md:23`).

## Probes — after this commit

In a fresh Claude Code session:

**V1 (install).** `/plugin marketplace add NVZver/claude-marketplace` → `/plugin install helper@NVZver` → `/plugin list` shows `helper` alongside `core` and `lsa`.

**V2 (description-match — signal c).** `/help what is the Standard flow?` → Helper responds with a definition cited to `.lsa/VISION.md` + `core/skills/flow-selector/SKILL.md`, ≤1.5 screens, closing `AskUserQuestion`. `/help` alone opens the 3-option starter picker.

**V3 (auto-engage — signal b).** Mid-session (no skill active), type `what is lsa:verify?` → Helper auto-engages without `/help`, cites `lsa/skills/verify/SKILL.md`, closing picker.

**V3 (auto-engage — signal a).** Run `lsa:discover` for a new feature; at any User Verification, pick `[c] reject`; on the re-presentation pick `[c] reject` again → Helper auto-engages with `AskUserQuestion`: *"Want me to explain what this User Verification is checking? — Yes / No"*. Yes → re-grounded Verification purpose. No → Helper steps back; the same Verification sequence does not re-trigger Helper (cooldown).

**Cooldown probe.** After declining a signal-(a) or signal-(b) auto-engage with No, re-trigger the same signal-type immediately → Helper does NOT re-engage. Trigger a different signal-type (or `/help`) → Helper engages again. Per [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md).

Probes follow `.lsa/standards/testing.md` V1 → V2 → V3 progression.
