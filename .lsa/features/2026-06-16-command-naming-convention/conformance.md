# Conformance — Epic 1 command-naming convention

Verdict: **PASS** (doc-mode)

| Requirement | Satisfied by (verified on disk) |
|---|---|
| R1 — file + trace header line 1 | `management/knowledge/command-naming.md:1` (mirrors `epic-decomposition.md:1`) |
| R2 — title | `command-naming.md:3` `# Command naming — knowledge` |
| R3 — convention rule | `command-naming.md:10` `<object|actor>:<action>-<modifier> arg1, arg2`; "verbs you call, not nouns you browse"; rejects metaphor (`fleet`/`swarm`) |
| R4 — anti-pattern + citation | `command-naming.md:22` quotes the 3-verb bundle, cites `management/skills/roadmap/SKILL.md:3`; before/after verb split (`manager:next`/`decompose`/`check`) |
| R5 — "How to apply" | `command-naming.md` §"How to apply" (5 steps incl. read-only no-arg default) |
| R6 — spec + README refs | `.lsa/modules/management/spec.md:9` (+"command naming"); new invariant `spec.md:37`; README inline mention `management/README.md:7` |

## Scenarios (does)
- "The convention file is present and grounded" — PASS
- "The module spec and README list the new knowledge file" — PASS

## Only / All
- **Only:** `git status` shows exactly 4 paths (new file, spec.md, README.md, feature spec dir). Every hunk traces to R1-R6. No out-of-scope change (no dir rename, no plugin.json/SemVer, no skill split, no `manager:implement`).
- **All:** R1-R6 each mapped above.

## Drift absorbed
None. R6's README scope was pre-adjusted at grounding (inline mention, no list) — implementer followed it.
