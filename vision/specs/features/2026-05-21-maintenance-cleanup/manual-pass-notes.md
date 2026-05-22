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
