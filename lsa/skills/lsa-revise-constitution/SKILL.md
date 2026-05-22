---
name: lsa-revise-constitution
description: Proposes and applies changes to the project constitution and `${specs_root}/standards/`. Use after a feature is merged during replan, when the user says "update the constitution", "revise standards", "update CLAUDE.md", or when feature decisions should become permanent standards.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-revise-constitution/SKILL.md] [lsa] ===============`


# LSA Revise Constitution

Single responsibility: propose and apply changes to the path configured by `.lsa.yaml: constitution` (default `/CLAUDE.md`) and to `${specs_root}/standards/` only. This skill does nothing else.

## Goal

After a feature is merged, propose and apply constitution / standards changes the feature taught us — one change at a time, each with explicit human approval.

## Input

- `.lsa.yaml` for `constitution` path and `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").
- The most recently archived feature directory at `${specs_root}/archive/<latest-feature>/` — decisions made during the completed feature.
- A human-provided change description (or proposals derivable from the feature's `design.md` / `tasks.md`).

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/standards/code.md`
   - `${specs_root}/standards/testing.md`
   - `${specs_root}/archive/<latest-feature>/` — decisions made during the completed feature

   Observable result: per-source one-liner printed per the protocol.

2. **Identify proposed changes.** From the completed feature, extract decisions that should become permanent standards:
   - New coding patterns or conventions adopted
   - New testing rules or coverage requirements
   - New agent behavior rules
   - Corrections to existing standards that proved incorrect in practice

   Do NOT propose: feature-specific decisions, one-off exceptions, implementation details.

   For each proposed change, produce:

   ```markdown
   ## Proposed Change [N]

   **File:** ${constitution} or ${specs_root}/standards/[file]
   **Section:** [section name]
   **Type:** add / modify / remove

   **Current:**
   [exact current content, or "none" if new]

   **Proposed:**
   [exact proposed content]

   **Reason:** [one sentence — what experience or decision drives this change]
   **Source:** [feature name or explicit human instruction]
   ```

   Observable result: one proposal block per change written to scratch.

3. **Human review gate.** Present each proposed change individually (one per turn): PROPOSED verdict + change-N-of-M + file path + section name + type (add / modify / remove) + verbatim current content (or "none") + proposed content + one-line reason + source (feature name or "manual") + decision `[a] apply → file edited, tagged, committed to constitution branch` / `[b] modify → apply your correction, re-present` / `[c] reject → change not applied`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision. Do not write until approval. Observable result: per-change decision logged.

4. **Apply approved changes.** For each approved change:
   1. Edit the target file (the configured `${constitution}` or a file under `${specs_root}/standards/`).
   2. Tag the change: `<!-- revised: <feature-name> YYYY-MM-DD -->` (per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Trace-tag format").
   3. Do not rewrite surrounding content.

   Observable result: diff shown per file.

5. **Create branch and commit.**

   ```bash
   git checkout -b constitution/<change-description>
   git add ${constitution} ${specs_root}/standards/
   git commit -m "constitution: [summary of changes]"
   ```

   Branch merges to `main` independently of any feature branch. Observable result: branch + commit exist.

6. **Report.** List each change applied with file, section, and type. State: "Constitution updated. Branch ready for PR to main."

## Output

Updated `${constitution}` and/or files under `${specs_root}/standards/`, each tagged `<!-- revised: <feature-name> YYYY-MM-DD -->` (per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Trace-tag format"). A `constitution/<change-description>` branch ready for PR to `main`.

## Constraints

- **Hard confirm per change.** No bulk approval; each proposal stands or falls on its own.
- **Never touch specs, src, or skills** — only the configured constitution and `${specs_root}/standards/`.
- **Never rewrite surrounding content.** Limit edits to the proposed section.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:revise-constitution` — manual invocation.
