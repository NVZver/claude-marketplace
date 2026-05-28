# Test Suites: LSA — what-and-why preamble on every verb-headline

> Source: `.lsa/roadmap.md` §"2026-05-22 backlog detail" #4 (`.lsa/roadmap.md:122-126`).

The feature ships changes to skill *bodies* (markdown text), not executable code. Verification combines (a) mechanical grep predicates, (b) a manual review checklist, (c) a helper-mode UX roleplay. No automated harness is added; the marketplace has no test runner for skill-body content beyond `core/tests/repo-anchored.md` D2 probe (`core/skills/output/SKILL.md:8`).

## Journey 1: User reaches a verdict emission and gets a what-and-why preamble

**Goal:** A user (LSA-fluent or not) invoking any LSA skill that emits a verdict label sees a one-sentence preamble before the verdict line, naming the action and consequence in their frame.

**Covers:** AC1, AC2, AC3, AC4, AC5, AC6.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | `/lsa:init` brownfield → inferred-modules confirm | Verify `lsa/skills/lsa-init/SKILL.md:51` worked-example shows preamble before `PROPOSED`. Roleplay as non-LSA reader: can I tell what would happen if I rejected? |
| 2 | `/lsa:reconcile` → per-module hard confirm | Verify `lsa/skills/lsa-reconcile/SKILL.md:35` worked-example shows preamble before `DRIFT`. Roleplay: do I understand *which* file diverges and *why* that's a problem? |
| 3 | `/lsa:verify` → three report variants (`PASS` / `FAIL` / `PASS WITH WARNINGS`) | Verify `lsa/skills/lsa-verify/SKILL.md:83-85` worked-examples show preamble before each variant. Roleplay: for `FAIL`, do I know what merging would break? |
| 4 | `/lsa:sync` → applied-modules report | Verify `lsa/skills/lsa-sync/SKILL.md:131` worked-example shows preamble before `APPLIED`. Roleplay: do I know what just changed and what the next decision controls? |
| 5 | `/lsa:revise-constitution` → per-change hard confirm | Verify `lsa/skills/lsa-revise-constitution/SKILL.md:61` worked-example shows preamble before each `PROPOSED`. Roleplay: do I know which constitution section is about to change? |

**Expected outcome:** All 5 paths produce a verdict emission whose preceding line is a single-sentence preamble naming (a) action in plain English, (b) consequence of inaction. No path produces a bare verdict line.

## Journey 2: A non-LSA reader audits the marketplace for compliance

**Goal:** Someone who has never read `lsa/knowledge/conventions.md` can mechanically verify the rule.

**Covers:** AC6, AC7, AC8.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Grep predicate — bare verdict labels in LSA skill bodies | Run `grep -nE '^[[:space:]]*\*?\*?(PROPOSED\|APPLIED\|DRIFT\|PASS\|FAIL\|BLOCKED\|READY\|CLEAN\|REJECTED\|PASS WITH WARNINGS)[:\*]' lsa/skills/*/SKILL.md` against worked-example blocks. Each match must be preceded *in the same paragraph or backticked block* by an English sentence (preamble). Visual review — no automated parser. |
| 2 | Grep predicate — rule citation present | Run `grep -l 'core/skills/output/SKILL.md' lsa/skills/lsa-init/SKILL.md lsa/skills/lsa-reconcile/SKILL.md lsa/skills/lsa-sync/SKILL.md lsa/skills/lsa-revise-constitution/SKILL.md lsa/skills/lsa-verify/SKILL.md` — all 5 files must match (per F6 and AC8). |
| 3 | Helper-mode UX check (`finding_helper_mode_as_ux_check.md` in memory index) | Roleplay each worked example as a first-time downstream collaborator. For each preamble: replace "I" with "this tool" — does the sentence still parse? Replace each LSA-jargon noun with its plain-English gloss — does the sentence get *shorter*? If yes (gloss is shorter), the original used jargon and should be rewritten. |

**Expected outcome:** Grep predicates pass (Path 1: no bare verdict in worked examples; Path 2: 5/5 files cite `core/output`); helper-mode roleplay surfaces no preamble that reads as LSA-frame rather than user-frame.

## Journey 3: Review checklist for the implementation PR

**Goal:** A reviewer of the implementation PR (executed via `tasks.md`) has a concrete predicate list.

**Covers:** AC6, AC7, AC8 + NF1, NF2, NF3.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Preamble length predicate | Each preamble ≤ ~25 words / ≤ 1 sentence. NF1. |
| 2 | User-frame predicate | Each preamble passes the "replace 'I' with 'this tool'" test. NF3. |
| 3 | Consequence predicate | Each preamble contains a clause naming the consequence — e.g., "without …", "merging now would …", "rejecting leaves …". Roadmap row's gold reference (`.lsa/roadmap.md:125`). |
| 4 | Jargon-gloss predicate | Each LSA-vocabulary term (per F3) is either avoided or glossed in 3–5 words at first use per turn. |
| 5 | Citation predicate | Each affected LSA skill body cites the new `core/output` sub-rule by markdown link, with no rule restatement (per AC8 + `core/skills/output/SKILL.md:8`). |
| 6 | CHANGELOG predicate | `core/CHANGELOG.md` and `lsa/CHANGELOG.md` each gain one entry under a new version; both `plugin.json` files bump per Keep a Changelog + SemVer (per `CLAUDE.md` "Discipline (sourced)" — "*Per-plugin SemVer + CHANGELOG*"). |
| 7 | README predicate | Per `CLAUDE.md` "Discipline (sourced)" — `core/README.md` and (if it enumerates verdict formats) `lsa/README.md` reflect the change. |

**Expected outcome:** All 7 predicates pass before the implementation PR merges. A FAIL on any predicate blocks merge; per `lsa/skills/lsa-verify/SKILL.md:81-92` standard PASS/FAIL semantics.
