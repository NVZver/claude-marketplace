---
name: cleanup
description: Audit + trim the repo's behavior-bearing Markdown to reduce ship-cost. Produces a staged uncommitted diff + a report at `vision/reports/cleanup-<date>.md`. Preserves 6 invariants on every patch (frontmatter `description`, public names, cited `file:line` links, rule IDs, SemVer + CHANGELOG head, actor frontmatter). Stages but never commits. Refuses to run on `main` or with uncommitted changes. Triggers when the user says "cleanup the repo", "trim the repo", "shrink ship-cost", "audit content discipline", "/maintenance:cleanup", or describes wanting to reduce repo size without changing behavior.
---

# Cleanup

## Goal

Produce a staged uncommitted diff + a report at `vision/reports/cleanup-<YYYY-MM-DD>.md` that reduces shipped-token count across the repo's behavior-bearing Markdown **without changing any of 6 defined invariants**, and run a 12-check verification protocol that resets the working tree on any failure. Stages but never commits — the human owns the commit via `/commit-commands:commit` after reviewing `git diff --staged`.

## Input

- Working directory: repo root.
- Git state: a clean tree on a non-`main` branch (preconditions enforced in Step 1; abort otherwise).
- `.lsa.yaml`: read for per-module `artifact_paths` (informs invariant checks).
- `vision/specs/features/2026-05-21-maintenance-cleanup/manual-pass-notes.md` (Knowledge): the 12-step procedure + 5 edit classes + false-positive whitelist that this skill encodes.

## Steps

1. **Preconditions.** Verify `git branch --show-current` ≠ `main` AND `git status --porcelain` is empty. If either fails, **abort**: print the failing precondition + the concrete next action ("switch to a feature branch via `git checkout -b feature/<name>`" or "commit/stash N uncommitted files first"). Observable result: continue, or exit with no side effects.

2. **Inventory.** Enumerate the artifact set via `git ls-files | grep -E '\.md$' | grep -v 'CHANGELOG\.md$' | grep -vE '^vision/specs/(archive|features)/'`. For each file: compute `wc -w * 1.3` (heuristic token count; no tokenizer dependency). Run 4 signal detectors: **(a) over-budget** per the per-class budgets in `maintenance/README.md`; **(b) redundancy** — text spans repeated near-verbatim across files; **(c) prose-density** — sentences > 30 words, filler phrases (`in order to`, `it should be noted`, `essentially`, `basically`), prose convertible to lists/tables; **(d) relocation-candidate** — top-of-tree historical files not in any plugin's `artifact_paths` and only cited from CHANGELOG narrative. Observable result: candidate-patch list ranked by impact.

3. **Classify.** Tag each candidate with exactly one of 5 edit classes — `relocate` (archive a historical file with citation rewrites), `prose-trim` (shorten without removing facts), `redundancy-remove` (de-dupe to canonical citation), `restructure` (prose → list/table), `whitespace` (consistency). Each class has its own invariant rule on top of the 6 universal invariants. Observable result: classified list ready to stage.

4. **Stage.** For each classified patch, in order: apply to working tree → check the 6 universal invariants (frontmatter `description:` byte-identical, public `name` fields unchanged, cited `file:line` link targets still resolve, rule IDs unchanged, SemVer + first `## [X.Y.Z]` CHANGELOG entry unchanged, actor `model`/`tools`/`argument-hint` frontmatter unchanged) → check class-specific invariants. On any violation: `git restore <file>`; record the skip in the report with category from the 10-item enum (categories `(a)` through `(j)`). For `relocate` class: use `git mv` (not file-system `mv` — rename detection matters) → add archival HTML comment at file head documenting move date, source path, target path, feature name, active-link rewrites performed → preserve internal historical narrative as-written → recalculate relative links inside the moved file based on new depth → upgrade external line-number citations (`file.md:N-M`) to section-name form (`file.md §"<section>"`). Archive link-target fixes inside `vision/specs/archive/**` are allowed (content changes still forbidden). Patches that survive end up `git add`-ed.

5. **Verify.** Run the 12-check protocol against the staged state: (1) every `SKILL.md` frontmatter intact; (2) skill `description:` byte-identical vs pre-cleanup HEAD; (3) `name` fields unchanged in `SKILL.md` + `plugin.json`; (4) every `plugin.json` parses + name/version non-empty; (5) `marketplace.json` parses + lists all plugins with resolvable source paths; (6) `.lsa.yaml` parses; (7) CHANGELOG heads Keep-a-Changelog-conformant (`[Unreleased]` then `[X.Y.Z]`); (8) rule IDs unchanged in `core/skills/ground-rules`, `core/skills/output`, `core/CLAUDE.md`; (9) actor frontmatter (`model` / `tools` / `argument-hint`) unchanged; (10) no binary or oversized additions; (11) every cited repo-root-style path in modified files resolves OR is on the false-positive whitelist; (12) working tree clean post-stage. On any FAIL: `git restore` on every staged file; record the failing check with `file:line` citation; abort to Step 6. Observable result: 12 ✓ or 1+ ✗ → reset.

6. **Report.** Compute target path `vision/reports/cleanup-<YYYY-MM-DD>.md`. If file already exists, **abort** (don't overwrite) — print "report file for today already exists; rename or delete before re-running" and leave the staged diff in place for human review. Otherwise: `mkdir -p vision/reports` if absent; write the report containing per-artifact before/after token counts, aggregate delta, "skipped" list with categories + `file:line` citations, false-positive whitelist, and Step 5 verification status. Print exit message: *"`<N>` patches staged; `<M>` skipped (see report); verification PASS. Review `git diff --staged` and commit via `/commit-commands:commit`."* Observable result: report file exists; staged diff ready for review; skill exits.

## Output

- **A staged uncommitted diff** on the current branch (`git diff --staged` shows the proposed changes).
- **A report** at `vision/reports/cleanup-<YYYY-MM-DD>.md` (per-artifact token counts, aggregate delta, skipped list, false-positive whitelist, verification status).
- **An exit message** to the user naming the next concrete action.

## Constraints

- **Never commit. Never push.** The skill stages only; the human commits.
- **Never run on `main` or with uncommitted changes** (Step 1 preconditions).
- **Never overwrite a same-day report** (Step 6 abort).
- **Preserve the 6 invariants on every staged patch** (Step 4 universal checks).
- **Idempotent** — second run on unchanged tree produces a diff with zero hunks; `relocate` class detects existing archival comments and skips.
- **Prompt voice** per [`core/output`](../../../core/skills/output/SKILL.md) Rule 5 — when the skill asks anything (e.g., "review report?"), the picker question names the concrete subject ("Review cleanup report for `<date>`?"), never the IDs or jargon. Never render `[a]/[b]/[c]` text blocks when `AskUserQuestion` is available (per `core/CLAUDE.md` operational checkpoint #1).
- **Skill body itself respects the NF1 SKILL.md budget** (≤ 2,000 tokens) — dogfood of the discipline this skill enforces.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) golden rules (structured, minimal, formatted, sourced, concrete).

---

`/maintenance:cleanup` — manual invocation.
