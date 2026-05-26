# Test Suites: Management Plugin — Project Manager Agent

## Journey: Decide what to work on next

**Goal:** The user has multiple backlog items and wants to know what to pick next, with rationale grounded in dependencies, risk, and value.
**Covers:** AC1

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — multiple candidates | user invokes `management:roadmap` → agent reads roadmap, finds 3+ backlog items → agent presents sequencing recommendation with per-item rationale → user sees ordered list with dependency/risk/value reasoning per item |
| 2 | Single candidate | user invokes `management:roadmap` → agent reads roadmap, finds 1 backlog item → agent presents the single item with rationale → user confirms or defers |
| 3 | Empty backlog | user invokes `management:roadmap` → agent reads roadmap, finds 0 backlog items → agent reports "no backlog items" and suggests shaping new work via `management:start-feature` |

**Expected outcome:** Happy path: the user receives a prioritized list with per-item rationale citing specific dependencies, risks, and value signals from the roadmap and linked pitches. Single candidate: the user sees a clear recommendation with rationale. Empty backlog: clean exit with actionable suggestion.

## Journey: Decompose a pitch into epics

**Goal:** The user has selected a roadmap item and wants it broken into focused, independently-shippable epics small enough for one LSA build cycle.
**Covers:** AC2, AC3

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — pitch has clear solution sketch | user confirms a roadmap item → agent reads linked pitch → agent produces 2-4 focused epics with one-sentence scope and definition of done → user approves epic list → agent hands first epic to `lsa:discover` |
| 2 | Pitch has vague solution sketch | user confirms item → agent reads pitch, finds solution sketch too vague for decomposition → agent asks user targeted questions to clarify scope boundaries → agent produces epics → user approves → handoff |
| 3 | User rejects epic list | user confirms item → agent produces epics → user rejects ("these are too big" / "wrong split") → agent re-decomposes based on user feedback → user approves revised list → handoff |
| 4 | No linked pitch | user confirms item → agent finds no pitch file linked in roadmap row → agent reports the gap and suggests shaping via `management:start-feature` first |

**Expected outcome:** Happy path: 2-4 epics, each independently shippable with a one-sentence scope, definition of done, and link to the parent pitch. First epic handed to `lsa:discover`. Vague pitch: agent drives clarification before decomposition. Rejected list: agent re-decomposes. No pitch: clean exit with actionable suggestion.

## Journey: Keep the roadmap tidy

**Goal:** The user wants the roadmap to reflect current reality — stale items flagged, completed items updated, new entries structured correctly.
**Covers:** AC4

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — stale items found | agent scans roadmap during recommendation phase → finds items with status "backlog" but linked pitch is >4 weeks old or branch exists with no recent commits → agent flags stale items with evidence → presents proposed status updates as inline diffs → user approves updates → agent writes changes |
| 2 | Roadmap is tidy | agent scans roadmap → all items are current, no stale entries → agent reports "roadmap is up to date" as part of the status overview |
| 3 | User rejects proposed update | agent flags a stale item → proposes status change → user rejects ("it's intentionally paused") → agent accepts without writing |

**Expected outcome:** Stale items are surfaced with evidence (date, branch activity). All roadmap changes go through explicit user approval. Rejected proposals leave no side effects.

## Journey: Product-manager adds roadmap entry on pitch approval

**Goal:** After a pitch is approved via `management:start-feature`, the system adds a structured backlog entry to the roadmap so the project-manager can find it.
**Covers:** AC5

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — pitch approved | user approves pitch in `start-feature` → system drafts a roadmap row (title, priority, status "backlog", pitch link) → presents inline for approval → user approves → system writes row to roadmap table → proceeds to `lsa:new` |
| 2 | User skips roadmap entry | user approves pitch → system drafts roadmap row → user skips/rejects the row → system proceeds to `lsa:new` without writing to roadmap |
| 3 | User adjusts priority | user approves pitch → system drafts row with assumed priority → user changes priority → system writes corrected row → proceeds to `lsa:new` |

**Expected outcome:** A structured roadmap row exists after pitch approval (unless user skips). The row links to the pitch file. Priority is user-confirmed, not agent-assumed.

## Journey: Plugin structure compliance

**Goal:** The management plugin continues to meet marketplace conventions after the project-manager is added.
**Covers:** AC6

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy | plugin.json version bumped to 0.2.0 → dependencies includes "core" → CHANGELOG.md has 0.2.0 entry → README updated with new skill + agent tables → module spec updated |

**Expected outcome:** Plugin passes V1 verification (installs cleanly, `/help` lists `management:roadmap`). Version, changelog, and README are consistent.
