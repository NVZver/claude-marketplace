# Design: Helper Agent

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `helper` (new) | new — entire plugin tree under `helper/` |
| `core` | read-only — Helper cites `core/output`, `core/ground-rules`, `core/actor-template`, `core/tier-selector`; no code change |
| `lsa` | read-only — Helper observes `lsa-specify` gate-reject state via main-agent context; cites all `lsa/skills/*/SKILL.md`; no code change |
| `vision/specs/main.spec.md` | modify (post-merge) — add `helper` row to Module Index; done by `lsa-sync` |
| `vision/specs/modules/helper/spec.md` | new (post-merge) — created by `lsa-sync` |
| `.claude-plugin/marketplace.json` | modify — list `helper` in plugins catalog |
| `README.md` (repo root) | modify — name `helper` in install lede alongside `core` + `lsa` |
| `vision/specs/roadmap.md` | modify (post-merge) — mark Help agent shipped |

## Technical Approach

### Plugin layout

```
helper/
├── .claude-plugin/
│   └── plugin.json              SemVer 0.1.0, description, manifest
├── CHANGELOG.md                  Keep-a-Changelog format
├── README.md                     Install, usage, what Helper does and doesn't do
├── agents/
│   └── helper.md                 The Helper subagent (Actor)
├── commands/
│   └── help.md                   `/help <question>` slash command
└── knowledge/
    └── friction-signals.md       Knowledge: how to recognise (a) gate-reject patterns, (b) free-form `?` / `what is X?` patterns
```

Layout follows the patterns documented in `plugin-dev:plugin-structure` skill (manifest under `.claude-plugin/`, agents under `agents/`, commands under `commands/`, knowledge under `knowledge/`).

### Helper agent body (`helper/agents/helper.md`)

Actor per `core/actor-template` (Goal · Input · Steps · Output · Constraints). Tools: `Read`, `Grep`, `Glob`, `AskUserQuestion`, `Skill`, `mcp__plugin_context7_context7__*` (when present).

- **Goal:** Be a friendly, fact-grounded assistant — explain marketplace concepts, walk through skills, and start workflows on the user's explicit confirmation.
- **Input:** The user's message (from `/help` argument OR detected friction signal); ambient repo state; installed-plugin state; optional `context7` MCP.
- **Steps:**
  1. Read relevant sources (scope per F4 — repo, installed plugins, optional `context7`). Stop after a bounded read; do not exhaust the codebase.
  2. Compose answer per `core/output` (≤1.5 screens, structured, citations per claim, first-turn-use jargon gloss).
  3. If user intent maps to a skill, ask `AskUserQuestion` to confirm; on Yes invoke `Skill(<name>)`.
  4. Close with `AskUserQuestion` offering 2–3 narrow next steps (or stop if a `Skill()` handoff just happened).
- **Output:** Either (a) a Helper response (≤1.5 screens, cited, `AskUserQuestion` close), or (b) a `Skill()` handoff to another skill.
- **Constraints:** Inherits `core/ground-rules` 6 content rules + `core/output` 5 golden rules. Cannot-ground → `"I cannot verify this"` per `core/ground-rules` Rule 2. No persona theater. No subagent spawn (see OQ3).

### Slash command body (`helper/commands/help.md`)

Thin shell:
- Accepts free-form `<question>` argument.
- If argument is empty, opens a `AskUserQuestion` picker offering 3 starter topics (`Install`, `Pick a skill`, `Explain a concept`).
- Otherwise, dispatches to Helper agent via `Skill(helper)` or by inlining its Steps.

### Friction-signal detection (NF6 — in-process)

Detection runs in the **main Claude Code agent's own context** — not as a separate subagent. The detection is a small piece of logic the main agent applies after each user message and after each `AskUserQuestion` response.

| Signal | Definition | Trigger condition |
|---|---|---|
| (a) Gate-reject pattern | Two consecutive `[c] reject` selections at any `lsa-specify` gate within the same gate sequence | After the second `[c] reject`, before re-presenting the gate, invoke Helper. |
| (b) Free-form question | User message contains `?` OR matches `(what\|why\|how) (is\|are\|does)` patterns OR starts with `?` | On user message receipt, before normal routing, check pattern. If match AND user is not already inside a skill flow, invoke Helper. |
| (c) Explicit `/help` | User invokes the `/help` slash command | Always invoke Helper. |

**Cooldown:** After Helper auto-engages once for a given signal-type and the user declines re-explanation (`AskUserQuestion` → No), do not re-auto-engage on the same signal-type until a different signal-type fires or the user explicitly invokes `/help`. Prevents nag-spam.

### Knowledge scope (F4)

- **This repo:** `vision/`, `core/`, `lsa/`, `README.md`, `CONTRIBUTING.md`, `lsa/ARCHITECTURE.md`, all `SKILL.md`, all `CHANGELOG.md`.
- **Installed plugins (best-effort):** `~/.claude/plugins/cache/**/README.md`, `**/SKILL.md`, `**/plugin.json`. Read-only; Helper does not modify installed-plugin caches.
- **External:** via `context7` MCP server when subject is not in repo or installed-plugin scope.

## Data Model Changes

None.

## API / Interface Changes

None — `contract.yaml` skipped at User Verification 1 (no API endpoint, no request/response schema, no DB schema, no typed cross-module data type). Helper interacts entirely via substrate-native tools (`AskUserQuestion`, `Skill`, `Read`, `Grep`, `Glob`, `context7` MCP).

## Cross-Module Contracts

- **`helper` ↔ `lsa-specify` (auto-engage signal).** Helper observes `lsa-specify` gate-reject state through the main-agent's own conversation context — no typed signal is emitted by `lsa-specify`. The detection logic reads the most recent `AskUserQuestion` answer at an `lsa-specify` gate. Behavioural contract only; no API change to `lsa-specify`.
- **`helper` ↔ `core` (output discipline).** Helper inherits `core/output` 5 golden rules and `core/ground-rules` 6 content rules by citation. Pure prose reference; no code dependency.
- **`helper` ↔ `core/actor-template` (Actor shape).** `helper/agents/helper.md` matches the Goal / Input / Steps / Output / Constraints structure. Validated by `lsa-verify` post-implementation.

## Open Questions

- **OQ1 — Cross-cutting AC handling.** AC6 (substrate-native pickers), AC7 (re-grounding gloss), AC8 (length budget) are constraints on every Helper response, not discrete journeys. Two resolutions:
  - (a) Keep as ACs; treat all 3 journeys as "Covers" them collectively (current draft).
  - (b) Demote to NFRs (already partially covered by NF3 substrate-native).
  - **Tentative:** (a) — preserves `lsa-verify` traceability. Diagonal AC→Journey row treats them as covered by every journey.
- **OQ2 — Friction-signal cooldown specifics.** Current design: cooldown is per signal-type within one friction window. To finalise at `lsa-plan` epic decomposition.
- **OQ3 — Helper spawning subagents.** When user asks a wide question (e.g. "explain the diagonal coverage check"), Helper might benefit from spawning an `Explore` subagent. F3 says "invoke matching skill", which is narrower than subagent spawn. **Tentative:** NO — Helper uses `Read` / `Grep` directly, no subagent spawn (Out of Scope at requirements.md). To finalise here or move to `lsa-plan`.
- **OQ4 — Auto-engage in plain Claude Code, no `lsa-specify` context.** Signal (a) requires `lsa-specify` to be active. If user is not in `lsa-specify`, signal (a) cannot fire. Acceptable: Helper still works via signals (b) and (c). Documented explicitly so a `lsa-verify` reviewer doesn't flag missing trace.
