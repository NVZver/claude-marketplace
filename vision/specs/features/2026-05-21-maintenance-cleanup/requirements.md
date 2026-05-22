# Feature: `/maintenance:cleanup` — repo-content refactor skill

## Summary

A new `maintenance` plugin (opt-in, not always-installed) shipping a single skill `cleanup` for v0.1.0. The skill automates the procedure validated by the manual cleanup pass on 2026-05-22 (3 commits — `35b1068`, `9c1a9f2`, `cb2bad1` — that reduced shipped-non-archive tokens by 52.1%). Operating as a non-functional refactor tool: it produces a *staged* diff + a report, refuses to apply patches that change any of 6 defined invariants, and aborts on any of 12 verification check failures. Human reviews the diff and commits separately. Sized for smaller-context-model contributors (Ollama / Mistral) — every artifact the skill operates on, and the skill itself, stays within per-class token budgets.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | Analyze the defined artifact set: behavior-bearing Markdown under `vision/`, `core/`, `lsa/` + repo root. Concretely: skill bodies (`*/skills/**/SKILL.md`), knowledge files (`*/knowledge/**/*.md`), READMEs (root + per-plugin), `CLAUDE.md` (root + per-plugin), `VISION.md`, `main.spec.md`, per-module `spec.md`, `ARCHITECTURE.md`, `VERIFICATION.md`, `roadmap.md`, `standards/**`, per-plugin test files. Excluded: `vision/specs/archive/**`, `vision/specs/features/**`, `CHANGELOG.md` (narrative), `*.json` / `*.yaml`, `.lsa-sync-state.json`, anything in `.gitignore`. File enumeration uses `git ls-files`, not `find`. | Must |
| F2 | Drive the audit by 4 signals: (a) token count `wc -w * 1.3` heuristic; (b) redundancy — near-verbatim text repeated across files; (c) prose-density — long sentences (>30 words), filler phrases ("in order to", "it should be noted", "basically", "essentially"), paragraphs convertible to lists/tables; (d) relocation-candidate detection — top-of-tree historical files not in any plugin's `artifact_paths`, not loaded by any skill, only cited from CHANGELOG narrative or pattern docs. **Signal (d) is the highest-leverage class** (proven by wave 1+2 → -52.1%). | Must |
| F3 | Preserve 6 invariants byte-identical across every staged patch: (1) frontmatter `description:` in all `SKILL.md`; (2) public `name` fields in `SKILL.md` + `plugin.json`; (3) every cited `file:line` link target resolves to a real file with content equivalence; (4) cited rule IDs (Rule 0..6, golden-rule names, EARS pattern names); (5) SemVer in `plugin.json` + first `## [X.Y.Z]` CHANGELOG entry; (6) frontmatter `model` / `tools` / `argument-hint` on any actor. Patches violating any invariant are excluded from the staged diff. | Must |
| F4 | Output shape per run: (a) a staged uncommitted diff on the current branch — never auto-commits; (b) a report at `vision/reports/cleanup-<YYYY-MM-DD>.md` with per-artifact before/after token counts, aggregate delta, "skipped — would change invariant X" list with offending hunks cited as `file:line`, false-positive whitelist. | Must |
| F5 | Run the 12-check verification protocol after staging (before reporting success): (1) all `SKILL.md` frontmatters intact; (2) skill `description:` byte-identical vs pre-cleanup HEAD; (3) `name` fields unchanged; (4) `plugin.json` parses + name/version non-empty; (5) `marketplace.json` parses + lists all plugins; (6) `.lsa.yaml` parses; (7) CHANGELOG heads Keep-a-Changelog-conformant; (8) rule IDs unchanged in ground-rules / output / `core/CLAUDE.md`; (9) actor frontmatter unchanged; (10) no binary / oversized additions; (11) every cited repo-root-style path in modified files resolves OR is on the false-positive whitelist; (12) working tree clean post-stage. **Any FAIL → `git restore` on staged files; abort.** | Must |
| F6 | Implement 5 distinct edit classes, each with its own invariant rule: (1) **Move (archive relocation)** — preserve all external citations; (2) **Prose trim** — preserve F3 set + rendered output equivalence; (3) **Redundancy removal** — preserve canonical citation; (4) **Format restructure** (prose → table) — preserve fact-expressibility; (5) **Whitespace / consistency** — preserve rendered output. Each proposed patch classified into exactly one class. | Must |
| F7 | Relocation class (F6.1) specifics: (a) add an archival HTML comment at the moved file's head documenting move date, source path, target path, feature name, and any active-link rewrites performed; (b) preserve the moved file's internal historical narrative as-written (no in-body path edits except active links); (c) recalculate all relative links inside the moved file based on the new file depth; (d) upgrade any external line-number citations (`file.md:N-M`) to section-name form (`file.md §"<section>"`) per `CONTRIBUTING.md:62`. | Must |
| F8 | Link-target fixes inside `vision/specs/archive/**` ARE allowed (one-line edits to keep links resolvable post-relocation). Content changes inside `archive/**` remain forbidden. | Should |
| F9 | Refuse to run if the current branch is `main` OR the working tree has uncommitted changes (must run on a clean feature branch). | Must |
| F10 | False-positive whitelist: when verification check 11 (path resolution) flags a path, the report categorizes the false positive into one of: `(g) historical narrative inside moved file (preserve-as-written policy)`, `(h) aspirational forward-planning reference`, `(i) grep over-match (placeholder syntax like <name>.md)`, `(j) documented deletion record in CHANGELOG`. Skip categories used in AC8. | Should |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Per-class token budgets (post-cleanup ceiling; the skill flags violations but doesn't auto-fix): skill `SKILL.md` ≤ 2,000 tokens; knowledge file ≤ 3,000; per-plugin README ≤ 1,500; per-plugin `CLAUDE.md` ≤ 1,000; module `spec.md` ≤ 1,500; `VISION.md` ≤ 6,000 (constitution); `main.spec.md` ≤ 1,500. |
| NF2 | Idempotence: second run on an unchanged tree (after applying first run's diff) produces a diff with zero hunks. Archival-comment re-add detection prevents the relocation class from re-applying. |
| NF3 | Smaller-context-model friendliness: target audience includes Ollama / Mistral users. The skill operates on artifacts of bounded size (per NF1) and itself respects NF1 for skill bodies (dogfood per `vision/VISION.md:47`). |
| NF4 | Fact-grounding (per `vision/specs/main.spec.md` NFR1): every skip-decision in the report cites a `file:line` for the offending hunk; no opaque skip reasons. |
| NF5 | Spec-grounding (per `vision/specs/main.spec.md` NFR2): every change in the staged diff traces to a requirement in this spec; verification check 11 enforces. |
| NF6 | Manual-before-automate validation: the cleanup procedure encoded by this skill was validated end-to-end via 3 manual commits on `feature/2026-05-21-maintenance-cleanup` (`35b1068`, `9c1a9f2`, `cb2bad1`) **before** the SKILL.md was authored, achieving -52.1% shipped-non-archive tokens (65,659 → 31,450). The 12-step procedure surfaced by that pass is captured in `manual-pass-notes.md` and encoded verbatim in the skill body. Per the user's *manual-before-automate* discipline: when building a tool that automates a procedure, run the procedure manually e2e first; design from lived experience, not imagined steps. |

## Inputs & Outputs

- **Input.** Invocation in a clean git working tree on a non-main branch. No CLI arguments required (the skill reads its scope from `git ls-files` filtered per F1; reads NF1 budgets from the skill body itself).
- **Output.** (1) Staged uncommitted diff on the current branch (no commit). (2) Report file at `vision/reports/cleanup-<YYYY-MM-DD>.md` (created if absent; if a file with today's date exists, the skill aborts rather than overwriting).
- **Side effects.** File modifications in the working tree (staged but uncommitted); new files in `vision/specs/archive/` for relocation patches; new report in `vision/reports/`; new directory `vision/reports/` if absent.

## Constraints

- `vision/VISION.md` principle 7 (*"the human owns intent; the system absorbs reality"*): the skill stages but never commits; the human reviews + commits via `/commit-commands:commit`.
- `vision/VISION.md` principle 1a (*"ownership over automation"*): the skill never auto-applies a patch that touches an invariant; never silently decides scope; always produces a reviewable diff + report.
- `vision/VISION.md` §2 sub-principle 2a (*"acceptance criteria are journey-shaped"*): AC1–AC8 below describe behavior at the human ↔ skill boundary.
- `CONTRIBUTING.md:62` (*"cite by section, not by line number — line numbers drift, section names survive edits"*): the skill upgrades all line-number citations as part of relocation (F7.d).
- `CONTRIBUTING.md:81` (*"Bump version in the same commit as the changelog entry. No exceptions."*): the maintenance plugin's CHANGELOG entry for `0.1.0` ships in the same commit as `plugin.json` version `0.1.0`.

## Out of Scope

- No actual cleanup pass on existing repo content via the shipped skill in this feature — already done manually in waves 1+2; the shipped skill is for *future* cleanup passes.
- No automated tokenizer dependency (token count is heuristic-only).
- No multi-pass refactoring in a single invocation (one diff per run; iteration is the human's choice).
- No automatic application + commit (human review mandatory).
- No retrofit of `vision/specs/archive/**` content (link-target fixes excepted per F8).
- No formal `lsa-verify` invocation (orthogonal verification; F5 is the contract).
- No edits to per-plugin `CHANGELOG.md` historical narrative beyond appending the new entry for the maintenance plugin's `0.1.0` release.
- No new module beyond `maintenance`; no skills beyond `cleanup` in v0.1.0.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->

- [ ] **AC1** *(Ubiquitous).* The `/maintenance:cleanup` skill shall produce two artifacts on every run: a staged uncommitted diff on the working branch, and a report at `vision/reports/cleanup-<YYYY-MM-DD>.md`.

- [ ] **AC2** *(Event).* When `/maintenance:cleanup` is invoked on a clean working tree on a non-main branch, the system shall produce a staged diff that, if applied, leaves the F3 invariant set byte-identical and reduces aggregate token count across the F1 artifact set.

- [ ] **AC3** *(Unwanted).* If a candidate patch would change any item in the F3 invariant set, the system shall exclude that patch from the staged diff and shall log it under "skipped — would change invariant X" in the report, with the offending hunk cited as `file:line`.

- [ ] **AC4** *(State).* While the staged diff is pending human review (between the skill's stage and apply steps), the system shall not modify any artifact under `vision/`, `core/`, `lsa/`, or `maintenance/`, and shall not call `git commit`.

- [ ] **AC5** *(Event).* When the F5 12-check verification protocol completes, if any check FAILs, the system shall reset the working tree to the pre-run state (`git restore` on staged files; no commit) and shall report the failing check with its `file:line` citation.

- [ ] **AC6** *(Event).* When `/maintenance:cleanup` is invoked twice in succession with no intervening human edits and the first run's diff has been applied, the second invocation shall produce a diff with zero hunks.

- [ ] **AC7** *(Event).* When `/maintenance:cleanup` proposes a relocation (F6 Class 1), the system shall (a) add an archival HTML comment at the moved file's head per F7.a, (b) preserve the moved file's internal historical narrative as-written per F7.b, (c) recalculate all relative links inside the moved file based on the new file depth per F7.c, (d) upgrade any external line-number citations to section-name form per F7.d.

- [ ] **AC8** *(Event).* When `/maintenance:cleanup` reports "skipped" patches, the system shall categorize each skip into one of: `(a) would change frontmatter description`, `(b) would change public name`, `(c) would break cited file:line link`, `(d) would change rule ID`, `(e) would change SemVer/CHANGELOG head`, `(f) would change actor frontmatter`, `(g) historical narrative inside moved file (preserve-as-written policy)`, `(h) aspirational forward-planning reference`, `(i) grep over-match (placeholder syntax)`, `(j) documented deletion record in CHANGELOG`.

- [ ] **AC9** *(Unwanted).* If `/maintenance:cleanup` is invoked on branch `main` OR with uncommitted changes in the working tree, the system shall refuse to run and shall print the precondition that failed (per F9).

- [ ] **AC10** *(Unwanted).* If a file with name `vision/reports/cleanup-<YYYY-MM-DD>.md` already exists when the skill runs (same-day re-invocation), the system shall abort with a clear error rather than overwriting.
