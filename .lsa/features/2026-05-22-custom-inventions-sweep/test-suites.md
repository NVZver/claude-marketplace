# Test Suites: Sweep custom inventions; remove the unjustified

> Source: `.lsa/roadmap.md:134-141` §"2026-05-22 backlog detail" #6.

## Journey 1: Reader audits the inventory completeness and rubric consistency

**Goal:** A reader (the user or a future collaborator) opens `design.md` and confirms (a) the inventory is complete to the ≥11-row bar and traces to the parent task framing, and (b) the rubric was applied consistently to every row.
**Covers:** AC1, AC2, AC3, AC6, F1, F2, F3, F4, F5, NF1, NF2, NF3

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — inventory complete and consistent | Reader opens `design.md` §"Invention inventory" → counts rows → confirms count ≥11 → confirms 3 named rows present (`.lsa-sync-state.json`, file-load trace, Hard/Soft Confirm) → spot-checks 3 random rows → confirms `file:line` cell is concrete (opens the file, lands within ±3 lines of cited line) → confirms recommendation cell is one of `keep` / `remove` / `needs-deeper-review` → confirms `keep` rows have a one-line defense → confirms `remove` rows have removal-cost cell populated |
| 2 | Alternate — pick a `keep` row and challenge the defense | Reader opens a `keep` row → reads the one-line defense → asks *"is the cited substrate / standard surface actually irreplaceable?"* → if the rubric Step 3 *Substrate-coverage* answer is genuinely no, the defense holds; if a substrate primitive subsumes it, file a counter in `## Open Questions` of `design.md` for the next sweep |
| 3 | Alternate — pick a `remove` row and verify the removal cost matches | Reader opens a `remove` row → reads the removal-cost cell → opens each named file → confirms the listed surface actually contains the invention (`grep` for the file-line citation) → confirms no surface holding the invention is missing from the cell |
| 4 | Error — inventory short of bar | Reader counts <11 rows OR a row is missing `file:line` OR a `keep` row has no defense → AC1 or AC2 fails → return to `design.md` and remediate before any removal PR is opened |
| 5 | Error — `needs-deeper-review` row without matching `## Open Questions` entry | Reader sees a `needs-deeper-review` row → searches `## Open Questions` for the corresponding entry → if missing, AC6 fails → file the missing OQ before any removal PR is opened |

**Expected outcome:** A reader can, in under 10 minutes (NF5 size bar), confirm or refute the inventory's completeness and the rubric's consistent application. Every `keep` is defended; every `remove` names what replaces it; every `needs-deeper-review` has a tracked open question.

## Journey 2: Removal PR matches the inventory's removal-cost cell exactly

**Goal:** When the agent (or a human) opens one of the `tasks.md` removal PRs, the resulting `git diff` touches only the surfaces the inventory's removal-cost cell named for that row.
**Covers:** AC4, AC5, AC7, F6, F7, NF4, NF5

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — PR diff matches inventory exactly | Agent picks the next `remove` row from `tasks.md` → opens its inventory row → reads the removal-cost cell → makes the edits per the cell → adds the plugin CHANGELOG entry + SemVer bump + README touch (if user-visible) → runs `git diff --name-only` → confirms the touched-file set equals the inventory's removal-cost cell ∪ `{CHANGELOG.md, README.md if user-visible, plugin.json}` |
| 2 | Alternate — diff is a strict subset (one named surface no longer needs the touch) | Agent finds, mid-edit, that a surface named in the removal-cost cell was already cleaned by a prior PR (e.g., reference removed) → updates the inventory's removal-cost cell (`design.md`) in the same PR to reflect the smaller set → PR proceeds with the smaller diff |
| 3 | Alternate — diff is a strict superset (surface discovered mid-edit) | Agent finds, mid-edit, a previously un-inventoried surface that holds the invention → adds the surface to the inventory's removal-cost cell (`design.md`) in the same PR → PR proceeds with the expanded diff |
| 4 | Error — PR touches an archive file | Agent runs `git diff --name-only` → finds a path under `.lsa/archive/**/` or `.lsa/plans/2026-05-20-*` → AC7 fails → revert the archive-file edit; archives are frozen per `lsa/CHANGELOG.md:7-14` |
| 5 | Error — PR missing CHANGELOG entry or SemVer bump | Reviewer opens the PR → searches for the plugin's `CHANGELOG.md` diff → if missing, NF5 / F7 fails → reviewer requests the entry + bump before merge per `CLAUDE.md` *"Discipline (sourced)"* |
| 6 | Error — PR touches a `keep` row's surface | Agent or reviewer opens the PR → cross-references the touched files against `keep`-row inventory entries → if any `keep` row's primary site is touched, F8 fails → revert the unrelated edit, raise as a separate `needs-deeper-review` OQ if intentional |

**Expected outcome:** Each `remove` PR is small (NF5 — <5 minute review), bounded (touches only inventory-named surfaces), discipline-compliant (CHANGELOG + SemVer + README touch in same commit), and archive-safe (zero archive-file edits).

## Journey 3: Rubric is applied identically to every row

**Goal:** A reader can replay the rubric (Step 1 source-mandate → Step 2 capability-lost → Step 3 substrate-coverage) against any row in the inventory and arrive at the same recommendation the inventory recorded.
**Covers:** AC1, AC2, AC3, AC6, F2

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — rubric is reproducible per row | Reader picks any inventory row → reads the source-mandate cell → applies Step 1 (any of EARS / SemVer / Keep a Changelog / CommonMark / Claude Code plugin schema / substrate primitive) → confirms the cell's answer matches → applies Step 2 (capability lost if removed?) → reads the removal-cost cell to answer in the row's frame → applies Step 3 (substrate-coverage?) → confirms the recommendation cell's answer is the rubric's answer |
| 2 | Alternate — a `keep` recommendation flips to `remove` on re-application | Reader re-runs the rubric → answer for that row is `remove` not `keep` → reader files a counter-OQ in `design.md` §"Open Questions"; does not silently override the recorded decision |
| 3 | Error — a row's recommendation does not match the rubric output | Same as Path 2 — file a counter-OQ. Per AC6, a row whose rubric does not yield a clear `keep` / `remove` should already be `needs-deeper-review`; if the inventory records a definitive recommendation the re-application disputes, the inventory is wrong and remediation is required before any PR for that row |

**Expected outcome:** The rubric is reproducible — two readers applying it independently to the same row reach the same recommendation, or the disagreement is explicit and tracked in §"Open Questions".

---

## Cross-artifact coverage check (Diagonal — per `lsa/skills/lsa-specify/SKILL.md:170-180`)

| # | Pair | Status | Citation |
|---|------|--------|----------|
| 1 | AC→Journey | ✓ | AC1–AC3, AC6 → Journey 1; AC4–AC5, AC7 → Journey 2; AC1–AC3, AC6 → Journey 3 |
| 1a | EARS-pattern | ✓ | requirements.md §"Acceptance Criteria" maps each AC to one of Ubiquitous / Event / Unwanted per `.lsa/VISION.md:204` |
| 1b | Journey-shape | ✓ | Every AC names a user-observable behavior (reader opens file, reader sees row, reader counts rows, agent diffs PR) at the user/system boundary — not unit-test scope. Per `.lsa/VISION.md` §2 sub-principle 2a |
| 2 | Journey→Design | ✓ | Journey 1 → `design.md` §"Invention inventory" + §"Decision rubric"; Journey 2 → `design.md` §"PR sequencing" + §"Cross-Module Contracts"; Journey 3 → `design.md` §"Decision rubric" |
| 3 | Design→Contract | N/A — contract skipped (no API endpoints, no shared data types) |
| 4 | Contract→test-suites | N/A — contract skipped |
