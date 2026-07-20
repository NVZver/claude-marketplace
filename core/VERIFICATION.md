# Core v1 — Verification

Three manual probes. Run them on a fresh session of each surface. No automated harness in v1 — see spec §6 (deferred eval rigor).

## V1 — Installs cleanly on both surfaces

**Claude Code.** Run:
```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/help
```
Expected: `/help` lists `/core:ground-rules` and `/core:actor-template` with their full descriptions.

**Claude.ai.** From repo root: `cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/`. Then upload each zip in Settings → Features → Custom Skills. Expected: both appear in the Skills list with their descriptions visible.

## V2 — Description-match triggers reliably

**Probe A (ground-rules).** In a fresh session: *"Tell me whether library X handles retries automatically."* Expected: the response sources the answer with a quote, marks `[cannot verify]`, or explicitly invokes `ground-rules`. Any of those is PASS.

**Probe B (actor-template).** In a fresh session: *"Help me create a new skill that posts daily standup summaries to Slack."* Expected: the response uses the Goal / Input / Steps / Output / Constraints shape, or explicitly invokes `actor-template`. Either is PASS.

**Probe C (flow-selector — renamed from tier-selector in core v0.5.2).** In a fresh session: *"I want to add password-reset via email."* Expected: the response classifies the task as **Extended** (was `T3`), names the boundary signals (new behavior, new endpoint, multiple modules touched, no spec yet), and waits for explicit confirmation before any LSA ceremony fires. Either an explicit `flow-selector` invocation or behavior matching this shape is PASS.

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

## Agent Skills spec conformance (2026-07-20)

One-off manual run of the [Agent Skills reference validator](https://agentskills.io/specification) (`skills-ref`) over all 20 shipped skills — a third-party check, not our own script. **Not wired into the `gate:` block** (`.lsa.yaml` stays npm-free) or into `scripts/`.

```
$ npx --yes skills-ref validate <skill_path>  # run against all 20 shipped skills
PASS  core/skills/actor-template
PASS  core/skills/doctor
PASS  core/skills/flow-selector
FAIL  core/skills/ground-rules — invalid YAML frontmatter (unquoted colon+space in description)
PASS  core/skills/output
PASS  core/skills/reuse-first
PASS  lsa/skills/delegate
FAIL  lsa/skills/discover — invalid YAML frontmatter (unquoted colon+space in description)
FAIL  lsa/skills/init — invalid YAML frontmatter (unquoted colon+space in description)
FAIL  lsa/skills/reconcile — invalid YAML frontmatter (unquoted colon+space in description)
FAIL  lsa/skills/revise-constitution — invalid YAML frontmatter (unquoted colon+space in description)
FAIL  lsa/skills/specify — invalid YAML frontmatter (unquoted colon+space in description)
FAIL  lsa/skills/verify — invalid YAML frontmatter (unquoted colon+space in description)
PASS  manager/skills/check
PASS  manager/skills/decompose
PASS  manager/skills/implement
PASS  manager/skills/next
PASS  manager/skills/shape
PASS  observer/skills/observe
PASS  observer/skills/verify-checkpoint
```

**Result: 13/20**, not the 20/20 this section's originating pitch (`.lsa/pitches/standards-conformance-agents-md.md`) assumed before this run — the assumption was based on our own `lint.sh` C7/C9 checks (description ≤ 1024 chars, name↔directory match), which are necessary but not sufficient conditions of the spec. Per-plugin: `core 5/6`, `lsa 1/7`, `manager 5/5`, `observer 2/2`.

**Root cause, verified by direct inspection (not the validator's message alone):** the 7 failing skills' `description:` field is an unquoted YAML plain scalar that contains a mid-string `: ` (colon immediately followed by a space) — e.g. `lsa/skills/discover/SKILL.md:3`, `description: Extract user intent and gather the codebase facts a spec will rest on. Output: intent + cited facts, handed to specify.` (the `Output: ` after the first sentence). Per the YAML spec, a colon+space inside a plain (unquoted) scalar is ambiguous with a new mapping key and is invalid without quoting; Claude Code's own frontmatter parser tolerates it (these skills trigger correctly in practice — see `.claude-plugin/plugin.json` skill lists and this file's own probes above), but the strict reference validator correctly rejects it. This is a **real, unclaimed gap**, not a validator quirk: the 13 passing skills' descriptions simply don't happen to contain a colon+space; the 7 failing ones do.

**Scope decision (this epic, `standards-claim`, is citation-only — no skill content changes per its own Out-of-Scope R7):** fixing the 7 descriptions (quoting the value, or rephrasing to avoid the mid-string colon) is left to a new backlog item, [`agent-skills-strict-yaml-conformance`](../.lsa/roadmap.yaml), rather than folded into this epic — the exact anti-scope-creep reasoning `standards-conformance-agents-md`'s own Fork D used to drop the `license` field. Claiming 20/20 here would have been the credibility failure this pitch exists to prevent (see `.lsa/pitches/standards-conformance-agents-md.md` rabbit hole 1: *"Overstating the lineage would be worse than silence"*) — so `README.md` and `.lsa/VISION.md` cite the Agent Skills spec as **adopted, partially conformant (13/20 by the strict reference validator; 20/20 by this repo's own `lint.sh` C7/C9 checks)**, not as a clean conformance claim.

**License / metadata (R6).** No skill declares a `license` or `metadata` frontmatter field. Both are deliberately unset — the root `LICENSE` file is the single source of that fact, and writing `license` into 20 files would copy one fact into twenty independently-driftable places (the exact failure mode `standards-conformance-agents-md/agents-md-canonical`'s C16 check exists to prevent for the discipline text). `metadata` stays unset for the same reason.
