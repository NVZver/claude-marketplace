# Design: Show actual changes inline (LSA / Core / Helper)

> Source: `vision/specs/roadmap.md:128-132` §"2026-05-22 backlog detail" #5.
> Requirements: `vision/specs/features/2026-05-22-show-changes-inline/requirements.md`.

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `core` (`core/skills/output/SKILL.md`) | **Add** — new Rule 6 *"Show changes inline — write, show, comment"*. |
| `core` (`core/CLAUDE.md`) | **Modify** — add a fourth operational checkpoint citing Rule 6, alongside the existing three (`core/CLAUDE.md` lines covering substrate-native pickers / 1–1.5 screen budget / file-load trace). |
| `lsa` (seven skill bodies) | **Modify** — sweep every `Observable result:` line whose action is a file write/edit/append/mark, naming what is quoted back per Rule 6. Skills touched: `lsa-sync`, `lsa-specify`, `lsa-init`, `lsa-plan`, `lsa-revise-constitution`, `lsa-verify` (metrics write only), `lsa-discover` (scratch `discovery.md` write at line 47 — still user-visible, still in scope). `lsa-reconcile` is excluded — it is the exemplar that sets the bar. |
| `helper` (`helper/agents/helper.md`) | **Modify** — add a Constraint citing Rule 6 by markdown link. Helper is read-only today (no file writes), but the constraint anchors the rule in the agent for when Helper grows write capabilities, and reinforces the existing answer-shape (every cited claim already obeys Rule 4 / Rule 6). |
| Per-plugin `CHANGELOG.md` | **Modify** — one entry per touched plugin (`core`, `lsa`, `helper`) per `CLAUDE.md` *"Per-plugin SemVer + CHANGELOG"*. |
| Per-plugin `plugin.json` | **Modify** — SemVer bump per `CLAUDE.md` discipline (likely `core` minor, `lsa` patch, `helper` patch). |
| Per-plugin `README.md` + root `README.md` | **Modify only if user-visible** — likely no change; the rule is an internal output discipline, not a new user-facing surface. (Per `CLAUDE.md` *"Pure refactors with no user-visible delta are exempt"*.) |

## Technical Approach

### The new `core/output` Rule 6 — drafted in full

The block below is **copy-paste-ready** into `core/skills/output/SKILL.md` immediately after Rule 5. The implementor inserts it verbatim; the only tweak expected is renumbering if a different rule lands first.

````markdown
## 6. Show changes inline — write, show, comment

Every write, edit, or mark performed by an agent is **echoed back inline** before any commentary. The order is **write → show → comment** — never *"I added X to file Y; here's why it matters."* without quoting X first.

This rule generalizes the 8-element drift block already in use by [`lsa-reconcile`](../../../lsa/skills/lsa-reconcile/SKILL.md), which the user endorsed as the gold standard: *"Good! Love it!"* (2026-05-22).

### Single-change template

For one edit to one file, the response contains, in order:

1. **What changed** — one phrase naming the action (added / edited / replaced / appended / marked).
2. **Where** — the file path with the precise line range, as `path:line` or `path:line-range`.
3. **Previous content** (if the change replaces existing content) — quoted verbatim in a fenced code block, with the source line range above it.
4. **New content** — quoted verbatim in a fenced code block, with the destination line range above it.
5. **Reason** — one sentence in the human's frame: *why* this change happened (the user's request, the spec line, the discovered drift). No agent-vocabulary verbs without a one-clause gloss.
6. **Source** — a `file:line` (or URL) for the authority that justified the change. Inherits Rule 4 (Sourced).
7. **Type tag** — one of `add` / `edit` / `replace` / `append` / `mark`, so the human can skim a sequence of changes by type.

Combined, the seven elements line up with the eight-element drift block at [`lsa-reconcile`](../../../lsa/skills/lsa-reconcile/SKILL.md) (the eighth — *bundle-explanation* — collapses into element 5 here when the change is not part of a multi-module batch).

### Batch template — compressed inspection table

When a single turn produces more than ~5 file changes or more than ~10 lines of new content, full single-change blocks blow the 1–1.5-screen budget (Rule 2). Replace them with a **compressed inspection table**:

| # | file:line | type | summary (≤8 words) | pointer |
|---|-----------|------|--------------------|---------|
| 1 | `lsa/skills/lsa-sync/SKILL.md:67` | edit | Observable result names quoted-diff format | step 3 |
| 2 | `lsa/skills/lsa-sync/SKILL.md:74` | edit | Observable result names quoted-diff format | step 4 |

After the table: one cluster of follow-up `file:line` pointers the human can open. **Never** *"see the files for the rest."* The table itself *is* the quote-back.

### What this rule forbids

- *"I added X to file Y"* without the verbatim X.
- *"Marked OQ5 as resolved"* without the new line content.
- *"Observable result: file is edited"* / *"diff shown"* without naming whether the diff is full-quote or compressed-table.
- *"go check the file"* / *"see file for details"* in any form.

### Worked examples

**Example 1 — single-file edit (a typo fix).**

> *Edited `core/skills/output/SKILL.md:32` — single line.*
>
> *Previous (line 32):*
> ```markdown
> ## 5. Concrete (decision prompts) — *prompt voce*
> ```
>
> *New (line 32):*
> ```markdown
> ## 5. Concrete (decision prompts) — *prompt voice*
> ```
>
> *Reason: fixing the typo flagged in the 2026-05-22 review pass.*
> *Source: user 2026-05-22.*
> *Type: `edit`.*

**Example 2 — multi-file batch write (this feature's own implementation).**

| # | file:line | type | summary | pointer |
|---|-----------|------|---------|---------|
| 1 | `core/skills/output/SKILL.md:42-90` | add | Rule 6 *Show changes inline* | new section |
| 2 | `core/CLAUDE.md:18` | edit | Operational checkpoint #4 cites Rule 6 | inline |
| 3 | `lsa/skills/lsa-sync/SKILL.md:67` | edit | Observable result names quoted-diff format | step 3 |
| 4 | `lsa/skills/lsa-sync/SKILL.md:74` | edit | Observable result names quoted-diff format | step 4 |
| 5 | `lsa/skills/lsa-specify/SKILL.md:99` | edit | Observable result names quoted-section format | step 4 |

*Reason: lands the `core/output` Rule 6 + LSA sweep per `vision/specs/features/2026-05-22-show-changes-inline/tasks.md` step 1-2. Source: `vision/specs/roadmap.md:128-132`. Type: `batch` (`add` + `edit` mix).*

**Example 3 — state mark.**

> *Marked **OQ5** as resolved in `vision/specs/features/2026-05-22-show-changes-inline/design.md:118`.*
>
> *Previous (line 118):*
> ```markdown
> - **OQ5** — Do we backfill archive specs under `vision/specs/archive/`?
> ```
>
> *New (line 118):*
> ```markdown
> - **OQ5** — Do we backfill archive specs under `vision/specs/archive/`? **Resolved 2026-05-23: no — per archive-files-don't-rewrite rule (`vision/specs/roadmap.md:48`).**
> ```
>
> *Reason: human picked `[b] no backfill` at User Verification 3. Source: this session 2026-05-23. Type: `mark`.*

### Inheritance & inheritance gaps

- **Inherits Rule 2 (Minimal).** The batch template is the explicit escape valve when full single-change blocks would blow the budget.
- **Inherits Rule 4 (Sourced).** Every change carries a `file:line` source per element 6.
- **Inherits Rule 5 (Concrete).** The reason (element 5) names the subject in the human's frame, not the spec ID.
- **Composes with Rule 3 (Formatted).** Single-change blocks use fenced code; batch blocks use markdown tables. Match the affordance to the content.

````

### Why this rule, not a tweak to Rule 4

Rule 4 (Sourced) governs *evidence under claims*. Rule 6 governs *evidence under actions*. The two are orthogonal: an answer to *"what does X do?"* is a Rule 4 case (cite the source); an action *"I edited X"* is a Rule 6 case (show the new content). The user's 2026-05-22 emphatic feedback specifically targets the actions — *"they say 'I put something in a file...' and make the user to go and search"* — Rule 4 alone doesn't cover this because the missing evidence is the *agent's own write*, not an external source.

## Inventory — current `Observable result:` violations

Surfaced by `grep -n "Observable result:" lsa/skills core/skills` (52 total `Observable result:` lines repo-wide). The table below lists every one that names a write/edit/append/mark without naming what is quoted back. The exemplar (`lsa-reconcile`) is excluded from the violation list.

| # | file:line | Current violation phrase | Type |
|---|-----------|-------------------------|------|
| 1 | `lsa/skills/lsa-sync/SKILL.md:59` | *"delta written to scratch; human approval logged."* | edit — names file mutation, no quoted content |
| 2 | `lsa/skills/lsa-sync/SKILL.md:67` | *"per-module diff shown."* | edit — *"diff shown"* without format (full / compressed) |
| 3 | `lsa/skills/lsa-sync/SKILL.md:74` | *"`${specs_root}/main.spec.md` updated; diff shown."* | edit — *"diff shown"* without format |
| 4 | `lsa/skills/lsa-sync/SKILL.md:82` | *"archive directory exists at the new path; original is gone."* | mark — names mutation, no quoted result |
| 5 | `lsa/skills/lsa-sync/SKILL.md:97` | *"the file contains a fresh SHA + ISO timestamp per touched module."* | edit (`.lsa-sync-state.json`) — no JSON fragment quoted |
| 6 | `lsa/skills/lsa-sync/SKILL.md:99` | *"aggregate file has the new row."* | append — no row quoted |
| 7 | `lsa/skills/lsa-specify/SKILL.md:53` | *"directory and branch both exist."* | mark — names mutation, no echo of branch / dir name |
| 8 | `lsa/skills/lsa-specify/SKILL.md:99` | *"`requirements.md` exists; contract-trigger logged; human approval logged."* | write — no requirements section quoted |
| 9 | `lsa/skills/lsa-specify/SKILL.md:204` | *"three files exist (or contract skip-note logged); diagonal coverage table rendered."* | write — *"three files exist"* without quoting |
| 10 | `lsa/skills/lsa-init/SKILL.md:60` | *"the spec tree exists on disk after approval; the human confirms the skeleton."* | write — no tree quoted |
| 11 | `lsa/skills/lsa-init/SKILL.md:101` | *"the three files exist with the templates above."* | write — no per-file quote |
| 12 | `lsa/skills/lsa-plan/SKILL.md:112` | *"`${specs_root}/features/<feature-name>/tasks.md` exists."* | write — no tasks table quoted |
| 13 | `lsa/skills/lsa-revise-constitution/SKILL.md:67` | *"diff shown per file."* | edit — *"diff shown"* without format |
| 14 | `lsa/skills/lsa-revise-constitution/SKILL.md:77` | *"branch + commit exist."* | mark — names mutation, no quoted commit message |
| 15 | `lsa/skills/lsa-verify/SKILL.md:118` | *"`metrics.md` exists when the gate is clean PASS; absent otherwise."* | **borderline — candidate; verify implementor intent.** Conditional file-existence assertion (write iff PASS), not a per-turn unconditional write. Two reads: (a) treat as a write step → still apply Rule 6 (quote the `metrics.md` body when emitted); (b) treat as a verdict-gate side effect → out of scope, leave as-is. Recommend (a) — cheap, and matches F4 (mark-with-quoted-content). Confirm at PR-β review. |
| 16 | `lsa/skills/lsa-discover/SKILL.md:47` | *"`discovery.md` exists; the handoff is invoked."* | write — no discovery block quoted (scratch file but still user-visible) |

**Totals: 16 violations across 7 LSA skills.** `lsa-reconcile` (exemplar) is clean. `lsa-discover`'s Standard branch (line 35) is clean — its single Extended-branch write at line 47 is in the inventory. `core/skills/` (4 skills) and `helper/agents/` (1 agent) have **0 violations** — they don't write files in the violating shape today. The sweep is therefore LSA-only.

**Indicator-pattern assumption.** This audit assumes write/edit/mark actions in skill bodies always appear under an `Observable result:` line per the actor-template convention. Prose writes outside this convention would be missed; sample inspection found none.

### Violations split by plugin

| Plugin | Skills audited | Skills with violations | Total `Observable result:` lines | Violation lines |
|--------|----------------|------------------------|----------------------------------|-----------------|
| `core` | 4 | 0 | 8 | 0 |
| `lsa` | 8 | 7 | 41 | 16 |
| `helper` | 1 agent (no skills) | 0 | n/a (agent has different shape) | 0 |
| **Total** | **13** | **7** | **49** | **16** |

The single Core skill that demos a write (`core/skills/actor-template/SKILL.md:32` — *"three bullets written to the output, each ≤ 1 line"*) is a demo template, not a real write step; it already quotes the bullets back implicitly via the worked example structure.

## Skill-body sweep plan

The sweep follows a strict order: ship Rule 6 first, then sweep the consumers. Each step lands as its own PR (or its own commit cluster within one feature PR — see `tasks.md`).

### Step A — Land Rule 6 in `core/skills/output/SKILL.md` (single Core PR)

- Insert the drafted block above as Rule 6, between current Rule 5 and the trailing `---` separator.
- Add a fourth operational-checkpoint bullet in `core/CLAUDE.md` (after the existing three at lines 16-22) citing Rule 6 by markdown link.
- `core/CHANGELOG.md` entry; `core/.claude-plugin/plugin.json` minor bump (new rule = minor in pre-1.0 per `CLAUDE.md` SemVer discipline).
- `core/README.md` — likely no surface change (rule count is internal to the canonical file per `core/skills/output/SKILL.md:8`).

### Step B — LSA skill sweep (single LSA PR)

- Touch the 16 lines in the inventory above. Each touch follows the same shape: replace the existing *"Observable result: X exists / diff shown"* line with a new line naming what is quoted back, and add a one-sentence reference to Rule 6 at the head of the relevant step.
- Example before/after for `lsa-sync/SKILL.md:67`:
  - **Before:** *"Observable result: per-module diff shown."*
  - **After:** *"Observable result: per-module diff shown inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 6 — full single-change block when the merge is ≤10 lines, compressed inspection table when larger."*
- `lsa/CHANGELOG.md` entry; `lsa/.claude-plugin/plugin.json` patch bump (no behavior change, just output discipline).
- `lsa/README.md` — no change (skill listing is unchanged; the user-visible shape change is per-skill output, not the plugin surface).

### Step C — Helper constraint reference (single Helper PR)

- Add one Constraint bullet to `helper/agents/helper.md` `## Constraints`:
  *"**Show changes inline** — when Helper grows write capabilities (currently read-only per `tools:` list), it inherits [`core/output`](../../core/skills/output/SKILL.md) Rule 6 — write, show, comment."*
- `helper/CHANGELOG.md` entry; `helper/.claude-plugin/plugin.json` patch bump.

### Step D — `lsa-reconcile` cross-cite (optional, defer-able)

- Optional housekeeping: add a forward-link from `lsa/skills/lsa-reconcile/SKILL.md` to the new Rule 6, noting *"the 8-element format below is the exemplar Rule 6 generalizes from."* No behavior change. Can be folded into Step B or deferred.

## Interaction with #4 (`LSA: what-and-why preamble`)

`vision/specs/roadmap.md:122-126` (row #4) wants a *what-LSA-is-doing-and-why-it-matters* preamble before every verb-headline. This row (#5) wants a *quote-the-actual-content* echo after every write.

**Boundary.** #4 governs the *framing of an action* (`What this means: I'm bumping the SHA so reconcile doesn't replay this delta`). #5 governs the *content of a change* (`Here is the new SHA line in .lsa-sync-state.json`). They compose: a complete output is `<what+why preamble> → <verb-headline + action> → <quoted change> → <commentary>`. The five-element ordering is consistent and non-overlapping.

**Proposal (not unilateral).** Propose combining the LSA-sweep portion of PR-β with row #4's sweep if both rows reach implementation in the same cycle. Confirm with row #4 implementor; row #4's spec (`vision/specs/features/2026-05-22-lsa-what-why-preamble/design.md` §"Interaction with roadmap row #5") currently prefers independent sequencing — *"Row #4 ships first because (a) it has fewer affected sites, (b) the gold reference is already concrete, (c) the format rule is short."* Reasoning for the combine option, if accepted:

- Both #4 and #5 touch every LSA skill body. Two sweeps over the same 7 files within weeks doubles the merge-conflict surface and the review burden.
- The combined edit per `Observable result:` line is short — adding both a preamble sentence and a quote-back clause is one edit, not two.
- If #4 is rejected or deferred, #5 ships standalone (this design covers that case).

**Concrete sequencing (default).** Land Rule 7 (this row's slot, Step A above) standalone first. Then ship Step B (LSA sweep) per row #4's preferred order — row #4's preamble sweep first, then this row's quote-back sweep as a second pass. The combine option is the *opportunistic* path, not the default.

### Rule numbering coordination with row #4

Row #4 (`vision/specs/features/2026-05-22-lsa-what-why-preamble/`) is moving from "sub-bullet under Rule 5" to "new Rule 6" per its audit-driven decision. Both rows can't both be Rule 6.

**Recommended order — defensible by ship sequence:**

- **Rule 6 = row #4 preamble (*"What-and-why before the verdict"*)** — ships first per row #4's stated sequencing; lands as the next number after Rule 5.
- **Rule 7 = row #5 write-show-comment (*"Show changes inline"*)** — ships second; lands as Rule 7 in the same canonical file.

Implementor for this row (#5): if row #4 has merged into `core/skills/output/SKILL.md` by the time Step A here begins, insert the drafted block as **Rule 7**, not Rule 6. If row #4 has not yet merged, insert as Rule 6 and row #4's implementor renumbers their landing to Rule 6 (sequencing flips). The drafted block above and all citations in this feature dir use *Rule 6* as a placeholder for "the new rule landing in `core/output`"; renumber to *Rule 7* at implementation time if row #4 has already landed.

## Cross-row sequencing notes

- **Helper Constraint bullet (vs. rows #1 + #2).** This row's edit to `helper/agents/helper.md` is **additive** — it appends one bullet to the `## Constraints` section. Row #1 (Helper assistant refactor) reshapes Steps 1, 3, 5 of the same file; row #2 (fast-path) adds Step 1.5. Different sections, no overlap. This row's Helper edit can rebase onto either, both, or neither of rows #1/#2 cleanly. No sequencing dependency.
- **`lsa-sync:97` line-shift risk (vs. row #6 T2).** Row #6 T2 (`.lsa-sync-state.json` removal) edits `lsa/skills/lsa-sync/SKILL.md:84-95` — adjacent to this plan's `lsa-sync:97` inventory citation (`.lsa-sync-state.json` SHA bump). If row #6 T2 lands first, the line number may shift or the violation may disappear entirely (if the `.lsa-sync-state.json` step is removed). **Implementor action:** before PR-β, re-verify line `:97` and the surrounding step still exist; if removed by row #6 T2, drop inventory row 5 and recount (15 violations across 6 or 7 LSA skills, depending on whether other lsa-sync rows survive).

## Data Model Changes

None. This is an output-discipline rule; it introduces no new file types, no new state files, no new schema. Per `requirements.md` Out-of-Scope.

## API / Interface Changes

None at the substrate or plugin-manifest level. The rule changes what a skill *prints*, not its inputs / outputs / tools.

## Cross-Module Contracts

- `core/skills/output/SKILL.md` ↔ all consumers — Rule 6 is the new canonical clause; consumers cite by markdown link per the existing canonical-source rule at `core/skills/output/SKILL.md:8` (*"They MUST NOT restate the rule count or rule names outside this file (citation by markdown link only)."*).
- `core/CLAUDE.md` ↔ all consumers — the new fourth operational checkpoint joins the existing three.

## Open Questions

- **OQ1** — *Should Rule 6 be the new Rule 6, or replace Rule 4's last paragraph?* Recommendation: new Rule 6 (the actions-vs-claims orthogonality argument above). The five existing rules stay numbered 1-5. Alternative: fold into Rule 4 as a sub-bullet — but that hides the visibility the user explicitly demanded ("THAT IS TERRIBLE USER EXPERIENCE!" implies the rule should be visible at top-level).
- **OQ2** — *Single-change template element count: 7 or 8?* The `lsa-reconcile` exemplar has 8; this draft has 7 (the eighth — *bundle-explanation* — collapses into element 5 for single-change cases). Going to 8 keeps perfect parity with the exemplar but adds an element that is always-empty for single edits. Recommendation: keep at 7; cite `lsa-reconcile`'s 8 as the multi-module-batch superset.
- **OQ3** — *Does Rule 6 apply to scratch-file writes (e.g., `lsa-discover`'s `discovery.md`)?* The roadmap says *"every skill that writes / edits / marks anything"* — scratch is still a write. Recommendation: yes — applies. Cheap; helps users verify what `lsa-discover` captured.
- **OQ4** — *Compressed-table threshold: ~5 files or ~10 lines — which fires first?* Either-or — whichever is hit first triggers the table. Recommendation: ship as "either-or"; refine after dogfooding.
- **OQ5** — *Worked-example #3 ("Marked OQ5 as resolved") is meta — should the example be drawn from real LSA flows (e.g., User Verification approval logged) for less recursion?* Recommendation: keep the meta example — it directly maps to the user's verbatim complaint (*"marked OQ5 as resolved"* is the user's own phrasing in the roadmap citation).
- **OQ6** — *Does the rule apply to `lsa-verify`'s PASS/FAIL gate output (which doesn't write files in the violating cases)?* Recommendation: no — the gate output is already a structured verdict block per the verdict labels in `core/knowledge/output-vocabulary.md` §"Verdicts" (cited by `core/skills/output/SKILL.md:46`), not a write step. Out of scope unless a verify failure produces a state mark.
- **OQ7** — *Should the rule cite Mavin EARS or any external standard for legitimacy?* Recommendation: no — the rule's authority is the user's verbatim 2026-05-22 feedback plus the in-repo `lsa-reconcile` exemplar. External citations would dilute the make-you-own-it framing.
