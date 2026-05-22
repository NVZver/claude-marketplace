# Core — CLAUDE.md fragment

> **Canonical source.** This file is the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules.

This is an **opt-in fragment** to merge into your project's `CLAUDE.md` when you install the `core` plugin. It declares three always-on rules: ground-rules application, output discipline, and flow-selector invocation. Copy the content below into your project's `CLAUDE.md`.

---

## Ground rules (always-on)

Apply [`core/ground-rules`](./skills/ground-rules/SKILL.md) to every substantive task — six content rules (ownership, fact-grounding, no fake confidence, read the real source, deliver only what was asked, no filler).

## Output discipline (always-on)

Apply [`core/output`](./skills/output/SKILL.md) to every human-facing output — five format golden rules (structured, minimal, formatted, sourced, concrete). Each component picks its own format within these rules.

**Three operational checkpoints (commonly skipped — surface them every turn):**

1. **Substrate-native pickers.** In Claude Code, every decision-bearing prompt uses `AskUserQuestion`. Never render `[a] / [b] / [c]` text blocks when the native picker is available — per `vision/VISION.md` §2 principle 9 (*"Substrate-native first"*) and [`core/output`](./skills/output/SKILL.md) Rule 5. Text decision blocks are the fallback when no picker exists (e.g., non-Claude-Code substrates, embedded `.md` body templates).
2. **1–1.5 screen budget per turn.** Default response budget is ~30–50 lines of rendered markdown. Split decisions into separate turns; pull facts on demand rather than pushing tables + worked examples + decision blocks in one turn. Per [`core/output`](./skills/output/SKILL.md) Rule 2.
3. **Output marker (`[plugin:skill]`).** Every substantive response opens with one `[plugin:skill]` marker naming the most-specific active marketplace skill — e.g., `[core:output]` (default), `[lsa:lsa-specify]`, `[lsa:lsa-verify]`. The marker is the response's "From:" line so the human sees at-a-glance which marketplace context produced the output. Per [`core/output`](./skills/output/SKILL.md) Rule 4.

## Flow selection (always-on)

Before any non-trivial task, invoke [`core/flow-selector`](./skills/flow-selector/SKILL.md) to classify the work as Quick, Standard, or Extended — and present the reasoning to the human for confirmation. Skip only for tasks that obviously stay inside Quick boundaries (single-string edits, single-question answers). Renamed from `tier-selector` (T1 / T2 / T3) in `core` v0.5.2 — the new names describe the *process shape*, not a hierarchy.

**The boundary signals** (Vision §4 `vision/VISION.md:124`): new module · API/contract change · data-model change · ~5 files · no existing spec.

**Flow outcomes:**
- **Quick** (was `T1`) — single pass, no LSA ceremony. `ground-rules` + `output` still apply.
- **Standard** (was `T2`) — `lsa-discover` (light) → agent TDD → `lsa-verify`.
- **Extended** (was `T3`) — `lsa-discover` → `lsa-specify` → `lsa-plan` → implement → `lsa-verify` → `lsa-sync`.
