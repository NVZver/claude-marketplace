# Feature: LSA — what-and-why preamble on every verb-headline

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #4 (`vision/specs/roadmap.md:122-126`).

## Summary

LSA's verdict-labeled headlines (`PROPOSED`, `APPLIED`, `DRIFT`, `PASS`, `FAIL`, `PASS WITH WARNINGS`, `BLOCKED`, `READY`, `CLEAN`, `REJECTED` — vocabulary at `core/knowledge/output-vocabulary.md:11-22`) currently render as bare labels that presume LSA-internal vocabulary (module, epic, gate, manifest, drift, reconcile — `lsa/knowledge/conventions.md:5`). A first-time user — and especially a downstream collaborator — can see *that* something happened but not *what* it means or *why it matters to them*.

This feature adds a one-sentence **preamble** before every verb-headline emission across all 8 LSA skill bodies in `lsa/skills/**/SKILL.md`. The preamble names (a) what LSA is doing in plain English, and (b) the concrete consequence if the user does not act. The format is `<context sentence>. <verb-headline + details>.` — a bare verb-headline is no longer acceptable.

The working positive exemplar is `lsa-init` brownfield's diagnostic line *".lsa.yaml missing → without it I would rescan src/ on every step"* (cited verbatim in `vision/specs/roadmap.md:125`). That line is the gold reference because it (a) names the missing precondition in the user's frame, (b) names the *concrete consequence* of inaction.

This feature **does not** add inline-content quoting of the change itself — that is roadmap row #5 (`vision/specs/roadmap.md:128-132`, "Show actual changes inline"). Row #4 = *framing of actions*; row #5 = *content of changes*. They compose: a preamble (this feature) precedes the verdict-headline; an inline content quote (row #5) follows it.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | When any LSA skill emits a verdict-labeled headline drawn from `core/knowledge/output-vocabulary.md:11-22` (`PROPOSED`, `APPLIED`, `DRIFT`, `PASS`, `FAIL`, `PASS WITH WARNINGS`, `BLOCKED`, `READY`, `CLEAN`, `REJECTED`), the skill body MUST require the agent to render a one-sentence preamble immediately preceding the headline. | P0 |
| F2 | The preamble MUST name (a) the action LSA is taking, in plain English in the user's frame, AND (b) the concrete consequence if the user does not act. Both elements are mandatory. | P0 |
| F3 | The preamble MUST avoid LSA-internal vocabulary terms unless that term has already been introduced in the same turn — at minimum: `module`, `epic`, `gate`, `manifest`, `drift`, `reconcile`, `verdict`, `predicate`, `orphan-diff`, `Hard Confirm`, `Soft Confirm`, `${specs_root}`, `manifest SHA`. When such a term is unavoidable, the preamble MUST gloss it in 3–5 plain words at first use per turn (consistent with `feedback_helper_must_reground.md` from the memory index). | P0 |
| F4 | The canonical format string MUST be: `<context sentence in user's frame>. <existing verb-headline + existing details>.` | P0 |
| F5 | The rule MUST land as a *single source of truth* in `core/skills/output/SKILL.md` as a new **Rule 6** ("What-and-why preamble — verdicts carry a one-sentence frame"), reusable by any plugin emitting verdict-labeled output. Each LSA skill body cites this new rule by markdown link rather than restating it. Rationale: the verdict vocabulary already lives in `core/knowledge/output-vocabulary.md:11-22` (marketplace-wide), so the preamble obligation belongs at the same layer — not duplicated 8 times across LSA. Rule 6 (not a sub-bullet under Rule 5) because Rule 5 governs picker-prompt subjects, a different category from action-framing — see `design.md` §"Where the rule lives" for the rationale. | P0 |
| F6 | Each LSA skill body that currently emits a verdict-labeled headline MUST be updated to: (a) cite the new `core/output` sub-rule by link, AND (b) replace any worked-example "Present: <VERDICT> verdict + …" template with a "Present: <preamble template>. <VERDICT> verdict + …" template that shows the preamble inline. | P0 |
| F7 | The CHANGELOG entries for both `core` and `lsa` MUST land in the same commit as the rule + skill-body edits, with SemVer bumps. The repo root `README.md`, `core/README.md`, and `lsa/README.md` are exempt unless the rule changes a user-visible surface listed in those READMEs (per `CLAUDE.md` "Discipline (sourced)" → "READMEs are living documents"). | P1 |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | The preamble must not exceed one sentence (≤ ~25 words). Per `core/skills/output/SKILL.md` Rule 2 ("Minimal — 1–1.5 screen budget") at `core/skills/output/SKILL.md:17-22`. |
| NF2 | The rule must be testable by a non-LSA reader without reading any LSA skill body. Per the helper-mode UX check pattern (`finding_helper_mode_as_ux_check.md` in the memory index). |
| NF3 | The preamble must read as a *user-frame* sentence, not an LSA-frame sentence. Test: replace "I / LSA" with "this tool" — does the sentence still make sense to a downstream collaborator who has never opened `lsa/`? If no, rewrite. |
| NF4 | Spec-grounding: every edit traces to a requirement ID below. Per `vision/VISION.md:35` ("Spec-grounding"). |

## Inputs & Outputs

**Inputs**
- `core/knowledge/output-vocabulary.md:11-22` — canonical verdict table (read-only here; not edited).
- `core/skills/output/SKILL.md:32-40` — current Rule 5 ("Concrete — prompt voice") that the new sub-rule extends.
- `lsa/skills/lsa-init/SKILL.md:51`, `lsa/skills/lsa-reconcile/SKILL.md:35`, `lsa/skills/lsa-sync/SKILL.md:131`, `lsa/skills/lsa-revise-constitution/SKILL.md:61`, `lsa/skills/lsa-verify/SKILL.md:83-92` — current verdict-emission sites (inventoried in `design.md`).
- `lsa/skills/lsa-discover/SKILL.md`, `lsa/skills/lsa-specify/SKILL.md`, `lsa/skills/lsa-plan/SKILL.md` — skills that emit *non-verdict* action prose; reviewed for completeness but not required to change unless they emit a label from `output-vocabulary.md`.

**Outputs**
- New **Rule 6** in `core/skills/output/SKILL.md` — see `design.md` §"Where the rule lives" (OQ1 resolved).
- Edits to each of the 5 LSA skill bodies that emit a verdict-headline (lsa-init, lsa-reconcile, lsa-sync, lsa-revise-constitution, lsa-verify — 5 total).
- `core/CHANGELOG.md` + `lsa/CHANGELOG.md` entries + SemVer bumps in `core/plugin.json` and `lsa/plugin.json` (one entry per plugin, same commit as the edits).

## Constraints

- **No edits outside the feature dir during planning.** This document is the plan; execution lives in `tasks.md` and produces edits to `core/` + `lsa/`.
- **Do not edit `core/knowledge/output-vocabulary.md`.** The vocabulary is stable; the gap is in the *format of emission*, not the labels.
- **Do not introduce new verdict labels.** Adding a label would be a separate Extended feature.
- **The preamble is mandatory on every emission, not a "best practice".** Per `vision/specs/roadmap.md:126` — "*A bare verb-headline is not acceptable.*"

## Out of Scope

- Inline-content quoting of the change itself ("show actual changes inline") — that is roadmap row #5 (`vision/specs/roadmap.md:128-132`). #4 and #5 compose at runtime but ship independently.
- Sweeping non-verdict action prose (`Observable result:`, `Present:`, `Stop.`) for tone or jargon. Only the verdict-labeled headlines are in scope.
- Helper skills (`helper/skills/**`). The roadmap row is explicit: "*Spans all 8 LSA skill bodies.*"
- Adding emojis or visual decoration to the preamble. Per the user's memory: avoid emojis unless requested.
- Restating verdict vocabulary in any LSA file. Cite `core/knowledge/output-vocabulary.md` by link only.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:204 — one of Ubiquitous / Event / State / Optional / Unwanted. -->

| ID | EARS form | Criterion |
|----|-----------|-----------|
| AC1 | Event | When a user runs `/lsa:init` in brownfield mode and reaches the inferred-modules confirm step (currently `lsa/skills/lsa-init/SKILL.md:51`), the rendered output begins with a one-sentence preamble naming the action ("draft module specs for this project from `src/` so future LSA steps can trace changes to a module") and the consequence ("without these specs, the next `/lsa:discover` cannot pick a module to attach the change to") BEFORE the `PROPOSED` verdict line. |
| AC2 | Event | When `/lsa:reconcile` detects a drift and presents a per-module hard confirm (currently `lsa/skills/lsa-reconcile/SKILL.md:35`), the user sees a one-sentence preamble in the user's frame ("the spec for `<module>` no longer matches the code; either update the spec or revert the code") before the `DRIFT` verdict line. |
| AC3 | Event | When `/lsa:verify` completes and emits its variant report (currently `lsa/skills/lsa-verify/SKILL.md:83-85`), each of the three variants (`PASS` / `FAIL` / `PASS WITH WARNINGS`) is preceded by a one-sentence preamble that names the consequence — e.g., for `FAIL`, "the implementation does not match the approved spec on `<feature>`; merging now would ship un-spec'd code". |
| AC4 | Event | When `/lsa:sync` finishes applying module updates and presents its decision (currently `lsa/skills/lsa-sync/SKILL.md:131`), the user sees a preamble naming "module specs are now up to date with the merged feature; the next step decides whether to open the PR now or hold". |
| AC5 | Event | When `/lsa:revise-constitution` presents a per-change human review gate (currently `lsa/skills/lsa-revise-constitution/SKILL.md:61`), each `PROPOSED` change carries a preamble naming the constitution section about to change and the consequence of accepting / rejecting. |
| AC6 | Ubiquitous | Every verdict label drawn from `core/knowledge/output-vocabulary.md:11-22` rendered by any LSA skill is preceded by a one-sentence preamble matching the canonical format `<context sentence>. <verb-headline + details>.` (per F4). |
| AC7 | Unwanted | If any LSA skill body emits a verdict label without a preceding preamble — i.e., a bare line beginning with `PROPOSED:`, `APPLIED:`, `DRIFT:`, `PASS:`, `FAIL:`, `BLOCKED:`, `READY:`, `CLEAN:`, `REJECTED:`, or `PASS WITH WARNINGS:` — the skill body does not pass review. Mechanical-grep predicate in `test-suites.md`. |
| AC8 | State | While the rule lives in `core/skills/output/SKILL.md`, every LSA skill that currently emits a verdict label MUST cite that rule by markdown link (no restatement) — verified by grep for the link target in the 5 affected skill bodies. |
