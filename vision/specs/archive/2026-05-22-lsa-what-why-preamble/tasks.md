# Tasks: LSA — what-and-why preamble on every verb-headline

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #4 (`vision/specs/roadmap.md:122-126`).
>
> Decomposed per `lsa/skills/lsa-plan/SKILL.md`. Five epics max.

## Recommended PR shape

**One bundled PR.** The rule + 5 skill-body edits + 2 changelogs + (≤1) README touch is ≤ ~12 file edits and forms a single semantic change. Splitting into per-skill PRs would force `core` to ship in isolation and break the rule citation in 5 LSA skills until LSA also merges — net friction without benefit. Bundle reduces partial-state risk.

The PR contains commits in the order below (each commit is mergeable in isolation against `main`; in practice the maintainer may squash):

## Epic 0 — Roadmap vocabulary correction

**Scope.** Single-line edit to `vision/specs/roadmap.md:124` replacing the speculative verb list (`INFERRED`, `MERGED`, `RECONCILED`, `SYNCED`, `GATED`) with the canonical 10-verdict vocabulary from `core/knowledge/output-vocabulary.md:11-22`. Bundled in this PR because the rest of the feature cites the canonical vocabulary and the roadmap row would otherwise drift on merge.

**Covers:** Roadmap-correction note per `design.md` §"Verb-headline inventory".

**Steps:**

1. Edit `vision/specs/roadmap.md:124` to point at the canonical vocabulary by link rather than listing speculative verbs.
2. No CHANGELOG entry needed (roadmap is planning surface, not user-facing).

**Acceptance:** `vision/specs/roadmap.md:124` no longer lists `INFERRED / MERGED / RECONCILED / SYNCED / GATED`; cites `core/knowledge/output-vocabulary.md` instead.

## Epic 1 — `core/output`: add Rule 6 ("What-and-why preamble")

**Scope.** Edit `core/skills/output/SKILL.md` to add a new **Rule 6** named "What-and-why preamble — verdicts carry a one-sentence frame". (OQ1 resolved: new Rule 6, not a sub-bullet under Rule 5 — see `design.md` §"Where the rule lives".) Update `core/CHANGELOG.md` and bump `core/plugin.json`.

**Covers:** F1, F2, F4, F5, AC6.

**Steps:**

1. Edit `core/skills/output/SKILL.md` to append a new Rule 6 section after Rule 5 (around line 40). Insert content per `design.md` §"Concrete shape of the `core/output` edit".
2. Update `core/CHANGELOG.md` with a Keep-a-Changelog entry under a new version. Note: framing changes from "five golden rules" to "six golden rules" — minor bump candidate (OQ4).
3. Bump `core/plugin.json` version (OQ4 in `design.md` — minor bump recommended due to user-visible rule-count change).
4. Coordinate naming with row #5: this PR locks in Rule 6 = "What-and-why preamble"; row #5 will claim Rule 7 = "Show changes inline".
5. If `core/README.md` enumerates the rules by count or name, add Rule 6 there; otherwise leave untouched (pull, not push).

**Acceptance:** `core/skills/output/SKILL.md` contains a new Rule 6 section citing `core/knowledge/output-vocabulary.md` and stating the canonical format. `core/CHANGELOG.md` + `core/plugin.json` updated in the same commit.

## Epic 2 — `lsa-init`: preamble before `PROPOSED` at brownfield confirm

**Scope.** Edit `lsa/skills/lsa-init/SKILL.md:51` to (a) replace the worked-example template with a preamble-first template, (b) cite the new `core/output` sub-rule by link.

**Covers:** F6, AC1, AC6, AC8.

**Steps:**

1. Rewrite the "Present: PROPOSED verdict …" sentence to lead with a preamble per `design.md` §"Worked examples" example 1 (gold reference from `vision/specs/roadmap.md:125`).
2. Add a one-line citation: *"Verdict carries a preamble per [`core/output`](…) Rule 6."*
3. Run helper-mode UX check (`test-suites.md` Journey 2 Path 3).

**Acceptance:** Bare-verdict grep predicate (`test-suites.md` Journey 2 Path 1) returns no hits in this file's worked-example block; citation grep (Journey 2 Path 2) hits.

## Epic 3 — `lsa-reconcile`: preamble before `DRIFT`

**Scope.** Edit `lsa/skills/lsa-reconcile/SKILL.md:35` per the same pattern.

**Covers:** F6, AC2, AC6, AC8.

**Steps:**

1. Rewrite per `design.md` §"Worked examples" example 2.
2. Add the citation line.
3. Helper-mode UX check.

**Acceptance:** Same grep predicates as Epic 2, scoped to this file.

## Epic 4 — `lsa-sync` + `lsa-revise-constitution`: preamble before `APPLIED` / `PROPOSED`

**Scope.** Edit `lsa/skills/lsa-sync/SKILL.md:131` and `lsa/skills/lsa-revise-constitution/SKILL.md:61` per the same pattern. Bundled because each has exactly one site and similar prose-confirm shape.

**Covers:** F6, AC4, AC5, AC6, AC8.

**Steps:**

1. Rewrite each per `design.md` §"Worked examples" examples 4 and 5.
2. Add the citation line to each.
3. Re-read `lsa/skills/lsa-sync/SKILL.md:17,99` (narrative `PASS` references). Confirm no edit needed (Open Question 3 in `design.md`); if a re-reading flips the call, add to scope.
4. Helper-mode UX check on each.

**Acceptance:** Same grep predicates; 2 files in scope.

## Epic 5 — `lsa-verify`: preamble before each of `PASS` / `FAIL` / `PASS WITH WARNINGS` + LSA-side wrap-up

**Scope.** Edit `lsa/skills/lsa-verify/SKILL.md:83-85` to add a preamble before each variant. Update `lsa/CHANGELOG.md`. Bump `lsa/plugin.json`. Update `lsa/README.md` if it enumerates verdict formats.

**Covers:** F6, F7, AC3, AC6, AC7, AC8.

**Steps:**

1. Rewrite each of the 3 variants per `design.md` §"Worked examples" example 3 (and analogous for `PASS` and `PASS WITH WARNINGS`).
2. Add a single citation line at the top of Step 4 in the skill body covering all three variants.
3. Re-read `lsa/skills/lsa-plan/SKILL.md:87,114` (in-table `PASS / FAIL` cells). Confirm Open Question 2 resolution: table cells, not verdict emissions — document the exclusion inline if needed, otherwise no edit.
4. Update `lsa/CHANGELOG.md` with a single entry covering all 5 skill-body edits (this Epic + Epics 2, 3, 4).
5. Bump `lsa/plugin.json`.
6. If `lsa/README.md` enumerates verdict formats or pre-amble samples, update; else leave untouched.
7. Run all `test-suites.md` Journey 2 + Journey 3 predicates against the full PR diff.

**Acceptance:** All 7 reviewer predicates in `test-suites.md` Journey 3 pass. Both CHANGELOGs + both `plugin.json` bumps land in the same commit as the skill-body edits.

## Closing checklist (`lsa-plan` template)

- [ ] All epics merged into feature branch
- [ ] tests passing (n/a — no executable tests; review checklist passed)
- [ ] No regressions in CI (n/a — no CI for skill bodies)
- [ ] lsa-verify passed on feature branch
- [ ] lsa-sync completed
- [ ] On merge, edit `vision/specs/roadmap.md` row "LSA: what-and-why preamble on every verb-headline" — move from Feature Backlog to Recently merged. (Distinct from Epic 0's vocabulary correction at `roadmap.md:124`.)
