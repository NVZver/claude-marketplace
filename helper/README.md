# Helper

Friendly fact-grounded assistant for the NVZver marketplace. Two surfaces:

- **`/help`** — explicit slash command. Ask a question or request a walkthrough.
- **Auto-engaging subagent** — activates on user-friction signals: two consecutive `lsa:discover` User Verification rejections, a free-form `?` / `what is X?` mid-flow, or explicit `/help`.

Inherits [`core/output`](../core/skills/output/SKILL.md) discipline: ≤1.5 screens per turn, `AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs — project jargon re-grounded on first turn-use. Says "I cannot verify this" rather than fabricating, per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 2.

Spec (absorbed into the module spec): [`.lsa/modules/helper/spec.md`](../.lsa/modules/helper/spec.md). Rationale: [`.lsa/VISION.md`](../.lsa/VISION.md).

## Status — v0.6.0

Built from the original 4-step helper-agent spec (since absorbed into [`.lsa/modules/helper/spec.md`](../.lsa/modules/helper/spec.md)). All three invocation paths are wired: (c) explicit `/help`, (a) two consecutive `[c] reject` selections at an `lsa:discover` User Verification, (b) free-form `?` / `what is X?` mid-flow. Per-signal-type cooldown prevents nag. Later releases adopted the `core` gate-delivery contract (agent proposes, dispatcher gates). The per-release history is the table below + [`CHANGELOG.md`](./CHANGELOG.md).

| Step | Adds | In this commit? |
|---|---|---|
| 1 | Plugin manifest, CHANGELOG, README, command + agent stubs, marketplace entry | ✓ |
| 2 | Helper agent body + two knowledge files ([`output-discipline.md`](./knowledge/output-discipline.md), [`knowledge-scope.md`](./knowledge/knowledge-scope.md)). Answers with citations, handoff to skills under explicit `AskUserQuestion`, cannot-ground fallback. | ✓ |
| 3 | `/help` command body ([`./commands/help.md`](./commands/help.md)) — free-form dispatch with `<question>` arg + empty-arg starter-topic picker (install / pick a skill / explain a concept). Thin shell that delegates to Helper (dispatch corrected to the `Agent` tool in v0.5.0 — `Skill(helper)` never existed). | ✓ |
| 4 | Friction-signal detection + per-signal-type cooldown. New knowledge file ([`friction-signals.md`](./knowledge/friction-signals.md)) defines signals (a) User-Verification-reject, (b) free-form question, (c) `/help`; agent body's Step 1 checks cooldown before responding; declined auto-engages stay declined until a different signal-type fires or the user pulls with `/help`. | ✓ |
| v0.3.0 | Answer-first refactor — Helper from command-router to assistant. Agent body Steps 1/3/5 reshaped: Step 1 adds a goal-restatement sub-step; Step 3 prefixes the answer with the goal sentence; Step 5 becomes conditional (clean exit OR fork-only `AskUserQuestion`). Bare `/help` now prompts inline in Helper's voice instead of opening a 3-option starter-topic picker; the starter topics live in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md) as examples, not runtime forks. Adds the "Genuine fork — operating definition" rule. Per [`.lsa/features/2026-05-22-helper-assistant-refactor/`](../.lsa/archive/2026-05-22-helper-assistant-refactor/). **v0.3.0 also adds onboarding fast-path** — README-cited answer in seconds for install / start / what-is questions; deep-research path unchanged for everything else. New Knowledge file [`./knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md) holds the 6-row catalog; new Step 1.5 in [`./agents/helper.md`](./agents/helper.md) wires it in. Per [`.lsa/features/2026-05-22-helper-onboarding-fast-path/`](../.lsa/archive/2026-05-22-helper-onboarding-fast-path/). | ✓ |
| v0.3.1 | Step 5 citation upgraded to point at canonical [`core/output`](../core/skills/output/SKILL.md) Rule 5 (*Genuine-fork test*); local § *Genuine fork — operating definition* referenced as re-grounded summary. Step 5 wording unchanged. Per [`.lsa/features/2026-05-22-askuserquestion-audit/`](../.lsa/features/2026-05-22-askuserquestion-audit/) Epic C. | ✓ |
| v0.3.2 | Prompt audit remediation — dead spec-links fixed across [`./agents/helper.md`](./agents/helper.md), [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md), [`./knowledge/knowledge-scope.md`](./knowledge/knowledge-scope.md), this README, and [`./VERIFICATION.md`](./VERIFICATION.md); restated knowledge removed from the agent's Steps + Constraints (cooldown, onboarding matching, genuine-fork test) — now cited by path. Per PR #32 (commit f39ec4a, 2026-05-27). | ✓ |
| v0.4.0 | Onboarding fast-path catalog expansion + heading-anchor citation migration (Stage 1 / Epic 2 of `readme-and-knowledge-base`). Catalog grows **6 → 8 rows** — adds *what is `management`* + *what is `prompt-engineer`*, covering all five shipped plugins. Citation format migrated from `file:line-range` to `file#heading-anchor` (anchors survive line shifts; line ranges broke silently on every edit); new repo-root [`knowledge/index.md`](../knowledge/index.md) is the heading-name source of truth. `plugin.json` description updated to match. Per [`.lsa/pitches/readme-and-knowledge-base.md`](../.lsa/pitches/readme-and-knowledge-base.md). | ✓ |
| v0.5.0 | **Gate-delivery inversion** (adopts `core` 0.13.0 Rule 5 *Self-contained gates* + Rule 7 *Delivery test*). Helper as a subagent cannot run `AskUserQuestion`/`Skill` — the agent now returns its answer + pending gates + a staged `Skill()` seed; the dispatcher ([`./commands/help.md`](./commands/help.md) or the main agent on friction signals) delivers the answer through a rendered channel, runs the pickers, and invokes confirmed handoffs. Also fixes `/help`'s dangling `Skill(helper)` dispatch (helper is an agent, not a skill). | ✓ |
| v0.5.1 | Inherited-ground-rules count synced to `core` 0.14.0 — [`./agents/helper.md`](./agents/helper.md) now cites **eight** content rules (added *done is a gate-proven cited predicate*). | ✓ |
| v0.5.2 | Doc-accuracy fix (quality audit, iteration 3) — this README's `## Status` header and lede updated to describe current state instead of a stale `v0.2.0` snapshot. | ✓ |
| v0.5.3 | Step-numbering fix (quality audit, iteration 4) — [`./agents/helper.md`](./agents/helper.md)'s fractional `1.5` step renumbered to a clean 1–6; in-file back-references updated. No behavior change. | ✓ |
| v0.5.4 | Cross-reference fix from the `observer` plugin addition — [`./knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md) row 3 repointed to the renamed `#the-six-plugins` anchor; "five-plugin table" → "six-plugin table". | ✓ |
| v0.6.0 | **Catalog-surface sweep** (per the `catalog-surface-drift` pitch, `.lsa/pitches/catalog-surface-drift.md`) — `plugin.json` declares `"dependencies": ["core", "lsa"]` (the manifest field exists and is functional; see "Depends on" below); onboarding fast-path catalog grows **8 → 9 rows** (adds *what is `observer`*, covering all six shipped plugins); this README's status header + release table brought current. | ✓ |

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

Claude Code's plugin manifest exposes a `dependencies` field — the official plugins-reference documents it (*"Other plugins this plugin requires, optionally with semver version constraints"*, code.claude.com/docs/en/plugins-reference), functional since Claude Code v2.1.110 — and [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) declares `"dependencies": ["core", "lsa"]` (bare-name form, matching the `lsa`/`manager`/`observer` manifests). The `context7` MCP server stays prose-only (optional, not a marketplace plugin).

## Probes — after this commit

In a fresh Claude Code session:

**V1 (install).** `/plugin marketplace add NVZver/claude-marketplace` → `/plugin install helper@NVZver` → `/plugin list` shows `helper` alongside `core` and `lsa`.

**V2 (description-match — signal c).** `/help what is the Standard flow?` → Helper responds with a definition cited to `.lsa/VISION.md` + `core/skills/flow-selector/SKILL.md`, ≤1.5 screens, closing `AskUserQuestion`. `/help` alone prompts inline in Helper's voice for a question (no starter picker, per v0.3.0).

**V3 (auto-engage — signal b).** Mid-session (no skill active), type `what is lsa:verify?` → Helper auto-engages without `/help`, cites `lsa/skills/verify/SKILL.md`, closing picker.

**V3 (auto-engage — signal a).** Run `lsa:discover` for a new feature; at any User Verification, pick `[c] reject`; on the re-presentation pick `[c] reject` again → Helper auto-engages with `AskUserQuestion`: *"Want me to explain what this User Verification is checking? — Yes / No"*. Yes → re-grounded Verification purpose. No → Helper steps back; the same Verification sequence does not re-trigger Helper (cooldown).

**Cooldown probe.** After declining a signal-(a) or signal-(b) auto-engage with No, re-trigger the same signal-type immediately → Helper does NOT re-engage. Trigger a different signal-type (or `/help`) → Helper engages again. Per [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md).

Probes follow `.lsa/standards/testing.md` V1 → V2 → V3 progression.
