> **Trace.** On load, print first: `=============== [helper/knowledge/friction-signals.md] [helper] ===============`

# Friction signals — knowledge

When the Helper agent auto-engages and when it stays out of the way. Per [`vision/specs/features/2026-05-21-helper-agent/requirements.md`](../../vision/specs/features/2026-05-21-helper-agent/requirements.md) F2 and [`vision/specs/features/2026-05-21-helper-agent/design.md`](../../vision/specs/features/2026-05-21-helper-agent/design.md) § *Friction-signal detection*.

Detection runs in the main Claude Code agent's own context — not as a separate detector subagent. The main agent matches Helper's `description` (frontmatter of [`../agents/helper.md`](../agents/helper.md)) against the live conversation and invokes Helper on signal-match. This file is the canonical spec for which patterns count.

## The three signals

| Signal | Definition | Trigger condition |
|---|---|---|
| (a) User-Verification-reject pattern | Two consecutive `[c] reject` selections at any `lsa-specify` User Verification within the same Verification sequence (no other Verification or skill in between). | After the second `[c] reject`, **before** re-presenting the Verification, invoke Helper with the Verification name and the rejection history as context. |
| (b) Free-form question | User message contains `?` OR matches `(what\|why\|how)\s+(is\|are\|does\|do)\b` AND user is not already inside an active skill flow (no in-progress `Skill()` invocation, no open `AskUserQuestion` from another skill). | On user-message receipt, before normal routing. If match, invoke Helper with the question as input. |
| (c) Explicit `/help` | User invokes the `/help` slash command (with or without argument). | Always invoke Helper. Handled by [`../commands/help.md`](../commands/help.md), not by this detection logic — listed here for completeness. |

## Cooldown rule (OQ2 resolution)

**Per signal-type, per session.** After Helper auto-engages once on a given signal-type and the user declines re-explanation (`AskUserQuestion` → No or equivalent), the main agent does NOT re-auto-engage on the **same signal-type** until:

1. A **different signal-type** fires (a → b, b → a, etc.), OR
2. The user **explicitly invokes** `/help` (signal c always resets all cooldowns), OR
3. The session ends (cooldown does not persist across Claude Code sessions — see Out of Scope below).

This prevents nag-spam: if the user wants Helper out of the way for one kind of friction, the main agent respects that for that kind. Signal (c) — explicit `/help` — always works regardless of cooldown state because it is the user's own pull.

### What counts as "declined"

- `AskUserQuestion` → `No` to "Want me to explain…?"
- `AskUserQuestion` → any option whose label includes `Skip` / `Drop` / `Not now` / `Move on`.
- A user message that pivots away from the offered help (e.g. user types a new substantive request instead of answering the picker).

### What does NOT count as declined

- The user accepts (`Yes`) but then rejects the Verification again afterwards. The first auto-engage was successful; Helper does not re-engage on the *next* `[c]` cycle within the same Verification sequence regardless (see "One per friction window" below).
- The user picks a non-Helper option from a non-Helper picker (e.g. answers an `lsa-specify` User Verification picker normally).

> **Note.** If Step 5 closes without a picker, no cooldown event is recorded; cooldown applies per-picker. Per `vision/specs/features/2026-05-22-askuserquestion-audit/tasks.md` C4.

### One per friction window

Even on the same signal-type with no explicit "No": Helper auto-engages **at most once** per continuous friction window. A friction window for signal (a) ends when the user either approves the Verification (`[a]`), accepts an `[b] approve with overrides`, or abandons the skill. After the window closes, signal (a) is eligible again on a fresh User-Verification-reject pair.

## OQ4 — Auto-engage in plain Claude Code (no `lsa-specify` active)

Signal (a) **requires `lsa-specify` to be the active skill flow.** If the user is not in `lsa-specify`, signal (a) cannot fire. This is acceptable: Helper still auto-engages via signals (b) and (c), and the user can always pull explicitly with `/help`. Documented per `design.md` OQ4 so an `lsa-verify` reviewer does not flag the asymmetry as missing trace.

## What the main agent observes (not what Helper persists)

The cooldown lives in the **main Claude Code agent's own working memory** for the session. Helper does not write state files, does not modify installed-plugin caches, and does not persist anything across sessions (per `requirements.md` § Out of Scope *"No conversation-state persistence between Claude Code sessions"*). The main agent re-derives cooldown state by reading the conversation transcript:

- Did Helper already auto-engage for signal X this session? → look for prior Helper response triggered by signal X.
- Did the user decline? → look for the immediately-following `AskUserQuestion` answer.
- Has a different signal-type fired since? → walk forward in the transcript.

## Trigger patterns — quick reference

| Pattern | Signal | Example |
|---|---|---|
| Second `[c] reject` at same `lsa-specify` User Verification | (a) | User Verification 1 → `[c]` → re-present → `[c]` → Helper engages |
| Free-form `?` mid-flow, no skill active | (b) | User: `what's a SKILL.md?` → Helper engages |
| `(what\|why\|how)` + `(is\|are\|does\|do)` mid-flow | (b) | User: `how does lsa-verify work?` → Helper engages |
| `/help` invocation | (c) | User: `/help` or `/help <question>` → Helper always engages |

Patterns that look like signals but **do not** trigger Helper:

- A `?` inside an active skill's own `AskUserQuestion` answer (user is mid-flow; the skill owns the turn).
- A `what is X?` typed AS the answer to an `AskUserQuestion` picker (the skill owns the answer slot).
- Rhetorical `?` in a statement Helper would have nothing to add to (e.g. `"so we're doing this now?"` — no actionable subject).

The main agent applies judgement on edge cases; Helper does not block in protest if the signal is missed. The user can always pull with `/help`.
