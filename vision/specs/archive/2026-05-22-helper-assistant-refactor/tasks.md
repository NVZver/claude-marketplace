# Tasks: Refactor Helper from command-router to assistant

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #1.
> See `requirements.md` for ACs, `design.md` for landing surface, `test-suites.md` for verification.

Each task is sized for a **single PR**. Tasks within an epic ship together; epics ship sequentially unless marked otherwise. Branch naming per `lsa/ARCHITECTURE.md:121-126`: `feature/helper-assistant-refactor` (parent); `feature/helper-assistant-refactor-e<N>` (epic).

## Epic 1 — Agent body Steps reshape + Constraint updates

**Branch.** `feature/helper-assistant-refactor-e1`. **Covers:** AC1, AC3, AC4, AC5, AC6, AC7 (no-regression). **Depends on.** None.

### Scope

- `helper/agents/helper.md` (Steps 1, 3, 5 + description frontmatter + Constraints block confirmed unchanged)

| # | Task | Files | Verification |
|---|------|-------|--------------|
| 1.1 | **Verify Open Question #2 in `design.md`.** Read `core/skills/output/SKILL.md` in full. Confirm the "closing picker every turn" rule is **not** stated there (hypothesis in `design.md` OQ2). If it IS stated, stop and escalate scope — the change must touch `core/output` (not in this row). If not, proceed. | `core/skills/output/SKILL.md` (read-only) | One-paragraph finding committed to `design.md` as a resolution note before any edits begin. |
| 1.2 | **Reshape Steps 1, 3, 5 in `helper/agents/helper.md`** per `design.md` §"Proposed Steps reshape". Step 1 gains goal-restatement sub-step; Step 3 prefixes the answer with the Step 1 sentence; Step 5 becomes conditional ("clean end OR fork-only picker"). Each Step preserves its observable-result line. | `helper/agents/helper.md:32-36` | Re-read Steps; each has Observable; Step 5 no longer says "Close with a next-step picker" unconditionally. Run Journey 1, 3, 4, 6 from `test-suites.md` in a fresh session. |
| 1.3 | **Update the `description` frontmatter** at `helper/agents/helper.md:3` per `design.md` table. Replace *"`AskUserQuestion` for every decision"* with *"`AskUserQuestion` only for genuine forks"*. Sanity-check that auto-trigger patterns still match (per `design.md` OQ4). | `helper/agents/helper.md:3` | Probe Journey 7a / 7b — auto-engage still fires on signal (a) and (b). |
| 1.4 | **No changes to Constraints block** (`helper/agents/helper.md:46-58`) — substrate-native, cannot-ground fallback, no-persona, cooldown, etc. all preserved. Confirm by re-read. | `helper/agents/helper.md:46-58` | Visual diff of Constraints block shows no change. |

## Epic 2 — `helper/commands/help.md` no-argument behavior + knowledge update

**Branch.** `feature/helper-assistant-refactor-e2`. **Covers:** AC2 (bare `/help`), F3, knowledge migration. **Depends on.** Epic 1 lands first (the agent Step 1 must already handle a bare-prompt invocation cleanly before this epic removes the picker from the command body).

### Scope

- `helper/commands/help.md` (no-argument block rewrite + description frontmatter)
- `helper/knowledge/output-discipline.md` (new "Starter-topic examples" section migrated from `help.md`)

| # | Task | Files | Verification |
|---|------|-------|--------------|
| 2.1 | **Rewrite the "no argument" block** in `helper/commands/help.md` per `design.md` §"What changes in `helper/commands/help.md`". Replace the 3-option `AskUserQuestion` (lines 18-22) with a dispatch to `Skill(helper)` carrying an empty/"general" argument; the agent body's Step 1 (now revised in Epic 1) emits the inline prompt. | `helper/commands/help.md:16-24` | Probe Journey 2a — bare `/help` produces an inline prose prompt, no picker. |
| 2.2 | **Update command description** at `helper/commands/help.md:2`. Replace *"opens a 3-option starter-topic picker"* with *"dispatches to Helper; if no argument, Helper prompts inline for the question"*. | `helper/commands/help.md:2` | Re-read; phrasing matches the new flow. |
| 2.3 | **Migrate starter-topic examples to knowledge.** Move the 3 starter-topic phrasings (Install / Pick a skill / Explain a concept) from `helper/commands/help.md` into a new "Starter-topic examples" section of `helper/knowledge/output-discipline.md` — as *examples of questions Helper can answer*, not as a runtime picker. | `helper/knowledge/output-discipline.md` (new section), `helper/commands/help.md` (removed) | Re-read; examples are present in knowledge; absent from command body. |

## Epic 3 — `helper/knowledge/output-discipline.md` rules update

**Branch.** `feature/helper-assistant-refactor-e3`. **Covers:** AC4, F2, F4. **Depends on.** Epic 1 (must already enforce the conditional close in Steps). May ship in same PR as Epic 1 if reviewer prefers — they're tightly coupled.

### Scope

- `helper/knowledge/output-discipline.md` (closing-picker rule revision + new "Genuine fork — operating definition" section + new "Goal-restatement opening" rule + violation bullet)

| # | Task | Files | Verification |
|---|------|-------|--------------|
| 3.1 | **Revise the "Closing picker" bullet** at `helper/knowledge/output-discipline.md:20`. Replace *"Every response (except `Skill()` handoff) closes with `AskUserQuestion`"* with *"Close with `AskUserQuestion` only when a genuine fork remains after the answer (see § Genuine fork below). Otherwise end cleanly."* | `helper/knowledge/output-discipline.md:20` | Re-read; new wording present. |
| 3.2 | **Add the "Genuine fork — operating definition" section.** 3–4 test bullets (destructive action? two architecturally equivalent options? missing required input the agent cannot infer? per-row triage at scale?) — cited from `vision/VISION.md:57` (Ownership) and project memory `feedback_askuserquestion_overuse.md`. | `helper/knowledge/output-discipline.md` (new section) | Re-read; section present with concrete tests; no jargon. |
| 3.3 | **Add the "Goal-restatement opening" rule.** One short bullet stating that every Helper response opens with a goal-restatement sentence (full sentence OR half-sentence prefix for one-word questions, per Decision 2 in `design.md`). | `helper/knowledge/output-discipline.md` (new bullet under Helper-specific extensions) | Probe Journey 3a–3d; all four opening shapes pass. |
| 3.4 | **Update the "What violates discipline" section.** Add: *"A response that opens with `AskUserQuestion` instead of a cited answer (except cannot-verify per `helper/agents/helper.md` Step 3)."* | `helper/knowledge/output-discipline.md:22-29` | Re-read; bullet added. |

## Epic 4 — README + CHANGELOG + version bump

**Branch.** `feature/helper-assistant-refactor-e4`. **Covers:** AC8, NF1, NF2. **Depends on.** Epics 1–3 (the user-facing surface must already match the new behavior before the README describes it).

### Scope

- `helper/README.md` (default-flow phrasing + v0.3.0 status row)
- `helper/CHANGELOG.md` (v0.3.0 entry)
- `helper/.claude-plugin/plugin.json` (version bump)
- `README.md`, `CONTRIBUTING.md` (read-only verification — confirmed no edits needed)

| # | Task | Files | Verification |
|---|------|-------|--------------|
| 4.1 | **Update `helper/README.md:8`.** Replace *"`AskUserQuestion` for every decision"* with *"`AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs"*. | `helper/README.md:8` | Re-read; phrasing matches. |
| 4.2 | **Add a v0.3.0 row to the status table** in `helper/README.md:12-21`. Describes the answer-first refactor: agent body Steps 1/3/5 reshaped; bare `/help` prompts inline; closing picker conditional. Cite this feature dir. | `helper/README.md:12-21` | Re-read; row present. |
| 4.3 | **Add `## [0.3.0] — 2026-05-23` entry to `helper/CHANGELOG.md`** in Keep a Changelog format. Highlights: answer-first default; conditional closing pickers; bare `/help` prompts inline. Cite `vision/specs/roadmap.md:104-108`. | `helper/CHANGELOG.md` | Re-read; entry present at top below header. |
| 4.4 | **Bump version in `helper/.claude-plugin/plugin.json`** to `0.3.0`. | `helper/.claude-plugin/plugin.json` (`version` field) | `jq '.version' helper/.claude-plugin/plugin.json` returns `"0.3.0"`. |
| 4.5 | **Verify no other user-facing surface changed.** Search repo root `README.md` and `CONTRIBUTING.md` for Helper references; confirm no edits needed (root README does not describe Helper's default flow). | `README.md`, `CONTRIBUTING.md` (read-only) | One-line confirmation in PR description. |

## Epic 5 — Manual verification + sync

**Branch.** `feature/helper-assistant-refactor` (parent) after epics 1–4 merge in.
**Covers:** All ACs end-to-end. **Depends on.** Epics 1–4.

### Scope

- (no artifact edits — runs `lsa-verify` + `lsa-sync` skills against the merged feature branch; on sync, `vision/specs/features/2026-05-22-helper-assistant-refactor/` moves to `vision/specs/archive/...`)
- Optional: `vision/specs/features/2026-05-22-helper-assistant-refactor/verify-run.md` (probe outcomes log)

| # | Task | Files | Verification |
|---|------|-------|--------------|
| 5.1 | **Run every Journey in `test-suites.md` (1–9)** in a fresh Claude Code session. Record outcomes per AC. Any FAIL kicks back to the responsible epic. | (probes only) | A `verify-run.md` (or PR comment) with each Journey's outcome. |
| 5.2 | **Run `lsa-verify`** on the feature branch. Confirm every change in `helper/agents/helper.md`, `helper/commands/help.md`, `helper/knowledge/output-discipline.md`, `helper/README.md`, `helper/CHANGELOG.md`, `helper/.claude-plugin/plugin.json` traces to an AC in this `requirements.md`. | (skill invocation) | Verify report: `✅ PASS` per `lsa/skills/lsa-verify/SKILL.md`. |
| 5.3 | **Run `lsa-sync`** to merge this feature into the permanent module specs and archive the feature dir. Per `lsa/skills/lsa-sync/SKILL.md`. | `vision/specs/modules/helper/spec.md` (if exists) OR new, plus archive | Feature dir at `vision/specs/features/2026-05-22-helper-assistant-refactor/` moves to `vision/specs/archive/2026-05-22-helper-assistant-refactor/`. |
| 5.4 | **Open PR to `main`.** PR title: *"feat(helper): answer-first refactor — picker becomes optional (v0.3.0)"*. Body links this feature dir + the roadmap row. Per `CONTRIBUTING.md`. | (PR creation) | PR linked from the row in `vision/specs/roadmap.md:36`; row status updated to "shipped — helper v0.3.0". |

## Epic 6 — Roadmap status update on merge

**Branch.** `feature/helper-assistant-refactor` (parent), final commit before / with merge.
**Covers:** Roadmap living-document discipline (NF2 — Living READMEs / roadmap is a living document per `CLAUDE.md` §"Discipline (sourced)"). **Depends on.** Epic 5.

### Scope

- `vision/specs/roadmap.md` (move the row "Refactor Helper from command-router to assistant" from Feature Backlog to Recently merged)

| # | Task | Files | Verification |
|---|------|-------|--------------|
| 6.1 | On merge, edit `vision/specs/roadmap.md` row "Refactor Helper from command-router to assistant" — move from Feature Backlog to Recently merged. One-line edit. | `vision/specs/roadmap.md` (row currently at line 33 of Feature Backlog table) | Row is absent from Feature Backlog; new entry appears in Recently merged with `helper` v0.3.0 highlights. |

## Dependencies on / from other rows

- **From row #2** (`vision/specs/features/2026-05-22-helper-onboarding-fast-path/`) — independent. Can ship in either order. If #2 lands first against current Helper, the closing picker stays mandatory; once this refactor lands, #2's fast-path inherits the new conditional close automatically.
- **From row #3** (`vision/specs/features/2026-05-22-askuserquestion-audit/`) — row #3 benefits from this refactor landing first (so it has a "genuine fork" definition to cite). Helper-side audit is substantially completed here; row #3's remaining work is LSA-wide.
- **From row #5** (`vision/specs/features/2026-05-22-show-changes-inline/`) — orthogonal. Helper does not edit files, so the *write → show → comment* rule applies only to Helper's `Skill()` handoff branch (where the *invoked skill* edits files, not Helper). Per `vision/specs/roadmap.md:130-132`.
- **From row #6** (`vision/specs/features/2026-05-22-custom-inventions-sweep/`) — orthogonal. The "no closing picker" rule is not a custom invention; it's a removal of one.
- **Upstream** — none. No `core/` or `lsa/` dependency.

## Open Questions

1. **Should Epics 1 and 3 ship as one PR?** They're tightly coupled (Steps + the discipline file that defines the rules the Steps cite). Spec keeps them separate for review hygiene; implementer may consolidate.
2. **Should Epic 5.3 (`lsa-sync`) run before or after PR merge?** Per `lsa/skills/lsa-sync/SKILL.md` it runs after `lsa-verify` PASS and before merging to main. Sequence above follows that. If the repo convention has shifted, adjust.
3. **Is there a `vision/specs/modules/helper/spec.md` to update on sync?** The module index at `vision/specs/main.spec.md:14-18` lists only `core` and `lsa`. Helper may be implicit (per `vision/specs/features/2026-05-21-helper-agent/`). `lsa-sync` will surface this; if a module spec needs creation, that becomes a fresh task — out of scope for this row's PRs.
