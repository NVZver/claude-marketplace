---
name: lsa-verify
description: >
  Verifies that implementation matches the feature spec and no changes exist outside
  spec scope. Use this skill whenever an epic or feature is marked as implemented,
  before any merge, when the user says "verify this", "check the implementation",
  "ready to merge", or when code changes exist on a feature branch. Mandatory before
  lsa-sync. Never skip.
---

# LSA Verify

Core contract: every code change must trace to a spec requirement.
No code change is acceptable if it has no corresponding item in the feature spec.

## Step 1 — Read Sources

1. `/CLAUDE.md` (mandatory)
2. `/specs/features/<feature-name>/requirements.md`
3. `/specs/features/<feature-name>/test-suites.md`
4. `/specs/features/<feature-name>/contract.yaml` (if exists)
5. `/specs/features/<feature-name>/design.md`
6. `/specs/features/<feature-name>/tasks.md`
7. `/specs/modules/<name>/spec.md` for each module in scope

## Step 2 — Get Diffs

```bash
git diff main -- specs/features/<feature-name>/
git diff main -- src/
```

## Step 3 — Verification Checklist

For each item: ✅ PASS / ❌ FAIL / ⚠️ WARNING + reason

**Scope**
- [ ] Every AC in tasks.md is addressed by at least one code change
- [ ] Every code change traces to a requirement in requirements.md
- [ ] No files outside the epic's declared scope were modified

**Accuracy**
- [ ] Implementation matches the technical approach in design.md
- [ ] Patterns match CLAUDE.md ground rules
- [ ] Data model changes match design.md
- [ ] API/interface changes match design.md
- [ ] API implementation matches contract.yaml (if contract exists)

**Tests**
- [ ] Unit tests exist for all new functions/methods
- [ ] Integration tests cover module boundaries touched
- [ ] E2E tests cover all journeys and paths in test-suites.md
- [ ] All tests pass (use test command from CLAUDE.md)

**Code Quality**
- [ ] No duplicated logic
- [ ] No dead code
- [ ] No commented-out code
- [ ] File structure matches CLAUDE.md

## Step 4 — Verification Report

```markdown
# Verification Report: [Feature/Epic Name]
Date: [date]
Branch: [branch name]

## Result: PASS / FAIL / PASS WITH WARNINGS

## Checklist
[Each item with ✅ / ❌ / ⚠️ and reason for non-PASS items]

## Issues
| Severity | Item | Description | Required Action |
|----------|------|-------------|-----------------|
| BLOCKER  | ...  | ...         | ... |
| WARNING  | ...  | ...         | ... |

## Scope Diff
- Spec changes: [list]
- Code changes: [list]
- Untraced code changes: [none / list]
```

## Step 5 — Gate

- **FAIL / BLOCKER:** Stop. Report to human. Do not proceed to lsa-sync.
- **PASS WITH WARNINGS:** Present report. Wait for human decision.
- **PASS:** Present report. Proceed to lsa-sync on human approval.

---

`/lsa:verify` — manual invocation
