# Testing Standards — claude-marketplace

## Manual probes per plugin

Each plugin defines manual V1 / V2 / V3 probes in its `VERIFICATION.md` (or equivalent). The `core` plugin has [`core/VERIFICATION.md`](../../../core/VERIFICATION.md); `lsa` documents its probes inside `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §13 until an `lsa/VERIFICATION.md` is added. The probes are:

- **V1 — installs cleanly.** `/plugin marketplace add NVZver/claude-marketplace`, `/plugin install <plugin>@NVZver`, `/help` lists every skill in the plugin.
- **V2 — description-match triggers reliably.** One short probe per skill in a fresh session. Either an explicit invocation or behavior consistent with the skill's body counts as PASS.
- **V3 — behavior change is observable.** Run the same small task with and without the plugin; compare on the three Vision §5 metrics: accuracy / facts-with-sources / only-required-changes.

Run probes on a fresh session of each surface. No automated harness in this release — per `vision/VISION.md` §6 *"Adjust #3"*: *"Statistical eval rigor… genuinely overkill for v1, defer."*

## ~90% description-match threshold

Source: `vision/specs/archive/2026-05-20-core-v1/design.md` §13 — the falsifiable threshold for description-match triggers. Across two weeks of regular use, log every session where a skill *should* have fired (any factual claim made, any non-trivial task started, etc.). If a skill fires on **fewer than ~90% of intended tasks**, that is a failure mode — not a wording tweak. Revisit the description or the always-on `CLAUDE.md` fragment option.

Applies to `core/ground-rules`, `core/actor-template`, `core/tier-selector`, `lsa-discover`, and `lsa-reconcile`. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §13 *"Falsifiable threshold"*.

## Statistical eval explicitly deferred

Wilson CIs, Elo head-to-head ranking, variance-aware regression checks are **out of scope** for this release. Source: `vision/VISION.md` §6 Adjust #3 — *"The day 'did my edit make this better or worse?' becomes unanswerable with pass/fail, this is the tool. Not before."*

The three metrics — accuracy to task, proven facts with sources, only-required-changes — are tracked as pass/fail counts per archived T3 feature in `${specs_root}/archive/<feature>/metrics.md`, written by `lsa-verify` on clean PASS. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §9.

## Run V1 first

When introducing a new skill: write a stub frontmatter file, install, run V1 (does `/help` list the skill?), *then* write the body. Source: `vision/specs/archive/2026-05-20-core-v1/design.md` §13 — *"Run V1 first, not last."*
