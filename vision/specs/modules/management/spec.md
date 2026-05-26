> **Trace.** On load, print first: `=============== [vision/specs/modules/management/spec.md] [vision] ===============`

# Module Spec — `management`

Product and project management discipline. Shapes vague ideas into structured pitches before the build cycle begins.

**Plugin manifest:** [`management/.claude-plugin/plugin.json`](../../../../management/.claude-plugin/plugin.json) (v0.1.0)
**Plugin README** (install, dependencies, status): [`management/README.md`](../../../../management/README.md)
**Knowledge** (pitch format, role adaptation): [`management/knowledge/`](../../../../management/knowledge/)

## Role in the marketplace

`management` is the pre-build shaping surface — it turns a user's vague idea into a structured pitch with clear scope, boundaries, and exclusions. The pitch is the input to the LSA build cycle (`lsa:discover` → `lsa:plan` → `lsa:implement` → `lsa:verify`). Depends on `core` ([`management/README.md`](../../../../management/README.md) *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (every claim cited; cannot-verify fallback rather than fabrication).
- `core/output` — format discipline every response inherits.

Reads `lsa` artifacts (roadmap, specs) for codebase context during shaping but does not depend on `lsa` at the plugin level. `lsa` does not depend on `management`.

## Invariants

- **Versioning.** `management` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*). Currently v0.1.0.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `vision/specs/standards/code.md`.
- **Depends on `core`.** Documented in `management/.claude-plugin/plugin.json` `dependencies` field and `management/README.md` *"Depends on"*.
- **Ownership over automation.** The agent facilitates shaping — it does not decide scope. Per `vision/VISION.md:15`.
- **Domain-neutral.** The agent self-selects a domain role per invocation. Per `management/knowledge/role-adaptation.md`.
- **Pitch structure is canonical.** Format, sections, and heading structure defined in `management/knowledge/pitch-structure.md`. That file is the single source of truth for pitch format.
- **Human gate before handoff.** A pitch must reach `approved` status before it enters the LSA build cycle.
- **Pitch output path.** All pitches land at `vision/specs/pitches/<slug>.md`.

## Artifact paths

```yaml
- management/agents/**/*.md
- management/skills/**/SKILL.md
- management/knowledge/**/*.md
- management/.claude-plugin/plugin.json
- management/README.md
```
