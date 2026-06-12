# Helper v0.2.0 — Verification

Manual probes for the friendly fact-grounded assistant. Run on a fresh Claude Code session. No automated harness — Helper's substrate is `AskUserQuestion` + `Skill` + `Read`, none of which currently have programmatic probes. Eyeball it.

> **Since helper v0.5.0** (gate-delivery contract): Helper as a subagent returns its answer + pending gates; the **dispatcher** (`/help` command body or main agent) delivers the answer through a rendered channel and runs the `AskUserQuestion` pickers. Every probe below that expects an `AskUserQuestion` now observes a **dispatcher-run** picker carrying the same content; a probe FAILs if the answer body never renders to the user (e.g. it stayed in the subagent payload) or if a picker opens about content the user was never shown.

Probes are scoped to the v0.2.0 surface: the `helper` subagent + the `/help` slash command + the cooldown rule from [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md). Cited acceptance criteria reference the original helper-agent spec (AC1–AC8) and its test-suites (Journeys 1–3), since absorbed into [`../.lsa/modules/helper/spec.md`](../.lsa/modules/helper/spec.md).

## V1 — Installs cleanly

Run:
```
/plugin marketplace add NVZver/claude-marketplace
/plugin install helper@NVZver
/help
```

Expected: `/help` lists the `helper:help` slash command with the description from [`./commands/help.md`](./commands/help.md) frontmatter. `/plugin list` shows `helper` at `0.2.0` alongside `core` and `lsa`.

## V2 — Description-match triggers reliably

Four probes covering each invocation path.

**Probe A (signal c — explicit slash command, in-repo subject).** Run:
```
/help what is the Standard flow?
```
Expected: Helper response in ≤1.5 screens with `Standard — moderate-effort flow` re-gloss on first use, a `file:line` (or section) citation to `.lsa/VISION.md` and/or `core/skills/flow-selector/SKILL.md`, and a closing `AskUserQuestion` offering 2–3 next steps. **Covers:** AC1, AC7, AC8 (Journey 1 / Happy path).

**Probe B (signal c — slash command, external library subject).** Run:
```
/help what's the context7 MCP?
```
Expected: Helper recognises external subject, fetches via `context7` MCP, responds with `MCP — Model Context Protocol` re-gloss, URL citation, ≤1.5 screens. **Covers:** AC4, AC7, AC8 (Journey 1 / Alternate path).

**Probe C (signal b — free-form question, no skill active).** In a fresh session with no skill running, type:
```
what is lsa:verify?
```
Expected: Helper auto-engages (no `/help` needed) via description-match on signal (b), responds with `LSA — Living Spec Architecture` + `lsa:verify — feature-spec verifier` re-gloss and a `file:line` citation to `lsa/skills/verify/SKILL.md`. **Covers:** AC1 + signal (b) trigger from [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) § *The three signals*.

**Probe D (signal a — consecutive User-Verification rejects).** Start `lsa:discover` for a small fictional feature. At any User Verification, pick `[c] reject`. On the re-presentation, pick `[c] reject` again. Expected: Helper auto-engages with `AskUserQuestion`: *"Want me to explain what this User Verification is checking? — Yes / No"*. On Yes → Helper re-grounds the Verification purpose with a `file:line` citation from `lsa/skills/discover/SKILL.md`. **Covers:** AC2, AC6, AC7, AC8 (Journey 2 / Happy path).

## V3 — Behavior change is observable

Run the same task twice — once with `helper` installed, once without — and compare on the three Vision §5 metrics:

- **Accuracy to task.** Did Helper answer exactly what was asked, no padding?
- **Proven facts with sources.** Share of Helper claims carrying a valid source + searchable quote (file:line or URL).
- **Only-required-changes.** Did Helper avoid spawning subagents, modifying files, or expanding scope beyond the question?

Sample task: *"How do I install the marketplace plugins?"* Without `helper`: an unsourced procedural answer. With `helper`: a citation to `README.md` § *"Default plugins"* (or equivalent), ≤1.5 screens, closing `AskUserQuestion`. PASS if Helper's response wins on at least two of the three metrics.

## Cooldown probe (per signal-type)

Probe the OQ2 resolution rule from [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) § *Cooldown rule*.

**Path 1 — Same-signal cooldown.** Trigger signal (a) per V2 Probe D. On the `AskUserQuestion` *"Want me to explain…?"*, pick **No**. Reject the User Verification a third time (still `[c]`). Expected: Helper does **NOT** re-engage. The original `lsa:discover` User Verification picker re-presents normally. **Covers:** Journey 2 / Alternate path.

**Path 2 — Different-signal-type resets.** After Path 1 (signal a in cooldown), type:
```
what is lsa:discover?
```
Expected: Helper engages on signal (b) — different signal-type, so cooldown does not apply. **Covers:** [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) § *Cooldown rule* item (1).

**Path 3 — Explicit `/help` bypasses cooldown.** After Path 1 (signal a in cooldown), type:
```
/help
```
Expected: Helper engages — signal (c) always bypasses cooldown. **Covers:** [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) § *Cooldown rule* item (2).

## Falsifiable threshold

Across two weeks of regular use, log every session where Helper *should* have auto-engaged (any signal a/b fired). If it engages on fewer than **~90% of intended signals**, that is a description-match failure — rewrite the `description:` in [`./agents/helper.md`](./agents/helper.md), do not tighten the agent body. Per [`../.lsa/standards/testing.md`](../.lsa/standards/testing.md) V2 threshold.

If Helper engages on the *wrong* turns (false-positive auto-engage on a `?` that wasn't a question for Helper), the patterns in [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) § *Trigger patterns — quick reference* need tightening, not the agent body.
