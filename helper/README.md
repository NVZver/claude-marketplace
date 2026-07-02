# Helper

Friendly fact-grounded assistant for the NVZver marketplace. Two surfaces:

- **`/help`** — explicit slash command. Ask a question or request a walkthrough.
- **Auto-engaging subagent** — activates on user-friction signals: two consecutive `lsa:discover` User Verification rejections, a free-form `?` / `what is X?` mid-flow, or explicit `/help`.

Inherits [`core/output`](../core/skills/output/SKILL.md) discipline: ≤1.5 screens per turn, `AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs — project jargon re-grounded on first turn-use. Says "I cannot verify this" rather than fabricating, per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 2.

Spec (absorbed into the module spec): [`.lsa/modules/helper/spec.md`](../.lsa/modules/helper/spec.md). Rationale: [`.lsa/VISION.md`](../.lsa/VISION.md).

## How it behaves

All three invocation paths are wired: (c) explicit `/help`, (a) two consecutive rejects at an `lsa:discover` User Verification, (b) free-form `?` / `what is X?` mid-flow. A per-signal-type cooldown prevents nag: a declined auto-engage stays declined until a different signal-type fires or you pull with `/help`. Onboarding questions (install / getting started / what is X) get a README-cited answer in seconds via the fast-path catalog ([`knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md)); everything else takes the deep-research path. Per-release history: [`CHANGELOG.md`](./CHANGELOG.md).

## Example

The snippet is `[illustrative]` (constructed for readability, not copied from a live session):

```text
> /help what is LSA?

LSA = Living Spec Architecture: a spec-first development methodology where specs
are the permanent source of truth and every code change traces to a spec
requirement. The loop is `lsa:discover` → `lsa:specify` → `lsa:verify` →
`lsa:delegate` → `lsa:reconcile`; code-writing is delegated to any implementer.

Sources: README.md#lsa (the loop and its five steps), lsa/README.md
(skill table + credo quote).
```

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

## Verify it works

In a fresh Claude Code session:

**V1 (install).** `/plugin marketplace add NVZver/claude-marketplace` → `/plugin install helper@NVZver` → `/plugin list` shows `helper` alongside `core` and `lsa`.

**V2 (description-match — signal c).** `/help what is the Standard flow?` → Helper responds with a definition cited to `.lsa/VISION.md` + `core/skills/flow-selector/SKILL.md`, ≤1.5 screens, closing `AskUserQuestion`. `/help` alone prompts inline in Helper's voice for a question (no starter picker, per v0.3.0).

**V3 (auto-engage — signal b).** Mid-session (no skill active), type `what is lsa:verify?` → Helper auto-engages without `/help`, cites `lsa/skills/verify/SKILL.md`, closing picker.

**V3 (auto-engage — signal a).** Run `lsa:discover` for a new feature; at any User Verification, pick `[c] reject`; on the re-presentation pick `[c] reject` again → Helper auto-engages with `AskUserQuestion`: *"Want me to explain what this User Verification is checking? — Yes / No"*. Yes → re-grounded Verification purpose. No → Helper steps back; the same Verification sequence does not re-trigger Helper (cooldown).

**Cooldown probe.** After declining a signal-(a) or signal-(b) auto-engage with No, re-trigger the same signal-type immediately → Helper does NOT re-engage. Trigger a different signal-type (or `/help`) → Helper engages again. Per [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md).

Probes follow `.lsa/standards/testing.md` V1 → V2 → V3 progression.
