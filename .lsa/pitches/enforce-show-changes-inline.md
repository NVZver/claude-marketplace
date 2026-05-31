Shaped by: Nikita Zverev
Date: 2026-05-28
Status: draft
Sequencing: ships BEFORE Pitch 2 (Relax `core/output` to advisory). This pitch is the user-visible critical fix; Pitch 2 cleans up the rule layout afterward, once per-skill enforcement is in place.
Why now: end-of-project user feedback re-surfaced this complaint despite the rule being canonical since `core` v0.8.0 — the rule is documented but skills are still violating it in practice; the project memory `feedback_show_actual_changes.md` notes this is the "dominant UX friction" and the user has now flagged it twice; without per-skill enforcement + a regression check, the rule will keep drifting.

# Enforce show-changes-inline across LSA / Core / Helper / Management

The show-changes-inline rule (`core/output` Rule 7, `feedback_show_actual_changes.md`) is canonical but unevenly applied — skills still tell the user to go open a file and verify. This pitch is the *enforcement* mechanism: where the rule lives in each skill body, what the verification check is, and what the regression catch is.

## Problem

Users repeatedly hit the same friction: a skill says "I added X to file Y" or "I marked OQ5 as resolved" without quoting the actual content. The user must open the file, find the edit, and read it to verify what happened. This was first flagged 2026-05-22, captured as canonical project memory (`feedback_show_actual_changes.md`), and shipped as `core/output` Rule 7 in `core` v0.8.0 + `lsa` v0.8.1 with a 16-line sweep across 7 LSA skills.

It is now 2026-05-28 and the user is reporting the same friction again. Evidence (verbatim): *"Sometimes steps are unclear because only files changed, and the agent asks to go and verify them. I'd rather see what actually was changed without jumping through files and picking changes."*

Diagnosis: Rule 7 lives in `core/output` as a general rule, was applied to LSA skill `Observable result:` lines once, and was deferred for Helper (Epic 3 of the original ship). The gaps where skills still violate the rule:
- Skills added after the v0.8.0 sweep (`lsa:implement`, `management:*`, `prompt-engineer:*`) inherit Rule 7 via cite but don't have explicit show-changes templates in their step bodies.
- Helper Epic 3 was deferred per the original roadmap row — Helper still describes file changes without quoting them.
- The original sweep targeted `Observable result:` lines, not the verb-headline lines (PROPOSED, APPLIED, MARKED) where the violation typically appears.
- No regression check exists — the rule can decay silently without any verify-time signal.

Reference exemplar that the user explicitly endorsed: `lsa:reconcile`'s 8-element drift block (one-change-at-a-time / location / current quoted / proposed quoted / evidence-rich reason / source / bundle-explanation / type tag). User quote on that block (2026-05-22): *"Good! Love it!"* — captured in `feedback_lsa_reconcile_gold_standard.md`.

Current workaround: the user opens the changed files manually after every skill turn to verify what actually happened.

Definition of success: (a) every skill in `lsa/`, `core/`, `helper/`, `management/`, `prompt-engineer/` that writes / edits / marks anything has the show-changes-inline expectation explicitly cited in its `Steps` body — not just in the constraints inheritance; (b) regression checks flag violations at BOTH author-time (`prompt-engineer:prompt-review` against skill/agent prompt sources) AND PR-time (`lsa:verify` against feature-implementation runtime outputs); (c) the `lsa:reconcile` 8-element template is the documented exemplar referenced from every enforcement cite.

## Appetite

Medium batch. The change is a per-skill sweep across five plugins plus regression checks added to two surfaces (prompt-review for sources, lsa:verify for runtime artifacts) — bounded but touches many files.

Out of appetite:
- Re-litigating Rule 7's content (it's canonical and the user re-endorsed it).
- Rewriting `core/output` Rule 7 itself (orthogonal to pitch #2 in this batch, which proposes Rule 7 may become guidance rather than hard rule).
- Building runtime instrumentation that catches violations during the agent's response (verify-time check only; runtime hook is out of scope).
- Changing the `lsa:reconcile` template (it's the gold standard; preserve verbatim).

## Solution sketch

- **Key user interactions:**
  - User runs `lsa:plan` and approves an epic -> the skill writes the epic to `tasks.md`, then quotes the new epic block inline before saying anything else. Today it often just says "Epic 3 added".
  - User runs `helper /help` and Helper updates a knowledge file as a side-effect -> Helper quotes the change inline. Today it says "I updated onboarding-fast-path.md".
  - User runs `management:roadmap` and a new row is appended -> the skill quotes the new row inline with `file:line` before the verdict. Today the verdict comes first; the row content is implicit.
  - User runs `prompt-engineer:prompt-review` against a skill source -> the review flags any step body that writes/edits/marks without an explicit show-changes-inline cite. Catches the violation in the prompt source before it ships.
  - User runs `lsa:verify` on a feature PR -> the verify scans the runtime outputs / PR diff for the "go check the file" patterns (bare "I added X to Y", "marked X as resolved", "updated Z") with no inline quote of the changed content. Catches the violation in the runtime artifact.

- **Main components:**
  - `core/skills/output/SKILL.md` Rule 7 — add a "How this gets enforced" sub-section pointing to (a) the per-skill cite locations, (b) the two regression checks (prompt-review for sources, lsa:verify for runtime), (c) the `lsa:reconcile` gold standard.
  - `core/CLAUDE.md` operational checkpoint — explicit reminder that write-then-show-then-comment is the order, with the `lsa:reconcile` 8-element template as the reference.
  - Skill body sweep (5 plugins):
    - `lsa/skills/**/SKILL.md` — every step that writes / edits / marks gets an explicit "quote the change inline" instruction in the step body, not only in the `Observable result:` line. Touches `discover`, `plan`, `implement`, `verify`, `init`, `revise-constitution` at minimum.
    - `helper/agents/helper.md` — explicit show-changes when Helper writes to its own knowledge files or surfaces a fact from a file (the fact-quote is already there; this extends to actions Helper takes).
    - `management/skills/**/SKILL.md` — `start-feature` and `roadmap` skills get explicit cites.
    - `management/agents/**` — `product-manager` already writes pitches and quotes them inline (per Step 4 of this very agent); `project-manager` needs the cite.
    - `core/skills/**/SKILL.md` — `flow-selector` and others get cites where applicable.
    - `prompt-engineer/**` — already complies; spot-check only.
  - **Regression check — author-time (sources):** new check inside `prompt-engineer:prompt-review` that scans skill/agent prompt source files (`**/SKILL.md`, `**/agents/*.md`) for steps that describe a write/edit/mark action without an accompanying show-changes-inline directive. Frames violations at the prompt-source layer, before the skill ships. Warning-only initially.
  - **Regression check — PR-time (runtime artifacts):** new check inside `lsa/skills/verify/SKILL.md` that scans the feature's runtime outputs / PR diff for the banned phrasings ("go check the file", "I added X to Y", "marked X", "updated Z") without inline quote of the change. Catches the violation as a runtime symptom, complementary to the prompt-review source-side catch. Warning-only initially.
  - Split frame: **`prompt-engineer:prompt-review` catches violations in prompt sources; `lsa:verify` catches violations in runtime artifacts.** Both surfaces ship in this pitch — neither alone is sufficient (prompt-review can't catch a skill that's correctly prompted but mis-executes; lsa:verify can't catch a structural prompt-source omission until a feature ships).

- **Tasks (ordered):**
  1. Update `core/output` Rule 7 with the "How this gets enforced" sub-section pointing to both regression checks + `lsa:reconcile` gold standard.
  2. Per-skill sweep across the 5 plugins (lsa first, then management, helper, core, prompt-engineer — independent PRs).
  3. Wire the author-time regression check into `prompt-engineer/skills/prompt-review/SKILL.md` (scan prompt sources).
  4. Wire the PR-time regression check into `lsa/skills/verify/SKILL.md` (scan runtime artifacts).
  5. Validate both checks against a recent PR known to comply (positive baseline) and one known to violate (negative baseline).

- **Critical path:** core Rule 7 sub-section update -> per-skill sweep -> author-time check in prompt-review -> PR-time check in lsa:verify -> validate both against baselines.

## Rabbit holes

1. **Regression-check false-positive rate (both surfaces).** Heuristic scans for unquoted modifications can't perfectly match a skill turn to a file change. Mitigation: ship both checks as warning-only initially; if the false-positive rate is low after a week of dogfood, promote to hard checks. Until then, treat each check as a *signal* rather than a *gate*. The two surfaces also cross-validate: a violation flagged in source by prompt-review should correlate with the same skill showing runtime violations under lsa:verify; mismatches are diagnostic.

2. **Interaction with pitch #2 (relax `core/output` to advisory).** Per the sequencing note above, this pitch ships FIRST. Once Pitch 2 lands, Rule 7 becomes guidance in `core/output` — but the per-skill enforcement and the two regression checks shipped here already hold the discipline at the skill / verify-time level, independent of `core/output`'s posture. This is exactly Pitch 2's stated mitigation pattern.

3. **Sweep scope blast radius.** Touching every skill body across five plugins is a wide change. Mitigation: chunk by plugin in separate PRs (lsa first, then management, then helper, then core, then prompt-engineer). Each PR is independently shippable; no cross-plugin atomicity required.

4. **`Observable result:` vs. step body.** The original v0.8.0 sweep modified `Observable result:` lines. This pitch proposes adding the cite to the step body too — duplication risk. Mitigation: keep `Observable result:` as the verdict ("change was quoted inline per Rule 7"); the step body carries the *instruction* ("when you write, quote the new content before your verdict"). Different roles, no duplication.

## No-gos

1. This pitch does NOT rewrite Rule 7's content — the rule is canonical.
2. This pitch does NOT add runtime enforcement (no hook that catches violations during the agent's response). Author-time + verify-time checks only.
3. This pitch does NOT touch the `lsa:reconcile` 8-element template — preserve verbatim as the gold standard.
4. This pitch does NOT re-classify whether Rule 7 is hard or guidance (pitch #2 owns that question).
5. This pitch does NOT cover process-narration in code comments (pitch #4 covers that — different surface, different rule).

## Open questions

1. For Helper specifically: the original Epic 3 was deferred until `helper` v0.3.0 landed (which it has). Should this pitch's Helper-side work be sequenced as a follow-up to the deferred Epic 3, or roll it in here? Recommendation: roll in here; the deferral was a sequencing decision, and `helper` v0.3.0 is now shipped.
2. What's the lowest-cost way to validate the regression checks against a recent PR? Suggested: pick one of the post-v0.8.0 PRs (PR #21 or later) where the show-changes discipline was deliberately practiced and use that as the positive baseline for the PR-time check; use a pre-v0.8.0 prompt-source diff as the negative baseline for the author-time check.
