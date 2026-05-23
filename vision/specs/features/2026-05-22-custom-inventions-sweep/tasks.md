# Tasks: Sweep custom inventions; remove the unjustified

> Source: `vision/specs/roadmap.md:134-141` §"2026-05-22 backlog detail" #6.
> Sequencing rule: one PR per `remove` row, ordered lowest → highest blast radius. Mirrors commit `c226623` (`lsa/CHANGELOG.md:7-14`) which removed one invention (trace tags) in one PR.

## Task ordering

The sequence below has 2 removal tasks (inventory rows #3 and #1) and 3 follow-up tasks (each tracking one of the 3 `needs-deeper-review` rows). The `keep` rows are not tasks — they generate no PR.

| # | Task | Type | Inventory row | Blast radius | Dependencies |
|---|------|------|---------------|--------------|--------------|
| T1 | PR: Remove "Hard Confirm" / "Soft Confirm" vocabulary | removal | #3 | LOW (≤5 files) | none |
| T2 | PR: Remove `.lsa-sync-state.json` | removal | #1 | MEDIUM (≤7 files + 1 hook script) | none — independent of T1 |
| T3 | Defer OQ1 (file-load trace) to next dogfood log | follow-up | #2, #5 | none (research entry) | next dogfood log row in `vision/specs/roadmap.md:23` |
| T4 | Surface OQ2 (verb-headline vocabulary) in row #4's design.md | follow-up | #4 | none (cross-feature note) | row #4 backlog item gets specified (`vision/specs/roadmap.md:36`) |
| T5 | Flag OQ4 (probe-as-substrate) for the next sweep | follow-up | (rubric) | none (note in this spec) | next custom-invention sweep, if any |
| T6 | Move roadmap row to "Recently merged" on land | follow-up | — | none (one-line roadmap edit) | T1 + T2 merged |

## T1 — PR: Remove "Hard Confirm" / "Soft Confirm" vocabulary

**Inventory row:** #3 (`design.md` §"Invention inventory"). Recommendation: `remove`.

**Cross-row sequencing (row #4 collision).** T1 edits `lsa-specify:21`, `lsa-reconcile:35`, `lsa-revise-constitution:61`, and `lsa-sync`. Roadmap row #4 (LSA what-and-why preamble, `vision/specs/features/2026-05-22-lsa-what-why-preamble/`) edits the same lines `lsa-reconcile:35` and `lsa-revise-constitution:61`. **T1 must ship AFTER row #4 lands.** Row #4 cites the Hard/Soft vocabulary as it currently stands when augmenting verb-headlines; if T1 ships first, row #4 must rebase its citations and re-author the preambles against the plain-English replacements. Sequencing T1 second avoids the double rewrite.

**Branch:** `feature/lsa-remove-confirm-vocabulary` (new) per `lsa/ARCHITECTURE.md:117-126`.

**Files touched (per inventory removal-cost cell, row #3):**
1. `lsa/knowledge/conventions.md:40-50` — delete §"Confirm gate types" section (header `:40`, entries `:44-45`, used-by `:47-50`).
2. `lsa/skills/lsa-specify/SKILL.md:21` — replace *"All three Verifications in this skill are **Hard Confirm**"* with plain-English *"All three Verifications stop until the human explicitly approves; no implicit approval is accepted."*
3. `lsa/skills/lsa-reconcile/SKILL.md:35` — replace *"Per-module hard confirm"* in the step name with *"Per-module — stop and present each delta individually; do not proceed without explicit approval."*
4. `lsa/skills/lsa-revise-constitution/SKILL.md:61` — replace *"Human review gate."* sentence's reliance on the named distinction with plain-English phrasing.
5. `lsa/skills/lsa-sync/SKILL.md` — grep for any "Hard"/"Soft" Confirm uses; replace inline.
6. `lsa/CHANGELOG.md` — add entry under a new `## [vNEXT] - 2026-05-DD` heading (Keep a Changelog format).
7. `lsa/.claude-plugin/plugin.json` — bump version (**minor** — matches the trace-tag PR precedent in commit `c226623`, which moved `0.6.5` → `0.7.0` for a user-visible documented-convention removal).
8. `lsa/README.md` — only if a user-visible cite of the convention exists; `grep` first.

**SemVer bump:** **minor** (e.g., `0.7.0` → `0.8.0`). Matches the `c226623` precedent: trace-tag PR moved `0.6.5` → `0.7.0` (minor) because it removed a user-visible documented convention section. This PR removes another user-visible documented convention section (`conventions.md` §"Confirm gate types" plus inline references across 4 skill bodies), so the same precedent applies. Recommended over patch because the convention removal is user-visible (anyone who learned the Hard/Soft vocabulary sees it disappear).

**CHANGELOG entry shape (per `lsa/CHANGELOG.md` v0.7.0 entry as template):**

```markdown
## [vNEXT] - 2026-05-DD

### Removed

- `lsa/knowledge/conventions.md` §"Confirm gate types" deleted. *Hard Confirm* / *Soft Confirm* were LSA-internal vocabulary with no upstream mandate; substituted plain-English phrasing inline at each cite site (`lsa-specify`, `lsa-reconcile`, `lsa-revise-constitution`, `lsa-sync`). Per the custom-inventions sweep at `vision/specs/features/2026-05-22-custom-inventions-sweep/design.md` inventory row #3.
```

**Verification:**
- `grep -rn "Hard Confirm\|Soft Confirm" lsa/` returns zero results.
- All 3 acceptance gates of `lsa-specify` still wire `AskUserQuestion` per `core/output` Rule 5 (verified by re-reading the renamed steps).
- The PR diff matches §"Files touched" above (Journey 2 path 1).

**Observable result:** PR opened, reviewer approves, merged to `main`.

## T2 — PR: Remove `.lsa-sync-state.json`

**Inventory row:** #1 (`design.md` §"Invention inventory"). Recommendation: `remove`.

**Cross-row sequencing (row #5 collision).** T2 edits `lsa/skills/lsa-sync/SKILL.md:84-95` (deleting Step 6). Roadmap row #5 (Show actual changes inline) cites `lsa-sync:97` in its inventory — adjacent line numbers. If T2 lands first, row #5's `:97` citation will shift upward by ~12 lines. Coordinate with the row-#5 implementor: either land row #5 first (T2 then re-anchors its own line numbers post-rebase) or update row #5's citation after T2 merges.

**Branch:** `feature/lsa-remove-sync-state-file` per `lsa/ARCHITECTURE.md:117-126`.

**Files touched (per inventory removal-cost cell, row #1):**
1. `lsa/skills/lsa-reconcile/SKILL.md:20` — input list: replace the `.lsa-sync-state.json` line with *"the last commit on `main` that modified the module's spec file, found via `git log -1 --format=%H -- <spec-path>`."*
2. `lsa/skills/lsa-reconcile/SKILL.md:40` — step 5 substep: delete the *"Update `.lsa-sync-state.json`"* bullet; `git` is the substrate of record now.
3. `lsa/skills/lsa-sync/SKILL.md:13` — Goal: drop *"record per-module last-sync SHAs in `.lsa-sync-state.json`"*.
4. `lsa/skills/lsa-sync/SKILL.md:84-95` — delete Step 6 entirely (`Update .lsa-sync-state.json`).
5. `lsa/skills/lsa-sync/SKILL.md:118-122` — sync-report section: delete the `.lsa-sync-state.json` block.
6. `lsa/skills/lsa-sync/SKILL.md:131` — Step 8 picker: drop the *"count of module SHAs bumped"* phrase.
7. `lsa/skills/lsa-sync/SKILL.md:135` — Output section: drop *"updated `.lsa-sync-state.json` at repo root"*.
8. `lsa/skills/lsa-sync/SKILL.md:141` — Constraints: delete the *"Preserve other modules' state when writing `.lsa-sync-state.json`"* bullet.
9. `lsa/hooks/session-start-drift-check.sh:28-75` — replace the JSON-parse block with a `git log -1 --format=%H -- <spec-path>` lookup per module.
10. `lsa/ARCHITECTURE.md:42` — directory diagram: remove the `.lsa-sync-state.json` entry.
11. `lsa/ARCHITECTURE.md:113` — SessionStart-hook paragraph: rewrite the SHA-source sentence.
12. `lsa/ARCHITECTURE.md:157` — OQ8 row: update the decision text to reflect the git-log baseline.
13. `lsa/README.md:20` — `lsa-sync` table row: drop the `.lsa-sync-state.json` mention.
14. `lsa/README.md:47` — SessionStart-hook paragraph: rewrite per item 11.
15. `lsa/CHANGELOG.md` — entry under `## [vNEXT] - 2026-05-DD`.
16. `lsa/.claude-plugin/plugin.json` — patch SemVer bump.
17. The existing `.lsa-sync-state.json` file at the repo root (if present in any active worktree) — delete; archive worktrees keep theirs frozen per AC7.

**SemVer bump:** patch (same precedent as T1). A minor bump is defensible if a downstream consumer was depending on the file's presence — flag this in the PR description for reviewer to decide.

**CHANGELOG entry shape:**

```markdown
## [vNEXT] - 2026-05-DD

### Removed

- `.lsa-sync-state.json` baseline-SHA file deleted. The per-module last-sync SHA + ISO timestamp the file held is recoverable from `git log -1 --format=%H -- <module-spec-path>`; switched `lsa-reconcile` Step 1, `lsa-sync` Step 6, and `lsa/hooks/session-start-drift-check.sh` to derive the SHA from git history instead. Per the custom-inventions sweep at `vision/specs/features/2026-05-22-custom-inventions-sweep/design.md` inventory row #1.
```

**Verification:**
- `grep -rn "\.lsa-sync-state" lsa/ vision/` returns zero results outside archive files.
- `lsa-reconcile` still detects drift end-to-end on a manual test (edit an artifact path → invoke `/lsa:reconcile` → expect the drift block to surface).
- SessionStart hook still exits 0 always (constraint at `lsa/ARCHITECTURE.md:113`).
- The PR diff matches §"Files touched" above (Journey 2 path 1).

**Observable result:** PR opened, reviewer approves, merged to `main`.

## T3 — Defer OQ1 (file-load trace) to next dogfood log

**Inventory row:** #2, #5 (`design.md` §"Open Questions" OQ1, OQ3). Recommendation: `needs-deeper-review`.

**Action:** Add a one-line row to `vision/specs/research-backlog.md` (or create the file if absent per `lsa/ARCHITECTURE.md:54`) noting the open question and the resolution path (next dogfood log per `vision/specs/roadmap.md:23`).

**Files touched:** `vision/specs/research-backlog.md` (one row added).

**No SemVer bump, no CHANGELOG entry** — research entry only.

**Observable result:** the research-backlog row exists; the question is tracked.

## T4 — Surface OQ2 (verb-headline vocabulary) in row #4's design.md

**Inventory row:** #4 (`design.md` §"Open Questions" OQ2). Recommendation: `needs-deeper-review`.

**Action:** File OQ2 in `vision/specs/features/2026-05-22-lsa-what-why-preamble/design.md` Open Questions section (line 174) so the verb-headline-vocabulary-keep-or-remove decision is made in the row-#4 spec context. The row-#4 feature spec already exists at `vision/specs/features/2026-05-22-lsa-what-why-preamble/`.

**Files touched:** `vision/specs/features/2026-05-22-lsa-what-why-preamble/design.md` (one entry added to §"Open Questions").

**No SemVer bump, no CHANGELOG entry** — coordination note only.

**Observable result:** when row #4's `design.md` exists, it contains a §"Open Questions" entry naming the verb-headline-vocabulary decision and citing this sweep's inventory row #4.

## T5 — Flag OQ4 (probe-as-substrate) for the next sweep

**Inventory row:** rubric scope (`design.md` §"Open Questions" OQ4). Not a `remove`; affects how the rubric counts in-repo probes.

**Action:** Note in `design.md` §"Open Questions" that `core/tests/repo-anchored.md`-style probes are treated as in-repo enforcement (not substrate) in this sweep. If probe count grows materially, the next sweep re-evaluates.

**Files touched:** none (already documented in `design.md` OQ4).

**Observable result:** the OQ4 entry exists; next sweep has a marker to revisit.

## T6 — Move roadmap row to "Recently merged" on land

**Action:** On merge, edit `vision/specs/roadmap.md` row *"Sweep custom inventions; remove the unjustified"* — move from Feature Backlog to Recently merged.

**Files touched:** `vision/specs/roadmap.md` (one row moved).

**No SemVer bump, no CHANGELOG entry** — roadmap status update only.

**Observable result:** the row appears under "Recently merged" with a date and one-sentence summary; no longer in the Feature Backlog table.

---

## Done definition

The feature is `done` when:

1. T1 and T2 are merged to `main`.
2. T3 has produced a `research-backlog.md` row.
3. T4 + T5 have produced their respective tracking entries.
4. `lsa-verify` PASSes on the feature branch (trace from `design.md` inventory + AC1–AC7 to changes in T1 and T2).
5. `lsa-sync` extracts the delta into `lsa/`'s module spec at `vision/specs/modules/lsa/spec.md` (the §"Decisions" or equivalent section gains a row noting the two removals + the three deferred OQs).
