Shaped by: Nikita Zverev
Date: 2026-05-28
Status: draft
Sequencing: ships AFTER Pitch 3 (Enforce show-changes-inline). Pitch 3 hardens the user-visible critical fix at the skill level; this pitch then relaxes the cross-cutting rule layout once per-skill enforcement is in place.
Why now: end-of-project user feedback identified `core/output` as over-constraining — restricting Claude (and any future model running these plugins) from its natural strengths; this trades off against the project's substrate-agnostic credo (`.lsa/VISION.md` "model-agnostic agentic engineering system"); the longer the 7 rules stay enforced as a template, the more skill bodies bake template-shape assumptions into their voice.

# Relax `core/output` to advisory; keep Sources+Quotes as the only hard rule

Revise `core/output` so that fact-grounding (Sources + Quotes / citations) remains a hard constraint, and the remaining six golden rules become guidance — outcomes to aim for, not a template every response must satisfy.

## Problem

`core/output` ships seven golden rules (Structured, Minimal, Formatted, Sourced, Concrete, What-and-why preamble, Show-changes-inline) all enforced as hard requirements across every human-facing response. The user's intent was discipline; the lived effect is a strait-jacket that flattens Claude's natural prose and would prevent any future agent (or different model) shipped through this marketplace from "shining" in its own voice. The format becomes the message.

Evidence (user, 2026-05-28, verbatim): *"Output format is a great idea, but it feels like we restriced Claude too much. I would try to keep the hard requirements to provide Sources + Quotes but in a free format so Claude OR any other tool can shine."*

This does NOT contradict prior `core/output` feedback that landed:
- `feedback_output_length.md` — concise (1-1.5 screens). Remains the desired *outcome*, not a per-response template check.
- `feedback_show_actual_changes.md` — show actual changes inline. Remains the desired *outcome*; pitch #3 in this batch handles enforcement separately on a per-skill basis.
- `feedback_askuserquestion.md` — use the substrate's native picker. Substrate selection is upstream of `core/output` shape rules and stays as-is.

What changes is the *enforcement posture*: from "every response must satisfy all seven" to "every response must cite sources; the rest is guidance the agent uses when it helps the user."

Verdict-vocabulary decision (resolved): the verdict tags (`PROPOSED`, `DRIFT`, `PASS`, `FAIL`, `RESOLVED`, etc., from `core/knowledge/output-vocabulary.md`) become **guidance**, not hard. Rationale: they are response shape, not content. Prerequisite check ships first to ensure no audit/lint tooling silently breaks — see Tasks step 1 below.

Current workaround: agents over-format simple answers (verb-headline + preamble + structured table + verdict + decision block for a one-line factual answer); skill bodies write to satisfy the template rather than the user; conciseness suffers because the template imposes a minimum shape even when the answer is one sentence.

Definition of success: (a) `core/output` distinguishes hard rules from guidance explicitly; (b) only Sources+Quotes / fact-grounding is hard; (c) the other rules become "principles to apply when they serve the answer"; (d) skill bodies that previously cite Rule N as a constraint shift to citing it as a recommended shape; (e) responses to simple questions get to be short prose, not a six-block template.

## Appetite

Small batch. The change is a re-classification inside one file (`core/skills/output/SKILL.md`) plus a sweep of cite-sites across skill bodies that currently treat the rules as hard constraints. Surface area is bounded because the rules already have a numbered structure — they're being re-tagged, not rewritten.

Out of appetite:
- Removing any rule entirely (Rules 1-7 remain documented; only the enforcement tag changes).
- Re-numbering rules (the numbering is cited by other files; preserve it).
- Touching `core/ground-rules` (the 6 content rules are about *what is true*, not output shape — different concern).
- Re-doing `feedback_show_actual_changes.md` enforcement (pitch #3 of this batch handles that on a per-skill basis, not via `core/output`).
- Changing the file-load trace directive (Rule 4 sub-section; that's a separate per-file directive, not a response-shape rule).

## Solution sketch

- **Key user interactions:**
  - A user asks Helper "what is LSA" -> Helper returns 2-3 sentences with one `file:line` citation. No verb-headline, no preamble, no structured table — because the answer doesn't need one. Today the same question yields a multi-block templated response.
  - A user runs `lsa:discover` and the agent finds a real fork -> the agent still uses verdict labels (PROPOSED / DRIFT / PASS / FAIL) and show-changes-inline because the situation calls for them, but the *rules* don't compel it on every response.
  - Skill bodies that today say *"per `core/output` Rule 6 (must)..."* shift to *"per `core/output` Rule 6 (guidance)..."* or drop the cite entirely when the shape isn't load-bearing.

- **Main components:**
  - `core/skills/output/SKILL.md` — re-organize into two sections: (1) Hard rules — fact-grounding (Sources + Quotes, file-load trace, citation format); (2) Guidance — the remaining shape rules (Structured, Minimal, Formatted, Concrete, What-and-why preamble, Show-changes-inline) with a header note that these are outcomes to aim for, not a checklist to satisfy.
  - `core/CLAUDE.md` — update the always-on rule wording from "apply `core/output` to every human-facing output (7 format golden rules)" to language reflecting the new posture (one hard rule + six pieces of guidance).
  - Skill-body sweep — every cite site for Rules 1-3, 5-7 in `lsa/skills/**/SKILL.md`, `manager/skills/**/SKILL.md`, `helper/agents/helper.md`, and `prompt-engineer/**` reviewed: keep where the shape genuinely matters for that skill's output (e.g., `lsa:reconcile` drift block — Rule 7 is load-bearing there); soften or drop where it was cited as boilerplate.
  - `core/CHANGELOG.md` + version bump (likely minor — public-surface behavior change).

- **Tasks (ordered):**
  1. **Prerequisite (must complete before any re-classification):** grep the entire marketplace (`core/`, `lsa/`, `helper/`, `manager/`, `prompt-engineer/`, `.lsa/`, root configs) for usages of the verdict tags `PROPOSED`, `DRIFT`, `PASS`, `FAIL`, `RESOLVED` and any audit/lint tooling that keys off them. Time-box: ~5 minutes. Document every dependent cite-site in a short audit list (file:line + how the tag is consumed). The relaxation in step 2+ only proceeds once the grep is clean OR every dependent has been documented + classified (load-bearing → stays cited; boilerplate → safe to soften).
  2. Revise `core/skills/output/SKILL.md` to split Hard rules vs. Guidance per the structure above.
  3. Update `core/CLAUDE.md` always-on wording to match the new posture.
  4. Sweep cite sites identified in step 1 + general cite-site review across the four plugins; keep / soften / drop per the load-bearing test.
  5. CHANGELOG + version bump.

- **Critical path:** grep prerequisite -> revise `core/output` shape -> sweep cite sites -> verify that responses to simple questions are now allowed to be short prose, and that fact-grounding has not regressed (every claim still carries a source).

## Rabbit holes

1. **Discipline regression risk.** Relaxing the rules to guidance risks losing the discipline they originally encoded. Some rules (show-changes-inline, what-and-why preamble) were added in response to specific user pain (`feedback_show_actual_changes.md`, `feedback_lsa_explain_what_and_why.md`). If the rule becomes optional, agents may stop following it. Mitigation: pitch #3 in this batch enforces show-changes-inline *per-skill* (where the user actually felt the pain) and ships FIRST per the sequencing note above, so the discipline lives at the skill level by the time this pitch lands. What-and-why preamble can take the same treatment if regression is observed.

2. **Cite-site triage cost.** Every cite of Rules 1-3, 5-7 across the marketplace must be reviewed — keep, soften, or drop. Mitigation: process the sweep in one pass, list each cite site with the verdict in the PR description so reviewers can audit at a glance (compressed inspection table per `core/output` Rule 7 — used as guidance, not template).

3. **Substrate-agnostic ambition vs. Claude-tuned reality.** The user wants other models to be able to "shine" through these plugins. The codebase today bakes Claude Code-specific behaviors (AskUserQuestion, file-load trace markers, plugin schema) into many surfaces. Relaxing `core/output` alone won't fully realize the substrate-agnostic goal; it removes the most visible blocker. Mitigation: scope this pitch to `core/output` only and note the broader substrate-agnostic audit as a separate future pitch.

4. **Tension with `core/output` enforcement work already shipped.** Recent rows in the roadmap (`core/output` discipline enforcement v0.5.1; What-and-why preamble v0.7.0; Show changes inline v0.8.0) all hardened these rules. This pitch partially walks that back. Mitigation: be explicit in the changelog about the rationale shift (from template-discipline to outcome-discipline) so the next maintainer doesn't re-tighten without context.

## No-gos

1. This pitch does NOT cover removing or rewriting any Rule's content — only the enforcement classification changes.
2. This pitch does NOT cover `core/ground-rules` — those are content rules (what is true), not output shape rules, and remain hard.
3. This pitch does NOT cover the file-load trace directive — that's a per-file load-time print, not a response-shape rule, and stays hard.
4. This pitch does NOT cover the substrate-agnostic audit beyond `core/output` — other Claude-Code-specific bakings (AskUserQuestion primitive, plugin schema) are out of scope.
5. This pitch does NOT cover Helper / LSA latency (pitch #1 of this batch) or per-skill show-changes-inline enforcement (pitch #3) — orthogonal concerns.

## Open questions

1. For the show-changes-inline rule specifically: keep it as guidance in `core/output` AND enforce per-skill in pitch #3, or remove it from `core/output` entirely and let the per-skill enforcement be the only home? (Recommendation: keep as guidance in `core/output` for discoverability; pitch #3 handles enforcement.)
2. What's the version bump? Minor (behavior change, no API break) seems right but the marketplace pre-1.0 SemVer policy gives the maintainer discretion.
