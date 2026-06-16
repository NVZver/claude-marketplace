# Grounding — Epic 1 command-naming convention

Verdict: **GROUNDED** (doc-mode)

| Spec reference | Status |
|---|---|
| Knowledge-file format template | exists @ `management/knowledge/epic-decomposition.md:1-3` |
| Anti-pattern source (roadmap = 3 verbs in 1) | exists @ `management/skills/roadmap/SKILL.md:3` |
| Module-spec knowledge list (R6) | exists @ `.lsa/modules/management/spec.md:9` |
| Module-spec invariant pattern (R6) | exists @ `.lsa/modules/management/spec.md:34-36` |
| README knowledge references (R6) | exists, inline only @ `management/README.md:5` (see note) |
| Target file | `new` — `management/knowledge/command-naming.md` absent |

## Feasibility
- Buildable: a markdown knowledge file authored to mirror the existing format. No code dependency.

## Note (R6 README scope)
The README has **no dedicated knowledge-list heading** — knowledge files are referenced inline
within agent descriptions (`management/README.md:5` cites `pitch-structure.md`). So R6's README
update is a contextual mention, not a list-append. Not a blocker; flagged for the implementer.

## Blockers
None.
