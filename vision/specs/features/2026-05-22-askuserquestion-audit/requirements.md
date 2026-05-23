# Feature: Audit + tighten `AskUserQuestion` call sites (Helper + LSA)

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #3 (`vision/specs/roadmap.md:116-120`).

## Summary

Helper (`helper/agents/helper.md`, `helper/commands/help.md`, `helper/knowledge/*.md`) and LSA (`lsa/skills/**/SKILL.md`) reflexively call `AskUserQuestion` when no real decision needs to be made — confirming what the user just asked for, offering rephrasings of the same answer, gating on a fork the agent could resolve from context. Each unnecessary picker is a context switch that blocks the answer (`vision/specs/roadmap.md:118`).

This feature audits **every** existing `AskUserQuestion` invocation in Helper and LSA, classifies each by the **genuine-fork test**, and rewrites the call sites that fail the test as direct cited answers (with at most one optional closing offer). It then publishes the test as a new sub-rule under `core/output` Rule 5 — **orthogonal** to `vision/VISION.md:66` Principle 9 (*which* primitive to use) — the new rule governs *whether to ask at all*.

This row is **partially orthogonal to backlog #1** (Helper command-router refactor, `vision/specs/roadmap.md:104-108`): #1 owns the Helper-side dispatch posture (lead with cited answer, not picker); this row owns the per-call-site classification across both Helper and LSA, plus the cross-plugin rubric.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | When a maintainer runs the audit, the system shall produce a complete inventory of every `AskUserQuestion` reference in `helper/` and `lsa/skills/**/SKILL.md`, each row carrying `file:line`, the surrounding step or constraint, and a `keep` / `remove` / `convert-to-closing-offer` classification with a one-line reason. | P0 |
| F2 | When a reviewer applies the genuine-fork test to any call site, the system shall provide a written rubric (decision checklist) such that two reviewers reach the same verdict on the same site without re-deriving the rule. | P0 |
| F3 | When a Helper or LSA skill renders an `AskUserQuestion` after this feature ships, the picker shall correspond to a verdict of `keep` in the inventory or to a new call site that passes the same rubric in code review. | P0 |
| F4 | When `core/output` is read after this feature ships, the file shall contain an **expanded** "Must-decide only" bullet under Rule 5 (replacing the existing one at `core/skills/output/SKILL.md:39`) that names the genuine-fork test and cites Principle 9 (`vision/VISION.md:66`) as the *substrate-selection* rule. The change is an expansion of the existing concept, not a net-new orthogonal rule — overlap acknowledged in `design.md` §"Proposed `core/output` Rule 5 expansion". | P0 |
| F5 | When a call site is reclassified from `keep` to `remove` or `convert-to-closing-offer`, the skill body shall replace the picker with a direct cited answer (Helper) or a stated decision the skill resolves from context (LSA) — and, optionally, one closing offer for the human to override. | P0 |
| F6 | When the Helper-side refactor in backlog #1 (`vision/specs/roadmap.md:104-108`) lands first, this feature's Helper edits shall layer on top without re-litigating the dispatch posture — the boundary line is defined in `design.md` §"Interaction with #1". | P1 |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Every classification row cites the call site by `file:line` (per `core/ground-rules` Rule 1, `core/skills/ground-rules/SKILL.md`). |
| NF2 | The new `core/output` sub-rule is ≤6 lines of body copy (per `core/skills/output/SKILL.md` Rule 2 "Minimal"). |
| NF3 | The audit pass shall not edit any file outside (a) `helper/`, (b) `lsa/skills/`, (c) `core/skills/output/SKILL.md`, (d) this feature directory, (e) per-plugin `CHANGELOG.md` and `README.md` deltas. Per `CLAUDE.md` "Discipline (sourced)" — README + CHANGELOG move in the same commit as any user-visible change. |
| NF4 | The rubric is expressed in plain English (no LSA jargon) — readable by a Helper user who has never seen `lsa-specify`. Per `core/skills/output/SKILL.md` Rule 5 "No project jargon". |

## Inputs & Outputs

**Inputs**
- `vision/specs/roadmap.md:116-120` — row #3 verbatim.
- `vision/VISION.md:66` — Principle 9 ("Substrate-native first").
- `core/skills/output/SKILL.md:32-40` — Rule 5 current body.
- `core/CLAUDE.md` operational checkpoint #1 — current "Substrate-native pickers" wording.
- `helper/agents/helper.md`, `helper/commands/help.md`, `helper/knowledge/*.md` — Helper call sites.
- `lsa/skills/**/SKILL.md` — 8 LSA skill bodies.

**Outputs**
- Updated `core/skills/output/SKILL.md` — new sub-rule under Rule 5 ("Genuine-fork test").
- Updated `helper/agents/helper.md` and `helper/commands/help.md` — per per-call-site verdicts.
- Updated `lsa/skills/<n>/SKILL.md` (subset) — per per-call-site verdicts.
- Updated `core/CHANGELOG.md`, `lsa/CHANGELOG.md`, `helper/CHANGELOG.md` + SemVer bumps in each plugin's `plugin.json` (per `CLAUDE.md` "Per-plugin SemVer + CHANGELOG").
- Updated `README.md` deltas only where a user-visible behavior changed (per `CLAUDE.md` "READMEs are living documents").

## Constraints

- **No edits outside scope** (NF3).
- **Per-plugin SemVer + CHANGELOG** in same commit (`CLAUDE.md` "Discipline").
- **Principle 9 unchanged.** Substrate selection is still `AskUserQuestion` when a fork exists; this row adds an upstream gate ("does the fork exist?") — it does not relax Principle 9.
- **The closing-offer cap.** When a call site is converted, at most **one** closing offer remains (e.g., *"Want me to run lsa-specify now? — Yes / No"*). Two closing pickers on the same turn is a regression.
- **Real-fork list is non-exhaustive but explicit.** Destructive choices, two valid architectures, missing info the agent can't infer, per-row triage in batched approvals — these stay. The rubric in `design.md` §"Operational checklist" lists them by name.

## Out of Scope

- Backlog #1 (Helper command-router refactor) — its scope is *the dispatch posture*; this row's scope is *the call-site classification*. The boundary line is defined in `design.md` §"Interaction with #1".
- Backlog #2 (Helper fast-path for onboarding) — separate row.
- Backlog #4 (LSA verb-headline preamble) — separate row; this row does not touch verb-headlines.
- Backlog #5 (write-then-show-then-comment) — separate row.
- Backlog #6 (custom-invention sweep) — separate row.
- Changing Principle 9 (`vision/VISION.md:66`).
- Renaming `AskUserQuestion` or proposing a new primitive.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:204 — one of Ubiquitous / Event / State / Optional / Unwanted. -->

- **AC1 (Event).** When a maintainer reads `design.md` §"Call-site inventory", each of the **43 actor-surface `AskUserQuestion` mentions** is classified as keep / keep+tighten / convert / remove / meta-reference; no actor-surface mention is missing from the inventory. **Canonical denominator: 43 actor-surface hits** from `grep -rn "AskUserQuestion" helper/agents/ helper/commands/ helper/knowledge/ helper/.claude-plugin/ lsa/skills/` (re-run 2026-05-23: 29 Helper + 14 LSA). Each grep hit maps to one inventory row carrying `file:line` and a verdict; `meta-reference` rows are individually enumerated (no cluster rows) so the maintainer can audit hit-by-hit.
- **AC2 (Event).** When a maintainer runs `/help "how do I install LSA?"` after this feature ships, Helper shall return a cited README excerpt as the first response body and no opening `AskUserQuestion` picker — only the (optional) closing next-step picker if any. The dispatch-posture *root cause* lives in backlog #1; this AC verifies the call-site classification holds on a representative user query.
- **AC3 (Event).** When `lsa-discover` runs in Standard flow (`lsa/skills/lsa-discover/SKILL.md:33`) and Steps 1+2 yield a single unambiguous candidate for module / change / AC, the skill shall accept the candidate as the answer and skip the per-pick `AskUserQuestion` for that line — silence-on-a-line is already approval per the existing skill text (`lsa/skills/lsa-discover/SKILL.md:26` "Silence on a line = approval").
- **AC4 (Ubiquitous).** `core/skills/output/SKILL.md` Rule 5 shall contain an **expanded "Must-decide only" bullet** (replacing the current one at line 39) titled **"Must-decide only — Genuine-fork test"** (or equivalent — name TBD per OQ1 in `design.md`) that cites Principle 9 by file:line, distinguishes *fork-existence* (this expansion) from *primitive choice* (Principle 9), and lists the four real-fork categories with operational criteria (destructive / two named designs in scope / fact absent from working context / per-row triage).
- **AC5 (Unwanted).** When the audit ships, no Helper or LSA `AskUserQuestion` call site classified `remove` in the inventory shall remain in the published `SKILL.md` / agent body (verified by re-grepping after the PRs land — see `test-suites.md` Journey 3).
- **AC6 (State).** While backlog #1 (Helper refactor) is in flight, this feature's Helper PR shall not land before #1 — otherwise the dispatch-posture rewrite in #1 would re-introduce removed pickers. Sequencing recorded in `tasks.md`.
