# Tasks: Show actual changes inline (LSA / Core / Helper)

> Source: `.lsa/roadmap.md:128-132`. Spec: `requirements.md` + `design.md` + `test-suites.md`.
> Branch: `feature/2026-05-22-show-changes-inline`.

## Epic sequencing (≤5 epics, parallel-safe within constraint)

The four epics ship as **three sequential PRs** with one optional fourth PR. Sequence reflects the dependency: Rule 6 must exist before consumers cite it.

### Epic 1 — `core/output` Rule 6 + `core/CLAUDE.md` checkpoint (`core` plugin)

**Depends on:** nothing.
**Blocks:** Epics 2 + 3 (they cite Rule 6 by markdown link).
**Files touched:** `core/skills/output/SKILL.md`, `core/CLAUDE.md`, `core/CHANGELOG.md`, `core/.claude-plugin/plugin.json`.
**PR shape:** one PR titled `feat(core): output Rule 6 — show changes inline (write → show → comment)`.

**Steps:**

1. **Read** the drafted Rule 6 block from `design.md` §"The new core/output Rule 6 — drafted in full".
2. **Write** the block verbatim into `core/skills/output/SKILL.md`, inserted between current Rule 5 (`## 5. Concrete (decision prompts) — *prompt voice*`) and the trailing `---` separator. Observable result per Rule 6 (now applies): full single-change block quoting the new section header (`## 6. Show changes inline — write, show, comment`) with `core/skills/output/SKILL.md:<new-line>` and the first three lines of the inserted body.
3. **Write** the new operational-checkpoint bullet into `core/CLAUDE.md` after the existing three (currently at lines 16-22 in the canonical fragment). Bullet text:
   > *"**Show changes inline.** Every write/edit/mark echoes back inline before commentary — write, show, comment. Per [`core/output`](./skills/output/SKILL.md) Rule 6."*
   Observable result: full single-change block quoting the new bullet with `core/CLAUDE.md:<new-line>`, plus the preceding bullet for context.
4. **Update** `core/CHANGELOG.md` — new entry under `## [Unreleased]` or the next minor version (suggest `core` v0.6.0):
   > *"### Added — Rule 6 *Show changes inline — write, show, comment* in `core/skills/output/SKILL.md`. Generalizes the 8-element drift block from `lsa-reconcile`. New operational checkpoint #4 in `core/CLAUDE.md`. Per `.lsa/features/2026-05-22-show-changes-inline/`."*
5. **Bump** `core/.claude-plugin/plugin.json` `"version"` to the new minor (e.g., `0.5.4 → 0.6.0`). Pre-1.0 SemVer treats a new rule as a minor.
6. **Verify** Journey 7 paths (in `test-suites.md`) pass via static read.

**Open in this epic.** Resolve OQ1 (new Rule 6 vs. Rule 4 sub-bullet) and OQ2 (7-element vs. 8-element) at User Verification 3. The draft assumes new Rule 6 + 7 elements.

### Epic 2 — LSA skill-body sweep (`lsa` plugin)

**Depends on:** Epic 1 merged (so the markdown link target exists).
**Blocks:** nothing.
**Files touched:** `lsa/skills/lsa-sync/SKILL.md`, `lsa/skills/lsa-specify/SKILL.md`, `lsa/skills/lsa-init/SKILL.md`, `lsa/skills/lsa-plan/SKILL.md`, `lsa/skills/lsa-revise-constitution/SKILL.md`, `lsa/skills/lsa-verify/SKILL.md`, `lsa/skills/lsa-discover/SKILL.md`, `lsa/CHANGELOG.md`, `lsa/.claude-plugin/plugin.json`.
**PR shape:** one PR titled `chore(lsa): sweep Observable result lines to cite output Rule 6`.

**Steps:**

1. **Read** the inventory table in `design.md` §"Inventory — current Observable result: violations" (16 violations, 6 skills).
2. For each of the 16 lines, **edit in place** — replace the existing `Observable result:` clause with the Rule-6-compliant clause per the before/after example in `design.md` §"Step B — LSA skill sweep". Each edit is a one-line touch — no surrounding-content rewrite (per `requirements.md` NF3).
3. **Verify** via static grep (per Journey 5 path 1): `grep -rn "Observable result:.*\(written\|edited\|appended\|marked\|diff shown\)" lsa/skills` returns 0 rows that don't cite Rule 6.
4. **Update** `lsa/CHANGELOG.md` — new entry under `## [Unreleased]` or the next patch version (suggest `lsa` v0.7.1):
   > *"### Changed — every `Observable result:` line in `lsa/skills/{lsa-sync,lsa-specify,lsa-init,lsa-plan,lsa-revise-constitution,lsa-verify,lsa-discover}/SKILL.md` that names a file write/edit/append/mark now cites `core/output` Rule 6 and names the quote-back format (full single-change block vs. compressed inspection table). No behavior change — output-discipline only. 16 lines touched. Per `.lsa/features/2026-05-22-show-changes-inline/`."*
5. **Bump** `lsa/.claude-plugin/plugin.json` `"version"` to the new patch.

**Coordination with row #4.** If `.lsa/roadmap.md:122-126` (row #4 — what-and-why preamble) is approved within ~1 week of this epic, fold its sweep into this PR per `design.md` §"Interaction with #4". The combined edit per Observable line is one touch, not two.

### Epic 3 — Helper constraint reference (`helper` plugin)

**Depends on:** Epic 1 merged.
**Blocks:** nothing.
**Files touched:** `helper/agents/helper.md`, `helper/CHANGELOG.md`, `helper/.claude-plugin/plugin.json`.
**PR shape:** one PR titled `chore(helper): add Constraint citing core/output Rule 6`.

**Steps:**

1. **Edit** `helper/agents/helper.md` `## Constraints` block — add one bullet (per `design.md` §"Step C"):
   > *"**Show changes inline.** When Helper grows write capabilities (currently read-only per `tools:` list), it inherits [`core/output`](../../core/skills/output/SKILL.md) Rule 6 — write, show, comment."*
2. **Update** `helper/CHANGELOG.md` — new entry under `## [Unreleased]` or the next patch version (suggest `helper` v0.2.2):
   > *"### Added — Constraint citing `core/output` Rule 6 in `helper/agents/helper.md`. Anchors the rule for future write-capable Helper versions. Per `.lsa/features/2026-05-22-show-changes-inline/`."*
3. **Bump** `helper/.claude-plugin/plugin.json` `"version"` to the new patch.

### Epic 4 (optional) — `lsa-reconcile` cross-cite + housekeeping

**Depends on:** Epic 1 merged.
**Blocks:** nothing.
**Defer-able.** Can fold into Epic 2 or ship later or skip entirely.
**Files touched:** `lsa/skills/lsa-reconcile/SKILL.md`.

**Steps:**

1. **Edit** `lsa/skills/lsa-reconcile/SKILL.md` — add a one-line forward-link near the top of `## Steps` or `## Constraints`:
   > *"The 8-element drift block below is the exemplar that [`core/output`](../../../core/skills/output/SKILL.md) Rule 6 generalizes from."*
2. **Update** `lsa/CHANGELOG.md` and bump (or fold into Epic 2's bump if shipped together).
3. **On merge**, edit `.lsa/roadmap.md` row *"Show actual changes inline (LSA / Core / Helper)"* — move from Feature Backlog to Recently merged.

## Verification gates (per `lsa-verify` flow)

- **Epic 1** — Journey 7 paths pass on static read.
- **Epic 2** — Journey 5 grep returns 0 violations; Journeys 1-4 manually validated via a roleplay session against one Standard-flow and one Extended-flow scenario per `test-suites.md`.
- **Epic 3** — static read confirms Constraint bullet present.

## Risk register

| Risk | Likelihood | Mitigation |
|------|------------|-----------|
| Epic 2 conflicts with row #4 sweep | Medium (both touch the same 6 LSA skills) | Combine into one PR if both approved within ~1 week; otherwise sequence Epic 2 first, accept the re-sweep for #4. |
| Rule 6's worked examples grow stale as templates evolve | Low | Worked examples cite `lsa-reconcile` as the source of truth — if `lsa-reconcile` evolves, the examples need a re-grounding pass. Cheap. |
| Rule count drift — other plugins start restating rule names | Low | Canonical-source rule at `core/skills/output/SKILL.md:8` already forbids this; D2 probe in `core/tests/repo-anchored.md` enforces. |
| Per-plugin SemVer bumps land out of order | Low | Epic 1 (Core) lands first; Epics 2/3 (LSA / Helper) cite the new Core version's Rule 6 via plugin-dependencies field (per `lsa/.claude-plugin/plugin.json` `"dependencies": ["core"]` already in place). |

## Sequence

```
Epic 1 (Core) ──┬─→ Epic 2 (LSA sweep)
                ├─→ Epic 3 (Helper)
                └─→ Epic 4 (optional — lsa-reconcile cross-cite)
```

Epic 1 is the only blocking PR. Epics 2 and 3 are parallel-safe once Epic 1 merges.
