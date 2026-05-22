# Discovery — 2026-05-21-maintenance-cleanup

- **Module(s):** new module: maintenance
- **Change:** Add a `/maintenance:cleanup` skill that analyzes specs/skills/READMEs, proposes byte/wordcount-reducing refactors as a single reviewable diff preserving frontmatter + cited rule IDs + public names, then runs `lsa-verify` + structural checks before commit.
- **Acceptance:** Running `/cleanup` on a clean tree produces a diff that reduces aggregate skill-body token count and leaves all `lsa-verify` invariants intact — zero changes to frontmatter `description`, public skill/command names, or cited rule IDs across `vision/`, `core/`, `lsa/`.

## Operating-context constraint (non-functional)

The cleanup output must keep the repo performant on **smaller-context / local models** (e.g., Ollama, Mistral). This is a forcing function for: shorter skill bodies, fewer cross-references per file, no redundant prose, lean READMEs.
