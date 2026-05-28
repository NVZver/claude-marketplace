# Tasks: Audit + tighten `AskUserQuestion` call sites (Helper + LSA)

> Source: `.lsa/roadmap.md` §"2026-05-22 backlog detail" #3 (`.lsa/roadmap.md:116-120`).
> Sequenced per `design.md` §"Technical Approach" and §"Interaction with backlog #1".

## Sequencing summary

1. **PR-A (`core`)** — rubric publication. Ships first.
2. **PR-B (`lsa`)** — 13 LSA call-site verdicts applied. Independent of Helper. Can ship in parallel with PR-A iff PR-A's draft text is final.
3. **PR-C (`helper`)** — 4 Helper call-site verdicts applied. Ships **after** backlog #1 (Helper command-router refactor) merges — otherwise #1 re-introduces removed pickers. **Confirmed:** this PR blocks on backlog #1 per `design.md` §"Interaction with backlog #1" and §"Technical Approach" item 3.

**Total: 29 tasks across 4 epics** (Epic A: 6, Epic B: 7, Epic C: 8, Epic D: 8).

If backlog #1 is delayed >2 weeks, PR-C may ship in parallel with a rebase plan documented in the PR description (see OQ in `design.md` if needed).

---

## Epic A — `core/output` Rule 5 "Genuine-fork test" sub-rule

**Owner:** `core` plugin.
**Branch:** `feat/core-output-genuine-fork-test`.

| # | Task | File(s) | Verify |
|---|------|---------|--------|
| A1 | Add "Genuine-fork test" sub-bullet under Rule 5, ≤6 lines body copy, citing `.lsa/VISION.md:66` | `core/skills/output/SKILL.md` ~line 40 | Journey 5 Path 1 |
| A2 | Clarify `core/CLAUDE.md` operational checkpoint #1 — append one line stating this checkpoint is downstream of Rule 5 sub-rule | `core/CLAUDE.md` checkpoint #1 | Journey 5 Path 2 |
| A3 | Bump `core/plugin.json` minor version | `core/.claude-plugin/plugin.json` (or wherever `plugin.json` lives in `core`) | `git diff` shows version bump |
| A4 | Add `core/CHANGELOG.md` entry under new minor — describe Rule 5 sub-rule, cite this feature directory | `core/CHANGELOG.md` | Keep-a-Changelog format check |
| A5 | Update `README.md` (root) only if user-visible surface changed — check whether the always-on rules section needs a mention; likely no edit needed since `core/output` link is already there | `README.md` | Skim post-edit |
| A6 | Open PR. Description includes: link to this feature dir, the proposed sub-rule text verbatim, the OQ1 sub-rule-naming question for reviewers | GitHub PR | PR opened against `main` |

---

## Epic B — LSA call-site verdicts (per inventory rows L1–L15)

**Owner:** `lsa` plugin.
**Branch:** `feat/lsa-askuserquestion-audit`.
**Depends on:** PR-A merged (so the Rule 5 sub-rule citation is live).

| # | Task | File(s) | Verdict from inventory | Verify |
|---|------|---------|------------------------|--------|
| B1 | Tighten L2 — `lsa-discover` per-line picker skips when N=1 candidate AND no `custom`. Silence-on-a-line semantics extended explicitly | `lsa/skills/lsa-discover/SKILL.md:26-33` | `keep + tighten` | Journey 4 |
| B2 | Convert L12 — `lsa-sync` post-completion PR-or-hold picker becomes optional closing offer with `hold` as silent-default | `lsa/skills/lsa-sync/SKILL.md:131` | `convert-to-closing-offer` | Manual roleplay: run `/lsa:sync` end-to-end |
| B3 | Verify L1, L3–L11, L13–L15 are `keep` — read each in context, confirm verdict; add no-op comment in `tasks.md` confirming pass | (read-only across 8 skills) | `keep` | Journey 6 |
| B4 | Bump `lsa/plugin.json` minor version (B1 is user-visible behavior change) | `lsa/.claude-plugin/plugin.json` | `git diff` shows bump |
| B5 | Add `lsa/CHANGELOG.md` entry — describe B1 + B2; cite this feature dir | `lsa/CHANGELOG.md` | Keep-a-Changelog format |
| B6 | Update `lsa/README.md` if skill-table behavior changed — likely a one-liner under `lsa-discover` and `lsa-sync` | `lsa/README.md` | Skim post-edit |
| B7 | Open PR. Description includes inventory table excerpt for LSA rows, citations to verdicts | GitHub PR | PR opened |

---

## Epic C — Helper call-site verdicts (per inventory rows H1–H5)

**Owner:** `helper` plugin.
**Branch:** `feat/helper-askuserquestion-audit`.
**Depends on:** PR-A merged AND backlog #1 Helper refactor merged.

| # | Task | File(s) | Verdict from inventory | Verify |
|---|------|---------|------------------------|--------|
| C1 | Verify H1, H2, H4 remain `keep` after backlog #1 lands — read each, confirm verdict still applies | `helper/agents/helper.md:34-35`, `helper/commands/help.md:18` | `keep` | Manual read |
| C2 | Convert H3 — closing picker becomes optional. Edit Step 5 wording: *"Close with a next-step picker WHEN a real next step exists; otherwise close with no picker."* Cite the new `core/output` Rule 5 sub-rule | `helper/agents/helper.md:36` | `convert-to-closing-offer` | Journey 3 |
| C3 | Relax `helper/knowledge/output-discipline.md:20` — change *"every response (except `Skill()` handoff) closes with `AskUserQuestion`"* to *"close with `AskUserQuestion` when a real next step exists; otherwise close with no picker"* | `helper/knowledge/output-discipline.md:20` | (binding rule fix) | Journey 3 |
| C4 | Cross-check `friction-signals.md` cooldown bookkeeping is unaffected — Helper still listens for `AskUserQuestion → No` to cooldown, that signal now simply may not fire if no picker opens. Add 1-line note: "If Step 5 closes without a picker, no cooldown event is recorded; cooldown applies per-picker." | `helper/knowledge/friction-signals.md:29-30` | (clarifying note) | Manual read |
| C5 | Bump `helper/plugin.json` minor version (C2 is user-visible) | `helper/.claude-plugin/plugin.json` | `git diff` shows bump |
| C6 | Add `helper/CHANGELOG.md` entry — describe C2 + C3 + C4; cite this feature dir + backlog #1 sequencing dependency | `helper/CHANGELOG.md` | Keep-a-Changelog format |
| C7 | Update `helper/README.md` if the Helper response-shape contract is mentioned there — likely yes (closing picker is part of the visible discipline) | `helper/README.md` | Skim post-edit |
| C8 | Open PR. Description includes inventory rows H1–H5 + sequencing note (after #1) | GitHub PR | PR opened |

---

## Epic D — Verification + sync

| # | Task | Verify |
|---|------|--------|
| D1 | After all three PRs merged, run `grep -rn "AskUserQuestion" helper/ lsa/skills/ core/skills/` and reconcile every hit against the final inventory | Journey 1 Path 1 |
| D2 | Second-reviewer blind classification pass | Journey 2 |
| D3 | Roleplay Journey 3 (`/help "how do I install LSA?"`) | AC2 |
| D4 | Roleplay Journey 4 (`/lsa:discover` single-candidate case) | AC3 |
| D5 | Roleplay Journey 6 (destructive gates still fire) | AC5 inverse |
| D6 | Run `lsa-verify` against feature branch (each PR's branch separately, since each plugin has its own SemVer) | `lsa-verify` PASS |
| D7 | Run `lsa-sync` to absorb feature into module specs | `.lsa/main.spec.md` updated; feature archived |
| D8 | If new constitution-level rule emerged (likely no — Rule 5 sub-rule sits inside `core/output`, not `.lsa/VISION.md`), trigger `lsa-revise-constitution` | Decided at D7 time |
| D9 | On merge, edit `.lsa/roadmap.md` row "Audit + tighten `AskUserQuestion` call sites (Helper + LSA)" — move from Feature Backlog to Recently merged | `.lsa/roadmap.md` row moved |

---

## Open Questions (from design.md)

Reproduced here for task-time triage; resolutions land in PR-A code review.

- **OQ1.** Sub-rule name: "Genuine-fork test" vs "Real-fork test" vs "Fork-existence test".
- **OQ2.** Closing-offer cap — forbid TWO offers in one turn?
- **OQ3.** B1 minor vs patch bump.
- **OQ4.** `output-discipline.md:20` delete vs relax (planned: relax per C3).
- **OQ5.** L12 silent-default `hold` (planned: yes per B2).
- **OQ6.** VISION-citation-refresh sweep — ride along on PR-A or defer to `lsa-reconcile`? (Default: piggyback on PR-A.)
