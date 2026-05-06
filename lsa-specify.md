---
name: lsa-specify
description: >
  Creates a feature spec from a human's description using the Living Spec Architecture.
  Use this skill whenever the user describes a new feature, says "I need to build X",
  "add a feature", "new requirement", "let's spec this out", or provides any functional
  requirement that needs to be captured before implementation. Always use this skill
  before planning or implementing anything. Never assume intent — always ask.
---

# LSA Specify

## Step 1 — Read Sources

1. `/CLAUDE.md` (mandatory)
2. `/specs/main.spec.md`
3. `/specs/modules/<name>/spec.md` for each module this feature touches

## Step 2 — Clarify with Human

Do not write any files until all answers received.

**Functional**
- What does this feature do?
- Who uses it and in what context?
- What are the inputs and outputs?
- What are the edge cases?

**Non-Functional**
- Performance requirements?
- Security requirements?

**Boundaries**
- Which existing modules does this touch?
- What must NOT change?

**Acceptance**
- What are the exact conditions for this feature to be considered done?

**Contract trigger — ask explicitly:**
Does this feature introduce or modify any of the following?
- An API endpoint (path, method, request, response)
- A request or response schema
- A database schema or table structure
- A shared data type used across modules

Answer determines whether `contract.yaml` is required (yes) or skipped (no).

## Step 3 — Create Spec Directory

```
/specs/features/<feature-name>/
  requirements.md
  test-suites.md
  contract.yaml      ← only if contract trigger = yes
  design.md
  tasks.md           ← empty, filled by lsa-plan
```

Feature name: kebab-case. Create git branch: `feature/<feature-name>`

## Step 4 — Write requirements.md → Hard Confirm

```markdown
# Feature: [Name]

## Summary
[What and why — max 1 paragraph]

## Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | ... | Must / Should |

## Non-Functional Requirements
| ID | Requirement |
|----|-------------|
| NF1 | ... |

## Inputs & Outputs
- Input: ...
- Output: ...
- Side effects: ...

## Constraints
[Applicable rules from CLAUDE.md]

## Out of Scope
[What this feature explicitly does NOT cover]

## Acceptance Criteria
- [ ] AC1: [binary pass/fail condition]
- [ ] AC2: ...
```

Present to human. Ask: **"Does requirements.md capture the full scope? Confirm to continue."**
Do not proceed until explicit confirmation.

## Step 5 — Write test-suites.md → Hard Confirm

```markdown
# Test Suites: [Feature Name]

## Journey: [Name]

**Goal:** [What problem/task the user is trying to solve]

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Primary | action → action → action |
| 2 | Alternative | action → action |

**Expected outcome:** [What success looks like for all paths]
```

One journey per distinct user goal. One path per distinct way to achieve that goal.
Cover all ACs from requirements.md across journeys.

Present to human. Ask: **"Do these journeys cover all user interactions correctly? Confirm to continue."**
Do not proceed until explicit confirmation.

## Step 6 — Write contract.yaml → Soft Confirm (skip if not applicable)

Write a valid OpenAPI 3.x YAML file covering all endpoints, schemas, and data types introduced or modified by this feature.

```yaml
openapi: 3.1.0
info:
  title: [Feature Name] Contract
  version: 0.1.0
paths:
  /[path]:
    [method]:
      summary: ...
      requestBody: ...
      responses: ...
components:
  schemas:
    [ModelName]:
      type: object
      properties: ...
```

Present to human. Ask: **"Does this contract look correct? Confirm or describe corrections — I can apply them."**
Human may delegate all corrections to agent. Proceed once human is satisfied.

## Step 7 — Write design.md

Derive from `contract.yaml` if it exists. Otherwise derive from `requirements.md`.

```markdown
# Design: [Feature Name]

## Modules Affected
| Module | Change Type |
|--------|-------------|
| ...    | new / modify / read-only |

## Technical Approach
[Patterns and structure per CLAUDE.md]

## Data Model Changes
[If none, write "none"]

## API / Interface Changes
[Reference contract.yaml if applicable, otherwise write "none"]

## Cross-Module Contracts
[New or modified contracts. If none, write "none"]

## Open Questions
[Unresolved items requiring human input. If none, write "none"]
```

## Step 8 — Final Review Gate

Present all spec files together. Ask:
**"Full spec ready. Approve all files to proceed to planning, or tell me what to change."**

Do not run `lsa-plan` until human gives explicit final approval.

---

`/lsa:specify` — manual invocation
