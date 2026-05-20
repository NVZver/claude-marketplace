# Core — CLAUDE.md fragment

> **Canonical source.** This file is the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules.

This is an **opt-in fragment** to merge into your project's `CLAUDE.md` when you install the `core` plugin. It declares two always-on rules: ground-rules application and tier-selector invocation. Copy the content below into your project's `CLAUDE.md`.

---

## Ground rules (always-on)

Apply `core/ground-rules` to every substantive task. Every factual claim carries a source + searchable quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked.

## Tier selection (always-on)

Before any non-trivial task, invoke `core/tier-selector` to classify the work as T1, T2, or T3 — and present the reasoning to the human for confirmation. Skip only for tasks that obviously stay inside T1 boundaries (single-string edits, single-question answers).

**The boundary signals** (Vision §4 `vision/VISION.md:124`): new module · API/contract change · data-model change · ~5 files · no existing spec.

**Tier outcomes:**
- **T1** — single pass, no LSA ceremony. `ground-rules` still applies.
- **T2** — `lsa-discover` (light) → agent TDD → `lsa-verify`.
- **T3** — `lsa-discover` → `lsa-specify` → `lsa-plan` → implement → `lsa-verify` → `lsa-sync`.
