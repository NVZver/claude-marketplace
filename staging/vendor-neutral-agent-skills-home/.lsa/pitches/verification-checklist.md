Shaped by: Nikita Zverev
Date: 2026-05-26
Status: draft
Why now: five verification passes emerged organically during the project-manager build — capturing them before they scatter across conversation history

# Verification checklist for the project-manager

A note on what was verified and what each pass caught, to inform a future `manager:verify` or quality-gate skill.

## 1. Spec trace (lsa:verify)

Traces every implementation change back to a spec requirement. Catches untraced code and uncovered acceptance criteria.

**What it checks:**
- Every diff hunk maps to an epic whose `**Covers:**` line cites a requirement ID (orphan-diff predicate)
- Every AC in requirements.md is cited by at least one epic (orphan-AC predicate)
- No files outside epic scope are modified
- Implementation matches design.md technical approach
- Version, changelog, README consistency

**What it caught (3 warnings):**
- `lsa:next` overlap not documented in user-facing files
- `main.spec.md` still said "two plugins" after management was the third
- `tasks.md` epic statuses still said "pending" after all were complete

## 2. Prompt-engineer review

Checks prompt files against actor ground rules and knowledge quality rules. Catches structural defects and separation-of-concerns violations.

**What it checks:**
- Actors: Goal/Input/Steps/Output/Constraints present, steps produce observable results, output has format + length + example, constraints are behavioral boundaries not quality rules
- Knowledge: rules numbered and actionable, no duplication across files, cross-references resolve, no execution logic in knowledge files
- Separation of concerns: actors don't restate knowledge, knowledge doesn't contain steps
- Cross-file consistency: sibling agents match in structure, sibling skills match in pattern

**What it caught (6 findings):**
- Adverb "always" in Goal
- "Re-ground jargon" constraint was prescriptive (do X) instead of boundary (do not do X)
- Output section lacked explicit length specification
- Mode numbering non-sequential (1, 3, 2)
- Roadmap skill example output was a placeholder, not a realistic example
- Sequencing-heuristics "Combining factors" item 4 was an output instruction belonging in the actor

## 3. KISS / DRY / SOC audit

Checks against the three constitutional principles. Catches unnecessary complexity, duplicated content, and mixed concerns.

**What it checks:**
- KISS: unnecessary abstraction layers, over-specified steps, files doing more than one thing at one level
- DRY: same content in multiple places (phrase tracing), format definitions hardcoded where a knowledge file already defines them
- SOC: each file has one concern, concern boundaries are clean, handoff levels of abstraction don't overlap

**What it caught (1 finding):**
- Roadmap table format defined in `sequencing-heuristics.md` but write format hardcoded in `start-feature/SKILL.md` — no cross-reference linking them

## 4. AI over-engineering sweep

Checks for patterns characteristic of AI-generated content: formalized common sense, reinvented paradigms, arbitrary thresholds, and unnecessary verbosity.

**What it checks:**
- Rules that formalize what the LLM already does naturally (counting sections as a risk proxy, naming natural reasoning as "three boundary signals")
- Custom frameworks where an established paradigm already provides the same answer (WSJF, Shape Up scoping, Kanban)
- Arbitrary hardcoded thresholds with no grounding (">4 weeks")
- Example bloat (three examples where one suffices)
- Missing provenance — adapted frameworks presented as novel without citing the source paradigm

**What it caught (5 findings):**
- Factor 2 detection rules formalized common sense the LLM already applies
- "3 boundary signals" were named categories for natural decomposition reasoning
- Agent had 3 example outputs where the sibling pattern had 1
- ">4 weeks" staleness threshold was arbitrary — replaced with state-based detection
- Knowledge files didn't cite the paradigms they adapted (WSJF, Shape Up)

## 5. Warning resolution

Re-verification after fixing warnings from pass 1. Confirms fixes are clean and don't introduce new issues.

**What it checks:**
- Each warning fix is applied correctly
- No new warnings introduced by the fixes
- Grep/read confirmation that the old problem text is gone

**What it caught:** Nothing new — all three fixes confirmed clean.

## Observation

The five passes are complementary, not redundant. Each caught issues the others missed:

| Pass | Catches what others miss |
|---|---|
| Spec trace | Untraced changes, stale metadata, version inconsistencies |
| Prompt-engineer | Structural prompt defects, boundary violations between actor/knowledge |
| KISS/DRY/SOC | Cross-file format coupling, concern leakage |
| AI sweep | Over-formalized common sense, missing paradigm provenance, arbitrary thresholds |
| Warning resolution | Regression from fixes |

Total findings: 15 across 4 passes (3 + 6 + 1 + 5). All resolved before commit.
