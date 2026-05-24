# Changelog

All notable changes to the `lsa` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

## [0.8.0] — 2026-05-24

Apply the new `core` v0.7.0 **Rule 6 — What-and-why preamble** to every LSA skill body that currently emits a verdict label from `core/knowledge/output-vocabulary.md` §"Verdicts". 5 skill bodies updated; 7 emission sites gain a one-sentence preamble in the user's frame, naming (a) what the verdict means and (b) the concrete consequence if the user does not act. PR #20 work (verdict-named picker prompts in `lsa-verify`, closing-offer reframe in `lsa-sync`) preserved intact — preambles land BEFORE the verdict line without disturbing the existing prompt voice. Per `vision/specs/features/2026-05-22-lsa-what-why-preamble/`. Standard flow.

### Changed
- **`lsa/skills/lsa-init/SKILL.md` Step 2 brownfield** — `PROPOSED` verdict at the "Stop" sub-step now carries a preamble in the user's frame: *"I scanned this repo and drafted `<N>` module specs from /src/ so future LSA steps can attach changes to a specific module — without these specs the next /lsa:discover has nothing to pick."* Citation line added: *"Verdict carries a preamble per `core/output` Rule 6."* PR #20's prompt-voice scaffold (Rule 5 picker question naming the project subject) preserved unchanged. Maps to AC1.
- **`lsa/skills/lsa-reconcile/SKILL.md` Step 4** — `DRIFT` verdict at the per-module hard confirm now carries a preamble in the user's frame: *"The auth spec says sessions expire after 24 hours, but the code now sets 7 days — one needs to win, otherwise the next review will block the merge until you pick one."* (adapted per delta at runtime). Citation line added. Maps to AC2.
- **`lsa/skills/lsa-sync/SKILL.md` Step 8** — `APPLIED` verdict at the post-completion report now carries a preamble in the user's frame: *"Module specs for `<modules>` now reflect the merged feature — the docs are current, and the next decision is just whether to open the PR now or later."* Citation line added. PR #20's closing-offer reframe (silent-default `hold`, Rule 5 Genuine-fork-test citation) preserved unchanged. Maps to AC4.
- **`lsa/skills/lsa-revise-constitution/SKILL.md` Step 3** — `PROPOSED` verdict at the per-change human review gate now carries a preamble in the user's frame: *"Last feature surfaced a rule worth making permanent: I'm offering to add a 'no inline secrets' line to CLAUDE.md — accepting makes it enforced on every future change; rejecting means the next contributor can still paste a secret without a warning."* (adapted per change at runtime). Citation line added. Maps to AC5.
- **`lsa/skills/lsa-verify/SKILL.md` Step 4** — all three variant verdicts (`PASS` / `FAIL` / `PASS WITH WARNINGS`) now carry a one-sentence preamble before the verdict line, naming what the verdict means and the consequence in the user's frame. Single citation line added at the top of Step 4 covering all three variants. PR #20's verdict-named `AskUserQuestion` prompts (*"Verdict: PASS — sync now? …"* etc.) preserved unchanged. Maps to AC3.

### Notes
- **Minor bump rationale.** 5 skill bodies' user-visible output shape changes — every verdict emission now leads with a plain-English preamble instead of a bare label. Per `vision/VISION.md` *"Distribution + versioning"* — observable behavior change across multiple skills is minor-bump territory.
- **Sibling core minor bump.** `core` v0.7.0 in the same feature ships the canonical Rule 6 these LSA edits cite (`core/skills/output/SKILL.md` Rule 6 *"What-and-why preamble — verdicts carry a one-sentence frame"*). The rule lives at the marketplace layer alongside the verdict vocabulary itself (`core/knowledge/output-vocabulary.md`); LSA cites by link, never restates.
- **Three LSA skills with zero verdict emissions stay untouched.** `lsa-discover`, `lsa-specify`, `lsa-plan` emit no verdict label per the inventory in `vision/specs/features/2026-05-22-lsa-what-why-preamble/design.md` §"Verb-headline inventory". The rule still ships in `core/output`, so the moment any of them adds a verdict emission the preamble obligation attaches automatically. (`lsa-plan` uses `PASS / FAIL` as in-table cell values, not verdict headlines — Open Question 2 resolution.)
- **Spec source.** `vision/specs/features/2026-05-22-lsa-what-why-preamble/requirements.md` AC1–AC8 + F1–F7; `design.md` §"Worked examples" carries the verbatim preamble strings used at each emission site; `tasks.md` Epics 0–5 enumerate the edits.

## [0.7.2] — 2026-05-24

Apply the `core` v0.6.0 *Genuine-fork test* to 3 LSA call sites — tightening `lsa-discover`'s per-line picker (composes with v0.7.1 infer-then-confirm), softening `lsa-sync`'s post-completion picker, and renaming `lsa-verify`'s verdict-picker prompt. Per `vision/specs/features/2026-05-22-askuserquestion-audit/` Epic B (rows L2 / L9 / L12 in the design inventory). Standard flow. Renumbered from v0.7.1 → v0.7.2 to coexist with the v0.7.1 infer-then-confirm release that landed independently.

### Changed
- **`lsa/skills/lsa-discover/SKILL.md` Step 2 (L2 — `keep + tighten`)** — added "Skip per-line picker when N=1 candidate AND no `custom`" semantics on top of v0.7.1's infer-then-confirm reshape. When Step 1 yields a single unambiguous candidate for a line and the human hasn't asked for `custom`, the skill accepts the candidate silently. Remaining picks batch into ONE multi-question `AskUserQuestion`.
- **`lsa/skills/lsa-sync/SKILL.md` Step 8 (L12 — `convert-to-closing-offer`)** — post-completion PR-or-hold picker reframed as an *optional closing offer*, not a mandatory gate. **Silent-default = `hold`** — `gh pr create` runs only on explicit `Yes`. Cites `core/output` Rule 5 Genuine-fork test.
- **`lsa/skills/lsa-verify/SKILL.md` Step 4 + Step 5 (L9 — `keep + tighten` verdict-picker prompt voice)** — verdict-picker prompts rewritten to name the verdict in the subject: *"Verdict: PASS — sync now?"* / *"Verdict: FAIL — block merge?"* / *"Verdict: PASS WITH WARNINGS — accept the warnings and sync?"*. Human picks the next action; verdict itself is already settled by the checklist.

### Notes
- **Patch bump rationale.** L2 (skip when N=1) + L12 (closing-offer) change observable behavior; L9 (verdict prompt) is prompt-text only. Cumulative effect is on the patch/minor boundary; chose patch — no rule/skill added or removed, only existing pickers' wording and conditional rendering changed.
- **Sibling `core` minor bump.** `core` v0.6.0 in the same feature ships the canonical rule this changelog cites (`core/skills/output/SKILL.md` Rule 5 *Genuine-fork test*). LSA edits are downstream of the rule.
- **Out of scope for this PR.** Helper-side call-site sweep (Epic C — H1, H2, H3, H4, H5m in the inventory) ships in a later PR; it folds with feature 5's Epic 3 since most Epic C work was substantially done by helper v0.3.0 (PR #19).
- **Spec source.** `vision/specs/features/2026-05-22-askuserquestion-audit/design.md` §"Call-site Inventory" rows L2, L9, L12 carry the verdict + reason; `tasks.md` Epic B enumerates B1–B6.

## [0.7.1] — 2026-05-23

`lsa-discover` infer-then-confirm. The agent now reads the codebase to determine module, change framing, and acceptance criterion — then presents all three as a pre-filled table for human override in a single `AskUserQuestion`. Previously the skill asked three questions the agent should have answered itself. Same pattern as the `lsa-init` v0.3.1 fix (greenfield/brownfield mechanical detection). Per user feedback 2026-05-23.

### Changed
- **`lsa/skills/lsa-discover/SKILL.md` Step 2** — replaced "Ask the three-question discovery probe" with "Infer all three discovery answers — then confirm." New sub-steps 2a (module inference via artifact_paths cross-reference), 2b (change framing from module spec), 2c (AC from task description + spec invariants), 2d (single confirmation prompt). The agent does the discovery work; the human confirms or overrides.
- **`lsa/skills/lsa-discover/SKILL.md` Goal** — updated to reflect agent-inferred, human-confirmed pattern.
- **`lsa/skills/lsa-discover/SKILL.md` Constraints** — first bullet changed from "Three questions, no more" to "Infer, don't ask" with the rule that the agent never asks for information derivable from repo state.
- **`lsa/README.md`** — `lsa-discover` row updated from "Light three-question probe" to "Infer-then-confirm discovery."

### Notes
- **Patch bump rationale.** Behavioral improvement to an existing skill — discovery answers are now agent-inferred rather than human-provided. The three-answer shape and downstream handoff (Standard oral / Extended scratch) are unchanged.
- **Precedent.** Mirrors `lsa-init` v0.3.1 (`lsa/CHANGELOG.md:163-166`) which replaced the redundant "Greenfield or brownfield?" question with mechanical detection.

## [0.7.0] — 2026-05-22

Remove the trace-tag convention and stop emitting `<!-- added/reconciled/revised: ... -->` HTML comments. The format was opaque to non-LSA collaborators and not required by EARS (`vision/VISION.md:187-206`) or any other adopted 3rd-party standard. Minor bump — three skills' observable output changes.

### Removed
- **`lsa/knowledge/conventions.md` §"Trace-tag format"** — section deleted (was lines 53-75).
- **`lsa/skills/lsa-sync/SKILL.md`** — 5 trace-tag references removed: the "(tagged)" mention in Step 2's decision block, the `Tag each addition` substep in Step 3, the `Tag each change` bullet in Step 4, the "(tagged)" qualifier in Output, and the **Tag every addition** constraint.
- **`lsa/skills/lsa-reconcile/SKILL.md`** — 3 trace-tag references removed: the `Tag the edited line(s)` sentence in Class (a), the `Tag with` sentence in Class (b), and the "both tagged" qualifier in Output.
- **`lsa/skills/lsa-revise-constitution/SKILL.md`** — 3 trace-tag references removed: the "tagged" mention in Step 3's decision block, the `Tag the change` substep in Step 4, and the "each tagged" qualifier in Output.

### Changed
- **`vision/VISION.md`** (2 sites — `:59`, `:206`), **`vision/specs/main.spec.md:18`**, **`vision/specs/modules/lsa/spec.md`** (2 sites — `:36`, `:37`) — stripped the 5 HTML comment tags from living specs. Archive files (`vision/plans/2026-05-20-*`, `vision/specs/2026-05-20-lsa-v0.2.0-design.md`) intentionally untouched per user choice — they remain as frozen historical records.

### Notes
- **Minor bump rationale.** Three skills change observable output (no more tagged HTML comments in their edits) — that's user-visible behavior change, not a patch-class fix. Per `vision/VISION.md` "Distribution + versioning".
- **No migration step needed.** Existing tags in archive files are valid Markdown comments; nothing parses them and nothing breaks.
- **User trigger.** Working with a collaborator on a downstream project (TripAnchor), the user flagged that `<!-- revised: manual 2026-05-22 -->` is unintelligible to anyone without LSA context. "If it's not a requirement from EARS or other 3rdparty we adopted - get rid of it." Confirmed not required by EARS (which is purely AC-phrasing per `vision/VISION.md:187-206`); no other adopted standard mandated provenance HTML comments.

## [0.6.5] — 2026-05-22

Replace 9 snapshot restatements with citation-by-link to satisfy `core` v0.5.5's new canonical-source contract for output discipline. No behavior change. Patch flow.

### Fixed
- **`lsa/ARCHITECTURE.md:30`** — Stale *"(4 golden rules)"* count snapshot (Core has five) → citation-only descriptor.
- **All 8 `lsa/skills/*/SKILL.md` Constraints footers** — *"golden rules (structured, minimal, formatted, sourced)"* (missing *concrete*) → *"citation by link, never restated."* Files: `lsa-discover`, `lsa-init`, `lsa-plan`, `lsa-reconcile`, `lsa-revise-constitution`, `lsa-specify`, `lsa-sync`, `lsa-verify`.

### Notes
- **Patch bump rationale.** Mechanical citation cleanup; no skill behavior change. The rules LSA outputs adhere to are exactly the rules `core/output` has always defined — only the prose changes. The next time `core/output` grows or shrinks a rule, LSA's citations will resolve to the new list automatically (no LSA edit needed).
- **Sibling core patch.** `core` v0.5.5 in the same PR declares `core/output` canonical + adds the D2 regression probe that prevents this drift class from recurring.

## [0.6.4] — 2026-05-22

File-load trace adoption. All 8 `lsa/skills/*/SKILL.md` and `lsa/knowledge/conventions.md` carry the new one-line trace directive at their top, per `core` v0.5.4 Rule 4 (Sourced) → *File-load trace*. On load, each file prints `=============== [<file>] [lsa] ===============` verbatim. Replaces the v0.5.3 `[plugin:skill]` marker scheme that did not survive in practice. Per user request 2026-05-22. Quick flow.

### Added
- **Trace directive in 9 files** — `lsa/knowledge/conventions.md` plus all 8 LSA skill bodies (`lsa-discover`, `lsa-init`, `lsa-plan`, `lsa-reconcile`, `lsa-revise-constitution`, `lsa-specify`, `lsa-sync`, `lsa-verify`). Hardcoded path + plugin name in each; on load the agent prints the line verbatim before the response body.

### Notes
- **Patch bump rationale.** No skill behavior change beyond the trace line. Same User Verification flow, same artifacts. The trace replaces the v0.5.3 single-line marker as a provenance mechanism — see `core` v0.5.4.

## [0.6.3] — 2026-05-22

Adopt the now-supported `dependencies` field in the Claude Code plugin manifest. Clears the "Marketplace dependency field" row from `vision/specs/roadmap.md` (status was `blocked` per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §14). Verified field availability against [code.claude.com/docs/en/plugin-dependencies](https://code.claude.com/docs/en/plugin-dependencies) and [code.claude.com/docs/en/plugins-reference](https://code.claude.com/docs/en/plugins-reference) on 2026-05-22 — `dependencies` is a top-level array (entries are bare strings or `{ name, version?, marketplace? }` objects) and ships in current Claude Code.

### Added
- **`lsa/.claude-plugin/plugin.json` `dependencies`** — bare-string declaration `"dependencies": ["core"]`. Claude Code now auto-resolves and installs `core` when a user installs `lsa`, and refuses to disable `core` while `lsa` is enabled (per the same-marketplace cascade rules in the docs above). No version constraint this cycle — `core` and `lsa` ship from the same repo on the same release cadence, so versions move in lockstep. A future row in the roadmap can add a `>=` floor + tagged-release flow if a downstream consumer outside this repo materializes.

### Changed
- **`lsa/.claude-plugin/plugin.json` `description`** — dropped trailing prose `Depends on \`core\` (cites \`core/ground-rules\` for fact-grounding and \`core/flow-selector\` for flow selection).` The structured `dependencies` field now carries the same intent; the cite-specific skills detail moves nowhere (it was illustrative, not load-bearing for the manifest).
- **`lsa/README.md`** — "Depends on" section: the line claiming the manifest does not enforce a `dependencies` field is now stale; replaced with a note that the structured field exists and Claude Code auto-resolves on install.

### Notes
- **Patch bump rationale** — manifest declaration moves from prose to structured, expressing the same intent. The user-visible install-behavior change (auto-resolve + enable/disable cascade) is additive and aligns with the prior `/plugin install core` → `/plugin install lsa` documented sequence. Treating as patch per the same pre-1.0 maintainer-discretion clause used for the v0.6.2 sibling-rename patch.
- **Sibling release** — `core` is unchanged. The dependency edge is declared from the dependent side only, per the documented schema.

## [0.6.2] — 2026-05-22

Naming clarity patch — two sibling renames:

1. **`lsa-specify` "Gate N" → "User Verification N: <name>"** — the prior `Gate 1` / `Gate 2` / `Gate 3` carried position but no meaning to a first-time user. New names: `User Verification 1: Requirements + Contract Trigger`, `User Verification 2: Test Suites + Contract + Design`, `User Verification 3: Final Integration`.
2. **Tier flow `T1` / `T2` / `T3` → `Quick` / `Standard` / `Extended`** — sibling to `core` v0.5.2's `tier-selector` → `flow-selector` rename. The new names describe the *process shape*, not a hierarchy.

Per `vision/specs/roadmap.md` rows *"Rename `lsa-specify` 'Gate N' → 'User Verification: <name>'"* and *"Rename `T1` / `T2` / `T3` → `Flow: Quick` / `Flow: Standard` / `Flow: Extended`"*. Bundle B (Naming clarity) of the 2026-05-22 fixing session.

### Changed
- **`lsa/skills/lsa-specify/SKILL.md`** — Goal sentence + Steps 4/5/6 section headers + cross-references updated to `User Verification N: <name>`; Constraints "Three bundled gates" → "Three bundled User Verifications"; "(determined at Gate 1)" comment + "re-run Gate 3" amend rule updated; "tier" / "T3" annotations in description + Input + Step 1.
- **`lsa/skills/lsa-discover/SKILL.md`** — `T2 / T3` → `Standard / Extended`; `tier-selector` → `flow-selector`; "tier" → "flow" throughout.
- **`lsa/skills/lsa-init/SKILL.md`** — Step 4 report message updated to name `Standard / Extended` entry path.
- **`lsa/skills/lsa-verify/SKILL.md`** — Step 6 + Output + Constraints updated: `T3` → `Extended`, `T2` → `Standard`, `T1` → `Quick`.
- **`lsa/skills/lsa-sync/SKILL.md`** — Step 7 aggregate-metrics description updated: `T3 feature` → `Extended-flow feature (was T3)`.
- **`lsa/README.md`** — `lsa-specify` row notes the User Verification rename; `lsa-discover` + `lsa-verify` rows replace `T2 / T3` with `Standard / Extended`; LSA's "expression of the credo" reads *"Every LSA User Verification is a decision..."*.
- **`lsa/ARCHITECTURE.md`** — "Tier flow (T1/T2/T3)" → "Flow types (Quick/Standard/Extended — was T1/T2/T3)"; "tier-selector" → "flow-selector"; OQ6 row in resolved-decisions table; metrics archive path comment.
- **`lsa/.claude-plugin/plugin.json` `description`** — "human gates" → "human User Verifications"; "Tier-aware (T1/T2/T3) via core/tier-selector" → "Flow-aware (Quick/Standard/Extended — renamed from T1/T2/T3 in lsa v0.6.2) via core/flow-selector".

### Cross-spec updates (active files only)
- **`vision/VISION.md`** — §3 directory diagram (`tier-selector` → `flow-selector` slot); §3 prose ("Core rules are always-on; flows govern workflow"); §3 always-on-vs-on-demand resolution; §4 tier-table + worked-examples table renamed; §7 open-decisions "Tier boundaries" → "Flow boundaries"; §2 sub-principle 2a + §6 Adjust #1 RESOLVED cross-cite Gate 2 → User Verification 2; Changelog gains v0.7 + v0.8 entries.
- **`vision/specs/main.spec.md`** — module index version bumps + cross-module-contract `tier-selector` → `flow-selector`.
- **`vision/specs/modules/core/spec.md`** — `core/tier-selector` row + `core/CLAUDE.md` invariants citation updated.
- **`vision/specs/modules/lsa/spec.md`** — `core/tier-selector` dependency + `lsa-specify Gate 2` invariants → `lsa-specify User Verification 2`; metrics-table T3 annotations + lsa v0.6.2 version bump.
- **`vision/specs/standards/testing.md`** — `core/tier-selector` reference + T3 annotation.
- **`vision/specs/metrics.md`** — header line: `archived T3 feature` → `archived Extended-flow feature (was T3)`.
- **`vision/specs/roadmap.md`** — both rename rows marked `shipped — lsa v0.6.2`; Recently merged gains the Bundle B entry; row 11 (Diagonal cross-artifact analysis row) + Tech Picture §3 updated to use `User Verification 2` with back-link to the old `Gate 2` name.
- **Repo root** — `CLAUDE.md` + `README.md` + `CONTRIBUTING.md` reference `core/flow-selector` and `Quick / Standard / Extended`.

### Notes
- **Breaking surface change, treated as patch** — same rationale as `core` v0.5.2 (sibling patch): pre-1.0 SemVer leaves this to maintainer discretion, and there are no external consumers of `/lsa:specify`'s `Gate N` literals.
- **Historical files left as-is.** Past entries in `core/CHANGELOG.md` / `lsa/CHANGELOG.md` (entries before 0.5.2 / 0.6.2) and every file under `vision/specs/archive/**/` keep their original `Gate N` / `T1/T2/T3` / `tier-selector` wording. The new entries (and the renamed surface) note the rename so historical lookup still resolves. `vision/plans/2026-05-20-*.md` files are pre-merge plans — also untouched.
- **Sibling core patch** — `core` v0.5.2 in the same Bundle B PR renames the `tier-selector` skill directory + slug.

## [0.6.1] — 2026-05-22

Gate-prompt voice patch. Applies `core/output` Rule 5 (Concrete — *prompt voice*) inside the user-facing pickers of `lsa-specify` / `lsa-plan` / `lsa-init` so the picker question names the feature subject (e.g., *"Approve the requirements for `<feature-name>`?"*) instead of meta-jargon (*"Approve Gate 1?"*, *"Approve F3?"*, *"Approve epic decomposition?"*). Per `vision/specs/roadmap.md` row *"LSA gate prompts must be concrete (no IDs, no jargon, must-decide only)"* (Must priority).

### Changed
- `lsa/skills/lsa-specify/SKILL.md` Step 2 (clarification) — Present block adds an explicit **Prompt voice** scaffold citing `core/output` Rule 5: picker question names the feature; option labels name the next outcome; never render `[a]/[b]/[c]` text blocks when the picker is available (per `core/CLAUDE.md` operational checkpoint #1).
- `lsa/skills/lsa-specify/SKILL.md` Step 4 (Gate 1) — Present block adds the same scaffold; explicit rule that `F<n>` / `NF<n>` / `AC<n>` IDs stay in `requirements.md`, not in the picker question.
- `lsa/skills/lsa-specify/SKILL.md` Step 5 (Gate 2) — Present block adds the same scaffold; failing-row pickers (Rule 6 decision blocks for `✗` diagonal rows) cite the two artifact lines in conflict, not the row number.
- `lsa/skills/lsa-specify/SKILL.md` Step 6 (Gate 3) — Present block adds the same scaffold; picker question is *"Final approval — start implementation planning for `<feature-name>`?"*.
- `lsa/skills/lsa-plan/SKILL.md` Step 5 (human review) — Present block adds the scaffold; picker question names the epic count and feature; `epic decomposition` reserved for skill body.
- `lsa/skills/lsa-init/SKILL.md` Step 2 (brownfield) — Present block adds the scaffold; picker question names the project subject; `brownfield` reserved for skill body.

### Notes
- **Cosmetic on the SKILL.md side, behavioral on the user-facing side.** The Gate names, the Hard Confirm gates, and the trace predicates are unchanged. Only the user-facing picker text is normalized.
- **Depends on `core` v0.5.1** (sibling patch in same Bundle A PR) — that patch elevates the substrate-native picker rule and screen-budget to always-on, which this patch's `core/CLAUDE.md` operational checkpoint #1 citation relies on.
- Sibling rename PRs (Gate N → User Verification; T1/T2/T3 → Flow) land in Bundle B.

## [0.6.0] — 2026-05-21

EARS + journey-shape AC discipline. Tightens `lsa-specify` Gate 2 along two axes (EARS pattern conformance + journey-shape) and extends `lsa-verify` with dual trace predicates sourced from a new `**Covers:**` line in `lsa-plan`'s epic template. Per `vision/specs/archive/2026-05-21-ears-journey-shape-ac/`.

### Added
- **`lsa-specify` Gate 2 — two new diagonal rows.** Row **1a** (EARS-pattern) checks each AC matches one of the five EARS patterns per `vision/VISION.md:201`. Row **1b** (Journey-shape) checks each AC describes a user-observable behavior at the user/system boundary per `vision/VISION.md` §2 sub-principle 2a. `✗` rows surface as Rule 6 decision blocks via the existing failing-row render at `lsa/skills/lsa-specify/SKILL.md:165-180`.
- **`lsa-specify` Gate 1 template — AC sub-block in EARS form.** Template at `lsa/skills/lsa-specify/SKILL.md:48-80` cites `vision/VISION.md` §2 sub-principle 2a (journey-shape) and `:201` (EARS patterns) inline so the agent reads the rule before authoring.
- **`lsa-plan` epic template — `**Covers:**` line.** New line under each epic's `### Scope` citing requirement IDs (`F<n>`, `NF<n>`, `AC<n>`) the epic implements. Parallel to the existing `**Covers:**` on `test-suites.md` Journeys. Sourced by `lsa-verify` trace predicates.
- **`lsa-plan` self-verification — AC-coverage row.** New row checking every AC in `requirements.md` appears in at least one epic's `**Covers:**`.
- **`lsa-verify` — orphan-diff predicate (broad).** Every non-trivial diff hunk must have an epic in `tasks.md` whose `### Scope` covers the hunk and whose `**Covers:**` cites ≥1 requirement ID. FAIL: `<artifact-file>:<line> has no requirement trace`. Mechanical hunks (whitespace, rename, formatting) are filtered before this check. Replaces the prior loose trace rule.
- **`lsa-verify` — orphan-AC predicate (narrow).** Every AC ID in feature `requirements.md` § Acceptance Criteria must be cited by ≥1 epic's `**Covers:**`. FAIL: `requirements.md:<AC-line> has no covering implementation`. Enforces behavior-coverage strictness.
- **`vision/VISION.md` §2 sub-principle 2a.** *"Acceptance criteria are journey-shaped"* — the standing principle that operationalizes principle 2's *"code traces to specs"* clause at the AC level. Authored via `lsa-revise-constitution`.
- **`vision/VISION.md` §6 Adjust #1 RESOLVED marker.** Records the EARS adjust as adopted, parallel to the §6 Adjust #4 RESOLVED marker at `vision/VISION.md:237`. Authored via `lsa-revise-constitution`.
- **`vision/specs/modules/lsa/spec.md` § Invariants** — new bullet documenting the Gate 2 EARS + journey-shape rows, the epic `**Covers:**` line, and the `lsa-verify` dual trace predicates. Parallel to the diagonal-coverage invariant at line 34.

### Changed
- **`lsa-verify` Scope checklist** — replaced the prior loose "Every change traces to a requirement in `requirements.md`" rule (which checked file-name presence in an AC) with the dual orphan-diff + orphan-AC predicates above. Mechanical-hunk exemption preserved. The Constraint *"FAIL on any untraced change"* updated to cite the orphan-diff predicate.
- **`vision/specs/main.spec.md`** — module index `lsa` row v0.5.0 → v0.6.0.
- **`vision/specs/modules/lsa/spec.md`** — plugin manifest tag v0.5.0 → v0.6.0; *"Currently v0.5.0"* → *"Currently v0.6.0"*.
- **`vision/specs/roadmap.md`** — row "EARS notation in AC block" status → `shipped — lsa v0.6.0`. Row "Diagonal cross-artifact analysis at `lsa-specify` Gate 2" status → `shipped — lsa v0.5.0` (reconciles stale row from prior merge). Recently merged gains rows for v0.6.0 and v0.5.0.
- **`lsa/README.md` skill table** — `lsa-specify` row updated from "4-row" → "6-row" diagonal table (5 with contract skipped); `lsa-plan` row mentions the epic `**Covers:**` field; `lsa-verify` row mentions the dual orphan-diff + orphan-AC predicates.

### Notes
- **Forward-only.** No `requirements.md` under `vision/specs/archive/**/` is modified. Existing archived specs keep their GWT-style ACs; the rule applies only to new specs authored after merge.
- **Broadened `**Covers:**` from AC-only to any requirement ID.** F4 + F8 of the feature `requirements.md` were originally AC-only; broadened during planning to align with `vision/specs/main.spec.md` NFR2 *"every artifact change traces to a spec requirement"* (constitution / CHANGELOG / version edits trace to F/NF requirements, not behavioral ACs). The dual predicate split (broad orphan-diff per AC3, narrow orphan-AC per AC4) keeps behavior coverage strict.
- **Vision-edit routing.** Per the feature's Gate 3 decision, the `vision/VISION.md` edits (§2 sub-principle 2a + §6 Adjust #1 RESOLVED marker) were authored via `lsa-revise-constitution`, then bundled into this feature commit per the precedent set by `feature/diagonal-cross-artifact-analysis` (commit `7235e17`).
- Corresponds to Vision v0.7.

## [0.5.0] — 2026-05-21

Diagonal cross-artifact analysis at `lsa-specify` Gate 2 — extends the existing AC→Journey coverage check to a 4-row diagonal coverage table (AC→Journey, Journey→Design, Design→Contract, Contract→test-suites). Failing rows surface as Rule 6 decision blocks. Per the 2026-05-20 Tech Picture adoption (`vision/specs/roadmap.md:64-75`).

### Added
- **`lsa-specify` Gate 2 — diagonal coverage.** Step 5 of `lsa/skills/lsa-specify/SKILL.md` now renders a 4-row coverage table after the AC-coverage check, citing every compared artifact pair in `<file>:<line> ↔ <file>:<line>` format. Failing rows surface as Rule 6 decision blocks; when multiple rows fail, all surface together in a single multi-question `AskUserQuestion` (batched). Approval blocks until every `✗` row resolves. When Gate 1 contract-trigger = NO, the two contract-touching rows render as `N/A — contract skipped`. Source: `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/`.
- **`vision/specs/modules/lsa/spec.md` § Invariants** — new bullet documenting the Gate 2 diagonal coverage discipline. Cites SKILL.md:154 + the archived feature spec.

### Changed
- **`lsa/README.md` skill table** — `lsa-specify` row description corrected from stale "hard/soft confirm gates per file" to "three bundled hard-confirm gates; Gate 2 renders a 4-row diagonal cross-artifact coverage check". Aligns with the audit-C gate collapse landed in v0.4.0.
- **`vision/specs/modules/lsa/spec.md`** — version references refreshed: plugin manifest tag v0.2.1 → v0.5.0; "Currently v0.2.1" → "Currently v0.5.0"; core dependency floor v0.2.0 → v0.4.0 (when `core/output` was added and cited from every LSA skill).
- **`vision/specs/main.spec.md`** — module index `lsa` row v0.2.0 → v0.5.0. Closes the version-drift gap that opened during the credo rollout (PRs that bumped lsa to v0.4.0 did not update main.spec.md).

## [0.4.0] — 2026-05-21

Credo rollout PR 2 — every LSA skill (+ `core/tier-selector`) adopts a component-specific output format that satisfies the four golden rules in `core/output` (structured, minimal, formatted, sourced). Builds on `core` v0.4.0 (PR 1). Per [`vision/plans/2026-05-20-credo-rollout-plan.md`](../vision/plans/2026-05-20-credo-rollout-plan.md).

### Added
- `lsa/README.md` — *"LSA's expression of the credo"* section right after the H1 with the user's verbatim line *"LSA doesn't automate your thinking — it makes you own it."* and links to `core/CLAUDE.md` + Rule 0.
- `lsa/ARCHITECTURE.md` §1 — new sub-section *"How `core/output` constrains LSA"* naming the four mechanical consequences (tabular discovery output; 7→3 gate collapse in `lsa-specify`; verdict-first verify reports; `AskUserQuestion` for every decision).

### Changed
- **`lsa-specify` gates 7 → 3.** Hard-confirm stops collapse to **Gate 1** (`requirements.md` + AC + contract-trigger, bundled), **Gate 2** (`test-suites.md` + `contract.yaml` + `design.md`, bundled), **Gate 3** (final integration). The contract-trigger check is folded into Gate 1 (no longer a separate human prompt). Step count drops from 9 to 6.
- **`lsa-discover` Output is a 3-row table** (Module / Change / Acceptance) instead of a single-paragraph context summary. Step 2 questions (b) and (c) shift to assume-then-override (agent proposes 2 candidate framings; human picks).
- **`lsa-verify` report is verdict-first** with three explicit variants (PASS / FAIL / PASS WITH WARNINGS). Metadata (date / branch / mode) moves below the verdict. Issues table is failures only.
- **All 8 LSA skills + `core/tier-selector`** — Constraints sections gain one citation line: *"Outputs follow [`core/output`](path) golden rules."* No restatement of format mechanics inside any skill.
- **Every decision-bearing prompt** in every skill describes data + decision options + outcomes; format defers to `core/output`; in Claude Code, `AskUserQuestion` is the canonical primitive (per `vision/VISION.md` §2 principle 9). The text decision-block is the fallback for plain-text rendering.
- `lsa/README.md` "Naming note" — `ground-rules` description updated 4 → 6 content rules; adds `core/output` as the format-discipline peer skill.
- `lsa/ARCHITECTURE.md` Version bumped from 0.2.1 to 0.4.0; Status line updated.

### Notes
- `lsa/knowledge/conventions.md` is **unchanged.** The audit-B D2 proposal to add a *"Prompt shape"* section was superseded by audit-C (output discipline lives in `core/output`; LSA skills cite it directly, not via a conventions.md alias).
- The S1–S17 component-specific output formats in the credo plan's Layer 1.5 stay as illustrative reference, not as embedded templates inside skill bodies (audit-C tight-pattern revision — each skill describes data + decisions, defers format to `core/output`).
- **Behavior change — `contract.yaml` + `design.md` Soft → Hard Confirm in `lsa-specify`.** Pre-PR-2, Steps 7 (`contract.yaml`) and 8 (`design.md`) were Soft Confirm (human may delegate corrections inline). After the 7→3 gate collapse, both live inside Gate 2 which is Hard Confirm. The Soft type still exists in `conventions.md` for other skills' use; `lsa-specify` no longer uses Soft. (Surfaced by Round-3 self-review finding L2.)
- **Pre-existing path-fix in `lsa-init` Constraints.** The cite to `core/skills/ground-rules/SKILL.md` was at the wrong relative depth (`../../core/skills/ground-rules/` — pointed at `lsa/core/skills/...` which doesn't exist). Repaired to `../../../core/skills/ground-rules/` during the Constraints edit. Pre-existing bug, not a credo-rollout regression. (Surfaced by Round-3 self-review finding L1.)
- Corresponds to Vision v0.6.

## [0.3.1] — 2026-05-20

KISS surgical edits. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 3.

### Changed
- `lsa-init/SKILL.md` Step 2 — replaced the redundant human question *"Greenfield or brownfield?"* with mechanical detection: *"If `${specs_root}/modules/` is empty AND `.lsa.yaml: modules.*` contains no `artifact_paths`, the mode is greenfield; otherwise brownfield. Print the determination and ask the human to confirm."* The gate is preserved; the question is no longer wasted on something derivable from repo state.
- `lsa-plan/SKILL.md` Step 2 — added the missing rationale for the ≤5 epics ceiling: *"chosen to keep epic-level human review tractable; if the work cannot be decomposed in five, the feature is too large and should be split at the spec level rather than at the plan level"*. Closes the magic-number gap surfaced in the simplification round-2 review.
- `lsa-specify/SKILL.md` — split contract trigger out of Step 4 into its own Step 5 *"Determine contract requirement"* so each step has one Goal/Output (round-2 finding). Renumbered subsequent steps: old Step 5 (`test-suites.md`) → 6, old 6 (`contract.yaml`) → 7, old 7 (`design.md`) → 8, old 8 (Final review) → 9. Updated cross-references inside the file (spec-tree comment, contract-step reference, Amending section).

### Removed
- Pre-Feature Checklist orphan — already deleted in 0.2.1 when `lsa/ARCHITECTURE.md` §5 (Workflow Phases) was pruned. Listed here for traceability against the round-2 finding.

### Notes
- Kept `.lsa.yaml: mode: mixed` as-is per the plan ("marginal complexity, removing would break an existing config surface").
- No behavioral semantics changed by these edits. The contract trigger still gates `contract.yaml` (now via Step 5 → Step 7); the ≤5 epics rule still escalates (now with the why); greenfield/brownfield still gates with explicit confirm (now mechanically pre-filled).

## [0.3.0] — 2026-05-20

Knowledge-vs-Actor boundary tightening across all eight LSA skills. New `lsa/knowledge/conventions.md` Knowledge surface owns cross-skill conventions formerly duplicated in skill bodies. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 2.

### Added
- `lsa/knowledge/conventions.md` — single Knowledge file holding (1) `.lsa.yaml` defaults, (2) the Read Protocol, (3) Hard / Soft Confirm gate type definitions, (4) the unified trace-tag format `<!-- <action>: <source> YYYY-MM-DD -->`. Each section was formerly restated in 6–7 skill bodies.
- `lsa/knowledge/**/*.md` added to `.lsa.yaml: modules.lsa.artifact_paths` so future Knowledge files are tracked by `lsa-verify` doc-mode.

### Changed
- All 8 LSA skill bodies (`lsa-init`, `lsa-discover`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-reconcile`, `lsa-revise-constitution`) — Step 1 read prose now cites `../knowledge/conventions.md` §"Read protocol" instead of inlining the `.lsa.yaml` defaults block + per-skill read protocol. Inputs cite conventions for the defaults.
- `lsa-specify/SKILL.md` — "Confirm gate definitions" section deleted; cited `../knowledge/conventions.md` §"Confirm gate types" instead.
- `lsa-sync/SKILL.md` — trace-tag format changed from `<!-- added: [feature-name] [YYYY-MM-DD] -->` to `<!-- added: <feature-name> YYYY-MM-DD -->` (unified shape per conventions.md).
- `lsa-reconcile/SKILL.md` — trace-tag format changed from `<!-- reconciled: YYYY-MM-DD -->` (no source slot) to `<!-- reconciled: drift YYYY-MM-DD -->` (with source slot, per conventions.md). Closes a round-2 finding that `reconciled` was the outlier.
- `lsa-revise-constitution/SKILL.md` — trace-tag format changed from `<!-- revised: [feature-name] [YYYY-MM-DD] -->` to `<!-- revised: <feature-name> YYYY-MM-DD -->` (unified shape).
- 6 LSA skills (`lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`) — removed the redundant `[assumption: <why>]` / `[cannot verify]` Constraints line from each. The marker convention is owned by `core/skills/ground-rules/SKILL.md` Rule 1; LSA skills cite it instead of restating.
- All 8 LSA skill frontmatter `description:` fields trimmed to ≤2 sentences (verb + trigger phrases). Implementation detail moved to skill body. Trigger phrases preserved so description-match triggering is unaffected.

### Notes
- No behavioral semantics changed. Hard/Soft Confirm gates fire identically; tag-format changes are mechanical and apply only to newly written tags.
- `lsa/.lsa.yaml` for this repo now includes `lsa/knowledge/**/*.md` under `modules.lsa.artifact_paths` so the new Knowledge surface is tracked by `lsa-verify` doc-mode.
- The "tag format change" is non-breaking: historical tags using the old shape (e.g., `<!-- added: [user-auth] [2026-05-15] -->`) remain valid in already-written specs; only new tags use the unified shape. No spec rewrite required.

## [0.2.1] — 2026-05-20

Pure DRY / SRP / KISS docs prune. No skill behavior change. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 1.

### Changed
- `ARCHITECTURE.md` — shrunk ~540 → ~145 lines. Kept §1 Purpose, §2 Directory Structure, §3 `.lsa.yaml` configuration, §4 Branch Management, §5 Resolved Decisions. Deleted §2 (8 first principles — duplicated `vision/VISION.md` §2), §4.1–§4.9 component definitions (duplicated each `SKILL.md`), §5 Workflow Phases (duplicated each `SKILL.md`), §6 Testing Policy (duplicated `vision/specs/standards/testing.md`), §7 Fact-Check Policy (duplicated `core/skills/ground-rules/SKILL.md`), §8 Constitution Revision (duplicated `lsa-revise-constitution/SKILL.md`), §10 Skills Index (duplicated `README.md`). Each deleted section's content survives at its canonical source.
- `README.md` — "Naming note" no longer lists `agents.md` (file deleted).
- `lsa/skills/lsa-init/SKILL.md` — greenfield template no longer includes `standards/agents.md` (mechanical sweep; file deleted).
- `lsa/skills/lsa-revise-constitution/SKILL.md` — Step 1 read list no longer includes `${specs_root}/standards/agents.md` (mechanical sweep; file deleted).

### Removed
- *(repo-level, not plugin-level, but listed here for traceability)* `vision/specs/standards/agents.md` deleted. The file self-declared as a digest of upstream sources; every section now lives at its canonical home (`vision/VISION.md` §2 for the eight first principles; `core/skills/ground-rules/SKILL.md` for the marker convention; `lsa/skills/lsa-specify/SKILL.md` for the gate types; `vision/VISION.md:124` for the boundary signals).

### Notes
- Out of scope for this patch: skill body deduplication (PR 2), KISS surgical edits (PR 3).
- Module specs at `vision/specs/modules/{core,lsa}/spec.md` were shrunk in the same change-set (not part of this plugin's CHANGELOG; tracked in the repo-level refactor plan).
- Repo `/CLAUDE.md` was shrunk in the same change-set; the always-on rules block now points to `core/CLAUDE.md` as the canonical source instead of restating it.

## [0.2.0] — 2026-05-20

Closes the seven Vision-alignment gaps between v0.1.1 and `vision/VISION.md` v0.4. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md`.

### Added
- `lsa/skills/lsa-discover/SKILL.md` — light three-question discovery probe at the start of every T2 and T3 task (Phase 0). T2 oral; T3 emits scratch `discovery.md` consumed by `lsa-specify`. Design §4.3.
- `lsa/skills/lsa-reconcile/SKILL.md` — absorbs direct artifact edits into module specs (Level 2.5, `vision/VISION.md:138`). Per-module hard confirm; reverse-sync in-place (class a) or append (class b); both tagged `<!-- reconciled: YYYY-MM-DD -->`. Updates `.lsa-sync-state.json` on confirm. Design §4.4.
- `lsa/hooks/hooks.json` + `lsa/hooks/session-start-drift-check.sh` — SessionStart drift-warning hook (matcher `startup`, type `command`, timeout 10s). Diffs `artifact_paths` against `.lsa-sync-state.json`'s recorded SHA per module; surfaces a one-line notice when drift is detected. Design §7.
- `.lsa.yaml` loader across every reshaped skill — `constitution`, `specs_root`, `mode` (code / docs / mixed), and per-module `{spec, artifact_paths}`. Defaults preserve v0.1.1 behavior when the file is absent. Design §6.
- Doc-mode in `lsa-verify` — when `.lsa.yaml: mode` is `docs` or `mixed`, verify diffs each module's `artifact_paths` against `main`. Tracing satisfied by (a) feature spec naming the file/dir in an AC, or (b) the diff being wholly mechanical. Design §8.
- `.lsa-sync-state.json` writer in `lsa-sync` (records HEAD SHA + ISO timestamp per touched module; preserves untouched modules' entries). Consumed by `lsa-reconcile` and the SessionStart hook. Design §7.
- Per-feature `metrics.md` writer in `lsa-verify` — emitted only on clean T3 PASS to `${specs_root}/archive/<feature>/metrics.md`; pass/fail counts for accuracy / facts-with-sources / only-required-changes. Design §9.
- Aggregate metrics row appended to `${specs_root}/metrics.md` by `lsa-sync` when per-feature `metrics.md` exists.
- Dependency note on `core` v0.2.0 (uses `core/tier-selector` upstream of T2/T3 paths). Carried in plugin description.

### Changed
- All six existing skills (`lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`) reshaped to the `core/actor-template` five-section shape: Goal / Input / Steps / Output / Constraints (replacing the historical `## Step 1 — ...`, `## Step 2 — ...` headers). Step content preserved as numbered sub-items under a single `## Steps` block, with each Step now stating its observable result. Design §5.
- Hardcoded `/CLAUDE.md` and `/specs/...` paths replaced with `${constitution}` and `${specs_root}/...` reads from `.lsa.yaml` (with defaults). Design §5.
- `lsa-init` brownfield mode scans `modules.*.artifact_paths` from `.lsa.yaml` (falling back to `/src/` when the file is absent).
- Marker convention swept to lowercase `[assumption: <why>]` and `[cannot verify]` across all 8 skills + `ARCHITECTURE.md` §7. Matches `core/skills/ground-rules/SKILL.md`. The historical `[ASSUMPTION: ...]` (uppercase) and `[INFERRED — verify]` markers are removed.
- `ARCHITECTURE.md` — major update: new §4.8/§4.9 (lsa-discover, lsa-reconcile), §4.10 (`.lsa.yaml`), Phase 0 + ad-hoc Phase Reconcile in §5, Knowledge-vs-Actor note in §7, OQ5–OQ8 in §11. Status line bumped to 0.2.0.
- `README.md` — skills table now lists all 8 skills; new "Configuration" section documents `.lsa.yaml`.
- Plugin description in `lsa/.claude-plugin/plugin.json` extended to mention all 8 skills + tier-awareness + `.lsa.yaml` configurability.

### Notes
- `.lsa.yaml` schema version is informational (`# Schema version: 1`); a future LSA major (1.x.y) will introduce a hard `schema_version: N` key if a breaking schema change is needed. v0.2.0 additions remain non-breaking.
- Claude Code's plugin manifest still does not expose a `dependencies` field. The LSA→Core dependency stays prose-only in `README.md` and `plugin.json` description (`lsa/CHANGELOG.md:21` carries forward).
- `core/registry` (the lazy-load map-not-territory skill) stays deferred — now to core v0.3.0 — per `vision/VISION.md:177`.

## [0.1.1] — 2026-05-20

### Changed
- `ARCHITECTURE.md` §2 P4 and §7 Fact-Check Policy now defer to [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) rather than restating its content. Eliminates a DRY violation against the marketplace's "core + packs" architecture (`vision/VISION.md` §3).
- `README.md` adds a **Depends on** section: install `core` before `lsa`.
- Plugin manifest `description` notes the dependency on `core`.

### Notes
- Claude Code's plugin manifest does not (as of writing) expose a `dependencies` field. The LSA→Core dependency is prose-only in `README.md` and `plugin.json` `description`. If a manifest field becomes available, adopt it in a future patch.

## [0.1.0] — 2026-05-20

First release. Migrates the six pre-vision LSA skill drafts into a proper Claude Code plugin.

### Added
- Six skills: `lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`. Each enforces a phase with explicit human gates per `ARCHITECTURE.md` §5.
- `ARCHITECTURE.md` — the LSA methodology document migrated from pre-v1 `LSA/LSA-ARCHITECTURE.md`.
- Plugin manifest at v0.1.0.

### Changed
- Migrated from `LSA/` (flat layout, repo root) to `lsa/` (plugin layout) per the marketplace's "core + packs" architecture (`vision/VISION.md` §3).
- Renamed LSA-internal `/specs/ground-rules/` → `/specs/standards/` (across 4 files) to remove name collision with Core's `ground-rules` discipline skill.
- `ARCHITECTURE.md` status updated from "Draft — Pending stress test" to "0.1.0 — Installable; pending stress test on actual project use".

[0.1.0]: https://github.com/NVZver/claude-marketplace/releases/tag/lsa-v0.1.0
