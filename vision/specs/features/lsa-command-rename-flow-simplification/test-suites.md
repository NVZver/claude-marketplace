# Test Suites: LSA Command Rename + Flow Simplification

## Journey: Extended-flow discovery (merged specify+discover)

**Goal:** User wants to spec a new feature using the Extended flow and invokes a single `lsa:discover` command instead of the former two-command `lsa-discover` → `lsa-specify` sequence.
**Covers:** AC1

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy | User invokes `lsa:discover` after `core/flow-selector` confirms Extended → system runs three phases (specify → discover → confirm) → spec artifacts produced (requirements.md, test-suites.md, design.md, tasks.md) |
| 2 | With contract | Same as path 1, but contract trigger fires → contract.yaml also produced |
| 3 | User overrides during confirm | User invokes `lsa:discover` Extended → system infers answers → user overrides one or more answers at confirm phase → system re-drafts with overrides → spec artifacts produced |

**Expected outcome:** Feature directory under `${specs_root}/features/<name>/` contains the same artifact set the former `lsa-specify` produced. The user never invokes a separate `specify` command.

## Journey: Standard-flow discovery (light)

**Goal:** User wants to fix a bug or do a small task using the Standard flow and invokes `lsa:discover` for lightweight context.
**Covers:** AC2

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy | User invokes `lsa:discover` after `core/flow-selector` confirms Standard → system infers three answers (module, change, AC) → user confirms → 3-row table rendered → stop (no spec files written) |
| 2 | User overrides | User invokes `lsa:discover` Standard → system infers → user overrides module assignment → system re-renders → stop |

**Expected outcome:** A 3-row context table (Module / Change / Acceptance) is rendered. No files written to `${specs_root}/`. User proceeds directly to implementation + verify.

## Journey: Renamed command invocation

**Goal:** User invokes any LSA command by its new name (without the `lsa-` prefix stutter) and the system responds.
**Covers:** AC3

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — plan | User types `/lsa:plan` → system loads `lsa/skills/plan/SKILL.md` → skill executes |
| 2 | Happy — verify | User types `/lsa:verify` → system loads `lsa/skills/verify/SKILL.md` → skill executes |
| 3 | Happy — init | User types `/lsa:init` → system loads `lsa/skills/init/SKILL.md` → skill executes |
| 4 | Happy — reconcile | User types `/lsa:reconcile` → system loads `lsa/skills/reconcile/SKILL.md` → skill executes |
| 5 | Happy — revise-constitution | User types `/lsa:revise-constitution` → system loads `lsa/skills/revise-constitution/SKILL.md` → skill executes |

**Expected outcome:** Each command resolves to the correct skill file at the new path. No `lsa-` prefix in directory names.

## Journey: Removed sync command

**Goal:** User attempts to invoke the removed `sync` command and the system does not find it.
**Covers:** AC4

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Old name | User types `/lsa:lsa-sync` → system finds no matching skill → reports no match |
| 2 | New-style name | User types `/lsa:sync` → system finds no matching skill → reports no match |

**Expected outcome:** No skill file exists at `lsa/skills/sync/` or `lsa/skills/lsa-sync/`. The system's standard "skill not found" behavior applies.

## Journey: New feature entry point (`lsa:new`)

**Goal:** User has a feature idea and wants to start working on it immediately — without manually creating a branch, running flow-selector, or invoking discover separately.
**Covers:** AC7

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — Extended | User invokes `lsa:new "payment retry logic"` → system derives slug `payment-retry-logic` → creates branch `feature/payment-retry-logic` → runs flow-selector → user selects Extended → system hands off to `lsa:discover` Extended → spec artifacts produced |
| 2 | Happy — Standard | User invokes `lsa:new "fix date format"` → system derives slug → creates branch → flow-selector → user selects Standard → system hands off to `lsa:discover` Standard → 3-row table rendered, no spec files |
| 3 | Branch already exists | User invokes `lsa:new "my-feature"` → branch `feature/my-feature` already exists → system reports the branch exists and asks whether to switch to it or pick a different name |

**Expected outcome:** Feature branch exists, flow type confirmed, discovery phase running — all from a single command invocation.

## Journey: Next backlog item (`lsa:next`)

**Goal:** User wants to pick the next highest-priority backlog item from the roadmap and start working on it, without manually scanning the roadmap or creating a branch.
**Covers:** AC8

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy | User invokes `lsa:next` → system reads roadmap → presents top Must-priority backlog item with name, priority, notes excerpt → user confirms "Start this one" → system creates branch → runs flow-selector → hands off to `lsa:discover` |
| 2 | Skip to second | User invokes `lsa:next` → system presents top item → user selects "Skip — show next" → system presents second item → user confirms → branch created → discover starts |
| 3 | Cancel | User invokes `lsa:next` → system presents top item → user selects "Cancel" → system stops, no branch created |
| 4 | Empty backlog | User invokes `lsa:next` → roadmap has no items with status "backlog" → system reports nothing to pick |

**Expected outcome:** User confirms a backlog item, feature branch is created, and discovery begins — all from a single command invocation.

## Journey: Skill description readability

**Goal:** A user (or collaborator) reads the LSA skill descriptions and understands what each command does, what it needs, and the workflow order — without opening documentation.
**Covers:** AC5, AC6

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Single skill | User reads the YAML frontmatter `description` of any LSA skill → description states input required and output produced |
| 2 | Workflow order | User reads all LSA skill descriptions together (e.g., in README skill table) → the order discover → plan → implement → verify is evident from the descriptions |

**Expected outcome:** Each description answers "what do I need before running this?" and "what will it produce?" The main flow order is self-documenting.
