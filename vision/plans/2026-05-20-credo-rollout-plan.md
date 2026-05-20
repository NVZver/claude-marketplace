# Credo Rollout — Change Plan

**Status:** `[todo — pre-approved, audited post-refactor, ready to apply]` — all 17 samples + all 7 cross-cutting format questions walked through and approved by the user; simplification refactor landed (core@0.3.0, lsa@0.3.1); audit-B (2026-05-20) resolved D1 (drop S16 — keep refactor's mechanical mode detection) and D2 (cross-cutting Rule 6/7 rule goes into `lsa/knowledge/conventions.md` as a new "Prompt shape" Knowledge section, not per-skill Constraints); line-number remap applied throughout Layers 2–3.
**Date:** 2026-05-20 (audit-A: Rule 1 reference discipline; audit-B: post-refactor remap)
**Credo (user-authored, this session):** *"LSA doesn't automate your thinking — it makes you own it."*

**Confirmed decisions:**
- Q1 — Credo placement → option (a): general form in core + LSA-flavored echo in `lsa/README.md`. (Implicitly confirmed via walkthrough acceptance.)
- Q2 — `lsa-specify` gate collapse 7→3 → option (a): do it as planned. (Confirmed by approving S5/S6/S7 in walkthrough.)
- Q3 — Rule 5 ("No filler") scope → option (a): all outputs incl. `vision/VISION.md`. (Confirmed explicitly earlier.)
- F1–F7 (format conventions) → all defaults accepted in bulk.
- S1–S17 (sample bodies) → all approved (S1, S3, S4, S5, S6, S7, S8, S9, S10, S11 individually; S12–S17 bulk on pattern acceptance; S2 approved after path-fix adjust).
- Rule 1 amendment (scope + `[illustrative]` tag) — applied across plan in audit pass.
- Version path corrected: `0.3.0 → 0.4.0` for both `core` and `lsa` (0.3.0 is reserved by the in-flight refactor).

**Audit-B resolutions (2026-05-20, post-refactor):**
- D1 → option (a): drop S16 (lsa-init mode prompt). Refactor's mechanical detection at `lsa/skills/lsa-init/SKILL.md:22` (*"If `${specs_root}/modules/` is empty (or absent) AND `.lsa.yaml: modules.*` contains no configured `artifact_paths`, the mode is **greenfield**; otherwise **brownfield**. Print the determination back to the human… and ask the human to confirm."*) replaces the direct Q. S17 (brownfield confirm) still applies. (User decision, 2026-05-20.)
- D2 → option (a): the cross-cutting "all human-facing prompts follow Rule 6 + Rule 7" rule lives in `lsa/knowledge/conventions.md` as a new section *"Prompt shape"* citing `core/skills/ground-rules/SKILL.md` Rule 6/7 as authority. Each LSA skill's Constraints section adds a one-line citation to that section instead of restating. Matches the existing `conventions.md` pattern (Read protocol, Confirm gate types, Trace-tag format). (User decision, 2026-05-20.)
- Baseline shift: lsa landed at `0.3.1` (refactor `0.3.0` + a `0.3.1` KISS patch). Credo target stays `0.4.0` — still a minor bump over `0.3.1`.

**Open decisions:** none. Plan is fully pre-approved; line-number remap below; ready to apply.

---

## Why this plan exists

User session observation: the system's interactive surface invites rubber-stamping. Vision §1.7 (`vision/VISION.md:60`) names *"the human owns intent"* as a property of the system — but gates as written (open-ended Qs, y/n without consequences, prose-first outputs) let the human disengage. This plan codifies the credo as a first principle and threads four new always-on rules through every actor that talks to the human.

---

## Layer 1 — `core/skills/ground-rules/SKILL.md`

Add 4 new rules. Keep the existing 4. Total = 8.

### Rule 0 — Ownership over automation *(the credo, domain-neutral form)*

> The human owns the thinking. The system surfaces facts, lays out options, and demands a choice — it never silently decides on the human's behalf. A "y/n" with no laid-out consequences is a hidden auto-decision; refuse to ship it that way.
>
> *Per `vision/VISION.md:60` — "The human owns intent; the system absorbs reality."*

### Rule 1 — amendment: scope + illustrative content

Existing Rule 1 (`core/skills/ground-rules/SKILL.md:10-20` — *"Every such claim must come with: a **source** — a document, URL, file path, dataset, or the user's own confirmed statement, and a **searchable quote** — a short verbatim snippet the reader can locate in the source in seconds."*) is amended with two sub-sections:

> **Scope.** Applies to every artifact you author — agent responses, plans, design docs, sample blocks, READMEs, commit messages, changelog entries, memory entries. No exception for "internal" or "draft" content. The reader must be able to verify any reference (file path, line number, version, URL, doc) without re-reading the source themselves.
>
> **Illustrative content.** When a sample, template, or example uses placeholder references that do not point to real things in this repo (e.g., a fake module name like `auth` or a fictional feature like `password-reset-via-email`), tag the block with `[illustrative]` at its top. Distinct from `[unverified]` (real claim, cannot verify) and `[assumption]` (best inference, labelled). Illustrative content makes no claim about reality and must be visibly tagged.

### Rule 5 — No filler

> Every sentence carries one of: a fact (with source), an opinion owned as opinion, or an action. Sentences that only restate the topic, add emotional weight, or decorate transitions are deleted. Headings and one-line section openers are exempt — they orient the reader.
>
> Banned phrasings (examples): *"It's worth noting that…"*, *"At the end of the day…"*, *"This is important because…"* — collapse to the underlying fact or delete.
>
> Applies to all outputs: agent responses, skill bodies, vision docs, READMEs, commit messages.

### Rule 6 — Decisions surface options + outcomes

> Every decision asked of the human is a finite, labelled option list. Each option carries the concrete consequence of choosing it on one line. Banned: open-ended *"what would you like?"* — those force the human to invent a decision space the agent should have framed.
>
> Required shape:
> ```
> Decision: <one-line question>
> [a] <option> — outcome: <one line of what changes>
> [b] <option> — outcome: <one line of what changes>
> [c] custom — describe in one line
> ```

### Rule 7 — Structured-first output

> Every human-facing output starts with: **(1)** a one-line verdict block, **(2)** the decision-or-result block (table or labelled list), **(3)** optional detail below the fold.
>
> The reader's eye must hit the verdict in ≤2 seconds. Banned: prose-first answers when a table or labelled block fits.
>
> **Verdict vocabulary (fixed — pick one):**
>
> | Verdict | When | Emoji |
> |---|---|---|
> | `PROPOSED` | Agent is proposing a draft for human decision | (none) |
> | `READY` | Artifact built, handoff to next phase awaits | (none) |
> | `PASS` | All checks succeeded | ✅ |
> | `PASS WITH WARNINGS` | Succeeded with non-blocking issues | ⚠️ |
> | `FAIL` | One or more blockers; cannot proceed | ❌ |
> | `BLOCKED` | Cannot proceed due to missing prerequisite (not a check failure) | 🛑 |
> | `DRIFT` | Artifacts diverge from spec; reconcile needed | (none) |
> | `CLEAN` | No drift, nothing to do | (none) |
> | `APPLIED` | Change made successfully | ✅ |
> | `REJECTED` | Human said no; state unchanged | (none) |

### Edits to existing parts of `ground-rules`

| File / location | Change |
|---|---|
| `core/skills/ground-rules/SKILL.md` frontmatter `description:` | Append: *"Also enforces ownership-over-automation, no-filler, decision-shape (options + outcomes), and structured-first output."* |
| Body — order | Rule 0 first, then existing 1–4, then 5–7. Add a one-line "Why eight, not four" note linking each to Vision §1 first-principle source. |
| "What this skill never does" section | Add 4 lines mirroring new rules. |

---

## Layer 1.5 — Output format samples (review + pre-approve before apply)

17 samples, one per place the format changes. Each shows the exact text the human would see.

> **Conventions in this section** (per Rule 1 amendment above):
> - Every "Replaces X at Y" header carries a verbatim quote from the cited file.
> - Every sample body uses placeholder names (e.g., `auth`, `password-reset-via-email`) that **do not** refer to anything in this repo — each is therefore tagged `[illustrative]` at its top.
> - Decision blocks always end the message so the reader's cursor is over the next action.

### S1 — `tier-selector` confirm prompt

Replaces `core/skills/tier-selector/SKILL.md:44-48` — verbatim: *"Proposed tier: T<N> / Rationale: <2–4 sentences> / Confirm? (y / n / override to T<other>)"*.

```
[illustrative — `auth` and T2 are placeholders; the real signals come from the user's actual task]
PROPOSED — Tier T2

Signals present:
- New module? ............... no
- API/contract change? ..... no
- Data-model change? ....... no
- > ~5 files? .............. no
- No existing spec? ........ no

Rationale: One bug in a spec'd module (auth — vision/specs/modules/auth/spec.md), behavior change but no new API.
Matches: "One bug in a spec'd module, behavior change, no new API" → T2.

Decision: confirm tier?
[a] confirm T2     — outcome: hand off to lsa-discover (light 3-Q probe)
[b] override T1    — outcome: skip LSA ceremony; single-pass response
[c] override T3    — outcome: hand off to lsa-discover, then lsa-specify
[d] reconsider     — outcome: re-run signal checklist with your correction
```

### S2 — `lsa-discover` Output

Replaces `lsa/skills/lsa-discover/SKILL.md:30` — verbatim: *"write a single-paragraph context summary (one paragraph, 2–4 sentences) naming the chosen module(s), the change, and the AC"*.

```
[illustrative — `auth` is a placeholder; the spec path follows the conventional `.lsa.yaml` layout]
READY — discovery captured

| Field      | Value                                                              |
|------------|--------------------------------------------------------------------|
| Module(s)  | auth → vision/specs/modules/auth/spec.md                           |
| Change     | Add 5-minute timeout to expired sessions                           |
| Acceptance | Expired-session redirect fires within 5 sec                        |

Handoff: T2 → agent writes failing test next.
```

### S3 — `lsa-discover` Step 2 questions

Replaces open Qs at `lsa/skills/lsa-discover/SKILL.md:25-26` — verbatim: *"(b) What's the change in one sentence? / (c) What's the acceptance criterion in one sentence? (How will we know the change is done?)"*.

```
[illustrative — `auth` and session-timeout are placeholders]
PROPOSED — discovery answers (override any line; silence = approve)

Module(s): auth → vision/specs/modules/auth/spec.md  (only candidate from your task description)

Candidate framings for the change (pick or override):
[a] Add 5-minute timeout to expired sessions, redirect to login.
[b] Reduce session expiry from 30d to 5min globally.
[c] custom: <your one-liner>

Candidate acceptance criteria (pick or override):
[a] Expired-session redirect fires within 5 seconds.
[b] No active request can outlive the new timeout.
[c] custom: <your one-liner>
```

### S4 — `lsa-specify` Step 2 `clarification.md`

Replaces 9 open Qs at `lsa/skills/lsa-specify/SKILL.md:42-57` — verbatim opening: *"What does this feature do?"* (L43); closing: *"What are the exact conditions for this feature to be considered done?"* (L57).

```
[illustrative — `password-reset-via-email`, `auth`, `mailer` are placeholders]
PROPOSED — clarification.md (override any line; silence = approve all)

# Clarification — password-reset-via-email

## Functional
- What it does:    Sends a reset-link email; user clicks; sets new password.   [ok]
- Who uses it:     Any registered user who forgot their password.              [ok]
- Inputs:          email (str), reset-token (str), new-password (str)          [override?]
- Outputs:         confirmation email; updated password hash in DB             [override?]
- Edge cases:      expired token, unregistered email, rate limit (3/hour)      [override?]

## Non-functional
- Performance:     email dispatch < 2s; token verification < 100ms             [override?]
- Security:        tokens HMAC-signed, 1-hour TTL, single-use                  [override?]

## Boundaries
- Modules touched: auth → vision/specs/modules/auth/spec.md ;
                   mailer → vision/specs/modules/mailer/spec.md                [override?]
- Must NOT change: existing login flow                                         [override?]

## Acceptance
- AC1: user receives email within 5s of submitting "forgot password"           [override?]
- AC2: clicking expired link shows "link expired" page                         [override?]
- AC3: successful reset invalidates all existing sessions                      [override?]

Decision: approve clarification?
[a] approve all                       — outcome: proceed to Gate 1
[b] approve with overrides (list)     — outcome: re-draft, re-present
[c] reject                            — outcome: stop; re-run lsa-discover
```

### S5 — `lsa-specify` Gate 1

Replaces `lsa/skills/lsa-specify/SKILL.md:107` — verbatim: *"Does requirements.md capture the full scope? Confirm to continue."* — and the contract-trigger Q at `:109-114` — verbatim: *"After confirmation — evaluate contract trigger. Ask the human explicitly: does this feature introduce or modify any of the following?"*.

```
[illustrative — endpoint names, tables, schemas are placeholders]
PROPOSED — Gate 1: requirements.md + AC + contract trigger

[requirements.md content rendered above]

Contract-trigger check:
- API endpoint introduced or modified? ............ yes (POST /auth/reset-request)
- Request/response schema introduced or modified?   yes (ResetRequest, ResetConfirm)
- DB schema or table structure changed? ........... yes (reset_tokens table)
- Shared data type used across modules? ........... no
→ contract.yaml required in Gate 2: YES

Decision: approve Gate 1?
[a] approve                           — outcome: proceed to Gate 2
[b] approve with corrections (list)   — outcome: apply, re-present Gate 1
[c] reject                            — outcome: stop; return to clarification
```

### S6 — `lsa-specify` Gate 2

Bundles three stops in `lsa/skills/lsa-specify/SKILL.md` —
- `:137` — *"Do these journeys cover all user interactions correctly? Confirm to continue."*
- `:159` — *"Does this contract look correct? Confirm or describe corrections — I can apply them."*
- `:187` — *"Does this design look correct? Any concerns before finalizing?"*

```
[illustrative — journey/AC numbers and Q1 are placeholders]
PROPOSED — Gate 2: test-suites.md + contract.yaml + design.md

AC coverage check:
- AC1 → Journey 1 (happy path)             ✓
- AC2 → Journey 2 (expired-link path)      ✓
- AC3 → Journey 1, step 4 (session reset)  ✓

[test-suites.md content rendered]
[contract.yaml content rendered]
[design.md content rendered]

Open Questions in design.md:
- Q1: rate-limit storage — Redis or DB?  [needs your call before Gate 3]

Decision: approve Gate 2?
[a] approve                           — outcome: proceed to Gate 3
[b] approve with corrections (list)   — outcome: apply, re-present Gate 2
[c] reject                            — outcome: stop; return to Gate 1
```

### S7 — `lsa-specify` Gate 3

Replaces `lsa/skills/lsa-specify/SKILL.md:189` — verbatim: *"Full spec ready. Verify consistency before approving: Does every AC have a journey covering it? Does the design match the contract? Are all Open Questions resolved or deferred? Approve to proceed to planning, or tell me what to change."*.

```
[illustrative — Q1 resolution is a placeholder]
PROPOSED — Gate 3: final integration check

Integrity checks:
- Every AC has a journey covering it? ..... yes
- Design matches contract? ................ yes
- Open Questions resolved or deferred? .... resolved (Q1 → Redis, your call)

Decision: approve spec?
[a] approve         — outcome: lsa-plan invoked next
[b] reject          — outcome: stop; name what to change
```

### S8 — `lsa-plan` Step 5 review gate

Replaces `lsa/skills/lsa-plan/SKILL.md:114` — verbatim: *"Does this plan look correct? Approve to start implementation, or tell me what to adjust."*.

```
[illustrative — "5 epics" and PASS row counts are placeholders]
READY — plan drafted (5 epics)

[tasks.md content rendered above]

Self-verification:
| Check         | Result |
|---------------|--------|
| Traceability  | PASS   |
| Accuracy      | PASS   |
| Consistency   | PASS   |
| Test coverage | PASS   |
| Completeness  | PASS   |

Decision: approve plan?
[a] approve         — outcome: implementation begins (TDD per epic, parallel where safe)
[b] adjust (list)   — outcome: re-decompose, re-present
[c] reject          — outcome: stop; return to lsa-specify for scope reduction
```

### S9 — `lsa-verify` PASS report

Replaces (clean-PASS variant of) the report template at `lsa/skills/lsa-verify/SKILL.md:86-107` — verbatim opening: *"# Verification Report: [Feature/Epic Name]"* (L87).

```
[illustrative — feature name, check counts, branch are placeholders]
✅ PASS — feature ready for sync

password-reset-via-email passed all 14 checks. No untraced changes.

| Check group   | Result   |
|---------------|----------|
| Scope         | ✅ 3/3   |
| Accuracy      | ✅ 5/5   |
| Tests         | ✅ 3/3   |
| Code quality  | ✅ 3/3   |

Decision: proceed to sync?
[a] proceed         — outcome: lsa-sync invoked; module specs updated; feature archived
[b] hold            — outcome: stop; verify later

---
Metadata: branch=feature/password-reset | mode=code | date=2026-05-20
Full checklist:
[full checklist below the fold]
```

### S10 — `lsa-verify` FAIL report

FAIL variant of the same template at `lsa/skills/lsa-verify/SKILL.md:86-107` — verbatim row from the Issues sub-template at L99: *"| BLOCKER  | ...  | ...         | ... |"*.

```
[illustrative — feature name, blocker descriptions, paths are placeholders]
❌ FAIL — 2 blockers, sync blocked

password-reset-via-email failed Scope and Tests checks.

| Severity | Item             | Required action                            |
|----------|------------------|--------------------------------------------|
| BLOCKER  | F3 (rate limit)  | implement rate-limiter; 0 tests cover it   |
| BLOCKER  | Untraced edit    | src/mailer/templates.ts not in any AC      |

Decision: how to proceed?
[a] fix and re-verify   — outcome: address blockers; re-run /lsa:verify
[b] reduce scope        — outcome: re-run lsa-specify to drop F3
[c] escalate            — outcome: human review for exception

---
Metadata: branch=feature/password-reset | mode=code | date=2026-05-20
Full checklist:
[full checklist below the fold]
```

### S11 — `lsa-verify` PASS WITH WARNINGS report

WARN variant of the template at `lsa/skills/lsa-verify/SKILL.md:86-107` — verbatim row at L100: *"| WARNING  | ...  | ...         | ... |"*.

```
[illustrative — feature name, warning, path are placeholders]
⚠️ PASS WITH WARNINGS — sync allowed with explicit acknowledgement

password-reset-via-email passed core checks; 1 warning raised.

| Severity | Item                 | Reason                                  |
|----------|----------------------|-----------------------------------------|
| WARNING  | Dead code in helper  | utils/email.ts:42 — never called        |

Decision: how to proceed?
[a] accept and sync     — outcome: lsa-sync invoked; warning logged in archive
[b] fix first           — outcome: address warning; re-verify
[c] hold                — outcome: stop

---
Metadata: branch=feature/password-reset | mode=code | date=2026-05-20
Full checklist:
[full checklist below the fold]
```

### S12 — `lsa-sync` delta-approval prompt

Replaces `lsa/skills/lsa-sync/SKILL.md:64` — verbatim: *"These are the decisions I will merge into the module specs. Correct?"*.

```
[illustrative — modules, endpoint, table, archive path are placeholders]
PROPOSED — delta to merge into module specs

## Module Deltas
| Module | Type          | Decision                                       |
|--------|---------------|------------------------------------------------|
| auth   | new behavior  | Reset tokens HMAC-signed, 1h TTL, single-use   |
| auth   | new contract  | POST /auth/reset-request (see contract.yaml)   |
| mailer | new behavior  | Triggers reset-link email on auth callback     |

Specs touched:
- auth   → vision/specs/modules/auth/spec.md
- mailer → vision/specs/modules/mailer/spec.md

## main.spec.md (vision/specs/main.spec.md) updates
- Add `reset_tokens` to Data Models section.
- Add `/auth/reset-request` to Cross-Module Contracts.

Decision: apply delta to module specs?
[a] apply           — outcome: module specs edited (tagged); feature archived next
[b] modify (list)   — outcome: revise delta; re-present
[c] reject          — outcome: stop; sync aborted
```

### S13 — `lsa-sync` "ready to PR" prompt

Replaces `lsa/skills/lsa-sync/SKILL.md:138` — verbatim: *"Sync complete. Ready to create PR to main?"*.

```
[illustrative — module list and archive path are placeholders]
✅ APPLIED — sync complete

Module specs updated:
- auth   → vision/specs/modules/auth/spec.md
- mailer → vision/specs/modules/mailer/spec.md
main.spec.md (vision/specs/main.spec.md) updated.
Archived to: vision/specs/archive/2026-05-20-password-reset-via-email/
.lsa-sync-state.json: 2 modules' SHAs bumped.

Decision: create PR to main?
[a] create PR       — outcome: `gh pr create` with auto-generated title/body
[b] hold            — outcome: branch ready; create PR manually later
```

### S14 — `lsa-reconcile` per-module confirm

Replaces `lsa/skills/lsa-reconcile/SKILL.md:34-39` — verbatim: *"Module: <name> / Classification: <(a) change to existing behavior / (b) new behavior> / Proposed spec update: <one-line description> / Apply? (y / n)"*.

```
[illustrative — `auth` module, `vision/specs/modules/auth/spec.md`, `src/auth/session.ts` do not exist in this repo]
DRIFT — auth module diverged from spec

Files changed since last sync: 3 | Lines: +12/-4
Classification: (a) change to existing behavior

Spec says (vision/specs/modules/auth/spec.md:42):
  "Sessions expire at 30 days."

Code now says (src/auth/session.ts:18):
  "Sessions expire at 7 days."

Proposed spec update: replace "30 days" with "7 days" on line 42.

Decision: apply reverse-sync?
[a] apply           — outcome: modules/auth/spec.md edited in place; SHA bumped
[b] reject          — outcome: spec untouched; row added to research-backlog.md
```

### S15 — `lsa-revise-constitution` per-change gate

Replaces `lsa/skills/lsa-revise-constitution/SKILL.md:66` — verbatim: *"Apply this change? Yes / No / Modify"*.

```
[illustrative — the proposed principle and source feature are placeholders]
PROPOSED — Constitution change 1 of 2

File:     vision/VISION.md
Section:  §2 First principles
Type:     add

Current:  none
Proposed: "9. Errors fail loud — never swallow exceptions to keep the agent moving."
Reason:   password-reset feature lost 3 errors to silent catch blocks.
Source:   vision/specs/archive/2026-05-20-password-reset-via-email/ (retrospective).

Decision: apply change?
[a] apply               — outcome: VISION.md edited; tagged; committed to constitution branch
[b] modify (correction) — outcome: apply your edit, re-present
[c] reject              — outcome: stop; change not applied
```

### S16 — DROPPED per audit-B D1

The refactor rewrote `lsa/skills/lsa-init/SKILL.md:27` from a direct Q (*"Greenfield (empty project) or brownfield (existing codebase)?"*) into mechanical detection at L22: *"If `${specs_root}/modules/` is empty (or absent) AND `.lsa.yaml: modules.*` contains no configured `artifact_paths`, the mode is **greenfield**; otherwise **brownfield**. Print the determination back to the human… and ask the human to confirm."*

D1 accepts the refactor's choice — the human now confirms a detected mode rather than picking one. Rule 7 (verdict-first) still applies to the printed detection; S17 (brownfield skeleton confirm) covers the only remaining option-bearing step in `lsa-init`. Layer 2's `lsa-init` row drops `:27` and keeps `:48` (was `:54`).

### S17 — `lsa-init` brownfield confirm

Replaces `lsa/skills/lsa-init/SKILL.md:48` (was `:54` in pre-refactor; remapped audit-B) — verbatim: *"Skeleton specs generated. Review and confirm before I continue."*.

```
[illustrative — `auth`, `api`, `utils` modules and src paths are placeholders; no src/ exists in this repo]
PROPOSED — brownfield skeleton (3 modules inferred)

| Module | Source                    | Confidence                                   |
|--------|---------------------------|----------------------------------------------|
| auth   | src/auth/*.ts (8 files)   | high                                         |
| api    | src/api/*.ts (12 files)   | high                                         |
| utils  | src/utils/*.ts (4 files)  | medium — small surface, may not be a module  |

Each generated spec is tagged `[assumption: inferred from <source>; verify]`.

Decision: accept skeleton?
[a] accept all                 — outcome: 3 module specs written under /specs/modules/; proceed to /lsa:discover
[b] accept subset (list which) — outcome: write only those; the rest deferred
[c] reject                     — outcome: stop; no specs written; reconsider module boundaries
```

### Pre-approval checklist — COMPLETED 2026-05-20

| # | Sample | Status | Notes |
|---|---|---|---|
| S1 | tier-selector confirm | ✅ approved | clarified element-by-element first |
| S2 | lsa-discover Output | ✅ approved | adjusted to include spec path (path-fix pattern → seeded F7) |
| S3 | lsa-discover assume-then-override | ✅ approved | |
| S4 | lsa-specify clarification.md | ✅ approved | |
| S5 | lsa-specify Gate 1 | ✅ approved | confirms Q2 gate-collapse 7→3 |
| S6 | lsa-specify Gate 2 | ✅ approved | confirms Q2 gate-collapse 7→3 |
| S7 | lsa-specify Gate 3 | ✅ approved | confirms Q2 gate-collapse 7→3 |
| S8 | lsa-plan review gate | ✅ approved | |
| S9 | lsa-verify PASS | ✅ approved | confirms verdict-first reorder (Rule 7) |
| S10 | lsa-verify FAIL | ✅ approved | |
| S11 | lsa-verify PASS WITH WARNINGS | ✅ approved | |
| S12 | lsa-sync delta-approval | ✅ approved (bulk) | user: *"I see the pattern, accept the rest"* |
| S13 | lsa-sync ready-to-PR | ✅ approved (bulk) | |
| S14 | lsa-reconcile per-module | ✅ approved (bulk) | |
| S15 | lsa-revise-constitution per-change | ✅ approved (bulk) | |
| S16 | lsa-init mode | 🚫 dropped (audit-B D1) | refactor's mechanical mode detection at `lsa-init:22` replaces the direct Q; no decision-block needed |
| S17 | lsa-init brownfield confirm | ✅ approved (bulk) | line remap `:54` → `:48` (audit-B) |

Cross-cutting questions — all defaults accepted in bulk 2026-05-20:

| ID | Question | Default (accepted) |
|---|---|---|
| F1 | Use emoji (✅ ❌ ⚠️ 🛑) in verdict line, or text only? | ✅ **emoji** (faster eye-jump) |
| F2 | `[a]` `[b]` `[c]` labels — or numeric `1.` `2.` `3.`? | ✅ **alpha** (avoids confusion with numbered AC/F IDs) |
| F3 | Decision block always last in message, or always first? | ✅ **last** (cursor over next action) |
| F4 | `outcome: …` prefix on each option, or omit when self-evident? | ✅ **always present** (Rule 6 demands it) |
| F5 | Metadata (date/branch/mode) below-fold or above? | ✅ **below** (verdict-first) |
| F6 | Override syntax in `clarification.md`/`discovery.md` — `[override?]` annotation, or strike-through? | ✅ **`[override?]` annotation** (text-friendly, copy-pasteable) |
| F7 | When referencing a module / feature / spec in a structured field — bare name, or always include the canonical path? | ✅ **always include the canonical path** (e.g., `auth → vision/specs/modules/auth/spec.md`); bare names allowed only in prose where the path was just stated |

---

## Layer 2 — Thread the rules through every LSA skill

One row per file. **Bold = behavior change, not just wording.** Each "Source of the violation" cell carries a verbatim quote per Rule 1 amendment above. **Line numbers below are post-refactor (audited 2026-05-20-B).**

| File | Change | Source of the violation (verbatim quote) |
|---|---|---|
| `core/skills/tier-selector/SKILL.md:32-36` | Add outcomes to each option in the confirm prompt: `[y] proceed at T<N> — outcome: <next skill>`, `[n] reconsider — outcome: re-run signal checklist`, `[override to T<other>] — outcome: rationale logged, hand off to <skill>`. | L36: *"Confirm? (y / n / override to T<other>)"* — options listed, **outcomes absent**. |
| `lsa/skills/lsa-discover/SKILL.md:24-25` | **Convert questions (b) and (c) to assume-then-override.** Agent proposes 2 candidate framings from the module spec; human picks `[a]` `[b]` or `[c] custom`. Question (a) already constrained (L23: *"Pick from the list printed in Step 1"*) — leave it but add outcomes per module choice. | L24: *"What's the change in one sentence?"* / L25: *"What's the acceptance criterion in one sentence?"* — open-ended, no options. |
| `lsa/skills/lsa-discover/SKILL.md:30` (Output) | **Replace paragraph format with verdict-first table:** `READY` line, then 3-row table (Module / Change / AC). | L30: *"write a single-paragraph context summary (one paragraph, 2–4 sentences) naming the chosen module(s), the change, and the AC"* — paragraph mandated, not table. |
| `lsa/skills/lsa-specify/SKILL.md:31-46` (Step 2) | **Replace the 9 open questions with assume-then-override.** Agent drafts a `clarification.md` scratch listing assumed answers for all 9 (Functional×4, NFR×2, Boundaries×2, Acceptance×1). Human responds with one-line overrides or `ok`. Silence on a line = approval. | L32: *"What does this feature do?"* through L46: *"What are the exact conditions for this feature to be considered done?"* — 9 open prompts. |
| `lsa/skills/lsa-specify/SKILL.md` (gates) | **Collapse 7 stops to 3:** (i) requirements + AC + contract-trigger bundled, (ii) test-suites + design bundled, (iii) final integration. Each gate uses Rule 6 shape. | Stops at L97 (requirements), L99-105 (contract trigger — now its own step post-refactor), L127 (journeys), L149 (contract), L177 (design), L179 (final) = 6 explicit; +1 implicit acceptance gate = 7. |
| `lsa/skills/lsa-specify/SKILL.md:97` `:127` `:149` `:177` `:179` | Rewrite every `"Confirm to continue"` prompt in Rule 6 shape with outcomes naming the next artifact each path produces. | L97: *"Does requirements.md capture the full scope? Confirm to continue."* / L127: *"Do these journeys cover all user interactions correctly? Confirm to continue."* / L149: *"Does this contract look correct? Confirm or describe corrections — I can apply them."* / L177: *"Does this design look correct? Any concerns before finalizing?"* / L179: *"Approve to proceed to planning, or tell me what to change."* — all open. |
| `lsa/skills/lsa-plan/SKILL.md:108` | Rewrite Step 5 human-review gate in Rule 6 shape with outcomes. | L108: *"Does this plan look correct? Approve to start implementation, or tell me what to adjust."* — open. |
| `lsa/skills/lsa-verify/SKILL.md:79-100` (report template) | **Re-order:** line 1 = verdict (`✅ PASS` / `❌ FAIL` / `⚠️ PASS WITH WARNINGS`), line 2 = one-sentence headline, then Issues table (failures only), then full Checklist as appendix. Metadata moves below the verdict. | L79-83 (current template): *"# Verification Report: [Feature/Epic Name]"* / *"Date: [date]"* / *"Branch: [branch name]"* / *"Mode: [code / docs / mixed]"* / *"## Result: PASS / FAIL / PASS WITH WARNINGS"* — verdict appears as Result on L83, after 4 lines of metadata. |
| `lsa/skills/lsa-verify/SKILL.md:104-107` (gate) | Rewrite Step 5 gate in Rule 6 shape with per-result outcomes. | L105: *"**FAIL / BLOCKER:** Stop. Report to human."* / L106: *"**PASS WITH WARNINGS:** Present report. Wait for human decision."* / L107: *"**PASS:** Present report. Proceed to sync on human approval."* — branches stated; no decision prompt with options visible to the human. |
| `lsa/skills/lsa-sync/SKILL.md:56` `:130` | Rewrite delta-approval and "ready to PR" prompts in Rule 6 shape with outcomes. | L56: *"These are the decisions I will merge into the module specs. Correct?"* / L130: *"Sync complete. Ready to create PR to main?"* — both y/n-shaped. |
| `lsa/skills/lsa-reconcile/SKILL.md:32-39` (Step 4 confirm) | Expand `Apply? (y/n)` to: `[y] apply — outcome: spec line edited in place + SHA bumped`, `[n] reject — outcome: row added to research-backlog.md` (per Step 6 at L50). | L32-38: *"Module: <name> / Classification: <(a) … / (b) …> / Proposed spec update: <one-line description> / Apply? (y / n)"* — y/n with no outcomes. |
| `lsa/skills/lsa-revise-constitution/SKILL.md:58` | Rewrite per-change gate as Rule 6 shape: `[a] apply` / `[b] modify (correction)` / `[c] reject` with outcomes. | L58: *"Apply this change? Yes / No / Modify"* — 3 options listed, no outcomes. |
| `lsa/skills/lsa-init/SKILL.md:48` | Rewrite brownfield-confirm prompt in Rule 6 shape with outcomes. **(Audit-B D1:** the pre-refactor direct Q at `:27` is gone — refactor's mechanical mode detection at `:22` is retained; print-detection conforms to Rule 7 with no decision-block needed.) | L48: *"Skeleton specs generated. Review and confirm before I continue."* — open. |
| All LSA skill Output sections | Audit for narrative outputs; convert to verdict-first per Rule 7. | Spot-check anchors: `lsa-discover:30` (paragraph mandated, quoted above); `lsa-sync` markdown report template (verdict-equivalent absent from line 1 — line range to verify during apply). |
| `lsa/knowledge/conventions.md` — add new Knowledge section *"Prompt shape"* (**audit-B D2**) | Add one section citing `core/skills/ground-rules/SKILL.md` Rule 6 (options + outcomes) and Rule 7 (verdict-first) as the canonical structure for every LSA skill's human-facing prompts. Each LSA skill's Constraints section then adds **one** citation line: *"Human-facing prompts follow [`conventions.md` §"Prompt shape"](../../knowledge/conventions.md)."* (DRY-Knowledge — replaces the pre-audit "add one line per skill" approach which would have duplicated the rule 8×.) | `conventions.md` currently has 4 sections (`.lsa.yaml defaults` L9, `Read protocol` L24, `Confirm gate types` L38, `Trace-tag format` L51) — no "Prompt shape" section. Pattern established by the existing 4 sections: cross-cutting LSA conventions live here as Knowledge, skills cite by section name. |

---

## Layer 3 — Entry-point docs

Each row carries a verbatim quote of the current cited content (per Rule 1 amendment).

| File | Current content (verbatim) | Change |
|---|---|---|
| `vision/VISION.md:13` (was `:11` pre-refactor — remapped audit-B) | *"Build a personal, model-agnostic agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**."* | Append a second sentence: *"And whose operating philosophy is **ownership over automation** — the system does not think for the human; it makes the human think."* |
| `vision/VISION.md:54` (start of §2 First principles, principle #1) | *"1. **Trust is the product.** A fast wrong answer is a defect. A grounded \"I cannot verify this\" is a feature."* | Insert immediately after as new principle 1a: *"**1a. Ownership over automation.** The system surfaces facts, lays out options, and demands choice. It never silently decides on the human's behalf. (See `core/ground-rules` Rule 0.)"* |
| `vision/VISION.md:255` (Changelog, current latest is v0.4) | *"**v0.4** — Simplified to **Claude Code only.** Removed the Claude App as a target…"* | Prepend new v0.5 entry: *"**v0.5** — Codified the operating-philosophy credo as a first principle; extended `ground-rules` from 4 rules to 8 (added ownership-over-automation, no-filler, decision-shape, structured-first); refit all LSA skills to surface options + outcomes and verdict-first outputs."* |
| `core/CLAUDE.md:3` (canonical-source declaration) | *"**Canonical source.** This file is the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules."* | **No change to this declaration** — but expand the "## Ground rules (always-on)" section below to enumerate all 8 rules in one-liner form (current state at L11 only summarizes the original 4). |
| `core/CLAUDE.md:11` (current 4-rule prose summary) | *"Apply `core/ground-rules` to every substantive task. Every factual claim carries a source + searchable quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked."* | Replace with an 8-line enumeration (Rules 0 + 1–7), each on its own line, with `core/ground-rules` linkified once at the top of the block. |
| `CLAUDE.md` (repo root) `:20-22` | *"## Always-on rules / The canonical always-on fragment lives at [`core/CLAUDE.md`](./core/CLAUDE.md): apply `core/ground-rules` to every substantive task; invoke `core/tier-selector` before any non-trivial task."* | **Already a pointer** (per simplification refactor PR 1). Single-sentence amendment: append *"The operating credo is ownership over automation — see `core/CLAUDE.md` Rule 0."* to that paragraph. |
| `core/README.md:7` (currently summarizes the 4 rules) | *"**`ground-rules`** — Apply on every substantive task. Enforces: every factual claim carries a source + quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked."* | Replace the "Enforces:" tail with a pointer: *"Enforces 8 rules — see `core/CLAUDE.md` for the canonical list."* (Honors canonical-source convention from `core/CLAUDE.md:3`.) |
| `core/VERIFICATION.md:17` (start of "V2 — Description-match triggers reliably") | *"## V2 — Description-match triggers reliably / **Probe A (ground-rules).** … **Probe B (actor-template).** … **Probe C (tier-selector).** …"* | Append Probes D / E / F / G under V2, one per new rule (Rule 0 = ownership, Rule 5 = no filler, Rule 6 = options+outcomes, Rule 7 = verdict-first). Each probe: a fresh-session prompt + a PASS/FAIL criterion matching the existing A/B/C shape. |
| `core/tests/repo-anchored.md:11` (start of Set A — ground-rules probes; current A1–A4 cover Rules 1–4) | *"### A1 — Fact-grounding on a falsifiable detail (Rule 1)"* through *"### A4 — Deliver only what was asked (Rule 4)"* | Append A5–A8: A5 = Rule 0 (ownership), A6 = Rule 5 (no filler), A7 = Rule 6 (options+outcomes), A8 = Rule 7 (verdict-first). Each anchored at a concrete repo path. |
| `lsa/README.md:1-3` (file currently opens with `# LSA — Living Spec Architecture` then a one-paragraph purpose) | *"# LSA — Living Spec Architecture / Spec-first development methodology installable as a Claude Code plugin. Specs are the permanent source of truth…"* | Insert a new section right after the H1 titled *"## LSA's expression of the credo"* with the user's verbatim line: *"LSA doesn't automate your thinking — it makes you own it."* and a one-line follow-up linking to `core/CLAUDE.md` Rule 0. |
| `lsa/ARCHITECTURE.md:1-4` (header block) | *"# Living Spec Architecture (LSA) / **Version:** 0.2.1 (plugin) / **Author:** Nikita Zverev / **Status:** 0.2.1 — Vision-aligned…"* | Bump Version line to **0.4.0** when applying. Add one new section under §1 Purpose titled *"How the 8 ground rules constrain LSA"* — one paragraph naming the three mechanical consequences: assume-then-override Qs (Rule 6), bundled gates (Rule 0 + Rule 6), verdict-first reports (Rule 7). |

---

## Layer 4 — Versions + changelogs

**Baseline (audited 2026-05-20-B):** simplification refactor landed: `core@0.3.0`, `lsa@0.3.1` (`0.3.0` refactor + `0.3.1` *"KISS surgical edits."*). The credo rollout therefore targets **0.4.0** — a minor bump over each plugin's current shipped state.

| File | Current state (verbatim) | Change |
|---|---|---|
| `core/.claude-plugin/plugin.json:4` | *`"version": "0.3.0",`* | Bump to `"version": "0.4.0"`. Minor bump: 4 new always-on rules = new observable contract; no breaking removal. |
| `core/CHANGELOG.md:7` | *"## [0.3.0] — 2026-05-20 / Knowledge-vs-Actor boundary tightening across all three core skills."* | Insert new `## [0.4.0] — <date>` entry above the existing 0.3.0 block: 4 new rules listed (Rule 0 ownership, 5 no-filler, 6 options+outcomes, 7 verdict-first); cite Vision v0.5 and this plan. |
| `lsa/.claude-plugin/plugin.json:4` | *`"version": "0.3.1",`* | Bump to `"version": "0.4.0"`. Minor bump: every skill's prompt format changes (Rule 6 + Rule 7) — observable to consumers but no new commands removed. |
| `lsa/CHANGELOG.md:7` | *"## [0.3.1] — 2026-05-20 / KISS surgical edits."* (top entry; `0.3.0` "Knowledge-vs-Actor boundary tightening across all eight LSA skills." below) | Insert new `## [0.4.0] — <date>` entry above the existing 0.3.1 block: skill prompts now Rule 6 / Rule 7 conformant; `lsa-specify` gates collapsed 7→3; `lsa-discover` and `lsa-verify` outputs verdict-first; tier-selector confirm prompt carries outcomes per option; new `conventions.md §"Prompt shape"` Knowledge section. |

**Why 0.4.0, not 0.3.x:** `core@0.3.0` and `lsa@0.3.0`/`0.3.1` are reserved by the simplification refactor + its KISS patch. That refactor restructured every skill body and shipped `lsa/knowledge/conventions.md` as the cross-cutting Knowledge surface (4 sections — see Layer 2 last row). The credo rollout adds new observable contracts on top of that baseline — `0.4.0` is the next minor for both plugins.

---

## Open decisions — RESOLVED

Audit-A (2026-05-20, pre-refactor):

| ID | Decision | Resolution |
|---|---|---|
| Q1 | Credo placement | ✅ (a) general form in core + LSA-flavored echo in `lsa/README.md` — implicitly confirmed via walkthrough acceptance |
| Q2 | `lsa-specify` gate collapse 7→3 | ✅ (a) do it as planned — confirmed by approving S5/S6/S7 in walkthrough |
| Q3 | Rule 5 ("No filler") scope | ✅ (a) all outputs incl. `vision/VISION.md` — confirmed explicitly by user before audit |

Audit-B (2026-05-20, post-refactor):

| ID | Decision | Resolution |
|---|---|---|
| D1 | `lsa-init` Step 2: refactor rewrote direct Q at `:27` into mechanical detection at `:22` — restore Q or accept? | ✅ (a) accept refactor's mechanical detection; drop S16 sample; Layer 2 row drops `:27` and keeps `:48` only — confirmed by user |
| D2 | Cross-cutting "all human-facing prompts follow Rule 6 + 7" — add to every skill's Constraints (would duplicate 8×) or add a new section to `lsa/knowledge/conventions.md` and cite once per skill? | ✅ (a) add new section *"Prompt shape"* to `conventions.md`; each skill cites by section name (DRY-Knowledge) — confirmed by user |

No open decisions remain. Plan is fully pre-approved and audit-B remap applied.

---

## Audit-B walkthrough — RESOLVED 2026-05-20

User signalled refactor complete. Diff-vs-current-state emitted; all 5 revisit steps walked:

1. ✅ Re-scanned every file path + line number in Layers 2 and 3 — Layer 2 cited text shifted up by 6–12 lines (refactor compaction); Layer 3 mostly unchanged, `vision/VISION.md:11` → `:13`. Line-number remap applied throughout.
2. ✅ Re-counted `lsa-specify` gates post-refactor — still 6 explicit "Confirm to continue" stops (L97 / L127 / L149 / L177 / L179) + a dedicated contract-trigger step (L99-105); the 7→3 collapse target stands.
3. ✅ Re-checked `lsa-verify` report template — refactor preserved the original verdict-buried structure (`Result:` line at L83, after 4 lines of metadata); the verdict-first reorder is still in scope of credo rollout, not the refactor.
4. ✅ Confirmed Layer 1 rule wording survives — `ground-rules` frontmatter still says "four rules"; Rule 1 verbatim quote (the source + searchable quote sentence) is intact at L10-14; Rules 1–4 still at L10 / L27 / L40 / L50. Inserts for Rules 0/5/6/7 still apply cleanly.
5. ✅ Q2 (gate collapse 7→3) re-validated — refactor did not reduce the gate count; target unchanged. **New question D1** surfaced (refactor rewrote `lsa-init` Step 2 to mechanical detection) — resolved option (a) above. **New question D2** surfaced (DRY of cross-cutting Rule 6/7 line) — resolved option (a) above.

Plan is now applicable as-is.
