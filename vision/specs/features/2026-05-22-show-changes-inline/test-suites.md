# Test Suites: Show actual changes inline (LSA / Core / Helper)

> Source: `vision/specs/roadmap.md:128-132` §"2026-05-22 backlog detail" #5.
> Requirements: `requirements.md`. Design: `design.md`.

## Verification approach (overview)

This row is an **output-discipline** change. There is no executable test surface — no API to call, no schema to validate, no compile step to fail. Verification therefore takes three forms, in increasing order of effort:

1. **Static grep predicates** — mechanical checks on the skill bodies post-sweep. Cheap, runnable in CI when a self-eval harness lands (deferred per `vision/specs/roadmap.md:28`).
2. **Reviewer checklist** — a human reviewer walks the seven-element template against five sample skill outputs before merge.
3. **Dogfood roleplay** — for User Verification 3, roleplay one Standard-flow and one Extended-flow session against the swept skills and verify every quoted-change instance meets Rule 6.

Each Journey below ties a verification path to one or more Acceptance Criteria in `requirements.md`.

## Journey 1: Single-file edit echo (AC1, AC7)

**Goal:** Verify that after a single-file write performed by a swept LSA skill, the human sees the new content quoted inline before any commentary.

**Covers:** `requirements.md` AC1, AC7 (worked-example #1 — single-file edit).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy: `lsa-specify` writes `requirements.md` (User Verification 1, step 4) | Run `/lsa:specify` for a tiny one-AC feature. After step 4 finishes, inspect the response: does it quote the actual `requirements.md` Functional Requirements table (or compressed table per AC3) before saying *"approval logged"*? |
| 2 | Negative: skill produces only *"file written"* prose | Manually revert one swept `Observable result:` line and re-run. Confirm the regression manifests as a bare *"file written"* line in the response — the reviewer-checklist catches it. |

**Expected outcome:** Path 1 — response contains a fenced markdown block quoting the new file content with `path:line` header, followed by commentary. Path 2 — the regression is visible at-a-glance (no quoted block before commentary).

## Journey 2: Replacement edit (previous + new both quoted) (AC2)

**Goal:** Verify that when a class-(a) replacement edit happens (per `lsa/skills/lsa-reconcile/SKILL.md:38`), both the previous and the new content are quoted in order.

**Covers:** `requirements.md` AC2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy: `lsa-reconcile` runs against a real drift | Make an artifact edit that contradicts a module spec line. Run `/lsa:reconcile`. Confirm the response contains both the previous (verbatim spec quote with path:line) and the new (verbatim artifact quote with path:line). |
| 2 | Happy: `lsa-revise-constitution` proposes a `modify`-type change | Trigger `lsa-revise-constitution` with a modify change. Inspect step 3's response: previous content first (or "none" if pure add), then proposed content, then reason. |

**Expected outcome:** Both paths — previous-then-new ordering preserved; both quoted with path:line; reason follows. (`lsa-reconcile`'s existing block already meets this; the test verifies the sweep didn't regress it.)

## Journey 3: Batch / multi-file write uses compressed inspection table (AC3)

**Goal:** Verify that when a single turn writes more than ~5 files (or more than ~10 lines), the response uses a compressed inspection table instead of full single-change blocks.

**Covers:** `requirements.md` AC3.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy: `lsa-init` brownfield writes `main.spec.md` + `roadmap.md` + `research-backlog.md` + 3 module specs | Run `/lsa:init` in brownfield mode against a fixture repo with 3 inferred modules. Confirm step 3's response renders a single inspection table covering all 6+ writes, not six separate quoted-content blocks. |
| 2 | Happy: `lsa-sync` updates 2 module specs + main.spec.md + state file in one turn | Run `/lsa:sync` against a feature that touched two modules. Confirm the sync report uses one table for the four+ writes. |
| 3 | Negative: single-file edit incorrectly uses compressed table | A single-line edit forced into a one-row table is a smell — the reviewer-checklist flags it (Rule 6 single-change template should be used for ≤5 files / ≤10 lines). |

**Expected outcome:** Paths 1 + 2 — one table, columns `# | file:line | type | summary | pointer`, ≤30 lines rendered, followed by pointer cluster. Path 3 — caught by reviewer at PR time.

## Journey 4: State-mark with quoted before/after (AC4)

**Goal:** Verify that *"marked X resolved"* style actions quote the actual state-file line(s) that changed.

**Covers:** `requirements.md` AC4.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy: `lsa-sync` bumps SHA in `.lsa-sync-state.json` | Run `/lsa:sync`. Inspect step 6's response: does it quote the new JSON fragment (per Rule 6 worked-example #3 shape) for each module's bumped SHA? |
| 2 | Happy: `lsa-specify` marks a User-Verification approval | After User Verification 1 approval, the response should quote the now-resolved decision line (or the new `[approved]` tag on the requirements section), not just say *"human approval logged"*. |
| 3 | Happy: `lsa-sync` archives a feature directory | Step 5's response quotes the `mv` source + destination paths, not just *"archive directory exists at the new path; original is gone."* |

**Expected outcome:** Each path's response contains a quoted block (JSON fragment / markdown line / shell command) showing the actual mark — no *"marked"* without content.

## Journey 5: Sweep coverage (AC5)

**Goal:** Verify that every `Observable result:` line in `lsa/skills/**/SKILL.md` that names a write/edit/append/mark cites Rule 6 and names what is quoted back.

**Covers:** `requirements.md` AC5.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Static grep: post-sweep | Run `grep -rn "Observable result:" lsa/skills`. For each row that includes `written\|edited\|appended\|marked\|exists\|diff shown`, verify the line cites `core/output` Rule 6 (markdown link) and names the quote-back format. |
| 2 | Static grep: regression | Run the same grep before the sweep — expect ≥16 violations matching the inventory in `design.md`. After sweep — expect 0. |
| 3 | Static grep: `core` + `helper` | Run the same grep on `core/skills` and `helper/agents`. Expect 0 violations (per inventory in `design.md`). |

**Expected outcome:** Path 1 — every relevant line cites Rule 6. Path 2 — count goes from 16 to 0. Path 3 — stays at 0.

## Journey 6: Write failure surfaces failure phrase, no fake quote (AC6)

**Goal:** Verify that when a write fails (e.g., disk full, permission denied), the response surfaces *"write failed — no content to quote"* rather than rendering fabricated quoted content.

**Covers:** `requirements.md` AC6.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Negative: simulate write failure | Force a write failure during a swept skill (read-only filesystem, missing parent dir). Confirm response says *"write failed"* with the error reason, and contains no fenced quoted block of pre-write speculation. |

**Expected outcome:** Failure phrase rendered; no fake quote; `core/ground-rules` Rule 2 (fact-grounding) preserved.

## Journey 7: Rule 6 lands intact in `core/skills/output/SKILL.md` (AC7)

**Goal:** Verify that the drafted Rule 6 from `design.md` lands verbatim (or with only renumbering tweaks) in `core/skills/output/SKILL.md`, and includes all three templates + three worked examples.

**Covers:** `requirements.md` AC7.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Static read | Read `core/skills/output/SKILL.md` after Step A of the sweep. Confirm sections: *"Single-change template"*, *"Batch template — compressed inspection table"*, *"What this rule forbids"*, *"Worked examples"* (with three sub-examples). |
| 2 | Static read: cross-cite | Confirm the rule cites `lsa/skills/lsa-reconcile/SKILL.md` as the exemplar. |
| 3 | Static read: line budget | Confirm the entire Rule 6 block stays under 90 lines rendered (NF1 = under 50 lines for the rule body proper, + worked examples). |

**Expected outcome:** All three paths pass after the Core PR merges.

## Reviewer checklist (single screen, for PR review)

Distilled from the seven Journeys above:

- [ ] **Rule 6 lands intact.** Three template forms + three worked examples present in `core/skills/output/SKILL.md`.
- [ ] **Cross-cite to exemplar.** Rule 6 names `lsa/skills/lsa-reconcile/SKILL.md` as the exemplar source.
- [ ] **Grep zero.** `grep -rn "Observable result:.*\(written\|edited\|appended\|marked\|diff shown\)" lsa/skills` returns 0 lines that don't cite Rule 6.
- [ ] **Single-change form.** At least one swept skill's `Observable result:` line for a single-file write names *"full single-change block"* per Rule 6.
- [ ] **Batch form.** At least one swept skill's `Observable result:` line for a multi-file write names *"compressed inspection table"* per Rule 6.
- [ ] **Failure form.** At least one swept skill's failure path names *"write failed — no content to quote"*.
- [ ] **Helper inherits.** `helper/agents/helper.md` `## Constraints` has a Rule 6 reference.
- [ ] **Operational checkpoint.** `core/CLAUDE.md` has a fourth bullet citing Rule 6 alongside the existing three.
- [ ] **CHANGELOG + SemVer.** Each touched plugin has a CHANGELOG entry + version bump.

## Heuristic for future-skill review (not a test — a discipline check)

When a new skill or hook is added to the marketplace, the author runs a one-question check against every `Observable result:` line: **"After reading this `Observable result:` line, can the user confirm what changed without opening another file?"** If no — the line is a Rule 6 violation. This heuristic stays unwritten in CI until the self-eval harness ships (deferred per `vision/specs/roadmap.md:28`).
