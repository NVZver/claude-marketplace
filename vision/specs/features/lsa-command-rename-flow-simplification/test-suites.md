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

## Journey: Skill description readability

**Goal:** A user (or collaborator) reads the LSA skill descriptions and understands what each command does, what it needs, and the workflow order — without opening documentation.
**Covers:** AC5, AC6

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Single skill | User reads the YAML frontmatter `description` of any LSA skill → description states input required and output produced |
| 2 | Workflow order | User reads all LSA skill descriptions together (e.g., in README skill table) → the order discover → plan → implement → verify is evident from the descriptions |

**Expected outcome:** Each description answers "what do I need before running this?" and "what will it produce?" The main flow order is self-documenting.
