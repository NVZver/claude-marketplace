# Feature: Helper Agent

## Summary

Ship a third plugin `helper` to the marketplace: a friendly, fact-grounded assistant for anyone working with the system. Provides a `/help` slash command AND an auto-engaging subagent that activates on user-friction signals (two consecutive `[c] reject` at an `lsa-specify` User Verification, free-form questions, explicit `/help`). Answers in-flow with `file:line` (or URL) citations and can invoke other skills (e.g. `lsa-specify`) on the user's behalf — always under explicit `AskUserQuestion` confirmation. Knowledge scope: this repo + installed plugins + external library docs via `context7` MCP. Inherits `core/output` discipline (≤1.5 screens/turn, `AskUserQuestion` for every decision, re-ground project jargon on first turn-use). Per the roadmap row at `vision/specs/roadmap.md:12`.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | Ship a `/help` slash command (`helper/commands/help.md`) the user can invoke at any moment to ask a question or request a walkthrough. | Must |
| F2 | Ship an auto-engaging subagent (`helper/agents/helper.md`) that activates on user-friction signals: (a) two consecutive `[c] reject` at any `lsa-specify` User Verification, (b) user types a free-form `?` / `what is X?` mid-session, (c) explicit `/help`. Detection runs in main agent context, not a separate detector subagent. | Must |
| F3 | When user expresses workflow intent ("I want to add X", "fix this bug", etc.), Helper confirms via `AskUserQuestion` and on Yes invokes the matching skill via the `Skill` tool. Never silent hand-off. | Must |
| F4 | Helper's knowledge scope: `vision/`, `core/`, `lsa/`, READMEs of this repo; READMEs + `SKILL.md` of user's other installed plugins; external library docs via the `context7` MCP server when relevant. | Must |
| F5 | Every Helper response inherits `core/output` 5 golden rules (structured · minimal · formatted · sourced · concrete) and `core/ground-rules` 6 content rules. ≤1.5 screens/turn; project jargon (`Standard`, `User Verification N`, `LSA`, `SKILL.md`) gets a 3–5 word gloss on first turn-use. | Must |
| F6 | When Helper cannot ground a claim in repo / installed plugins / `context7`, it responds "I cannot verify this" + states which sources were checked + offers `AskUserQuestion` next steps. No fabricated answer. Per `core/ground-rules` Rule 2. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | **Per-plugin SemVer + CHANGELOG.** `helper` plugin maintains its own `CHANGELOG.md` (Keep a Changelog format) and SemVer in `helper/.claude-plugin/plugin.json`. v0.1.0 at first release. Per `vision/VISION.md` §1 *"Distribution + versioning"* and `vision/specs/main.spec.md:30` NFR3. |
| NF2 | **Fact-grounding.** Every Helper claim carries a `file:line` citation (in-repo) or URL citation (external via `context7`). Per `vision/specs/main.spec.md:28` NFR1. |
| NF3 | **Substrate-native.** Every decision-bearing prompt uses `AskUserQuestion`; never a text `[a]/[b]/[c]` block in a live Claude Code session. Per `vision/VISION.md:63` Principle 9. |
| NF4 | **Knowledge vs Actor separation.** `helper/agents/helper.md` is an Actor (Goal · Input · Steps · Output · Constraints per `core/actor-template`). Any standalone Knowledge that Helper teaches lives in `helper/knowledge/`. Per `vision/specs/main.spec.md:32` NFR5. |
| NF5 | **No filler.** Helper never pads — no preamble, no recap, no "happy to help!" Per `core/ground-rules` Rule 5 (No filler). |
| NF6 | **Detection in-process.** Friction-signal detection runs in the main Claude Code agent's own context; auto-engage fires the same turn the signal appears. No separate detector subagent. |

## Inputs & Outputs

- **Input:**
  - User invocation: `/help <question>`, free-form `?` / `what is X?` text, or detected friction at an `lsa-specify` User Verification.
  - Ambient state: this repo's `vision/`, `core/`, `lsa/`, READMEs; the user's other installed plugins' READMEs + `SKILL.md` files.
  - Optional: `context7` MCP server (for external library docs).
- **Output:**
  - Helper response: ≤1.5 screens, structured per `core/output`, with `file:line` or URL citations per claim, ending with `AskUserQuestion` offering 2–3 next steps.
  - Optionally: a `Skill(<name>)` invocation on the user's confirmed intent.
- **Side effects:** None outside the conversation. Helper does not write files, does not modify state, does not persist across Claude Code sessions.

## Constraints

- **NFR1 fact-grounding** (`vision/specs/main.spec.md:28`) — every Helper claim carries a source + searchable quote.
- **NFR2 spec-grounding** (`vision/specs/main.spec.md:29`) — every behavior below traces back to an AC.
- **NFR3 per-plugin SemVer + CHANGELOG** (`vision/specs/main.spec.md:30`) — new `helper` plugin gets its own from day one.
- **NFR5 Knowledge vs Actor separation** (`vision/specs/main.spec.md:32`) — agent body holds how-to-act; knowledge files hold what-is-true.
- **Vision Principle 9 — substrate-native first** (`vision/VISION.md:63`) — `AskUserQuestion`, `Skill`, `Read`/`Edit`/`Write` only.
- **Vision §2 sub-principle 2a — journey-shaped ACs** (`vision/VISION.md:57`) — every AC describes user-observable behavior at the user/system boundary.
- **Memory: re-ground jargon per turn** (`finding_helper_must_reground`) — Helper re-glosses project terms on first use each turn.
- **Memory: outputs ≤1.5 screens** (`feedback_output_length`) — Helper splits long answers into multiple turns.
- **Memory: real-world prompt phrasing** (`feedback_gate_prompts_concrete`) — Helper's `AskUserQuestion` options use subject phrasing, never opaque IDs (no `F1` / `AC2` / `OQ5`).

## Out of Scope

- No retrofit of existing `core/` or `lsa/` skills to call Helper internally. Helper is a consumer; other skills stay unaware.
- No confusion-detection inside subagent-spawned contexts. Main agent context only.
- No conversation-state persistence between Claude Code sessions. Each `/help` invocation starts cold.
- No persona theater — no name, no avatar, no greeting beyond `core/output` discipline. "Helper" is the role, not a character.
- No first-run onboarding wizard separate from `/help`.
- No publishing of Helper docs to external destinations (Claude.ai upload, etc.). Ships only as a Claude Code plugin.
- No automated lint for friction-signal detection — agent-judged at runtime; human can always intervene with explicit `/help` or "stop".

## Acceptance Criteria

Journey-shaped per `vision/VISION.md` §2 sub-principle 2a — every AC describes user-observable behavior at the user/system boundary. EARS patterns where applicable per `vision/VISION.md:198`.

- [ ] **AC1 — Inline question (`/help` slash command).**
  *Journey:* user types `/help what is the Standard flow?` mid-session, with no prior Helper context.
  *Behavior:* **When** `/help` is invoked with a free-form question, **the system shall** respond in ≤1.5 screens with a re-grounded definition, a `file:line` citation per claim, and a closing `AskUserQuestion` offering 2–3 next steps.

- [ ] **AC2 — Friction auto-engage at `lsa-specify` User Verification.**
  *Journey:* user has rejected an `lsa-specify` User Verification with `[c]` once; rejects it again.
  *Behavior:* **When** two consecutive `[c] reject` selections occur at any `lsa-specify` User Verification, **the system shall** auto-engage Helper, which asks via `AskUserQuestion` whether the user wants the Verification's purpose re-explained. **On Yes**, Helper re-grounds the Verification purpose with `file:line` citations from `lsa/skills/lsa-specify/SKILL.md`.

- [ ] **AC3 — Workflow handoff.**
  *Journey:* user types "I want to add password reset" (or any new-feature intent) into Helper.
  *Behavior:* **When** Helper detects new-feature intent in the user's question, **the system shall** confirm via `AskUserQuestion` ("Start `lsa-specify` for this? — Yes / No") and, **on Yes**, invoke `Skill(lsa-specify)` with the user's description as the argument. User lands inside the started skill.

- [ ] **AC4 — External library question.**
  *Journey:* user asks Helper about an external dependency (`/help what's the context7 MCP?`).
  *Behavior:* **When** Helper recognises an external-library question (subject is not in repo / installed plugins), **the system shall** fetch via the `context7` MCP server and respond with a URL-cited answer in ≤1.5 screens.

- [ ] **AC5 — Cannot-ground fallback.**
  *Journey:* user asks Helper a question whose subject does not appear in repo, installed plugins, or `context7`.
  *Behavior:* **If** no grounded source is found after a bounded read, **then the system shall** respond `"I cannot verify this"`, state which sources were checked (e.g., "checked `vision/`, `core/`, `lsa/`, installed plugins, `context7`"), and offer `AskUserQuestion` next steps. No fabricated answer is produced.

- [ ] **AC6 — Substrate-native decisions.**
  *Journey:* any moment Helper offers options to the user.
  *Behavior:* **The system shall always** render decisions via `AskUserQuestion` (Claude Code native picker), never as a text `[a]/[b]/[c]` block. Per `vision/VISION.md:63`.

- [ ] **AC7 — Re-grounding jargon on first turn-use.**
  *Journey:* Helper's response uses a project-internal term (`Standard`, SKILL.md, `lsa-verify`, User Verification N) for the first time in the current turn.
  *Behavior:* **When** Helper uses a project-internal term in a turn for the first time, **the system shall** include a 3–5 word inline gloss (e.g. "Standard — moderate-effort flow"). Acronyms (`LSA`, `EARS`, `MCP`) get re-glossed every turn.

- [ ] **AC8 — Output length budget.**
  *Journey:* Helper composes any response.
  *Behavior:* **The system shall** keep every response to ≤1.5 screens; **if** the answer needs more, **then the system shall** split it across turns, ending each with `AskUserQuestion` offering "show more" or pivot. No single response exceeds the budget.
