# Epic 1 — Command-naming convention knowledge file

## Summary
Doc-mode. Author `management/knowledge/command-naming.md` stating the function-like
command-naming convention, so future commands ground in one citable rule.
Parent: `.lsa/pitches/function-command-naming-and-manager-rename.md` (Epic 1)

## User flow
| Flow | Success | I/O | Scenario |
|------|---------|-----|----------|
| A reader/agent looks up the command-naming rule | finds a citable convention with a worked anti-pattern | ∅ → command-naming.md | convention-file.feature |

## Functional requirements (doc-mode — about the artifact)
- R1. The file SHALL exist at `management/knowledge/command-naming.md` with the trace
  header on line 1, mirroring `management/knowledge/epic-decomposition.md:1`.
- R2. It SHALL title `# Command naming — knowledge` (existing knowledge-file format).
- R3. It SHALL state the convention: shape `<object|actor>:<action>-<modifier> arg1, arg2`;
  commands are verbs you call with arguments, not nouns you browse; a new reader understands
  a command from name + args alone; zero metaphor.
- R4. It SHALL carry a worked anti-pattern: `management:roadmap` (one noun bundling three
  verbs) vs the verb split `manager:next` / `manager:decompose <pitch>` / `manager:check`,
  citing `management/skills/roadmap/SKILL.md:3`.
- R5. It SHALL include a short "how to apply" for authoring future commands.
- R6. The module spec knowledge list (`.lsa/modules/management/spec.md:9`), a matching
  canonical-source invariant (mirroring the pattern at `spec.md:34-36`), and the README
  knowledge list SHALL be updated to include `command-naming.md` in the same commit.

## Out of scope (other epics)
- Dir rename, plugin.json/SemVer, manifest sweep (Epic 2); skill split (Epic 4);
  `manager:implement` (Epic 3). No backward-compat aliases (clean break).
