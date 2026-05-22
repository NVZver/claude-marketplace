> **Trace.** On load, print first: `=============== [vision/specs/features/2026-05-21-helper-agent/clarification.md] [vision] ===============`

# Clarification — 2026-05-21-helper-agent

Captures the human's answers to `lsa-specify` Step 2 assume-then-override. Silence on a line = approval; overrides logged inline.

Five must-decide questions surfaced via `AskUserQuestion` and answered by the human; the remainder were rendered as assumptions A1–A5 with batch approval.

## Functional (5)

- **F1 — How does a confused user reach the Helper?**
  - **Answered:** Both — a `/help` slash command AND an auto-engaging subagent. The command covers explicit asks; the subagent covers friction signals.

- **F2 — When the Helper answers, what is it allowed to do?**
  - **Answered:** Can start workflows. If user expresses intent ("I want to add X"), Helper invokes the matching skill via the `Skill` tool — under explicit `AskUserQuestion` confirmation per A2.

- **F3 — When does the Helper auto-engage (interrupt the current flow)?**
  - **Answered:** Only on user-friction signals — (a) two consecutive `[c] reject` at any `lsa-specify` User Verification; (b) user types a free-form `?` / `what is X?` mid-session; (c) explicit `/help`. Not the "aggressive" hesitation-pattern detector.

- **F4 — What is the Helper allowed to read?**
  - **Answered:** Repo + installed plugins + web via `context7` MCP. Helper reads `vision/`, `core/`, `lsa/`, READMEs of this repo; READMEs and `SKILL.md` of other installed plugins; external library docs via `context7` when relevant.

- **F5 — Output discipline.**
  - **Assumed (A1).** Inherits `core/output` 5 golden rules (structured · minimal · formatted · sourced · concrete) + `core/ground-rules` 6 content rules. ≤1.5 screens/turn; re-ground project jargon (`Standard`, `User Verification 2`, `LSA`, `SKILL.md`) on first turn-use per `finding_helper_must_reground`.

## Non-functional (2)

- **NF1 — Performance / latency.**
  - **Assumed (A5).** Friction-signal detection runs in the main Claude Code agent's own context — no separate detector subagent. Auto-engage fires in the same turn as the signal. `context7` calls only on explicit external-library questions.

- **NF2 — Failure modes.**
  - **Assumed (A3).** Per `core/ground-rules` Rule 2: when Helper can't ground a claim, says "I cannot verify this" + offers `AskUserQuestion` next steps. No fake-confidence hedging. Skill-invocation failures surface the error + offer retry/step-back.

## Boundaries (2)

- **B1 — Where does the Helper ship?**
  - **Answered:** New `helper` plugin (third plugin in the marketplace, separate install). Not in `core`, not in `lsa`.
  - **In-scope edits:**
    - New plugin tree: `helper/.claude-plugin/plugin.json`, `helper/CHANGELOG.md`, `helper/README.md`.
    - `helper/agents/helper.md` — subagent definition.
    - `helper/commands/help.md` — slash command.
    - `helper/skills/` — supporting skill bodies if needed (e.g. `explain-workflow/SKILL.md`); decision deferred to User Verification 2 design.
    - `helper/knowledge/` — any standalone Knowledge files Helper reads (per NFR5 Knowledge vs Actor).
    - `.claude-plugin/marketplace.json` — list new plugin in catalog.
    - `README.md` (repo root) — name `helper` in the install lede alongside `core` + `lsa`.
    - `vision/specs/main.spec.md` — add `helper` row to Module Index after `lsa-sync`.
    - `vision/specs/modules/helper/spec.md` — new module spec (created by `lsa-sync` post-merge).
    - `vision/specs/roadmap.md` — mark Help agent shipped after sync.

- **B2 — Out of scope.**
  - **Assumed:**
    - No retrofit of existing `lsa/` or `core/` skills to call Helper internally — Helper is a consumer, the others stay unaware.
    - No confusion detection inside subagent-spawned contexts (main agent context only).
    - No conversation-state persistence between Claude Code sessions — each `/help` invocation starts cold.
    - No persona theater (A4) — no name, no avatar, no greeting beyond `core/output` discipline.
    - No first-run onboarding wizard separate from `/help`.
    - No publishing of Helper docs to external destinations (Claude.ai upload, etc.). Ships only as a Claude Code plugin.

## Acceptance (8 — journey-shaped, per `vision/VISION.md` §2 sub-principle 2a)

See `requirements.md` § Acceptance Criteria — AC1 through AC8. Every AC describes user-observable behavior at the user/system boundary; AC1–AC5 trace to the 5 candidate ACs surfaced and approved at Step 2; AC6–AC8 codify the output-discipline assumptions A1, A4 as testable journey-shaped behaviors.

---

## Decision log

| Step | Picker | Answer | Date |
|---|---|---|---|
| Round 1 (Shape · Scope · Home) | 3-question batch via `AskUserQuestion` | Both command+agent · Can start workflows · New `helper` plugin | 2026-05-21 |
| Round 2 (Auto-engage · Knowledge) | 2-question batch via `AskUserQuestion` | Friction-signals only · Repo + plugins + `context7` | 2026-05-21 |
| Round 3 (A1–A5 + AC1–AC5 batch approval) | 1-question via `AskUserQuestion` | Approve all → draft requirements | 2026-05-21 |
