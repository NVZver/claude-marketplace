# Design: /maintenance:cleanup

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `maintenance` (new) | new — new plugin + single skill `cleanup` at v0.1.0 |
| `core` | read-only — cites `core/actor-template` for SKILL.md shape; cites `core/output` Rule 5 for prompt voice; cites `core/CLAUDE.md` operational checkpoint #1 for `AskUserQuestion` discipline |
| `lsa` | read-only — orthogonal (the skill explicitly does NOT invoke `lsa-verify`; see F5-edge in requirements) |
| `vision/specs/main.spec.md` | modify — append `maintenance` row to Module Index |
| `.lsa.yaml` | modify — register `modules.maintenance` with `artifact_paths` covering the new plugin's files |
| `.claude-plugin/marketplace.json` | modify — append `maintenance` plugin entry |

## Technical Approach

The skill is pure Markdown (per `vision/VISION.md` §3 + `vision/specs/standards/code.md` *"Markdown-only"*). It runs in 6 sequential phases inside a single invocation:

1. **Preconditions (F9 / AC9).** Check current branch ≠ `main` AND `git status --porcelain` is empty. If either fails, print the failing precondition + the concrete next action; exit without inventory, diff, or report.

2. **Inventory (F1 + F2).** Enumerate the artifact set via `git ls-files` filtered by F1 includes/excludes (NOT `find` — `.gitignore` matters). For each file, compute heuristic token count `wc -w * 1.3`. Run 4 signal detectors: (a) over-budget per NF1; (b) near-verbatim redundancy across files; (c) prose-density flags; (d) relocation-candidate detection (top-of-tree historical files not in any plugin's `artifact_paths` and only cited from CHANGELOG narrative). Output: candidate-patch list, each tagged with one of 5 edit classes (F6).

3. **Classify (F6).** Each candidate patch lives in exactly one of 5 edit classes — `relocate`, `prose-trim`, `redundancy-remove`, `restructure`, `whitespace`. Each class has its own invariant rule (encoded in skill body) on top of the 6 universal invariants (F3).

4. **Stage (F3 + F7 + F8).** For each classified patch:
   - Apply the patch to the working tree.
   - Run invariant checks (F3) + edit-class-specific invariants. On violation: `git restore` that single file; record the skip in the report with category from AC8's 10-item enum.
   - For `relocate` class (F7): use `git mv` (not file-system `mv` — rename detection matters); add archival HTML comment at head; preserve internal historical narrative as-written; recalculate relative links inside the moved file by depth-diff; upgrade external line-number citations (`file.md:N-M`) to section-name form (`file.md §"<section>"`).
   - For archival citation fixes inside `archive/**`: allowed per F8 (link-target only; content changes still forbidden).
   - Patches that survive end up staged via `git add`.

5. **Verify (F5 / AC5).** Run the 12-check protocol against the staged state:
   1. All `SKILL.md` frontmatters intact (`name:` + `description:`).
   2. Skill `description:` byte-identical vs pre-cleanup HEAD.
   3. `name` fields unchanged in `SKILL.md` + `plugin.json`.
   4. Each `plugin.json` parses + name/version non-empty.
   5. `marketplace.json` parses + lists all plugins with resolvable source paths.
   6. `.lsa.yaml` parses.
   7. CHANGELOG heads Keep-a-Changelog-conformant (`[Unreleased]` then `[X.Y.Z]`).
   8. Rule IDs unchanged in ground-rules / output / `core/CLAUDE.md`.
   9. Actor frontmatter (`model` / `tools` / `argument-hint`) unchanged.
   10. No binary / oversized additions.
   11. Every cited repo-root-style path in modified files resolves OR is on the F10 false-positive whitelist.
   12. Working tree clean post-stage.
   On any FAIL: `git restore` on every staged file; record the failing check with `file:line` citation; stop.

6. **Report (F4 / AC10).** Write `vision/reports/cleanup-<YYYY-MM-DD>.md`. If the file already exists, abort (AC10) — the staged diff stays staged so the human can decide. The report contains: per-artifact before/after token counts; aggregate delta; "skipped" list with AC8 categories + `file:line` citations; F10 false-positive whitelist; F5 verification status.

**Idempotence (AC6 / NF2).** The `relocate` class detects an existing archival comment matching the expected pattern and skips. The other 4 classes are by construction idempotent — they preserve rendered output equivalence, so a second run on unchanged input finds no signal change.

## Data Model Changes

None. The skill is pure file-system + Markdown editing. State lives in git (working tree, staged index, branch HEAD). No new schemas, no new databases, no shared cross-module types.

## API / Interface Changes

None. (Contract trigger = NO at User Verification 1.) The skill is invoked as a slash command `/maintenance:cleanup` with no arguments; its outputs are file-system artifacts (staged diff + report).

## Cross-Module Contracts

- **`maintenance` depends on `core`** — cites `core/actor-template` for the SKILL.md shape (Goal / Input / Steps / Output / Constraints), `core/output` Rule 5 for prompt voice in the skill's user-facing pickers, `core/CLAUDE.md` operational checkpoint #1 (never render `[a]/[b]/[c]` text blocks when the picker is available). Per `vision/specs/main.spec.md` "Cross-Module Contracts" pattern — prose-only until Claude Code's plugin manifest exposes a `dependencies` field.
- **`maintenance` does NOT depend on `lsa`** — by design, orthogonal to spec-lifecycle. Cleanup is content discipline (slimness, citation integrity), not spec-grounding. The skill explicitly does NOT invoke `lsa-verify` (F5-edge in requirements). A human can run both serially, but they don't compose.

## Open Questions

- **OQ1: Should the cleanup skill validate `core/actor-template` shape on edits to any `SKILL.md`?** A prose-trim patch on a `SKILL.md` could accidentally violate the Goal/Input/Steps/Output/Constraints structure even while preserving the frontmatter `description:`. The 6 universal invariants don't catch this. Decision deferred to implementation: the manual pass (waves 1+2) only used the `relocate` class, so we have no empirical evidence of prose-trim failures. Revisit when first `prose-trim` patch is proposed against any `SKILL.md`.
- **OQ2: What if `vision/reports/` doesn't exist yet?** First-ever invocation needs to create the directory. Skill should `mkdir -p vision/reports` as part of phase 6 before writing the report file. Trivial; flagged here for the implementor.
