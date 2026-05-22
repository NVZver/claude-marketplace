# Tasks: Helper Agent

## Epic Overview

| Epic | Branch | Status | Dependency |
|------|--------|--------|------------|
| E1: Plugin shell + marketplace registration | `feature/2026-05-21-helper-agent-e1` | pending | none |
| E2: Helper subagent body + knowledge | `feature/2026-05-21-helper-agent-e2` | pending | E1 |
| E3: `/help` slash command body | `feature/2026-05-21-helper-agent-e3` | pending | E1 |
| E4: Friction-signal detection + cooldown | `feature/2026-05-21-helper-agent-e4` | pending | E2 |

E2 and E3 run in parallel after E1. E4 ships last (extends E2's agent body).

---

## Epic 1: Plugin shell + marketplace registration

### Description

Make `helper` installable as a third plugin alongside `core` and `lsa`. Ship the plugin manifest, CHANGELOG skeleton, README skeleton, and register in `.claude-plugin/marketplace.json` + repo `README.md` install lede. After E1, `/plugin install helper@NVZver` succeeds (V1 probe passes) even though no agent or command is wired yet.

### Scope

- Files/modules touched:
  - `helper/.claude-plugin/plugin.json` — NEW
  - `helper/CHANGELOG.md` — NEW (Keep-a-Changelog format, v0.1.0 entry)
  - `helper/README.md` — NEW (install + skill table skeleton; rows filled by E2/E3/E4)
  - `helper/commands/help.md` — NEW (stub: prints "Helper not yet implemented", to be fleshed out in E3)
  - `helper/agents/helper.md` — NEW (stub: Goal + placeholder Steps, to be fleshed out in E2)
  - `.claude-plugin/marketplace.json` — MODIFY (add `helper` to plugins array)
  - `README.md` (repo root) — MODIFY (extend install lede to name `helper` alongside `core` + `lsa`)
- Creates: 5 new files in `helper/`
- Modifies: `.claude-plugin/marketplace.json`, `README.md`
- Does NOT touch: `vision/`, `core/`, `lsa/`

**Covers:** F1 (command file as stub), F2 (subagent file as stub), NF1 (SemVer + CHANGELOG present from v0.1.0)

### Technical Details

- Plugin manifest: `name: helper`, `version: 0.1.0`, `description` names purpose (friendly fact-grounded assistant). Cite the `description: "Depends on core for ground-rules + output discipline"` shape from `lsa/.claude-plugin/plugin.json` (until Claude Code adds a typed `dependencies` field per `vision/specs/main.spec.md:23`).
- `helper/README.md` — match `core/README.md` + `lsa/README.md` structure (Purpose, Skills/Commands/Agents table, Install, Depends-on).
- `.claude-plugin/marketplace.json` — append-only edit (add `helper` to the plugins array, do not reorder).
- Repo `README.md` — extend the `/plugin install` block; bump the "always-on rules" lede if Helper is described as always-on (per design.md it is auto-engaging but not always-on — frame as "third on-demand plugin").
- Per `vision/specs/standards/testing.md` *"Run V1 first"*: ship stubs only in this epic; V1 = `/plugin install helper@NVZver` succeeds + `helper` appears in `/plugin list`.

### Acceptance Criteria

- [ ] E1-AC1: `/plugin install helper@NVZver` succeeds in a fresh Claude Code session.
- [ ] E1-AC2: `helper/.claude-plugin/plugin.json` parses as valid JSON; `version: 0.1.0`.
- [ ] E1-AC3: `helper/CHANGELOG.md` has a `[0.1.0]` entry naming the scaffold scope.
- [ ] E1-AC4: `.claude-plugin/marketplace.json` lists `helper` alongside `core` and `lsa`.
- [ ] E1-AC5: Repo `README.md` install block names all three plugins.

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | `helper/.claude-plugin/plugin.json` is valid JSON; required fields present (name, version, description) | Must |
| Integration | V1 probe — install in fresh session, confirm appears in `/plugin list` | Must |
| E2E | n/a — no behavior yet; V2/V3 land in E2/E3 | — |

### Definition of Done

- [ ] All E1 ACs pass
- [ ] V1 probe documented in `helper/README.md`
- [ ] No code smells per `vision/specs/standards/code.md` *"Markdown-only"*
- [ ] `lsa-verify` PASS on `feature/2026-05-21-helper-agent-e1`
- [ ] Repo README + marketplace edits committed in the SAME commit as the plugin scaffold (per `CLAUDE.md` *"READMEs are living documents"*)

---

## Epic 2: Helper subagent body + knowledge

### Description

Flesh out `helper/agents/helper.md` from the E1 stub into a full Actor per `core/actor-template` — Goal / Input / Steps / Output / Constraints. Implement the cited claim → file:line citation discipline, the `AskUserQuestion`-confirm-then-`Skill` handoff, the cannot-ground fallback, jargon re-grounding, and length-budget self-clipping. Add `helper/knowledge/` files for any standalone Knowledge the agent reads.

### Scope

- Files/modules touched:
  - `helper/agents/helper.md` — MODIFY (replace E1 stub with full body)
  - `helper/knowledge/output-discipline.md` — NEW (re-grounded summary of `core/output` rules Helper applies; pure Knowledge file per NF4)
  - `helper/knowledge/knowledge-scope.md` — NEW (lists the read globs per F4: repo paths, installed-plugin paths, when to invoke `context7`)
  - `helper/README.md` — MODIFY (fill the agent row of the skill table)
  - `helper/CHANGELOG.md` — MODIFY (add `## [0.1.0] – Unreleased` entry for the agent body)
- Creates: 2 new knowledge files
- Modifies: `helper/agents/helper.md`, `helper/README.md`, `helper/CHANGELOG.md`
- Does NOT touch: detection signal logic (E4), `/help` command body (E3), other plugins

**Covers:** F3, F4, F5, F6, AC1, AC3, AC4, AC5, AC6, AC7, AC8, NF2, NF3, NF4, NF5

### Technical Details

- Agent frontmatter: `name: helper`, tools list = `Read, Grep, Glob, AskUserQuestion, Skill, mcp__plugin_context7_context7__*` (only the context7 tools, not all MCPs — narrow per Vision §3 lazy-load).
- **Knowledge vs Actor separation (NF4):** agent body holds only Goal/Input/Steps/Output/Constraints + 3-5 lines of orienting prose; rule lists and reference patterns go into `helper/knowledge/`.
- **OQ3 resolution.** No subagent spawn (no `Agent` tool in the tools list). Helper uses `Read`/`Grep` directly. If implementation reveals this is too narrow, escalate to a spec amendment via `/lsa:specify` re-entry — do not silently widen.
- **OQ1 handling.** AC6/7/8 are cross-cutting per `design.md:89`; this epic implements them as Constraints in the agent body that fire on every response, not as discrete Steps.
- Per `vision/specs/standards/testing.md` ~90% threshold: V2 probe writes a fresh-session log of any-claim-made tasks Helper *should* have engaged on; threshold < 90% triggers description rewrite (not body changes).

### Acceptance Criteria

- [ ] E2-AC1: `helper/agents/helper.md` matches Goal/Input/Steps/Output/Constraints shape per `core/skills/actor-template/SKILL.md`.
- [ ] E2-AC2: Manual probe — invoke Helper with a free-form question grounded in this repo → response includes a `file:line` citation per claim (per AC1, NF2).
- [ ] E2-AC3: Manual probe — invoke Helper with an external-library question → Helper fetches via `context7` MCP and cites the URL (per AC4).
- [ ] E2-AC4: Manual probe — invoke Helper with an unanswerable question → Helper responds `"I cannot verify this. Checked: …"` + `AskUserQuestion` next steps (per AC5, F6).
- [ ] E2-AC5: Manual probe — Helper response length ≤1.5 screens; longer answers split across turns ending with `AskUserQuestion` (per AC8).
- [ ] E2-AC6: Manual probe — Helper uses `AskUserQuestion` for every decision; no text `[a]/[b]/[c]` blocks (per AC6, NF3).
- [ ] E2-AC7: Manual probe — Helper re-grosses project jargon on first turn-use (e.g. "T2 — Standard ceremony tier") (per AC7).
- [ ] E2-AC8: Manual probe — Helper recognises new-feature intent ("I want to add X") → asks `AskUserQuestion` "Start `lsa-specify`? — Yes/No"; on Yes invokes `Skill(lsa-specify)` (per AC3, F3).

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | `helper/agents/helper.md` frontmatter valid; Goal/Input/Steps/Output/Constraints sections present | Must |
| Integration | V2 probe — Helper agent description-matches in a fresh session when user asks a free-form question | Must |
| E2E | Run all paths of test-suites.md Journey 1 (Quick lookup) and Journey 3 (Workflow handoff) | Must |

### Definition of Done

- [ ] All E2 ACs pass
- [ ] V2 probe + 5+ E2E session transcripts captured in `helper/VERIFICATION.md`
- [ ] OQ1 + OQ3 marked RESOLVED in `design.md` § Open Questions
- [ ] `lsa-verify` PASS on `feature/2026-05-21-helper-agent-e2`
- [ ] `helper/README.md` agent row filled; `helper/CHANGELOG.md` updated in the same commit

---

## Epic 3: `/help` slash command body

### Description

Flesh out `helper/commands/help.md` from the E1 stub into a working slash command. Two modes: with an argument (`/help <question>`) dispatches to the Helper agent; without argument, opens an `AskUserQuestion` picker with 3 starter topics. Runs in parallel with E2 (each can stub the other; final integration verifies they compose).

### Scope

- Files/modules touched:
  - `helper/commands/help.md` — MODIFY (replace E1 stub with full body)
  - `helper/README.md` — MODIFY (fill the command row of the skill table)
  - `helper/CHANGELOG.md` — MODIFY (note the `/help` command landed)
- Does NOT touch: agent body (E2), detection logic (E4)

**Covers:** F1, AC1

### Technical Details

- Command frontmatter: `description: "Ask Helper a question or pick a starter topic"`; positional arg = `<question>` (free-form text).
- Empty-arg branch: opens `AskUserQuestion` with options `[Install / Pick a skill / Explain a concept]`; routes to Helper agent with the picked topic as seed.
- Non-empty branch: invokes `Skill(helper)` with the user's question as input.
- During E2/E3 parallel work: E3 can be tested against an E2 stub by mocking the agent's response to "echo question + cite this README".

### Acceptance Criteria

- [ ] E3-AC1: `/help` (no argument) opens an `AskUserQuestion` with 3 starter topics (per AC6).
- [ ] E3-AC2: `/help <question>` dispatches to Helper agent and shows a response (per AC1).
- [ ] E3-AC3: `/help` command appears in `/help` listing after `/plugin install`.

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | `helper/commands/help.md` frontmatter valid; positional arg pattern set | Must |
| Integration | V1 probe — `/help` appears in command list after install | Must |
| E2E | Run test-suites.md Journey 1 Happy path (`/help what is T2?`) | Must |

### Definition of Done

- [ ] All E3 ACs pass
- [ ] V1 + E2E probe documented in `helper/VERIFICATION.md`
- [ ] `lsa-verify` PASS on `feature/2026-05-21-helper-agent-e3`

---

## Epic 4: Friction-signal detection + cooldown

### Description

Wire the auto-engage path. Extend `helper/agents/helper.md` (from E2) with the in-process detection logic for signals (a), (b), (c) per `design.md:57`. Add `helper/knowledge/friction-signals.md` codifying the patterns + cooldown rule. Resolves OQ2 (cooldown specifics).

### Scope

- Files/modules touched:
  - `helper/agents/helper.md` — MODIFY (add detection Steps + cooldown bookkeeping)
  - `helper/knowledge/friction-signals.md` — NEW (signals a/b/c definitions, trigger patterns, cooldown rule)
  - `helper/README.md` — MODIFY (note auto-engage behavior)
  - `helper/CHANGELOG.md` — MODIFY (note auto-engage landed)
- Does NOT touch: `lsa/skills/lsa-specify/SKILL.md` (signal observation is one-way from Helper's side — `lsa-specify` stays unaware per `design.md:84`)

**Covers:** F2, AC2, NF6

### Technical Details

- **Signal (a) — gate-reject:** Helper agent body's Steps add a precondition check: "before responding to any user message, check if the most recent `AskUserQuestion` answer was `[c] reject` at an `lsa-specify` gate AND the prior answer was also `[c] reject` at the same gate". If true, fire auto-engage.
- **Signal (b) — free-form question:** check if user message matches `^\s*\?` OR contains `(what|why|how)\s+(is|are|does|do)` AND user is not inside an active skill flow. If true, fire auto-engage.
- **Signal (c) — explicit `/help`:** handled by E3's command, not detection.
- **Cooldown (OQ2 resolution):** after Helper auto-engages once for a signal-type and the user declines re-explanation (`AskUserQuestion` → No), do not re-auto-engage on the same signal-type until a different signal-type fires OR the user explicitly invokes `/help`. Track cooldown in agent's working memory for the session.
- **OQ4 acknowledgement:** signal (a) only fires when `lsa-specify` is the active flow; documented in `helper/knowledge/friction-signals.md`.

### Acceptance Criteria

- [ ] E4-AC1: Manual probe — invoke `lsa-specify`, reject a gate with `[c]` twice → Helper auto-engages with `AskUserQuestion` "Want me to explain what this gate is checking?" (per AC2).
- [ ] E4-AC2: Manual probe — user types `what is T2?` mid-session (no active skill) → Helper auto-engages and answers (per F2 signal b).
- [ ] E4-AC3: Manual probe — same trigger as E4-AC1, user picks No → Helper steps back; same trigger fires again immediately, Helper does NOT re-engage (cooldown).
- [ ] E4-AC4: Manual probe — user persists rejecting after Helper explained → Helper does NOT re-engage (no nag).

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | `helper/knowledge/friction-signals.md` documents signals a/b/c + cooldown rule | Must |
| Integration | V2 probe — auto-engage fires within the same turn the signal appears | Must |
| E2E | Run test-suites.md Journey 2 (Friction auto-engage) — all 3 paths (Happy / Alternate-declined / Error-persistent-reject) | Must |

### Definition of Done

- [ ] All E4 ACs pass
- [ ] OQ2 marked RESOLVED in `design.md` § Open Questions
- [ ] `lsa-verify` PASS on `feature/2026-05-21-helper-agent-e4`
- [ ] `helper/VERIFICATION.md` extended with auto-engage probes
- [ ] `helper/CHANGELOG.md` finalized — bump to `0.1.0` if all E1–E4 land in one minor release

---

## Integration Checklist

- [ ] E1 merged into `feature/2026-05-21-helper-agent`
- [ ] E2 + E3 merged into `feature/2026-05-21-helper-agent` (parallel)
- [ ] E4 merged into `feature/2026-05-21-helper-agent`
- [ ] All 8 ACs (AC1–AC8) verified end-to-end on the feature branch via test-suites.md journeys
- [ ] `lsa-verify` PASS on the feature branch with 0 untraced changes
- [ ] `lsa-sync` lands `vision/specs/modules/helper/spec.md`, updates `vision/specs/main.spec.md` Module Index, marks roadmap row shipped
- [ ] `lsa-revise-constitution` reviewed (no constitution change expected for this feature)
- [ ] PR to `main` opened: title `feat(helper): friendly fact-grounded assistant (v0.1.0)`
