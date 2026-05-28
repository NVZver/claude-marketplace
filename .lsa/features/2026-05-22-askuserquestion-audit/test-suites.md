# Test Suites: Audit + tighten `AskUserQuestion` call sites (Helper + LSA)

> Source: `.lsa/roadmap.md` §"2026-05-22 backlog detail" #3 (`.lsa/roadmap.md:116-120`).

Verification is a mix of mechanical re-grep and human roleplay — there is no compiled artifact to test. Per `.lsa/VISION.md` §2 sub-principle 2a, every journey is user-observable at the user/system boundary.

## Journey 1: Inventory completeness — every call site classified

**Goal:** After PR-A, PR-B, PR-C all land, every `AskUserQuestion` reference in Helper + LSA traces to an inventory row in `design.md` §"Call-site inventory".
**Covers:** AC1, AC5.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Mechanical sweep | Run `grep -rn "AskUserQuestion" helper/ lsa/skills/` on the merged commit. For each hit, locate the matching `file:line` row in the inventory table. Hit-count and row-count must match. |
| 2 | Drift check | If new `AskUserQuestion` references appear post-merge (in PRs landed after this feature), they shall pass the rubric in code review or be flagged in `lsa-reconcile`. |

**Expected outcome:** 100% of grep hits map to a row. Any orphan grep hit fails review.

## Journey 2: Rubric application by a second reviewer

**Goal:** A reviewer who has not seen the original audit applies the Genuine-fork test from `core/skills/output/SKILL.md` Rule 5 sub-rule to the same call sites and reaches the same verdicts.
**Covers:** AC4, F2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Blind classification | Hand the reviewer a fresh inventory skeleton (`file:line` + context column, verdict column blank) and the published `core/output` Rule 5 sub-rule. They fill in verdicts. |
| 2 | Verdict diff | Compare their verdicts against `design.md`. Disagreements >2 rows = rubric is ambiguous; refine wording in PR-A. |

**Expected outcome:** ≥15 of 17 live verdicts match independently. Disagreements are documented and either accepted (verdict revised) or rejected (rubric wording sharpened).

## Journey 3: Live behavior — `/help "how do I install LSA?"` (representative user query)

**Goal:** The dominant user-visible failure mode from `.lsa/roadmap.md:119` no longer reproduces.
**Covers:** AC2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Roleplay | Invoke `/help "how do I install LSA?"` against post-merge `helper/agents/helper.md`. Observe response. |
| 2 | Assert | Response opens with a cited excerpt from `README.md` (default plugins block) or `lsa/README.md`. No opening `AskUserQuestion` picker. At most ONE closing picker if a real next step exists; otherwise zero pickers. |

**Expected outcome:** First Helper turn is a cited answer, not a picker. Total response ≤1.5 screens per `core/skills/output/SKILL.md` Rule 2. Note: full *dispatch posture* fix lives in backlog #1 — this journey verifies only the call-site classification holds.

## Journey 4: `lsa-discover` tightening — silent acceptance on single candidate

**Goal:** When `lsa-discover` Step 1 yields exactly one candidate per question (module / change / AC) AND the user does not speak, the per-line picker is skipped.
**Covers:** AC3.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Single-module repo | Run `/lsa:discover` in a Standard-flow context where `main.spec.md` lists exactly one module and the change framing is unambiguous from the user message. |
| 2 | Assert | The three-row discovery table renders with the single candidate filled in. No `AskUserQuestion` was opened for module / change / AC lines unless ≥2 candidates or `custom` exist. |

**Expected outcome:** Discovery table appears; no redundant pickers; silence-on-a-line behavior matches existing `lsa-discover/SKILL.md:26` semantics extended to single-candidate skip.

## Journey 5: `core/output` Rule 5 sub-rule cites Principle 9 correctly

**Goal:** A reader of `core/output` Rule 5 can identify which rule governs *fork-existence* vs *primitive choice*.
**Covers:** AC4, F4.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Document read | Read `core/skills/output/SKILL.md` Rule 5 after PR-A merges. Confirm the new sub-rule names the orthogonality to `.lsa/VISION.md:66` Principle 9. |
| 2 | Reviewer check | A reviewer asks: *"If a picker is justified, which rule says to use `AskUserQuestion`? If a picker is NOT justified, which rule says don't open one?"* Both questions resolve to a single cited line. |

**Expected outcome:** Rule 5 sub-rule answers both questions distinctly. No reader conflates the two.

## Journey 6: No regression — destructive pickers remain

**Goal:** All `keep`-verdict call sites continue to open `AskUserQuestion` for destructive operations.
**Covers:** AC1, AC5 (inverse).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | `lsa-sync` apply gate | Run `/lsa:sync` against a feature branch. Confirm the pre-write delta picker (L11) appears with three options (`apply` / `modify` / `reject`). |
| 2 | `lsa-revise-constitution` | Run with one proposed change. Confirm per-change picker (L14) appears. |
| 3 | `lsa-reconcile` drift | Trigger drift on one module. Confirm per-module picker (L13) appears with quoted current/proposed content. |
| 4 | `flow-selector` | Trigger any non-trivial task. Confirm Quick/Standard/Extended picker (L15) appears. |

**Expected outcome:** All four destructive gates fire. No silent writes.

## Notes

- Journeys 1, 5, 6 are mechanical/grep-based and can run unattended.
- Journeys 2, 3, 4 require a human reviewer (roleplay). Per `MEMORY.md` `finding_helper_mode_as_ux_check.md`, a 5-min roleplay before "skill done" is the established discipline.
- No automated test framework yet for skill bodies — the marketplace's verification is read-and-roleplay, not unit-test.
