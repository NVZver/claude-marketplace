# Clarification — 2026-05-21-maintenance-cleanup

Assumed answers. Silence on a line = approval. Override per line, or batch via the decision below.

## Functional (5)

- **F1 — What artifact set does `/maintenance:cleanup` analyze?**
  - Assumed: All Markdown under `vision/`, `core/`, `lsa/` that is a behavior-bearing artifact: skill bodies (`*/skills/**/SKILL.md`), knowledge files (`*/knowledge/**/*.md`), READMEs (root + per-plugin), `CLAUDE.md` (root + per-plugin), `VISION.md`, `main.spec.md`, per-module `spec.md`, `ARCHITECTURE.md`, `VERIFICATION.md`, `roadmap.md`, `standards/**`, and per-plugin test files. **Excluded:** `vision/specs/archive/**` (frozen history), `vision/specs/features/**` (in-flight), `CHANGELOG.md` files (versioned record), `*.json` / `*.yaml` (catalog), `.lsa-sync-state.json`.

- **F2 — What signals drive the audit?**
  - Assumed: Three signals per file. (a) Token count — approximated as `wc -w * 1.3` (LLM-friendly heuristic, no tokenizer dependency); flagged when above the per-class budget in NF1. (b) Redundancy — text spans repeated near-verbatim across files, surfaced as "say-once" candidates with the canonical citation. (c) Prose-density — long sentences (>30 words), filler phrases ("in order to", "it should be noted", "essentially", "basically"), paragraphs that could be lists/tables.

- **F3 — Definition of "no functional change" (the invariant set the diff must preserve).**
  - Assumed: A proposed patch is rejected from the diff if it would change **any** of: (a) any skill `description:` frontmatter (byte-identical); (b) any public skill/command/plugin name (filename + heading + frontmatter `name:`); (c) any cited `file:line` link target (link still resolves to the same lines); (d) any cited rule ID (Rule 0..6, golden-rule names, EARS pattern names, the four-pillar names); (e) any SemVer in `plugin.json` or `CHANGELOG.md` entry; (f) frontmatter `model` / `tools` / `argument-hint` fields on any actor.

- **F4 — Output shape.**
  - Assumed: Two artifacts. (1) A staged-but-uncommitted diff on a working branch (default: current branch) — human reviews via `git diff`, applies via the existing `/commit` flow. (2) A report at `vision/reports/cleanup-<YYYY-MM-DD>.md` with: per-artifact before/after token counts; aggregate delta; "skipped — would change invariant X" list; redundancy candidates left untouched with rationale. No new tool is invoked to commit.

- **F5 — Verifications run at the end.**
  - Assumed: After staging the diff (before commit), the skill runs in this order: (i) invariant-check against the F3 list — script-level diff inspection, hard FAIL on any violation; (ii) `lsa-verify` on the working branch — hard FAIL on any unmapped change; (iii) structural checks — every `plugin.json` parses, every `CHANGELOG.md` head version matches its `plugin.json` version. Any FAIL aborts the cleanup and leaves the working tree unchanged.

## Non-functional (2)

- **NF1 — Smaller-context-model friendliness (budget-per-artifact-class).**
  - Assumed: Target budgets (post-cleanup), used to flag candidates but not as hard caps:
    - skill body (`SKILL.md`) — ≤ 2000 tokens (≈ 1500 words)
    - knowledge file — ≤ 3000 tokens
    - per-plugin README — ≤ 1500 tokens
    - per-plugin `CLAUDE.md` — ≤ 1000 tokens
    - module `spec.md` — ≤ 1500 tokens
    - `VISION.md` — ≤ 6000 tokens (constitution; longest allowed)
    - `main.spec.md` — ≤ 1500 tokens
  - Rationale: keeps all routinely-loaded artifacts within a 32k context window even when several load together. The cleanup skill itself respects these budgets (dogfood per `vision/VISION.md:47`).

- **NF2 — Idempotence.**
  - Assumed: Running `/maintenance:cleanup` twice in a row, with no human edits between runs, MUST produce an empty diff on the second run. This is the operational definition of "converged" — and is checked at end-of-run.

## Boundaries (2)

- **B1 — In-scope edits.**
  - Assumed:
    - **New module `maintenance`** — `vision/specs/modules/maintenance/spec.md`, registered in `.lsa.yaml` `modules.maintenance`, indexed in `vision/specs/main.spec.md`.
    - **New plugin `maintenance`** — `maintenance/.claude-plugin/plugin.json`, `maintenance/README.md`, `maintenance/CHANGELOG.md`, `maintenance/CLAUDE.md` (if always-on rule needed; otherwise omit).
    - **New skill** `maintenance/skills/cleanup/SKILL.md` — the actor; follows `core/actor-template`.
    - **Marketplace registration** — append `maintenance` plugin to `.claude-plugin/marketplace.json`.
    - **Repo README + repo `CLAUDE.md`** — one-line mention of the new plugin under "Default plugins" only if `maintenance` is intended as always-installed; otherwise the plugin lives as opt-in and the repo README adds it under a separate "Maintenance" section. **Default assumption: opt-in, not always-installed.** Repo `CLAUDE.md` adds a single line under "Discipline" pointing at the new skill.
    - **Roadmap** — add an entry under `vision/specs/roadmap.md`.

- **B2 — Out of scope (this feature).**
  - Assumed:
    - No actual cleanup pass on the existing repo content in *this* feature — that is a follow-up T2 run of the shipped `/maintenance:cleanup` skill against the repo, with its own diff + verify cycle.
    - No automated tokenizer dependency — token count is heuristic-only.
    - No multi-pass refactoring (the skill produces one diff per run; iterating is the human's choice).
    - No automatic application + commit — human review is mandatory; the skill stages, never commits.
    - No retrofit of `vision/specs/archive/**` (frozen).
    - No edits to per-plugin `CHANGELOG.md` entries beyond appending the new entry for the maintenance plugin's `0.1.0` release.

## Acceptance (6 EARS-form journey-shaped + 2 structural)

**Journey-shaped ACs (observable at the human ↔ `/maintenance:cleanup` boundary):**

- **AC1** *(Ubiquitous).* The `/maintenance:cleanup` skill shall produce two artifacts on every run: a staged uncommitted diff on the working branch, and a report at `vision/reports/cleanup-<YYYY-MM-DD>.md`.

- **AC2** *(Event).* When `/maintenance:cleanup` is invoked on a clean working tree, the system shall produce a staged diff that, if applied, leaves the F3 invariant set byte-identical and reduces aggregate token count across the F1 artifact set.

- **AC3** *(Unwanted).* If a candidate patch would change any item in the F3 invariant set, the system shall exclude that patch from the staged diff and shall log it under "skipped — would change invariant X" in the report, with the offending hunk cited as `file:line`.

- **AC4** *(State).* While the staged diff is pending human review (between Steps 5 and 6 of the skill), the system shall not modify any artifact under `vision/`, `core/`, `lsa/`, or `maintenance/`, and shall not call `git commit`.

- **AC5** *(Event).* When the F5 verifications complete, if any check FAILs, the system shall reset the working tree to the pre-run state (`git restore` on staged files; no commit) and shall report the failing check with its `file:line` citation.

- **AC6** *(Event).* When `/maintenance:cleanup` is invoked twice in succession with no intervening human edits and the first run's diff has been applied, the second invocation shall produce a diff with zero hunks (idempotence per NF2).

**Structural requirements (in-scope but not journey-shaped):**

- **SR1.** `vision/specs/modules/maintenance/spec.md` exists and lists the new module's invariants (markdown-only, dogfood NF1 budgets, single-skill scope for v0.1.0).
- **SR2.** `.lsa.yaml` `modules.maintenance` is registered with `artifact_paths` matching the F1 scope of the *maintenance plugin itself* (so the maintenance skill is subject to the same drift detection as `core` and `lsa`).

---

## Decision

Format per `core/output`. Choose one:
- `[a]` approve all assumed answers → proceed to Gate 1
- `[b]` approve with overrides → list overrides per line; I re-draft and re-present
- `[c]` reject → stop; re-run `lsa-discover`
