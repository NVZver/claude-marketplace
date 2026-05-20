---
name: lsa-revise-constitution
description: >
  Proposes and applies changes to the project constitution and standards. Use this
  skill after a feature is merged during the replan phase, when the user says "update
  the constitution", "revise standards", "update CLAUDE.md", or when decisions made
  during a feature should be captured as permanent project standards. Single
  responsibility: CLAUDE.md and /specs/standards/ only. Never touches specs, src,
  or skills.
---

# LSA Revise Constitution

Single responsibility: propose and apply changes to `/CLAUDE.md` and `/specs/standards/` only.

## Step 1 — Read Sources

1. `/CLAUDE.md` (mandatory)
2. `/specs/standards/code.md`
3. `/specs/standards/testing.md`
4. `/specs/standards/agents.md`
5. `/specs/archive/<latest-feature>/` — decisions made during the completed feature

## Step 2 — Identify Proposed Changes

From the completed feature, extract decisions that should become permanent standards:
- New coding patterns or conventions adopted
- New testing rules or coverage requirements
- New agent behavior rules
- Corrections to existing standards that proved incorrect in practice

Do NOT propose: feature-specific decisions, one-off exceptions, implementation details.

For each proposed change, produce:

```markdown
## Proposed Change [N]

**File:** /CLAUDE.md or /specs/standards/[file]
**Section:** [section name]
**Type:** add / modify / remove

**Current:**
[exact current content, or "none" if new]

**Proposed:**
[exact proposed content]

**Reason:** [one sentence — what experience or decision drives this change]
**Source:** [feature name or explicit human instruction]
```

## Step 3 — Human Review Gate

Present all proposed changes individually. For each one ask:
**"Apply this change? Yes / No / Modify"**

Do not write any file until human approves that specific change.
If human says "Modify" — apply their correction and re-present before writing.

## Step 4 — Apply Approved Changes

For each approved change:
1. Edit the target file
2. Tag the change: `<!-- revised: [feature-name] [YYYY-MM-DD] -->`
3. Do not rewrite surrounding content

## Step 5 — Create Branch and Commit

```bash
git checkout -b constitution/<change-description>
git add CLAUDE.md specs/standards/
git commit -m "constitution: [summary of changes]"
```

Branch merges to `main` independently of any feature branch.

## Step 6 — Report

List each change applied with file, section, and type. State: "Constitution updated. Branch ready for PR to main."

---

`/lsa:revise-constitution` — manual invocation
