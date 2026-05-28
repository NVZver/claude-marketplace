# Design: Sweep custom inventions; remove the unjustified

> Source: `.lsa/roadmap.md:134-141` §"2026-05-22 backlog detail" #6.

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `lsa` | modify (per-row PRs; some inventions removed, some kept with one-line defense) |
| `core` | modify (per-row PRs; same) |
| `helper` | modify (per-row PRs; same) |
| `vision` | read-only (constitution + roadmap are inputs, not edited) |

## Technical Approach

The sweep runs in two phases:

1. **Phase 1 — Inventory + decision (this feature spec).** All ≥11 inventions are inventoried in §"Invention inventory" below; each row carries a `keep` / `remove` / `needs-deeper-review` recommendation produced by the rubric in §"Decision rubric". Phase 1 lands as this spec only — no production-file edit.
2. **Phase 2 — Per-row removal PRs (`tasks.md`).** Each `remove` row becomes one independent PR, sequenced from lowest to highest blast radius, modeled on the trace-tag-removal exemplar (commit `c226623`, `lsa/CHANGELOG.md:7-14`). Each PR is small enough that a reviewer can read it in under 5 minutes (NF5).

The rubric is opportunistic, not scheduled — the parent backlog row at `.lsa/roadmap.md:38` flags it *"opportunistic — not scheduled on a tight slot, but proof-of-concept already shipped."*

## Decision rubric

Apply to every surveyed invention. The rubric mirrors the deletion question from `.lsa/roadmap.md:137` — *"Do we really need it? What would change if we remove it? If nothing or minor — Remove"* — in operational form.

**Step 1 — Source-mandate test.** Does any adopted standard or Claude Code substrate primitive mandate this invention?

The five adopted 3rd-party standards (parent task framing + `.lsa/roadmap.md:138`):
- **EARS** — Mavin's Easy Approach to Requirements Syntax (`.lsa/VISION.md:204`).
- **SemVer** — Semantic Versioning 2.0.0.
- **Keep a Changelog** — keepachangelog.com.
- **CommonMark** — markdown spec.
- **Claude Code plugin schema** — `*.claude-plugin/plugin.json` shape and `dependencies` field per [code.claude.com/docs/en/plugin-dependencies](https://code.claude.com/docs/en/plugin-dependencies) (cited at `.lsa/roadmap.md:25`).

Claude Code substrate primitives (`.lsa/VISION.md:66` Principle 9 + `core/CLAUDE.md` checkpoint #1):
- `AskUserQuestion` for decisions.
- `Read` / `Edit` / `Write` for files.
- `TaskCreate` / `TaskUpdate` for task tracking.
- `Skill` for skill invocation.
- Hooks (`hooks.json`) for SessionStart / PreToolUse / PostToolUse.

If yes → recommendation is `keep` (the standard or substrate mandates it). Record the standard / primitive in the source-mandate cell.

**Step 2 — Capability-lost test.** What concrete capability is lost if the invention is removed?

Answer in one sentence, in the user's frame. *"Tags duplicate git's `when + why"* (the trace-tag answer per commit `c226623` body) is concrete; *"loses structure"* is not.

If the answer is *"nothing"* or *"minor"* (per `.lsa/roadmap.md:137`) → recommendation is `remove`.

**Step 3 — Substrate-coverage test.** If the capability is non-trivial, is it achievable via a substrate primitive or a standard?

If yes → recommendation is `remove` (the standard / primitive subsumes it). Record the subsuming surface in the source-mandate cell of the inventory.

If no, but the capability is irreplaceable → recommendation is `keep`. Record a one-line defense (F3).

If the rubric cannot resolve (dual-purpose invention, ambiguous removal cost, blast radius unclear) → recommendation is `needs-deeper-review`. File the specific open question in §"Open Questions" (F5).

## Invention inventory

Eleven inventions surveyed. Three are named in the parent task framing (`.lsa/roadmap.md:139-141`); eight are newly surfaced by the scan. Citations are `file:line`; `none` in the source-mandate cell means no adopted standard or substrate primitive mandates the invention.

| # | Invention | Primary site (`file:line`) | Source mandate | Removal cost | Recommendation | One-line `keep` defense / subsuming surface |
|---|-----------|---------------------------|----------------|--------------|----------------|---------------------------------------------|
| 1 | `.lsa-sync-state.json` (per-module last-sync SHA + ISO timestamp) | `lsa/ARCHITECTURE.md:42`; writer at `lsa/skills/lsa-sync/SKILL.md:84-95`; reader at `lsa/skills/lsa-reconcile/SKILL.md:20` | none — SHA recoverable from `git log` against the module's spec file (parent framing, `.lsa/roadmap.md:139`) | `lsa-reconcile` Step 1 baseline-SHA derivation switches from file lookup to `git log -1 --format=%H -- <spec>` (single-line change); `lsa-sync` Step 6 (`SKILL.md:84-95`) deleted; SessionStart hook `lsa/hooks/session-start-drift-check.sh:28-75` switched to `git log` lookup; `lsa/ARCHITECTURE.md:42`, `:113`, `:157` (OQ8 entry) edited; `lsa/README.md:20`, `:47` edited | **remove** | git is the substrate of record for "when did this file last change." **Substitution is exact for drift detection** (SessionStart hook compares the spec's last-commit SHA — `git log` returns the same SHA the JSON's `last_sync_sha` field held). **Substitution is approximate for `last_sync_iso`**: `git log` returns the commit timestamp of the spec file's last change, which equals "when the spec last changed" rather than "when `lsa-sync` last ran for this module." Those semantics diverge when a sync runs without modifying the module's spec (e.g., a no-op archive). Accept the shift — the ISO field is decorative (no consumer reads it for control flow today; only displayed in sync reports and SessionStart drift summaries). |
| 2 | File-load trace directive (per-file `=============== [<path>] [<plugin>] ===============` banner) | `core/skills/output/SKILL.md:30` (rule); banners at `core/CLAUDE.md` checkpoint #3, `core/skills/output/SKILL.md:6`, `lsa/knowledge/conventions.md:1`, `lsa/skills/lsa-*/SKILL.md:6` (×8), `helper/agents/helper.md:7`, `helper/commands/help.md:5`, `helper/knowledge/*.md:1` (×3) | none — source-attribution is a payoff-vs-noise tradeoff (parent framing, `.lsa/roadmap.md:140`) | Per-file banner deletion across ~19 files; `core/skills/output/SKILL.md:30` *"File-load trace"* sub-section deleted; `core/CLAUDE.md` operational checkpoint #3 deleted; `core/CHANGELOG.md` + `lsa/CHANGELOG.md` + `helper/CHANGELOG.md` entries documenting the rollback; `core/tests/repo-anchored.md` probe D2 may regress without it (see `lsa/CHANGELOG.md` cross-ref) | **needs-deeper-review** | Open question OQ1 below — payoff (provenance for which marketplace files shaped the turn) vs noise (one line per file per turn, visible to the user on every response). |
| 3 | "Hard Confirm" / "Soft Confirm" vocabulary | `lsa/knowledge/conventions.md:40-50` §"Confirm gate types" (section header `:40`, entries `:44-45`, used-by `:47-50`); references at `lsa/skills/lsa-specify/SKILL.md:21`, `lsa/skills/lsa-reconcile/SKILL.md:35`, `lsa/skills/lsa-revise-constitution/SKILL.md:61` | none — the two named distinctions could be replaced by plain-English *"approval required"* vs *"approve or correct inline"* (parent framing, `.lsa/roadmap.md:141`) | `lsa/knowledge/conventions.md:40-50` deleted; 4 skill bodies (`lsa-specify`, `lsa-plan`, `lsa-reconcile`, `lsa-revise-constitution`) re-phrase confirm steps in plain English; `lsa/CHANGELOG.md` entry | **remove** | Plain-English subject-voice (per `core/skills/output/SKILL.md:35-41` Rule 5) subsumes the named-distinction overhead — *"Stop until human approves"* is one phrase; *"Wait for approval or corrections"* is another; neither needs a vocabulary item. |
| 4 | Verb-headline vocabulary — canonical 10-verdict table at `core/knowledge/output-vocabulary.md:11-22` (`PROPOSED` / `READY` / `PASS` / `PASS WITH WARNINGS` / `FAIL` / `BLOCKED` / `DRIFT` / `CLEAN` / `APPLIED` / `REJECTED`); **6 verdicts emitted today across LSA skills** (verified by grep): 3 general (`PROPOSED`, `APPLIED`, `DRIFT`) + 3 in `lsa-verify` (`PASS`, `FAIL`, `PASS WITH WARNINGS`) | Canonical source: `core/knowledge/output-vocabulary.md:11-22`. Emission sites today: `lsa/skills/lsa-sync/SKILL.md:131` (`APPLIED`); `lsa/skills/lsa-reconcile/SKILL.md:35` (`DRIFT`); `lsa/skills/lsa-revise-constitution/SKILL.md:61` (`PROPOSED`); `lsa/skills/lsa-init/SKILL.md:51` (`PROPOSED`); `lsa/skills/lsa-verify/SKILL.md:83` (`PASS`); `lsa/skills/lsa-verify/SKILL.md:84` (`FAIL`); `lsa/skills/lsa-verify/SKILL.md:85` (`PASS WITH WARNINGS`) | none — opaque to non-LSA readers per `.lsa/roadmap.md:122-126` row #4 (LSA: what-and-why preamble on every verb-headline). Note: 4 canonical verdicts (`READY` / `BLOCKED` / `CLEAN` / `REJECTED`) are defined in the vocabulary but never emitted by any LSA skill today | Touches all 8 LSA skill bodies; couples with row #4 (`.lsa/roadmap.md:36`) which lands what-and-why preambles | **needs-deeper-review** | Open question OQ2 below — interacts with row #4. Row #4 may *augment* verb-headlines with a preamble (keeps the verb) or *replace* them with plain-English headlines (removes the verb). This sweep cannot decide without row #4's outcome. |
| 5 | "Trace." blockquote (the load-printable directive's framing as `> **Trace.** On load, print first:`) | `core/skills/output/SKILL.md:6`, `lsa/knowledge/conventions.md:1`, every `lsa/skills/lsa-*/SKILL.md:6`, every `core/skills/*/SKILL.md:6`, `helper/agents/helper.md:7`, `helper/commands/help.md:5`, all `helper/knowledge/*.md:1`, `.lsa/VISION.md:1`, `.lsa/roadmap.md:1` (~21 files) | none — the *blockquote framing* is invented; the *banner content* is invention #2. CommonMark blockquote is the only adopted standard at play | Tied to invention #2 — if #2 is removed, this is removed by the same edit; if #2 is kept, the blockquote framing stays | **needs-deeper-review** | Inherits the decision from invention #2 (OQ1). Filed as separate row to make the inheritance explicit. |
| 6 | `.lsa.yaml` configuration file (`constitution`, `specs_root`, `mode`, `modules.*`) | `lsa/ARCHITECTURE.md:84-114` §3; consumer in every LSA skill's Read protocol per `lsa/knowledge/conventions.md:28-34` | none — but the field set encodes operational decisions that the Claude Code plugin schema does not cover (per-project spec-root path, doc-mode vs code-mode, per-module artifact globs) | Removing would force every spec path to be hard-coded; `lsa-init` brownfield (`lsa/skills/lsa-init/SKILL.md`) would lose its primary write target; SessionStart hook would lose its config source | **keep** | Holds operational config the Claude Code plugin schema does not cover (per-project `specs_root`, `mode`, `modules.*.artifact_paths`). The schema-shape itself (YAML at repo root) follows the de-facto `.<tool>.yaml` convention used by hundreds of dev tools — substrate-adjacent. |
| 7 | LSA requirement-ID scheme (`F<n>` / `NF<n>` / `AC<n>` / `OQ<n>` / `UV<n>`) | `lsa/skills/lsa-specify/SKILL.md:64-89` (template); `.lsa/modules/lsa/spec.md` ID columns; consumed by `lsa-verify` AC-trace (`lsa/skills/lsa-verify/SKILL.md`) | none — EARS does not mandate IDs (`.lsa/VISION.md:200-206` cites EARS patterns only); but the ID columns are the trace anchor `lsa-verify` reads | Removing IDs forces `lsa-verify` to trace by AC text content (fragile); affects every requirement template across LSA and every archived feature spec | **keep** | The ID column is the substrate-of-record for verifier `lsa-verify`'s AC→code trace predicate. Removing it forces verification to match by AC prose, which drifts under normal edits; ID columns are the cheapest fix. Per `core/skills/output/SKILL.md:35-37` Rule 5, IDs stay in spec files; the rule already forbids IDs in user-facing pickers. |
| 8 | `[assumption: <why>]` / `[cannot verify]` / `[illustrative]` / `[unverified]` markers | `core/skills/ground-rules/SKILL.md:37`, `:44`, `:58`; consumer in every plugin's content | none — but the marker convention is the operational expression of `.lsa/VISION.md` §2 principle 2 (*"Two groundings, always"*) and `core/skills/ground-rules/SKILL.md` Rule 1 (fact-grounding) | Removing forces every uncertainty to either be a fabricated claim or a paragraph of hedged prose; `core/tests/repo-anchored.md` probes that depend on marker recognition regress | **keep** | The marker convention is the substrate-of-record for fact-grounding — there is no Claude Code primitive for *"this claim is an assumption, labelled."* Removing it would require either fabricating or omitting; both violate `ground-rules` Rule 1. |
| 9 | Canonical-source clause pattern (the blockquote *"This file is the single source-of-truth"* at the top of `core/output`, `core/CLAUDE.md`, etc.) | `core/skills/output/SKILL.md:8`, `core/CLAUDE.md:3`, `lsa/ARCHITECTURE.md:30` (cite-not-restate convention) | none — a convention to prevent rule-count drift; `core/tests/repo-anchored.md` probe D2 enforces it | Removing the clause invites paraphrase drift (the proximate failure mode this clause prevents, per `core/CHANGELOG.md:12`); probe D2 fails | **keep** | The clause is the operational anti-drift mechanism for `core/output` (the most-cited file in the marketplace). Removing it has a known-bad failure mode (paraphrase drift); the clause itself is one blockquote per canonical file (~3 files total) — minor surface cost. |
| 10 | `discovery.md` / `clarification.md` scratch files | `lsa/skills/lsa-discover/SKILL.md:37-47` (`discovery.md` writer); `lsa/skills/lsa-specify/SKILL.md:18`, `:32` (consumer + `clarification.md` writer) | none — but the handoff format between `lsa-discover` and `lsa-specify` is the operational expression of the Extended flow (`.lsa/VISION.md` §4) | Removing forces in-memory hand-off (no audit trail of the discovery answers); `lsa-specify` Step 2 (assume-then-override) loses its seed | **keep** | Scratch files are the substrate-of-record for the discover→specify hand-off — the alternative is losing the answers between two skill invocations, which Claude Code does not preserve. File-on-disk is the cheapest substrate. (Could be re-evaluated if Claude Code adds persistent inter-skill state; track in research-backlog if so.) |
| 11 | LSA branch-naming convention (`feature/<name>` / `feature/<name>-e<N>` / `constitution/<desc>` / `replan/<desc>`) | `lsa/ARCHITECTURE.md:117-126` (§4 "Branch Management" header `:117`, table `:121-126`); written by `lsa-specify` Step 3 (`lsa/skills/lsa-specify/SKILL.md:53`); written by `lsa-plan` (per `lsa/ARCHITECTURE.md:142`) | none — but git itself has no naming standard for feature branches; the convention is operational | Removing would force the verifier (`lsa-verify`) to discover the spec path by other means (currently `<feature-name>` comes from the branch name per `lsa/skills/lsa-verify/SKILL.md:19`); cross-references in `lsa-sync`'s archive step (`lsa/skills/lsa-sync/SKILL.md:79`) break | **keep** | The branch name is the substrate-of-record `lsa-verify` uses to locate the feature spec (`lsa/skills/lsa-verify/SKILL.md:19` — *"assumed to be `feature/<feature-name>`"*). Removing requires inventing a different feature-name source. The convention itself is one paragraph in `ARCHITECTURE.md`; minor surface cost. |

**Summary counts.** 11 surveyed = 3 named (`.lsa/roadmap.md:139-141`: rows #1, #2, #3 of this table) + 8 newly surfaced (rows #4–#11). Recommendations: 2 `remove` (#1 `.lsa-sync-state.json`, #3 Hard/Soft Confirm), 6 `keep` (#6 `.lsa.yaml`, #7 ID scheme, #8 marker convention, #9 canonical-source clause, #10 scratch files, #11 branch-naming), 3 `needs-deeper-review` (#2 file-load trace, #4 verb-headline vocabulary, #5 Trace blockquote framing).

## Data Model Changes

None. The sweep deletes inventions; it does not introduce data structures. The two `remove` recommendations:
- **#1 `.lsa-sync-state.json`** — the JSON file itself is deleted; the SHA value is recovered via `git log` at the point of consumption (`lsa-reconcile` Step 1, SessionStart hook). No replacement file.
- **#3 Hard/Soft Confirm** — the named vocabulary is deleted from `conventions.md`; skill bodies use plain-English phrasing inline.

## API / Interface Changes

The two `remove` recommendations touch internal LSA surfaces only — no public API changes for downstream plugins.

- **#1 removal.** `lsa-reconcile` and SessionStart hook switch from `.lsa-sync-state.json` reads to `git log` reads. The reconcile-skill's contract (`/lsa:reconcile` slash command, inputs, outputs) is unchanged.
- **#3 removal.** `conventions.md` §"Confirm gate types" deleted; cite-by-section-name references in skill bodies (`lsa-specify` §21, `lsa-reconcile` §35, `lsa-revise-constitution` §61) inline the phrasing.

## Cross-Module Contracts

None changed. The two removals stay inside `lsa/`. Documented in §"PR sequencing" below.

## PR sequencing

One PR per `remove` row, ordered from lowest to highest blast radius. The trace-tag-removal PR (commit `c226623`, +35 / -47 lines across 9 files) is the size and shape exemplar.

| Order | PR | Blast radius | Files touched (est.) | Blocked by |
|-------|----|--------------|----------------------|------------|
| 1 | Remove "Hard Confirm" / "Soft Confirm" vocabulary (inventory row #3) | LOW — vocabulary edit only; one knowledge file + 4 skill cite-sites | ~5 files: `lsa/knowledge/conventions.md`, `lsa/skills/lsa-specify/SKILL.md`, `lsa/skills/lsa-reconcile/SKILL.md`, `lsa/skills/lsa-revise-constitution/SKILL.md`, `lsa/CHANGELOG.md` | none — fully independent of the others |
| 2 | Remove `.lsa-sync-state.json` (inventory row #1) | MEDIUM — touches a state file, two skill bodies, one hook script, and architecture docs | ~7 files: `lsa/skills/lsa-sync/SKILL.md`, `lsa/skills/lsa-reconcile/SKILL.md`, `lsa/hooks/session-start-drift-check.sh`, `lsa/ARCHITECTURE.md`, `lsa/README.md`, `lsa/CHANGELOG.md`, the existing `.lsa-sync-state.json` file at repo root (deleted) | none — fully independent of row #3 |

The 3 `needs-deeper-review` rows produce no PR in this feature. Their open questions are below.

**Row #4 (LSA verb-headline what-and-why preamble) interaction.** Inventory row #4 (verb-headline vocabulary) and inventory row #5 (Trace blockquote framing) both depend on outside decisions: row #4 is gated on the row-#4-backlog-item (`.lsa/roadmap.md:36`) outcome, and row #5 inherits row #2's decision (file-load trace). This sweep deliberately stops at `needs-deeper-review` for those three — see open questions below.

## Open Questions

- **OQ1 — Does the file-load trace's source-attribution payoff exceed the visual-noise cost?** Tied to inventory row #2. The directive prints one line per loaded marketplace file at the top of every response (`core/CLAUDE.md` checkpoint #3, `core/skills/output/SKILL.md:30`). For a turn that loads `core/CLAUDE.md` + `core/output` + 3 LSA skills, that's 5 lines of banner above the response — directly tensions `core/output` Rule 2 *Minimal* and the 1–1.5 screen budget. The payoff is provenance (which marketplace files shaped the turn — `.lsa/roadmap.md:16` parent rationale). Resolution requires a usage data point (does the user reference the trace to debug something? Has it ever surfaced a misload?). Defer to the next dogfood log (`.lsa/roadmap.md:23`).
- **OQ2 — Does row #4 (LSA verb-headline what-and-why preamble) keep or replace the verb-headline vocabulary?** Inventory row #4. Canonical vocabulary is at `core/knowledge/output-vocabulary.md:11-22` (10 verdicts). 6 are emitted by LSA skills today (3 general: `PROPOSED`, `APPLIED`, `DRIFT` + 3 in `lsa-verify`: `PASS`, `FAIL`, `PASS WITH WARNINGS`); the other 4 (`READY` / `BLOCKED` / `CLEAN` / `REJECTED`) are defined but unused. The row-#4 backlog item (`.lsa/roadmap.md:36`) lands what-and-why preambles on every verb-headline. If row #4 replaces the verb with plain English, the vocabulary item is implicitly removed; if row #4 augments the verb with a preamble, the vocabulary stays. Defer to the row-#4 feature spec at `.lsa/features/2026-05-22-lsa-what-why-preamble/`.
- **OQ3 — Does the "Trace." blockquote framing get scoped to inventory row #2's decision, or evaluated separately?** Inventory row #5. The blockquote (`> **Trace.** On load, print first: ...`) is a CommonMark blockquote — the framing itself is standard. The contents are invention #2. Listed separately so the inheritance is explicit; resolution = inherit OQ1's decision. No standalone work.
- **OQ4 — Should `core/tests/repo-anchored.md` probe D2 (mentioned at `core/skills/output/SKILL.md:8`) and any other future probes count as a "Claude Code substrate primitive" for the rubric?** The probe is in-repo, not platform-provided — but it enforces the canonical-source clause (inventory row #9). For this feature: treated as in-repo enforcement, not substrate; inventory rows that the probe enforces (#9 in particular) defended on their own merits. Flag for the next sweep if probes proliferate.
