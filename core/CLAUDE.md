# Core — CLAUDE.md fragment

> **Canonical source.** This file is the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules.

This is an **opt-in fragment** to merge into your project's `CLAUDE.md` when you install the `core` plugin. It declares three always-on rules: ground-rules application, output discipline, and tier-selector invocation. Copy the content below into your project's `CLAUDE.md`.

---

## Ground rules (always-on)

Apply [`core/ground-rules`](./skills/ground-rules/SKILL.md) to every substantive task — six content rules (ownership, fact-grounding, no fake confidence, read the real source, deliver only what was asked, no filler).

## Output discipline (always-on)

Apply [`core/output`](./skills/output/SKILL.md) to every human-facing output — five format golden rules (structured, minimal, formatted, sourced, concrete). Each component picks its own format within these rules.

## Tier selection (always-on)

Before any non-trivial task, invoke [`core/tier-selector`](./skills/tier-selector/SKILL.md) to classify the work as T1, T2, or T3 — and present the reasoning to the human for confirmation. Skip only for tasks that obviously stay inside T1 boundaries (single-string edits, single-question answers).

**The boundary signals** (Vision §4 `vision/VISION.md:124`): new module · API/contract change · data-model change · ~5 files · no existing spec.

**Tier outcomes:**
- **T1** — single pass, no LSA ceremony. `ground-rules` + `output` still apply.
- **T2** — `lsa-discover` (light) → agent TDD → `lsa-verify`.
- **T3** — `lsa-discover` → `lsa-specify` → `lsa-plan` → implement → `lsa-verify` → `lsa-sync`.
