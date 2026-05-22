# Clarification — 2026-05-21-maintenance-cleanup (v2 — lived-experience refresh)

> **v1 was theoretical** (drafted before the manual pass). **v2 (this) is grounded** in the procedure captured by `manual-pass-notes.md` after wave 1 + wave 2 manual cleanup (-52.1% shipped tokens across 3 commits: `35b1068`, `9c1a9f2`, `cb2bad1`). Silence on a line = approval. Override per line, or batch via the decision below.

## Functional (5)

- **F1 — What artifact set does `/maintenance:cleanup` analyze?**
  - Confirmed: All Markdown under `vision/`, `core/`, `lsa/` + repo root that is a behavior-bearing artifact. Concretely (the F1 scope used in the manual pass, validated):
    - skill bodies (`*/skills/**/SKILL.md`)
    - knowledge files (`*/knowledge/**/*.md`)
    - READMEs (root + per-plugin)
    - `CLAUDE.md` (root + per-plugin)
    - `VISION.md`, `main.spec.md`, per-module `spec.md`
    - `ARCHITECTURE.md`, `VERIFICATION.md`, `roadmap.md`, `standards/**`
    - per-plugin test files
  - **Excluded:** `vision/specs/archive/**` (frozen content; **link-target fixes inside are allowed** per the manual-pass edge case finding), `vision/specs/features/**` (in-flight), `CHANGELOG.md` files (versioned record; modifiable for citation-path fixes only, never for narrative content), `*.json` / `*.yaml` (catalog), `.lsa-sync-state.json`, anything in `.gitignore` (e.g., `vision/mnt/`, `vision/experience/`).

- **F2 — What signals drive the audit?**
  - Confirmed + extended. The original 3 signals stand, but a fourth is needed (relocation-candidate detection):
    1. **Token count** — approximated as `wc -w * 1.3`. The manual pass surfaced that `git ls-files` (not `find`) must be the file enumerator — `find` includes `.gitignored` paths and inflates the count by ~2.3% in this repo.
    2. **Redundancy** — text spans repeated near-verbatim across files.
    3. **Prose-density** — long sentences (>30 words), filler phrases, paragraphs that could be lists/tables.
    4. **Relocation candidates** — top-of-tree historical files (pre-formal-LSA-flow plans/designs) that are not in any plugin's `artifact_paths`, not loaded by any skill, and only cited from CHANGELOG narrative or pattern-docs. These ship to every install but don't fire in context. **Highest-leverage cleanup class** — wave 1+2 demonstrated 52.1% reduction by handling this class alone.

- **F3 — Definition of "no functional change" (the invariant set the diff must preserve).**
  - Refined from the manual pass. The 6 invariants in `manual-pass-notes.md` are the contract:
    1. Frontmatter `description:` byte-identical across all `SKILL.md`.
    2. Public `name` fields unchanged in `SKILL.md` + `plugin.json`.
    3. Every cited `file:line` link target still resolves to a real file (with content equivalence — see F3-edge).
    4. Cited rule IDs unchanged (Rule 0..6 in `core/ground-rules`, golden-rule names in `core/output`, EARS pattern names in `vision/VISION.md`).
    5. SemVer in `plugin.json` + first `## [X.Y.Z]` CHANGELOG entry — modifiable only via explicit version bump (CHANGELOG entry + plugin.json version edit in the same commit, per `CONTRIBUTING.md:81`).
    6. Frontmatter `model` / `tools` / `argument-hint` unchanged on any actor.
  - **F3-edge — Line-number citations become unsafe after archival header insertion.** The 2-line archival HTML comment shifts every internal line by +2. Citations of the form `file.md:243-246` either need updating to the new line range OR rewriting to the section-name form (`file.md §"<section>"`). **Policy choice (per `CONTRIBUTING.md:62`): always rewrite to section-name.**

- **F4 — Output shape.**
  - Confirmed: two artifacts per run.
    1. **A staged uncommitted diff** on the working branch — human reviews via `git diff`, applies via the existing `/commit-commands:commit` flow. The skill stages but never commits.
    2. **A report** at `vision/reports/cleanup-<YYYY-MM-DD>.md` with: per-artifact before/after token counts; aggregate delta; "skipped — would change invariant X" list with the offending hunk cited as `file:line`; "false-positive whitelist" (paths cited as aspirational, historical, or grep over-matched — captured during the manual pass).

- **F5 — Verifications run at the end.**
  - Refined from the manual pass. The 12-check verification protocol in `manual-pass-notes.md` § "Regression sweep" is the contract. The order matters:
    1. All 12 `SKILL.md` frontmatters intact (`name:` + `description:`).
    2. Every skill `description:` byte-identical vs `main` (or vs pre-cleanup HEAD).
    3. Public `name` fields unchanged in `SKILL.md` + `plugin.json`.
    4. Every `plugin.json` parses + name/version non-empty.
    5. `marketplace.json` parses + lists all plugins with resolvable source paths.
    6. `.lsa.yaml` parses.
    7. CHANGELOG heads are Keep-a-Changelog-conformant (`[Unreleased]` then `[X.Y.Z]`).
    8. Rule IDs unchanged in `core/skills/ground-rules`, `core/skills/output`, `core/CLAUDE.md`.
    9. Actor frontmatter (`model` / `tools` / `argument-hint`) unchanged.
    10. No accidental binary / oversized additions.
    11. Every cited repo-root-style path that appears in modified files resolves to a real file **OR** is documented as aspirational/historical/grep-false-positive (the F4 false-positive whitelist).
    12. Working tree clean post-stage.
  - **F5-edge — formal `lsa-verify` is intentionally OUT of the skill's automatic pipeline** (per the manual-pass finding). Cleanup runs as a chore that may NOT have a formal feature spec; `lsa-verify` against a non-existent spec FAILs uselessly. The skill instead runs the 12 checks above; the user can run `lsa-verify` separately if a feature spec exists.

## Non-functional (2)

- **NF1 — Smaller-context-model friendliness (budget-per-artifact-class).**
  - Confirmed budgets, validated against current state post-cleanup:

    | Class | Budget | Worst post-cleanup | Status |
    |-------|--------|--------------------|--------|
    | skill body (`SKILL.md`) | ≤ 2000 tokens | 2,031 (`lsa-specify`) | 1.5% over — flagged |
    | knowledge file | ≤ 3000 tokens | 495 (`lsa/knowledge/conventions.md`) | ✓ |
    | per-plugin README | ≤ 1500 tokens | 822 (`lsa/README.md`) | ✓ |
    | per-plugin `CLAUDE.md` | ≤ 1000 tokens | 302 (`core/CLAUDE.md`) | ✓ |
    | module `spec.md` | ≤ 1500 tokens | 605 (`lsa`) | ✓ |
    | `VISION.md` | ≤ 6000 tokens | 4,889 | ✓ |
    | `main.spec.md` | ≤ 1500 tokens | 730 | ✓ |
  - Rationale: keeps all routinely-loaded artifacts within a 32k context window even when several load together. The cleanup skill itself respects these budgets (dogfood per `vision/VISION.md:47`).

- **NF2 — Idempotence.**
  - Refined: second run on unchanged tree MUST produce empty diff. The manual pass uncovered an edge case: archival HTML comments must NOT be re-added on a re-run. The skill's relocation logic must detect "this file already has an archival comment matching the expected pattern" and skip.

## Boundaries (2)

- **B1 — In-scope edits (the eventual `/cleanup` skill's deliverable surface).**
  - Refined into 5 edit classes (each with its own invariant rule, surfaced by the manual pass):
    1. **Move (archive relocation)** — invariant: every external citation still resolves; archival HTML comment added; historical narrative inside moved file preserved as-written; active links inside moved files have their relative paths recalculated for the new depth.
    2. **Prose trim** — invariant: F3 set unchanged; rendered output equivalent.
    3. **Redundancy removal** — invariant: canonical citation preserved + non-canonical copies replaced with cross-link.
    4. **Format restructure** (prose → table) — invariant: every fact still expressible in the new form.
    5. **Whitespace / consistency** (lowest-impact) — invariant: rendered output unchanged.
  - **Module + plugin shape (unchanged from v1):** new `maintenance` module + plugin (opt-in, not always-on), single skill `cleanup` for v0.1.0.

- **B2 — Out of scope (this feature).**
  - Confirmed + extended:
    - **No actual cleanup pass on the existing repo content via the shipped skill in this feature** — already done manually in waves 1+2; the shipped skill is for *future* cleanup passes.
    - No automated tokenizer dependency — token count is heuristic-only (`wc -w * 1.3`).
    - No multi-pass refactoring in a single invocation (the skill produces one diff per run; iterating is the human's choice).
    - No automatic application + commit — human review is mandatory; the skill stages, never commits.
    - **No retrofit of `vision/specs/archive/**`** for content — **link-target fixes are allowed** (one-line edits to keep links resolvable post-relocation, per the wave 1 + 2 precedent).
    - No edits to per-plugin `CHANGELOG.md` historical narrative beyond appending a new entry for the maintenance plugin's `0.1.0` release.
    - **No automatic formal `lsa-verify` invocation** — orthogonal verification (F5-edge above).

## Acceptance (6 EARS-form journey-shaped + 2 structural — confirmed from v1, plus 2 new from lived experience)

**Journey-shaped ACs (observable at the human ↔ `/maintenance:cleanup` boundary):**

- **AC1** *(Ubiquitous).* The `/maintenance:cleanup` skill shall produce two artifacts on every run: a staged uncommitted diff on the working branch, and a report at `vision/reports/cleanup-<YYYY-MM-DD>.md`.

- **AC2** *(Event).* When `/maintenance:cleanup` is invoked on a clean working tree, the system shall produce a staged diff that, if applied, leaves the F3 invariant set byte-identical and reduces aggregate token count across the F1 artifact set.

- **AC3** *(Unwanted).* If a candidate patch would change any item in the F3 invariant set, the system shall exclude that patch from the staged diff and shall log it under "skipped — would change invariant X" in the report, with the offending hunk cited as `file:line`.

- **AC4** *(State).* While the staged diff is pending human review (between the skill's stage and apply steps), the system shall not modify any artifact under `vision/`, `core/`, or `lsa/` (or `maintenance/`), and shall not call `git commit`.

- **AC5** *(Event).* When the F5 verifications complete, if any check FAILs, the system shall reset the working tree to the pre-run state (`git restore` on staged files; no commit) and shall report the failing check with its `file:line` citation.

- **AC6** *(Event).* When `/maintenance:cleanup` is invoked twice in succession with no intervening human edits and the first run's diff has been applied, the second invocation shall produce a diff with zero hunks (idempotence per NF2 + edge case).

- **AC7 (new from lived experience)** *(Event).* When `/maintenance:cleanup` proposes a relocation (Edit Class 1), the system shall: (a) add an archival HTML comment at the moved file's head documenting the move date, source path, target path, feature name, and any active-link rewrites performed; (b) preserve the moved file's internal historical narrative as-written; (c) recalculate all relative links inside the moved file based on the new file depth; (d) upgrade any external line-number citations (`file.md:N-M`) to section-name form (`file.md §"<section>"`).

- **AC8 (new from lived experience)** *(Event).* When `/maintenance:cleanup` reports "skipped" patches, the system shall categorize the skip reason into one of: `(a) would change frontmatter description`, `(b) would change public name`, `(c) would break cited file:line link`, `(d) would change rule ID`, `(e) would change SemVer/CHANGELOG head`, `(f) would change actor frontmatter`, `(g) historical narrative inside moved file (preserve-as-written policy)`, `(h) aspirational forward-planning reference`. Categories (g) and (h) come from the F4 false-positive whitelist.

**Structural requirements (in-scope but not journey-shaped):**

- **SR1.** `vision/specs/modules/maintenance/spec.md` exists and lists the new module's invariants (markdown-only, dogfood NF1 budgets, single-skill scope for v0.1.0, depends on `core`).
- **SR2.** `.lsa.yaml` `modules.maintenance` registered with `artifact_paths` matching the maintenance plugin's own files.

---

## Decision

Format per `core/output`. Choose one:
- `[a]` approve all assumed answers → proceed to User Verification 1 (Requirements + Contract Trigger)
- `[b]` approve with overrides → list overrides per line; I re-draft and re-present
- `[c]` reject → stop; re-run `lsa-discover`
