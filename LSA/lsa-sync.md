---
name: lsa-sync
description: >
  Syncs a completed feature spec into permanent module specs and archives the feature.
  Use this skill whenever a feature has passed lsa-verify, when the user says "sync the
  spec", "archive this feature", "merge and sync", or "feature is done". Mandatory before
  merging any feature branch to main. Always runs after lsa-verify.
---

# LSA Sync

## Step 1 — Read Sources

1. `/CLAUDE.md` (mandatory)
2. `/specs/features/<feature-name>/requirements.md`
3. `/specs/features/<feature-name>/contract.yaml` (if exists)
4. `/specs/features/<feature-name>/design.md`
5. `/specs/features/<feature-name>/tasks.md`
6. `/specs/modules/<name>/spec.md` for each module this feature touched
7. `/specs/main.spec.md`

## Step 2 — Extract Delta

From the feature spec, identify only system-level decisions to carry forward:
- New behaviors added to a module
- New non-functional constraints
- New or modified cross-module contracts
- New or modified API endpoints and data types from contract.yaml (if exists)
- Technical decisions that apply to future features

Do NOT extract: task statuses, implementation details, scaffolding, or anything
specific to this feature that does not affect how the system works going forward.

Produce a delta summary:

```markdown
## Delta: [Feature Name]
Date: [date]

### Module Deltas
| Module | Type | Decision |
|--------|------|----------|
| ...    | new behavior / constraint / contract | ... |

### Cross-Module Contracts
[New or modified. If none, write "none"]

### main.spec.md Updates
[Module index changes, new global NFRs. If none, write "none"]
```

Present to human: **"These are the decisions I will merge into the module specs. Correct?"**
Wait for explicit approval before writing any files.

## Step 3 — Merge into Module Specs

For each affected module:
1. Open `/specs/modules/<module-name>/spec.md`
2. Append or extend the relevant sections with delta content
3. Tag each addition: `<!-- added: [feature-name] [YYYY-MM-DD] -->`
4. Do not rewrite or delete existing content
5. If a conflict exists between new and existing content, stop and ask human

## Step 4 — Update main.spec.md

- Add new modules to the module index if created
- Add new global NFRs or contracts if any
- If contract.yaml exists, update the Cross-Module Contracts section with new or modified endpoints and data types
- Tag each change: `<!-- added: [feature-name] [YYYY-MM-DD] -->`

## Step 5 — Archive Feature Spec

```bash
mv /specs/features/<feature-name>/ /specs/archive/$(date +%Y-%m-%d)-<feature-name>/
```

`/specs/features/` must be empty after this step.

## Step 6 — Sync Report

```markdown
# Sync Report: [Feature Name]
Date: [date]

## Module Specs Updated
| Module | Changes |
|--------|---------|
| ...    | ... |

## main.spec.md Updated
[yes — what changed / no]

## Archived To
/specs/archive/[date]-[feature-name]/

## PR Checklist
- [ ] Module specs reviewed by human
- [ ] main.spec.md reviewed by human
- [ ] Feature spec archived
- [ ] Branch ready for PR to main
```

Present report. Ask: **"Sync complete. Ready to create PR to main?"**

---

`/lsa:sync` — manual invocation
