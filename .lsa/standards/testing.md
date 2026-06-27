> **Trace.** On load, print first: `=============== [.lsa/standards/testing.md] [vision] ===============`

# Testing Standards — claude-marketplace

## Manual probes per plugin

Each plugin defines manual V1 / V2 / V3 probes in its `VERIFICATION.md` (or equivalent). The `core` plugin has [`core/VERIFICATION.md`](../../core/VERIFICATION.md); `lsa` documents its probes inside `.lsa/2026-05-20-lsa-v0.2.0-design.md` §13 until an `lsa/VERIFICATION.md` is added. The probes are:

- **V1 — installs cleanly.** `/plugin marketplace add NVZver/claude-marketplace`, `/plugin install <plugin>@NVZver`, `/help` lists every skill in the plugin.
- **V2 — description-match triggers reliably.** One short probe per skill in a fresh session. Either an explicit invocation or behavior consistent with the skill's body counts as PASS.
- **V3 — behavior change is observable.** Run the same small task with and without the plugin; compare on the three Vision §5 metrics: accuracy / facts-with-sources / only-required-changes.

Run probes on a fresh session of each surface. No automated harness in this release — per `.lsa/VISION.md` §6 *"Adjust #3"*: *"Statistical eval rigor… genuinely overkill for v1, defer."*

## ~90% description-match threshold

Source: `.lsa/archive/2026-05-20-core-v1/design.md` §13 — the falsifiable threshold for description-match triggers. Across two weeks of regular use, log every session where a skill *should* have fired (any factual claim made, any non-trivial task started, etc.). If a skill fires on **fewer than ~90% of intended tasks**, that is a failure mode — not a wording tweak. Revisit the description or the always-on `CLAUDE.md` fragment option.

Applies to `core/ground-rules`, `core/actor-template`, `core/flow-selector` (renamed from `core/tier-selector` in `core` v0.5.2), `discover`, and `reconcile`. Per `.lsa/2026-05-20-lsa-v0.2.0-design.md` §13 *"Falsifiable threshold"*.

## Statistical eval explicitly deferred

Wilson CIs, Elo head-to-head ranking, variance-aware regression checks are **out of scope** for this release. Source: `.lsa/VISION.md` §6 Adjust #3 — *"The day 'did my edit make this better or worse?' becomes unanswerable with pass/fail, this is the tool. Not before."*

The three metrics — accuracy to task, proven facts with sources, only-required-changes — are tracked as pass/fail counts per archived Extended-flow feature (was `T3`) in `${specs_root}/archive/<feature>/metrics.md`, written by `verify` on clean PASS. Per `.lsa/2026-05-20-lsa-v0.2.0-design.md` §9.

## Run V1 first

When introducing a new skill: write a stub frontmatter file, install, run V1 (does `/help` list the skill?), *then* write the body. Source: `.lsa/archive/2026-05-20-core-v1/design.md` §13 — *"Run V1 first, not last."*

## Guards must be prompt-forced (adversarial dogfooding)

A behavior-bearing prompt (skill, agent, or role/knowledge data) that *describes* a
desired behavior but does not *forbid* its failure mode is not done: a guard that
holds only because the model is generous is not a guard. Verify guards by
**adversarial dogfooding** — generate the behavior from the prompt alone, then have an
**independent** judge (a separate agent/session, never the author) check both (a) did
the output honor the guard, and (b) is the guard written as an *enforceable* line, not
riding on model good-will. Iterate until the guards are forced. This is the prompt
analogue of `reconcile`'s *does* check (run N times; one pass is not proof — see
[`lsa/CORE.md`](../../lsa/CORE.md) §6). Source: observer feature eval,
[`observer/tests/eval-findings-2026-06-27.md`](../../observer/tests/eval-findings-2026-06-27.md)
— 8/8 probes "passed" on model good-will until independent judges forced 5 guards and
caught a silence-leak + a self-introduced regression a describe-only prompt let through.

Scope note: behavioral, not statistical — this does not reintroduce the deferred
Wilson/Elo rigor (§*"Statistical eval explicitly deferred"*); it is a pass/fail
adversarial probe, run when a prompt's failure modes matter.
