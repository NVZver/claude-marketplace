# Prompt Engineer — Verification

Portable probes — run on a fresh session of each surface. Repo-pinned probes live in [`tests/repo-anchored.md`](./tests/repo-anchored.md); this file stays generic so it travels with the plugin.

## V1 — Installs cleanly

Run:
```
/plugin marketplace add NVZver/claude-marketplace
/plugin install prompt-engineer@NVZver
/help
```
Expected: `/help` lists `/prompt-engineer:prompt-review`, `/prompt-engineer:prompt-optimize`, and `/prompt-engineer:prompt-create` with their descriptions, and the `prompt-engineer` agent is available.

## V2 — Description-match triggers reliably

**Probe A (review).** In a fresh session: *"Review this agent prompt for quality issues."* Expected: the response scans against the rule categories and returns a findings table with per-row rule citations, or explicitly invokes `prompt-review`. Either is PASS.

**Probe B (create).** In a fresh session: *"Scaffold a new command that lints a config file."* Expected: the response asks for the missing inputs (type/name), then produces a file with the actor sections (Goal / Input / Constraints / Steps / Output / Example Output), or explicitly invokes `prompt-create`. Either is PASS.

**Probe C (separation of concerns).** In a fresh session, point the agent at a prompt that inlines a rule already defined in a knowledge file. Expected: it flags the boundary violation as HIGH and names the knowledge file the rule belongs in. PASS on the HIGH classification; FAIL if it rewrites the rule in place or ignores the duplication.

## V3 — Behavior change is observable

Review the same deliberately flawed prompt twice — once with `prompt-engineer` installed, once without — and compare:

- **Findings cite a rule.** Share of reported issues carrying a rule-category citation.
- **Severity assigned.** Each finding rated HIGH / MEDIUM / LOW (or WARNING for show-changes-inline).
- **No invented fixes.** Reported issues trace to a real rule, not a stylistic preference.

With the plugin, expect a cited, severity-rated table; without it, expect a prose "looks fine" pass or uncited suggestions. The delta is the behavior change the plugin is meant to produce.

## Falsifiable threshold

Across two weeks of regular use, log every session where the prompt-engineer discipline *should* have fired (a prompt file was authored, reviewed, or optimized). If it engages on fewer than **~90% of intended tasks**, that is a failure mode — not a wording tweak — mirroring the threshold `core` holds itself to ([`../core/VERIFICATION.md`](../core/VERIFICATION.md), "Falsifiable threshold"). Separately, on the `tests/repo-anchored.md` B3 sample, a missed **HIGH** (missing Example Output) is a hard failure: the tool let through exactly what it exists to catch.
