# Manual Cleanup Pass — Running Notes

Live capture during the manual cleanup pass. Per `feedback_manual_before_automate.md` (auto-memory): the procedure encoded into the eventual `/maintenance:cleanup` skill MUST be derived from these notes, not invented.

## Starting state

- Branch: `feature/2026-05-21-maintenance-cleanup`
- Inventory total: **65,659 tokens** across git-tracked Markdown (excl. `CHANGELOG.md`, `archive/`, `features/`).
- Per-class budgets (NF1 in `clarification.md`): SKILL.md ≤ 2k, knowledge ≤ 3k, README ≤ 1.5k, CLAUDE.md ≤ 1k, module spec ≤ 1.5k, VISION.md ≤ 6k, main.spec.md ≤ 1.5k.
- Sweep strategy chosen 2026-05-21: top-down by inventory, applying the right invariant set per file class.

## Invariants (must hold after every change)

1. Frontmatter `description:` byte-identical for every skill.
2. Public skill / command / plugin names unchanged.
3. Cited `file:line` link targets still resolve to the same content.
4. Cited rule IDs (Rule 0..6, golden-rule names, EARS pattern names, four-pillar names) unchanged.
5. SemVer in `plugin.json` + head `CHANGELOG.md` entry unchanged (no bump from cleanup; the cleanup itself is a non-functional change tracked under the maintenance feature).
6. Frontmatter `model` / `tools` / `argument-hint` unchanged on any actor.

## File-by-file log

(Each file gets: class, action taken, citations touched, lessons learned.)

---

### Wave 1 — `lsa-v0.2.0` pair → archive (2026-05-22)

**Files moved:**
- `vision/specs/2026-05-20-lsa-v0.2.0-design.md` (8,303 tokens) → `vision/specs/archive/2026-05-20-lsa-v0.2.0/design.md`
- `vision/plans/2026-05-20-lsa-v0.2.0-plan.md` (12,040 tokens) → `vision/specs/archive/2026-05-20-lsa-v0.2.0/plan.md`

**Citations touched:** 13 lines across 5 files:
- `core/CHANGELOG.md` (1)
- `lsa/CHANGELOG.md` (1)
- `vision/specs/roadmap.md` (9)
- `vision/specs/standards/testing.md` (3)
- `lsa/ARCHITECTURE.md` (1) — partial; credo-plan ref deferred to wave 2
- Plus 1 internal active link (plan → design) updated to `./design.md`

**Inventory delta:** -20,343 tokens (-31%) from shipped-non-archive total. Baseline 65,659 → 45,315.

**Procedure that emerged (proto-spec for `/cleanup`):**

1. **Pre-move grep** — enumerate every external citation to each moving file BEFORE the `git mv`. Group by citing file. Distinguish: link (`[label](url)`), bare-backtick path, prose-only path.
2. **Internal cross-cite scan** — grep for sibling-file references INSIDE the moving files. Distinguish: **active links** (need rewrite to new relative path) from **historical narrative** (paths-as-described-events; preserve as written).
3. **Archive dir creation + `git mv`** — `git mv` (not `mv` + `git add`) so rename detection works in `git log --follow`.
4. **Archival note** — single HTML comment at file head: `<!-- ARCHIVED <date>: moved from <old-path> → <new-path> as part of <feature>. Internal historical path references preserved as written at time of authorship. -->`. Invisible to rendered Markdown, fully informative in raw.
5. **Active-link rewrite** — only the live cross-references (e.g., `**Source spec:**` line). Use relative paths (`./design.md`) for siblings, not absolute repo paths.
6. **External citation rewrite** — `Edit replace_all` per file with the unique substring (old absolute path) → new absolute path. The substring is unique enough to be safe; preserves link syntax around it.
7. **Verify** — grep for the old path post-rewrite; remaining hits should all be inside the moved file's historical narrative + the archival comment itself (both expected).

**Edge cases hit:**

- **Citation from archive/** — `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/discovery.md` cites `vision/plans/2026-05-20-credo-rollout-plan.md` (will surface in wave 2). Touches the "don't retrofit archive" boundary but justifiable as a one-line link-target fix (not a content change). The cleanup procedure must distinguish: link-target fix in archive = OK; content change in archive = NOT OK.
- **Historical self-references** — moved files contain ~5 historical references to their own old paths (e.g., the plan's task-7 instruction "Update status line at top from ... to ...see vision/specs/2026-05-20-lsa-v0.2.0-design.md"). Updating these would rewrite history. Preserved as-written; archival HTML comment documents the policy.
- **CHANGELOG citations are immutable narrative** — the CHANGELOG entries cite "per `vision/plans/X-plan.md`" as audit trail. Rewriting the path is acceptable because the citation's MEANING (which plan governed this work) is preserved by following the move. The historical pin survives.
- **git mv works across directory creation** — `mkdir -p` then `git mv` chains cleanly; git status shows `R` (rename) for both.

**Lessons for the `/cleanup` skill design:**

- The procedure has FIVE distinct edit classes, each with a different invariant rule:
  1. **Move (archive relocation)** — invariant: every external citation still resolves; archival HTML comment added; historical narrative preserved.
  2. **Prose trim** — invariant: frontmatter/description/names/rule-IDs/file:line links unchanged.
  3. **Redundancy removal** — invariant: canonical citation preserved + non-canonical copies replaced with cross-link.
  4. **Format restructure** (prose → table) — invariant: every fact still expressible.
  5. **Whitespace / consistency** (lowest-impact) — invariant: rendered output unchanged.
  The skill should classify each candidate patch into one of these before applying.

- **Pre-move citation discovery is mandatory** and not cheap (a `grep -rln` plus `grep -n` per moved filename). The skill should batch this.

- **Internal historical narrative is sacred** — any procedure that auto-rewrites paths inside moved files risks history-rewriting. The skill should explicitly skip internal references and document the skip via an archival HTML comment.

- **`Edit replace_all` on absolute path strings is safe** when the path itself is unique (date-stamped slugs). For generic refactors (e.g., renaming a skill), this would NOT be safe.

---

### Wave 2 — credo-rollout + simplification plans → archive (2026-05-22)

**Files moved:**
- `vision/plans/2026-05-20-credo-rollout-plan.md` (11,429 tokens) → `vision/specs/archive/2026-05-20-credo-rollout/plan.md`
- `vision/plans/2026-05-20-simplification-refactor-plan.md` (2,473 tokens) → `vision/specs/archive/2026-05-20-simplification-refactor/plan.md`

**Citations touched:** ~17 lines across 6 files:
- `core/CHANGELOG.md` (5 — 3 credo + 2 simplification)
- `lsa/CHANGELOG.md` (4 — 1 credo + 3 simplification)
- `lsa/ARCHITECTURE.md` (2 — credo only)
- `vision/specs/roadmap.md` (2 — 1 credo line-number→section, 1 vision/plans/ deprecation reference)
- `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/discovery.md` (1 — credo line-number→section)
- `CONTRIBUTING.md` (4 — deprecation rewrites: line 38, 91, 103, 107-115)

**Empty `vision/plans/` directory removed.**

**Inventory delta:** -34,208 cumulative tokens (-52.1% from 65,659 baseline). Wave 2 added ~-13.9k on top of wave 1's -20.3k.

**New procedure findings (refinements to the `/cleanup` skill design):**

- **Line-number citations break on archival header insertion.** Adding a 2-line archival HTML comment + blank line shifts every internal line +2. Two citations that used `:243-246` line-range format were affected. **Fix policy** (CONTRIBUTING.md:62 already requires): cite by section name (`§"S6 — lsa-specify Gate 2"`), not by line number. The cleanup procedure must rewrite line-number citations to section-name citations as part of archival relocation — not just update the path prefix. **Bonus discovery:** the original `:243-246` was already wrong (real content was at lines 295-323 in the original file); the cleanup pass caught a pre-existing bug via the forced re-examination.

- **Empty source directory cleanup.** After both wave-1 + wave-2 moves, `vision/plans/` was empty (1 file moved per wave + 1 in wave 1 in wave 2). `git mv` does NOT remove the source directory. Manual `rmdir vision/plans/` needed. The `/cleanup` skill should detect emptied source directories after a relocation pass and offer to remove them.

- **Policy-document edits cascade.** Removing `vision/plans/` as an active directory triggered cascading edits to CONTRIBUTING.md (5 spots): the `Multi-step refactors` section, the plan-files-as-spec fallback, the version-bump exclusion list, etc. Removing a structural convention is NOT a single-file edit — it's a policy change requiring documentation updates. The `/cleanup` skill should flag this kind of cascade explicitly: "deprecating `<path>` requires the following documentation rewrites: …".

- **Archival comment as line-shift documentation.** The archival comments now explicitly state how many lines were inserted (e.g., wave 1 lsa-v0.2.0 plan: *"only the active 'Source spec' link (line 13) was rewritten"* — tells readers that the 2-line shift moved line 11 → 13). Useful breadcrumb for future readers who may grep for an original line number and not find it.

- **Active links inside moved files need relative-path recalculation.** `vision/plans/.../plan.md`'s `[Constitution](../VISION.md)` resolved to `vision/VISION.md` from the old location. After move to `vision/specs/archive/2026-05-20-simplification-refactor/plan.md`, the same `../VISION.md` would resolve to `vision/specs/archive/2026-05-20-simplification-refactor/VISION.md` (which doesn't exist). Had to rewrite to `../../../VISION.md`. The cleanup procedure must scan moved files for relative links and recalculate them based on the depth change.

- **Archive-to-archive citation is a special case.** `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/discovery.md` cited a wave-2 plan. Updating its single line was within the established policy (link-target fix in archive = OK). Did not modify any other archive content.

**Cumulative procedure (proto-spec, updated):**

1. **Pre-move inventory** — grep every external citation; classify (link / bare-backtick / prose-only; with line-number vs section-name suffix).
2. **Internal cross-cite scan** — grep moved files for sibling/parent references; classify (active link / historical narrative).
3. **Relative-link depth-shift recalculation** — for each active link inside moved files, recompute the relative path based on the new file location's depth.
4. **Archive dir creation + `git mv`** — preserve rename detection.
5. **Archival HTML comment at head** — explicit about what was rewritten (active-link line numbers, etc.).
6. **Active-link rewrite inside moved files** — only live cross-references.
7. **External path-citation rewrite** — `Edit replace_all` per file with unique substring.
8. **Line-number → section-name citation upgrade** — for any external citation using `:N-M` line-range, convert to `§"<section>"` form (CONTRIBUTING.md:62 policy).
9. **Cascading-policy edits** — if the relocation drops a structural convention (e.g., `vision/plans/` as a directory), update all documentation that referenced the convention.
10. **Empty source directory cleanup** — `rmdir` any source dirs left empty by `git mv`.
11. **Invariant + structural verify** — 6 invariants + plugin.json parses + CHANGELOG head matches version.
12. **Post-verify grep sweep** — confirm all old paths only appear inside (a) the moved files' historical narrative, (b) the archival comment itself, (c) the manual-pass-notes scratch. Anything else is a missed citation.

---
