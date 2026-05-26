# Test Suites: Management Plugin — Product Manager Agent

## Journey: Shape a feature from a vague idea

**Goal:** The user has a vague problem or opportunity and wants to turn it into a well-defined, buildable pitch before committing to a build cycle.
**Covers:** AC1, AC2, AC3, AC4, AC5, AC6

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — full shaping conversation | user invokes `management:start-feature "users struggle with onboarding"` → agent adopts role (e.g., "developer-experience product manager") → agent asks clarifying questions (who, evidence, current workaround, definition of success, why now, appetite, solution sketch, rabbit holes, no-gos) → user answers → agent checks cross-section consistency → agent presents complete pitch → user approves → handoff to `lsa:new` |
| 2 | Happy — role override | user invokes `start-feature` → agent proposes role → user overrides to a different domain role → agent re-adapts and continues shaping with new role |
| 3 | Happy — bare invocation (no argument) | user invokes `management:start-feature` with no argument → agent prompts for problem description → user provides it → shaping conversation proceeds as path 1 |
| 4 | Alternate — user reshapes pitch | agent presents completed pitch → user selects "reshape" → agent asks what to change → user provides corrections → agent re-presents revised pitch → user approves |
| 5 | Alternate — user rejects pitch | agent presents completed pitch → user selects "reject" → agent acknowledges, no downstream work fires, conversation ends cleanly |
| 6 | Alternate — user provides rich input upfront | user invokes `start-feature` with detailed problem + appetite + risks already stated → agent skips already-answered questions, confirms understanding, fills remaining gaps → shorter conversation → pitch produced |

**Expected outcome:** Happy paths end with an approved pitch file at `vision/specs/pitches/<slug>.md` containing all five sections, and control passed to `lsa:new`. Alternate paths 4–5 end with either a revised approved pitch or a clean exit with no side effects. Path 6 demonstrates the agent adapts its question depth to the richness of the input.

## Journey: Plugin installation and dependency resolution

**Goal:** The user installs the management plugin and it integrates correctly with the marketplace.
**Covers:** AC7

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — install with core present | user has `core` installed → installs `management` → plugin loads, `start-feature` skill appears in skill list |
| 2 | Error — core not installed | user installs `management` without `core` → Claude Code reports unmet dependency |

**Expected outcome:** Happy path: plugin loads and `management:start-feature` is available. Error path: dependency check prevents silent breakage.
