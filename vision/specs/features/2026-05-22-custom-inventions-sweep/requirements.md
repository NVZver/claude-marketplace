# Feature: Sweep custom inventions; remove the unjustified

> Source: `vision/specs/roadmap.md:134-141` §"2026-05-22 backlog detail" #6.
> Status: backlog (proof-of-concept shipped — lsa v0.7.0 trace-tag removal, commit `c226623`; `vision/specs/roadmap.md:38`).
> Priority: Should (per `vision/specs/roadmap.md:38`).

## Summary

LSA, Core, and Helper have accumulated custom conventions — HTML-comment markers, internal state files, proprietary vocabulary, opaque verb-headlines, file-load trace banners — that are cheap to add individually but compound into a private dialect collaborators must learn. The just-shipped trace-tag removal (lsa v0.7.0, commit `c226623`; `lsa/CHANGELOG.md:7-14` and `vision/specs/roadmap.md:44`) demonstrated one such invention had zero upstream mandate and was opaque to non-LSA readers. User principle 2026-05-22 (`vision/specs/roadmap.md:137`): *"We should find all such custom inventions and critically assess all of them asking the question 'Do we really need it? What would change if we remove it?' If nothing or minor - Remove."*

This feature performs a one-pass audit across `lsa/`, `core/`, and `helper/`, applies a single decision rubric to every surveyed invention, lands each removal as an independent PR, and records each keep with a one-line defense. The rubric is anchored to five adopted 3rd-party standards (EARS, SemVer, Keep a Changelog, CommonMark, Claude Code plugin schema) and to Claude Code substrate primitives (`AskUserQuestion`, `Read`/`Edit`/`Write`, `Skill`, `Task*`, hooks). The inventory in `design.md` §"Invention inventory" is the highest-value artifact — 11 surveyed inventions, each with `file:line`, source mandate (or "none"), removal cost, recommendation.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | The agent shall enumerate every custom invention in `lsa/`, `core/`, and `helper/` not required by EARS, SemVer, Keep a Changelog, CommonMark, the Claude Code plugin schema, or a Claude Code substrate primitive — populating the inventory table in `design.md` with `file:line` for each row. | Must |
| F2 | For each surveyed invention the agent shall apply the rubric in `design.md` §"Decision rubric" — answering, in order: (a) Does any adopted standard or Claude Code substrate primitive mandate it? (b) What concrete capability is lost if it is removed? (c) Is that capability achievable via a substrate primitive or a standard? — and shall record a single recommendation of `keep`, `remove`, or `needs-deeper-review`. | Must |
| F3 | When the recommendation is `keep`, the agent shall record a one-line defense citing the irreplaceable capability the invention preserves and the substrate/standard surface that does not cover it. | Must |
| F4 | When the recommendation is `remove`, the agent shall record the removal cost (what other surfaces — skills, hooks, knowledge files — must change) and the standard or substrate primitive that subsumes the invention's job. | Must |
| F5 | When the recommendation is `needs-deeper-review`, the agent shall record the specific question that the one-pass rubric cannot resolve (e.g., dual-purpose invention, ambiguous removal cost) and route the row to `## Open Questions` in `design.md`. | Must |
| F6 | The agent shall sequence the resulting removal PRs in `tasks.md` from lowest to highest blast radius, so each removal lands as one independent PR per the trace-tag-removal exemplar (`vision/specs/roadmap.md:44`, commit `c226623`). | Must |
| F7 | Each removal PR shall update the relevant plugin `CHANGELOG.md` and bump the plugin SemVer per `CLAUDE.md` *"Discipline (sourced) — Per-plugin SemVer + CHANGELOG"*, and shall update README user-visible surface in the same commit per `CLAUDE.md` *"READMEs are living documents"*. | Must |
| F8 | Where an invention is recommended `keep`, the agent shall not touch the invention's source files in this feature — the one-line defense lives in the inventory only. | Must |

EARS-form mapping:

- **F1, F2, F6, F7** — *Ubiquitous* (`shall` on every row / every PR).
- **F3** — *Event* (*"When the recommendation is `keep`… shall"*).
- **F4** — *Event* (*"When the recommendation is `remove`… shall"*).
- **F5** — *Event* (*"When the recommendation is `needs-deeper-review`… shall"*).
- **F8** — *Unwanted* (*"Where an invention is recommended `keep`… shall not"*).

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | The inventory shall surface at least 8 candidates — the 3 named in `vision/specs/roadmap.md:139-141` plus a minimum of 5 newly surfaced by the scan — to satisfy the parent task's framing (*"the sweep itself will surface more"* — `vision/specs/roadmap.md:138`). |
| NF2 | Each inventory row shall cite `file:line` for the invention's primary site (the canonical declaration or first use), not a paraphrase. Per `core/skills/ground-rules/SKILL.md` Rule 1. |
| NF3 | The rubric shall name exactly five adopted 3rd-party standards (EARS, SemVer, Keep a Changelog, CommonMark, Claude Code plugin schema) plus Claude Code substrate — no more, no less — so the rubric is verifiable. The five are enumerated in the parent task framing and at `vision/specs/roadmap.md:138`. |
| NF4 | The sweep shall not edit any archive file under `vision/specs/archive/**/` or `vision/plans/2026-05-20-*` — those are frozen historical records per the trace-tag-removal precedent (`lsa/CHANGELOG.md:7-14`). |
| NF5 | Each removal PR shall be small enough that a reviewer can read the diff in under 5 minutes — i.e., one invention per PR, one CHANGELOG entry, one README touch, one SemVer bump. The trace-tag PR (commit `c226623`, +35 / -47 lines across 9 files) is the size exemplar. |

## Inputs & Outputs

**Inputs.**
- `vision/specs/roadmap.md:134-141` — the user's verbatim Problem / Example / Expected Output text.
- `vision/specs/roadmap.md:44` and `lsa/CHANGELOG.md:7-14` — the trace-tag-removal exemplar (commit `c226623`).
- `lsa/knowledge/conventions.md` — current LSA-internal vocabulary surface.
- `vision/VISION.md` §2 (especially principles 6, 7, 9) — the constitutional anchor.
- `vision/VISION.md:204` — EARS five-pattern definition.
- The full skill / agent / knowledge file inventory under `lsa/`, `core/`, `helper/`.
- The Claude Code plugin schema (referenced by `*.claude-plugin/plugin.json` in all three plugins) and the [plugin-dependencies docs](https://code.claude.com/docs/en/plugin-dependencies) (cited at `vision/specs/roadmap.md:25-26`).

**Outputs.**
- The inventory table in `design.md` §"Invention inventory" — ≥11 rows (3 named + ≥8 newly surfaced; this feature lands 11 in v1).
- A sequenced removal-PR plan in `tasks.md` — one task per `remove` row, ordered by blast radius.
- For each `remove` PR: a commit modifying only the surfaces that hold the invention, a `CHANGELOG.md` entry, a README touch (where user-visible), and a SemVer bump.
- For each `keep` row: a one-line defense in the inventory; no source-file edit.
- For each `needs-deeper-review` row: an entry in `design.md` §"Open Questions" naming the specific question to be resolved later.

## Constraints

- **No invention is removed without a passing rubric.** Specifically, F2 (a/b/c) must produce a `remove` recommendation; otherwise the row is `keep` or `needs-deeper-review`.
- **One invention per PR.** Mirrors the trace-tag-removal exemplar (commit `c226623`). Bundling removals couples blast radii.
- **Archive files are frozen.** Per `lsa/CHANGELOG.md:7-14`, archive files (`vision/specs/archive/**/`, `vision/plans/2026-05-20-*`) are intentionally untouched — historical references resolve via the current CHANGELOG entries.
- **Per-plugin SemVer + CHANGELOG.** Each removed-invention PR bumps the affected plugin's version and lands a CHANGELOG row in the same commit. Per `CLAUDE.md` *"Discipline (sourced)"*.
- **README touch on user-visible removals.** Per `CLAUDE.md` *"READMEs are living documents"* — any removal that changes a user-visible install / usage / skill surface updates the relevant README in the same commit.
- **No new conventions.** This sweep deletes; it does not introduce replacement inventions.

## Out of Scope

- Refactoring Helper from command-router to assistant (row #1, `vision/specs/roadmap.md:33`).
- Helper fast-path for onboarding questions (row #2, `vision/specs/roadmap.md:34`).
- Audit + tighten `AskUserQuestion` call sites (row #3, `vision/specs/roadmap.md:35`) — different decision rubric (when to ask, not what to keep).
- LSA verb-headline what-and-why preamble (row #4, `vision/specs/roadmap.md:36`) — interacts with the verb-headline-vocabulary candidate in this sweep; see `design.md` §"PR sequencing → row #4 interaction".
- Show actual changes inline (row #5, `vision/specs/roadmap.md:37`) — separate behavioral discipline.
- Reconcile-classification automation (`vision/specs/roadmap.md:32`) — Class (a) / (b) is a deliberate LSA-internal taxonomy; in scope only as an inventory entry, not for removal in this feature.
- Lints / harness checks that auto-detect new inventions (deferred to the Self-eval harness row in `vision/specs/roadmap.md:28`).
- Backfilling archive specs.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:204 — one of Ubiquitous / Event / State / Optional / Unwanted. -->

- **AC1** — *Ubiquitous*. A reader opening `design.md` shall, on the first screen of §"Invention inventory", see a table of ≥11 rows (3 named in the parent task + ≥8 newly surfaced) where every row carries `file:line`, a source-mandate cell (or "none"), a removal-cost cell, and a recommendation cell (`keep` / `remove` / `needs-deeper-review`). *Observable*: a Read of `design.md` returns the table; no row is missing any of the four cells.
- **AC2** — *Event*. When a reader opens any `keep` row, they shall, in the same row, see a one-line defense citing the irreplaceable capability the invention preserves. *Observable*: every `keep` row has a non-empty defense cell.
- **AC3** — *Event*. When a reader opens any `remove` row, they shall, in the same row, see (a) the standard or substrate primitive that subsumes the invention and (b) the removal cost (specific other surfaces that change). *Observable*: every `remove` row names both.
- **AC4** — *Event*. When a reader opens `tasks.md`, they shall see one sequenced task per `remove` row, ordered from lowest to highest blast radius, each task naming the target files, the CHANGELOG location, the README touch (if any), and the SemVer bump direction. *Observable*: task count = `remove` row count; ordering field is present and explicit.
- **AC5** — *Event*. When the agent applies any one of the `remove` PRs from `tasks.md`, the diff shall touch only the surfaces named in the inventory's removal-cost cell for that row, plus the plugin's `CHANGELOG.md`, plus (when user-visible) the relevant README. *Observable*: `git diff` of the PR matches the row's removal-cost cell exactly.
- **AC6** — *Unwanted*. If any inventory row's rubric (F2 a/b/c) does not yield a clear `keep` or `remove`, the row shall be recommended `needs-deeper-review` and the specific open question shall appear in `design.md` §"Open Questions" — the row shall not be silently defaulted. *Observable*: count of `needs-deeper-review` rows in inventory = count of rows in §"Open Questions" attributable to this sweep.
- **AC7** — *Ubiquitous*. No file under `vision/specs/archive/**/` or `vision/plans/2026-05-20-*` is modified by any PR generated from this feature. *Observable*: `git diff` of every PR touches zero archive files.
