# Core v1 — Verification

Three manual probes. Run them on a fresh session of each surface. No automated harness in v1 — see spec §6 (deferred eval rigor).

## V1 — Installs cleanly on both surfaces

**Claude Code.** Run:
```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
/help
```
Expected: `/help` lists `/core:ground-rules` and `/core:actor-template` with their full descriptions.

**Claude.ai.** From repo root: `cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/`. Then upload each zip in Settings → Features → Custom Skills. Expected: both appear in the Skills list with their descriptions visible.

## V2 — Description-match triggers reliably

**Probe A (ground-rules).** In a fresh session: *"Tell me whether library X handles retries automatically."* Expected: the response sources the answer with a quote, marks `[cannot verify]`, or explicitly invokes `ground-rules`. Any of those is PASS.

**Probe B (actor-template).** In a fresh session: *"Help me create a new skill that posts daily standup summaries to Slack."* Expected: the response uses the Goal / Input / Steps / Output / Constraints shape, or explicitly invokes `actor-template`. Either is PASS.

**Probe C (tier-selector).** In a fresh session: *"I want to add password-reset via email."* Expected: the response classifies the task as **T3**, names the boundary signals (new behavior, new endpoint, multiple modules touched, no spec yet), and waits for explicit confirmation before any LSA ceremony fires. Either an explicit `tier-selector` invocation or behavior matching this shape is PASS.

**Probe D (output).** In a fresh session: *"Check whether `core/.claude-plugin/plugin.json` exists and report the current version."* Expected: the response is **structured** (verdict line or table — not a paragraph), **minimal** (no fluff, no banned phrasings like *"It's worth noting…"*), **formatted** (the version is rendered in a code span or table cell, not buried in prose), and **sourced** (the version number cites `core/.claude-plugin/plugin.json` with the verbatim version line). All four properties together = PASS; failing any one (paragraph response, padding, no source quote) = FAIL. Either an explicit `output` skill invocation or behavior matching this composed shape is PASS.

Run all four probes on **both** surfaces.

## V3 — Behavior change is observable

Run the same small task twice — once with `core` installed, once without — and compare:

- **Accuracy to task.** Did the output do what was asked, no more, no less?
- **Proven facts with sources.** Share of agent claims carrying a valid source + searchable quote.
- **Only-required-changes.** Did the change touch only what the task needed?

Eyeball it for v1; instrument later (spec §6 adjust #3).

## Falsifiable threshold

Across two weeks of regular use, log every session where `ground-rules` *should* have fired (any factual claim was made or any output overreached). If it fires on fewer than **~90% of intended tasks**, that is a v1 failure mode — not a wording tweak. Revisit the `CLAUDE.md`-fragment option from VISION §3 before tightening the description further.
