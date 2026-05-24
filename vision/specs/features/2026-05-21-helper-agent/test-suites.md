> **Trace.** On load, print first: `=============== [vision/specs/features/2026-05-21-helper-agent/test-suites.md] [vision] ===============`

# Test Suites: Helper Agent

Three journeys, each anchored to a distinct user goal. Cross-cutting ACs (AC6 substrate-native pickers, AC7 re-grounding gloss, AC8 length budget) appear in **every** journey's `**Covers:**` line because they constrain every Helper turn rather than describing a discrete journey of their own.

---

## Journey 1: Quick lookup / definition

**Goal:** User gets a grounded answer to a question about the marketplace (or an external dependency the marketplace touches) without leaving their current flow.
**Covers:** AC1, AC4, AC5, AC6, AC7, AC8.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — in-repo lookup | User types `/help what is the Standard flow?` → Helper reads `vision/VISION.md` + `core/skills/flow-selector/SKILL.md` → composes ≤1.5-screen response with definition + `file:line` citation + first-turn-use gloss ("Standard — moderate-effort flow") → closes with `AskUserQuestion` offering next steps (`Show worked example`, `Move on`, `Compare to Quick / Extended`). |
| 2 | Alternate — external library | User types `/help what's the context7 MCP?` → Helper recognises subject is not in repo or installed plugins → fetches via `context7` MCP tool → composes ≤1.5-screen response with URL citation + acronym re-gloss (`MCP — Model Context Protocol`) → closes with `AskUserQuestion`. |
| 3 | Error — cannot ground | User types `/help what's foobaz?` → Helper reads repo + installed plugins + queries `context7` → no source found → responds `"I cannot verify this. Checked: vision/, core/, lsa/, installed plugins, context7."` + `AskUserQuestion` offering `Rephrase the question` / `Drop this` / `Continue without answer`. No fabricated content. |

**Expected outcome:**
- *Happy paths (1, 2):* User has a cited answer in ≤1.5 screens; can pull more detail via picker.
- *Error path (3):* User sees explicit non-answer; no hallucination; can decide whether to rephrase or move on.

---

## Journey 2: Friction auto-engage at an `lsa:discover` User Verification

**Goal:** User is stuck at an `lsa:discover` User Verification (rejected it once, about to reject again); Helper unsticks them without forcing them through the Verification.
**Covers:** AC2, AC6, AC7, AC8.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — re-explain accepted | User selects `[c] reject` at, say, User Verification 1 in `lsa:discover`; the skill re-presents; user selects `[c] reject` again → friction signal (a) fires → Helper auto-engages with `AskUserQuestion`: "Want me to explain what this User Verification is asking? — Yes / No" → user picks Yes → Helper re-grounds the Verification purpose with `file:line` citation from `lsa/skills/discover/SKILL.md` (re-gloss "User Verification" as "the checkpoint where you approve the artifact") → user understands, returns to the Verification and approves or makes a substantive override. |
| 2 | Alternate — re-explain declined | Same trigger → user picks No on `AskUserQuestion` → Helper steps back silently; the original Verification picker re-presents; Helper does not re-auto-engage for this same Verification sequence (cooldown). |
| 3 | Error — user persists rejecting after re-explanation | User picks Yes, gets explanation, returns to the Verification, rejects again → Helper does NOT re-auto-engage (one auto-engage per friction window). User can always pull help explicitly via `/help`. |

**Expected outcome:**
- *Happy path (1):* User exits the rejection loop with a grounded understanding.
- *Alternate path (2):* User keeps full control; Helper does not nag.
- *Error path (3):* User retains full control; no infinite Helper loop; explicit `/help` always available.

---

## Journey 3: Workflow handoff

**Goal:** User expresses intent to do something but does not name the skill; Helper recognises the intent and starts the right skill under explicit confirmation.
**Covers:** AC3, AC6, AC7, AC8.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — new-feature intent → `lsa:discover` | User types `I want to add password reset` (via `/help` or as a free-form question caught by signal (b)) → Helper recognises new-feature intent → `AskUserQuestion` "Start `lsa:discover` for this? — Yes / No" (with re-gloss `lsa:discover — discovery + feature spec skill`) → user picks Yes → Helper invokes `Skill(lsa:discover)` with the user's description as argument → user lands inside `lsa:discover`. |
| 2 | Alternate — decline handoff | Same trigger → user picks No → Helper offers alternate next steps: explain why `lsa:discover` was the recommendation, point to relevant docs, suggest a different skill (`lsa:discover` for lighter probe). |
| 3 | Error — ambiguous intent | User types `I think I want to do something with the gates` → Helper cannot map to a single skill → `AskUserQuestion` "Which sounds closest? — New feature spec (`lsa:discover`) / Bug fix or quick task (`lsa:discover`) / Just exploring (no skill)" → routes from there or stops. |

**Expected outcome:**
- *Happy path (1):* User is inside the right skill in one turn, with explicit confirmation logged.
- *Alternate path (2):* User retains control; no silent handoff.
- *Error path (3):* Helper surfaces the ambiguity rather than guessing a skill.
