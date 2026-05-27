---
name: spec-templates
description: Markdown templates for LSA spec artifacts — requirements.md, test-suites.md, design.md
---

> **Trace.** On load, print first: `=============== [lsa/knowledge/spec-templates.md] [lsa] ===============`

# Spec Artifact Templates

Canonical templates for each spec artifact written during `lsa:discover` Extended flow. Skills reference these templates by section heading rather than embedding them inline.

---

## requirements.md template

```markdown
# Feature: [Name]

## Summary
[What and why — max 1 paragraph]

## Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | ... | Must / Should / Could / Won't |

## Non-Functional Requirements
| ID | Requirement |
|----|-------------|
| NF1 | ... |

## Inputs & Outputs
- Input: ...
- Output: ...
- Side effects: ...

## Constraints
[Applicable rules from the constitution]

## Out of Scope
[What this feature explicitly does NOT cover]

## Acceptance Criteria
<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->
- [ ] AC1: While <state> / when <event>, the system shall <observable behavior>.
- [ ] AC2: ...
```

---

## test-suites.md template

```markdown
# Test Suites: [Feature Name]

## Journey: [Name]

**Goal:** [What problem/task the user is trying to solve]
**Covers:** AC1, AC2

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | action → action → success |
| 2 | Alternate | action → action → success (different route) |
| 3 | Error | action → system rejects → user sees feedback |

**Expected outcome:** [What success looks like for happy paths. What feedback the user sees for error paths.]
```

One journey per distinct user goal. One path per distinct way to achieve that goal. Every AC must appear in at least one journey's **Covers** field.

---

## design.md template

```markdown
# Design: [Feature Name]

## Modules Affected
| Module | Change Type |
|--------|-------------|
| ...    | new / modify / read-only |

## Technical Approach
[Patterns and structure per the constitution]

## Data Model Changes
[If none, write "none"]

## API / Interface Changes
[Reference contract.yaml if applicable, otherwise write "none"]

## Cross-Module Contracts
[New or modified contracts. If none, write "none"]

## Open Questions
[Unresolved items requiring human input. If none, write "none"]
```
