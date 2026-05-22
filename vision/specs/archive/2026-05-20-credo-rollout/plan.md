<!-- ARCHIVED 2026-05-22: moved from vision/plans/2026-05-20-credo-rollout-plan.md → vision/specs/archive/2026-05-20-credo-rollout/plan.md as part of feature/2026-05-21-maintenance-cleanup. Internal historical path references preserved as written at time of authorship. -->

# Credo Rollout — Change Plan

**Status:** `[applied 2026-05-21 at commit 38067cc]` — audit-C (proposal drafted 2026-05-20, applied 2026-05-21) flagged DRY/KISS/SRP defects in PR 1's structure: output discipline conflated with content rules inside `ground-rules`; `core/CLAUDE.md` restated the 8 rules instead of citing them; probes restated rule behaviors per-rule. Restructure shipped: output discipline extracted to `core/skills/output` (4 golden rules); ground-rules stays content-only (6 rules); every component picks its own output format within the golden rules; substrate-native principle landed at Vision §2 principle 9. PR 1 commits 3dc1828 + 53d7c58 discarded by `git reset --hard 01126d1`; rebuilt as 5bb5181 (plan) + 38067cc (apply). Force-pushed.
**Date:** 2026-05-20→21 (audit-A: Rule 1 reference discipline; audit-B: post-refactor remap; audit-C: DRY/KISS/SRP restructure, applied 2026-05-21)
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
- D2 → option (a): the cross-cutting "all human-facing prompts follow Rule 6 + Rule 7" rule lives in `lsa/knowledge/conventions.md` as a new section *"Prompt shape"* citing `core/skills/ground-rules/SKILL.md` Rule 6/7 as authority. **Audit-C amends:** Rule 6/7 themselves no longer exist as ground-rules rules; the citation in `conventions.md` (if kept at all) now points to `core/skills/output`. See audit-C resolutions below.
- Baseline shift: lsa landed at `0.3.1` (refactor `0.3.0` + a `0.3.1` KISS patch). Credo target stays `0.4.0` — still a minor bump over `0.3.1`.

**Audit-C resolutions (drafted 2026-05-20, applied 2026-05-21, post-PR1-self-review):**
- User flagged that PR 1 violates `CONTRIBUTING.md` DRY/KISS/SRP: ground-rules mixes content + format rules; `core/CLAUDE.md` restates the 8 rules (DRY); probes restate per-rule (DRY); the Rule 7 verdict-vocabulary table is Knowledge embedded in an Actor body (SRP). User directive (verbatim, 2026-05-20): *"the skill should cover only common rules applicable to all cases like structured, minimal, formatted output with exact source and quote - that is the rule for everthing. NO fluff, no overexplanation. BUT Every component can decide on its own output format (or we will) which suites best its purpose, but it must adhere to our golden rules for output. Do you get my point? Golden Rules + Custom Decisions never breaking golden rules."*
- C1 → New skill `core/skills/output/SKILL.md` — 4 golden rules only: **(1) Structured** (output has a shape), **(2) Minimal** (no fluff, no overexplanation), **(3) Formatted** (markdown affordance matches content), **(4) Sourced** (every factual claim has source + exact quote, cites `ground-rules` Rule 1 — doesn't restate). Body is ≤20 lines. See Layer 1.6.
- C2 → `core/skills/ground-rules/SKILL.md` stays content-only. PR 1's plan to add Rules 0 + 5 still applies (Rule 0 Ownership; Rule 5 No filler) — both are content/posture, not format. Rules 6 (decision-shape) + Rule 7 (verdict-first) **do NOT** go to ground-rules. ground-rules ends at 6 rules: existing 1/2/3/4 + new 0 + new 5. The Rule 1 amendment (Scope + Illustrative) stays.
- C3 → Component output formats: pre-approved S1–S17 samples become per-component canonical formats. Each LSA skill's Output section adopts its S-sample; its Constraints section adds **one** citation: *"Output follows `core/output` golden rules."* No restatement of any specific format inside ground-rules or output.
- C4 → Substrate-native first → Vision §2 first principle (broad reach: file I/O, task tracking, picker selection). NOT a golden rule (golden rules are about output properties; substrate-native is about substrate-primitive selection — a meta-principle that informs both ground-rules' read-protocol and output's format choices). Output skill cites the Vision principle; doesn't restate.
- C5 → `core/CLAUDE.md` collapses back to ~5 lines: one pointer each to ground-rules, output, tier-selector. NO rule restatement.
- C6 → Probes restructure: V2 probes become **per-skill** (Probe A=ground-rules, B=actor-template, C=tier-selector, D=output) — one composed test per skill, not one per rule. The per-rule Probes D/E/F/G + A5/A6/A7/A8 from PR 1 do NOT survive.
- C7 → core@0.4.0 still applies (new output skill = new contract; minor bump). Plugin description rewritten to enumerate skills, not individual rules.

**Open decisions:** plan rewrite below awaiting user review. On approval: `git reset --hard 01126d1` on `feature/credo-core`, force-push, re-apply per the audit-C structure. PR 3 description updates.

---

## Why this plan exists

User session observation: the system's interactive surface invites rubber-stamping. Vision §1.7 (`vision/VISION.md:60`) names *"the human owns intent"* as a property of the system — but gates as written (open-ended Qs, y/n without consequences, prose-first outputs) let the human disengage. This plan codifies the credo as a first principle and threads four new always-on rules through every actor that talks to the human.

---

## Layer 1 — `core/skills/ground-rules/SKILL.md` (content discipline)

Add Rule 0 + Rule 5 + Rule 1 amendment. Keep the existing 4. Total = **6 rules** (content / posture only — format discipline lives in the new output skill at Layer 1.6). Audit-C C2.

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

### NOT in ground-rules (audit-C): old Rules 6 + 7

The PR-1 attempt added Rule 6 (decision-shape: labelled options + outcomes) and Rule 7 (verdict-first + verdict vocabulary table) to `ground-rules`. **Audit-C reverts both.** Reasons:

- **SRP** — Rules 6 + 7 are format rules; the surrounding rules (0/1/2/3/4/5) are content/posture rules. Mixing concerns in one file.
- **Reuse** — every component needs the output discipline; threading two specific rules through every skill's body or Constraints duplicates intent. A dedicated `core/output` skill is one citation per component.
- **Component freedom** — Rule 6's mandated *"Decision: [a]/[b]/[c]"* text shape and Rule 7's mandated verdict-line-first structure are *one* valid output format among many. Components should pick the format that fits their purpose (the S1–S17 samples in Layer 1.5 show the diversity); golden rules constrain properties, not templates.

Both concerns move to Layer 1.6.

### Edits to existing parts of `ground-rules`

| File / location | Change |
|---|---|
| `core/skills/ground-rules/SKILL.md` frontmatter `description:` | Adjust: *"Enforces six rules: ownership-over-automation, fact-grounding (sources + quotes), no fake-confidence hedging, read the real source before answering, deliver only what was asked, no filler."* |
| Body — order | Rule 0 first, then existing 1 (with amendment) / 2 / 3 / 4, then Rule 5. |
| Footer cross-references (existing line + new line) | Existing footer at end of file: *"Writing or editing an actor (Skill, slash command, workflow)? See `actor-template`."* Add one new line below it: *"Producing a human-facing output (response, prompt, report, comment)? See [`core/output`](../output/SKILL.md) for the four format golden rules."* Makes the cross-link bidirectional — `output` already cites `ground-rules` Rule 1 from inside its Rule 4. |
| "What this skill never does" section | NOT re-added (per audit-B F1 — the 0.3.0 refactor removed it as a Knowledge-vs-Actor violation; re-adding would reverse the refactor's own DRY logic). |

---

## Layer 1.6 — NEW skill `core/skills/output/SKILL.md` (format discipline)

Audit-C C1. The single source of truth for output discipline. Every component (skill, slash command, agent response) cites this skill; nothing restates it.

### Frontmatter

```yaml
---
name: output
description: Apply to every human-facing output — agent responses, skill bodies, plan files, READMEs, commit messages, PR descriptions, comments. Enforces four golden rules: structured shape, minimal length, correct markdown formatting, every factual claim sourced + quoted (cites ground-rules Rule 1). Each component picks its own format within these constraints.
---
```

### Body (≤20 lines, complete)

```markdown
# Output Discipline

Four golden rules. Every output is bound by them. Component-specific
formats (tier-selector confirm prompts, lsa-verify reports, etc.) are
free choices WITHIN these rules — they may not violate any of the four.

## 1. Structured
Output has a shape: headings, sections, tables, lists, blocks. No
stream-of-consciousness prose. The reader's eye finds key information
without reading top-to-bottom.

## 2. Minimal
No fluff, no overexplanation, no padding. Every line earns its place.

## 3. Formatted
Markdown affordances match content: tables for tabular data, lists for
enumerations, code blocks for code, headings for sections.

## 4. Sourced
Every factual claim carries source + exact quote per `core/ground-rules`
Rule 1. This rule enforces visibility; ground-rules enforces existence.
```

### What the output skill does NOT prescribe

To preserve component freedom (audit-C user directive):

- **No verdict vocabulary mandate.** Components MAY use `PROPOSED` / `READY` / `PASS` / `FAIL` / etc. (the vocabulary lives in `core/knowledge/output-vocabulary.md` — see below). Components that don't have a verdict moment (e.g., a Knowledge surface) don't render one.
- **No decision-block template mandate.** Decisions follow Rule 0 (ownership) — *"explicit consequences, no silent auto-decisions"* — but the SHAPE is component choice: `AskUserQuestion` in Claude Code, text `[a]/[b]/[c]` block in plain-text contexts, custom table for visual comparison, etc.
- **No verdict-first structure mandate.** Many components will adopt verdict-first (it satisfies "structured" + "minimal") but it's not the only well-shaped output. A Knowledge surface that opens with section headings is structured + minimal without a verdict.

### Optional Knowledge surface — `core/knowledge/output-vocabulary.md`

Lifts the 10-row verdict vocabulary out of PR-1's Rule 7 body into a Knowledge file (SRP — pure constants belong in Knowledge, not in an Actor body):

| Verdict | When | Emoji |
|---|---|---|
| `PROPOSED` | Agent is proposing a draft for human decision | (none) |
| `READY` | Artifact built, handoff to next phase awaits | (none) |
| `PASS` | All checks succeeded | ✅ |
| `PASS WITH WARNINGS` | Succeeded with non-blocking issues | ⚠️ |
| `FAIL` | One or more blockers; cannot proceed | ❌ |
| `BLOCKED` | Cannot proceed due to missing prerequisite (not a check failure) | 🛑 |
| `DRIFT` | Artifacts diverge from spec; reconcile needed | (none) |
| `CLEAN` | No drift, nothing to do | (none) |
| `APPLIED` | Change made successfully | ✅ |
| `REJECTED` | Human said no; state unchanged | (none) |

Components that adopt verdict-first cite this Knowledge surface for the vocabulary. The output skill body stays free of the table (SRP).

### How other skills consume `core/output`

Each skill's Constraints section adds **one** line: *"Outputs follow [`core/output`](../output/SKILL.md) golden rules."* That's the entire integration. The skill's own Output section (per `actor-template`) describes its specific format choice (a sample from Layer 1.5 below, or its own).

---

## Layer 1.5 — Output format samples (component-specific format choices, pre-approved)

17 samples, one per place the format changes. Each shows the exact text the human would see. **Audit-C reframing:** these are not "Rule 6/7 implementations" — they are **per-component canonical output formats**. Each is a free format choice by its owning skill that demonstrably satisfies the four golden rules in `core/output` (structured, minimal, formatted, sourced). The user pre-approved them in walkthrough 2026-05-20.

> **Conventions in this section** (per Rule 1 amendment above):
> - Every "Replaces X at Y" header carries a verbatim quote from the cited file.
> - Every sample body uses placeholder names (e.g., `auth`, `password-reset-via-email`) that **do not** refer to anything in this repo — each is therefore tagged `[illustrative]` at its top.
> - Decision blocks always end the message so the reader's cursor is over the next action.
> - Each sample's verdict (`PROPOSED`, `READY`, `PASS`, `DRIFT`, etc.) comes from `core/knowledge/output-vocabulary.md` — the component cites that Knowledge surface in its skill body.

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

## Layer 2 — Apply per-component formats to LSA skills + tier-selector

**Audit-C reframing.** Each affected skill gets two changes only:

1. Its existing prompt/output is **replaced** with the pre-approved S-sample from Layer 1.5 (a free format choice by the skill that satisfies the four golden rules in `core/output`).
2. Its Constraints section gains **one** citation line: *"Outputs follow [`core/output`](../../core/skills/output/SKILL.md) golden rules."* — no rule restatement, no Rule 6/7 reference, no specific format mandated by ground-rules.

Line numbers are post-refactor (audited 2026-05-20-B).

| File | Replace with | Source line (verbatim) |
|---|---|---|
| `core/skills/tier-selector/SKILL.md:32-36` | S1 sample (confirm-with-outcomes) | L36: *"Confirm? (y / n / override to T<other>)"* |
| `lsa/skills/lsa-discover/SKILL.md:24-25` | S3 sample (assume-then-override Qs) | L24-25: *"What's the change in one sentence?"* / *"What's the acceptance criterion in one sentence?"* |
| `lsa/skills/lsa-discover/SKILL.md:30` (Output) | S2 sample (Module/Change/AC table) | L30: *"write a single-paragraph context summary…"* |
| `lsa/skills/lsa-specify/SKILL.md:31-46` (Step 2) | S4 sample (`clarification.md` assume-then-override) | L32–L46: 9 open Qs (*"What does this feature do?"* … *"What are the exact conditions for this feature to be considered done?"*) |
| `lsa/skills/lsa-specify/SKILL.md` (gates 7→3 collapse) | S5 + S6 + S7 samples (Gate 1 = requirements + AC + contract-trigger; Gate 2 = test-suites + design; Gate 3 = final integration) | Stops at L97 (requirements), L99-105 (contract trigger — now its own step post-refactor), L127 (journeys), L149 (contract), L177 (design), L179 (final) = 6 explicit + 1 implicit acceptance gate = 7 |
| `lsa/skills/lsa-plan/SKILL.md:108` | S8 sample (plan-review gate) | L108: *"Does this plan look correct? Approve to start implementation, or tell me what to adjust."* |
| `lsa/skills/lsa-verify/SKILL.md:79-100` (report template) | S9 / S10 / S11 samples (PASS / FAIL / PASS-WITH-WARNINGS — three rendered variants of the same template; skill body shows the canonical one and lists the three vocab options) | L79-83 (current template): metadata block (Date/Branch/Mode) precedes Result line; verdict at L83, after 4 lines of metadata |
| `lsa/skills/lsa-verify/SKILL.md:104-107` (gate) | S9/S10/S11 decision footer | L105-107: branches stated; no decision prompt with options visible to the human |
| `lsa/skills/lsa-sync/SKILL.md:56` `:130` | S12 + S13 samples (delta-approval + ready-to-PR) | L56: *"These are the decisions I will merge into the module specs. Correct?"* / L130: *"Sync complete. Ready to create PR to main?"* |
| `lsa/skills/lsa-reconcile/SKILL.md:32-39` (Step 4 confirm) | S14 sample (per-module DRIFT block) | L32-38: *"Module: <name> / Classification: <…> / Proposed spec update: <…> / Apply? (y / n)"* |
| `lsa/skills/lsa-revise-constitution/SKILL.md:58` | S15 sample (per-change PROPOSED block) | L58: *"Apply this change? Yes / No / Modify"* |
| `lsa/skills/lsa-init/SKILL.md:48` | S17 sample (brownfield confirm; S16 dropped per audit-B D1) | L48: *"Skeleton specs generated. Review and confirm before I continue."* |
| All LSA skill Constraints sections + `core/skills/tier-selector/SKILL.md` Constraints | Add one line: *"Outputs follow [`core/output`](../../core/skills/output/SKILL.md) golden rules."* | Cross-cutting integration point — single citation per skill. |

### NOT in Layer 2 (audit-C reverts audit-B D2)

`lsa/knowledge/conventions.md` is **NOT modified**. Audit-B D2 proposed adding a *"Prompt shape"* section that cited Rules 6/7. Audit-C eliminates Rules 6/7 entirely; the output discipline lives in `core/output`, which every component cites directly. `conventions.md` keeps its 4 existing sections (`.lsa.yaml defaults`, `Read protocol`, `Confirm gate types`, `Trace-tag format`) unchanged.

---

## Layer 3 — Entry-point docs

**Audit-C reshaping:** `core/CLAUDE.md` collapses back to pointers (no rule restatement); probes restructure per-skill (no per-rule probes); Vision §2 gets the new "Substrate-native first" principle. Each row carries a verbatim quote of the current cited content (per Rule 1 amendment).

| File | Current content (verbatim) | Change |
|---|---|---|
| `vision/VISION.md:13` (was `:11` pre-refactor — remapped audit-B) | *"Build a personal, model-agnostic agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**."* | Append a second sentence: *"And whose operating philosophy is **ownership over automation** — the system does not think for the human; it makes the human think."* |
| `vision/VISION.md:54` (start of §2 First principles, principle #1) | *"1. **Trust is the product.** A fast wrong answer is a defect. A grounded \"I cannot verify this\" is a feature."* | Insert sub-principle 1a after #1: *"**1a. Ownership over automation.** The system surfaces facts, lays out options, and demands choice. It never silently decides on the human's behalf. (See `core/ground-rules` Rule 0.)"* |
| `vision/VISION.md:61` (after current principle #8) | *"8. **The system improves itself.** Every iteration leaves a trace: a retro, a metric, a changelog entry. Drift is a measured failure mode, not a surprise."* | Append new principle 9 (audit-C C4): *"**9. Substrate-native first.** When the platform provides a primitive — picker, file API, task tracker, verifier — use it. Don't ship a text-shadow of a feature the substrate already gives you. In Claude Code that means `AskUserQuestion` for decisions, `Read`/`Edit`/`Write` for files, `TaskCreate`/`TaskUpdate` for task tracking. Informs `core/ground-rules` (read protocol) and `core/output` (picker-and-format selection)."* |
| `vision/VISION.md:255` (Changelog, current latest is v0.4) | *"**v0.4** — Simplified to **Claude Code only.** Removed the Claude App as a target…"* | Prepend new v0.5 entry: *"**v0.5** — Codified the operating-philosophy credo: §0 sentence + §2 sub-principle 1a (Ownership over automation) + §2 principle 9 (Substrate-native first). `core/ground-rules` extended 4→6 (Rule 0 Ownership + Rule 5 No filler + Rule 1 amendment); NEW `core/output` skill ships the four output golden rules (structured / minimal / formatted / sourced) every component cites. NEW `core/knowledge/output-vocabulary.md` Knowledge surface. Corresponds to `core` plugin v0.4.0. The LSA-skill refit (per-component formats from this plan's Layer 1.5) lands as Vision v0.6 alongside `lsa` v0.4.0."* |
| `core/CLAUDE.md:3` (canonical-source declaration) | *"**Canonical source.** This file is the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules."* | **No change to this declaration.** |
| `core/CLAUDE.md:11` (current 4-rule prose summary) | *"Apply `core/ground-rules` to every substantive task. Every factual claim carries a source + searchable quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked."* | **Audit-C C5: collapse, do not restate.** Replace with three pointer lines: *"Apply [`core/ground-rules`](./skills/ground-rules/SKILL.md) to every substantive task (6 content rules). Apply [`core/output`](./skills/output/SKILL.md) to every human-facing output (4 format golden rules). Before any non-trivial task, invoke [`core/tier-selector`](./skills/tier-selector/SKILL.md) (T1/T2/T3 chain-of-thought)."* No rule enumeration. |
| `CLAUDE.md` (repo root) `:20-22` | *"## Always-on rules / The canonical always-on fragment lives at [`core/CLAUDE.md`](./core/CLAUDE.md): apply `core/ground-rules` to every substantive task; invoke `core/tier-selector` before any non-trivial task."* | Append one sentence: *"Outputs follow `core/output` (the four golden rules: structured / minimal / formatted / sourced). The operating credo is ownership over automation — see `core/CLAUDE.md`."* |
| `core/README.md:7` (currently summarizes the 4 rules) | *"**`ground-rules`** — Apply on every substantive task. Enforces: every factual claim carries a source + quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked."* | Replace with: *"**`ground-rules`** — Apply on every substantive task. Enforces 6 content rules — see `core/CLAUDE.md`."* and add a new bullet immediately after: *"**`output`** — Apply to every human-facing output. Enforces 4 golden format rules — see `core/CLAUDE.md`."* |
| `core/VERIFICATION.md:17` (start of "V2 — Description-match triggers reliably") | *"## V2 — Description-match triggers reliably / **Probe A (ground-rules).** … **Probe B (actor-template).** … **Probe C (tier-selector).** …"* | **Audit-C C6: per-skill, not per-rule.** Existing Probes A/B/C stay. Append one new probe: **Probe D (output)** — a fresh-session prompt that asks for a status report; PASS = response is structured (headings/table) + minimal (no fluff) + formatted (markdown affordances correct) + sourced (claims have file:line refs). No per-rule D/E/F/G. |
| `core/tests/repo-anchored.md:11` (start of Set A — ground-rules probes; current A1–A4 cover Rules 1–4) | *"### A1 — Fact-grounding on a falsifiable detail (Rule 1)"* through *"### A4 — Deliver only what was asked (Rule 4)"* | **Audit-C C6.** Existing A1–A4 stay. Append A5 (Rule 0 Ownership — anchored at `core/skills/ground-rules/SKILL.md` Rule 0) and A6 (Rule 5 No filler — anchored at `core/skills/ground-rules/SKILL.md` Rule 5). Add new probe Set D = `output` skill probe (one composed test covering all 4 golden rules). No per-rule probes for output. |
| `lsa/README.md:1-3` (file currently opens with `# LSA — Living Spec Architecture` then a one-paragraph purpose) | *"# LSA — Living Spec Architecture / Spec-first development methodology installable as a Claude Code plugin. Specs are the permanent source of truth…"* | Insert a new section right after the H1 titled *"## LSA's expression of the credo"* with the user's verbatim line: *"LSA doesn't automate your thinking — it makes you own it."* and a one-line follow-up linking to `core/CLAUDE.md`. (Lands in PR 2 alongside the LSA refit, not PR 1.) |
| `lsa/ARCHITECTURE.md:1-4` (header block) | *"# Living Spec Architecture (LSA) / **Version:** 0.2.1 (plugin) / **Author:** Nikita Zverev / **Status:** 0.2.1 — Vision-aligned…"* | (Lands in PR 2.) Bump Version line to **0.4.0**. Add one new section under §1 Purpose titled *"How `core/output` constrains LSA"* — one paragraph naming the mechanical consequences for LSA skills (per-component format adopts an S-sample; Constraints cites `core/output`; conventions.md unchanged). |

---

## Layer 4 — Versions + changelogs

**Baseline (audited 2026-05-20-B):** simplification refactor landed: `core@0.3.0`, `lsa@0.3.1` (`0.3.0` refactor + `0.3.1` *"KISS surgical edits."*). The credo rollout therefore targets **0.4.0** — a minor bump over each plugin's current shipped state.

| File | Current state (verbatim) | Change |
|---|---|---|
| `core/.claude-plugin/plugin.json:4` | *`"version": "0.3.0",`* | Bump to `"version": "0.4.0"`. Minor bump: 2 new ground-rules (0 + 5) + 1 new skill (`output`) = new observable contracts; no breaking removal. |
| `core/.claude-plugin/plugin.json:3` | *`"description": "...fact-grounding (sources + quotes), no fake-confidence hedging, read-before-write, only-required-output, the Goal/Input/Steps/Output/Constraints shape for any actor, and tier-selector (T1/T2/T3) chain-of-thought."`* | **Audit-C C7: enumerate skills, not rules.** Replace with: *"Domain-neutral discipline for trustworthy output and ceremony-scales-to-weight task orchestration. Four skills: `ground-rules` (6 content rules: ownership, fact-grounding, no fake-confidence, read-before-write, only-required-output, no-filler), `output` (4 format golden rules: structured, minimal, formatted, sourced), `actor-template` (Goal/Input/Steps/Output/Constraints shape), `tier-selector` (T1/T2/T3 chain-of-thought)."* |
| `core/CHANGELOG.md:7` | *"## [0.3.0] — 2026-05-20 / Knowledge-vs-Actor boundary tightening across all three core skills."* | Insert new `## [0.4.0] — <date>` entry above the existing 0.3.0 block. Body lists: (1) added ground-rules Rule 0 + Rule 5 + Rule 1 amendment; (2) NEW skill `core/skills/output/SKILL.md` (4 golden rules); (3) NEW Knowledge surface `core/knowledge/output-vocabulary.md` (10-row verdict-vocabulary table); (4) `core/CLAUDE.md` collapsed to 3 pointer lines (no rule restatement); (5) `core/README.md` adds `output` row + collapses `ground-rules` row to pointer; (6) `core/VERIFICATION.md` adds Probe D (output, composed test); (7) `core/tests/repo-anchored.md` adds A5 + A6 (Rules 0 + 5) + new Set D (output composed test). Cite Vision v0.5 + this plan. |
| `lsa/.claude-plugin/plugin.json:4` | *`"version": "0.3.1",`* | (PR 2.) Bump to `"version": "0.4.0"`. Minor bump: per-component output formats adopted across all 8 LSA skills + tier-selector; Constraints cite `core/output`. |
| `lsa/CHANGELOG.md:7` | *"## [0.3.1] — 2026-05-20 / KISS surgical edits."* (top entry; `0.3.0` "Knowledge-vs-Actor boundary tightening across all eight LSA skills." below) | (PR 2.) Insert new `## [0.4.0] — <date>` entry above the existing 0.3.1 block: each LSA skill's prompt/output replaced with its pre-approved S-sample format; `lsa-specify` gates collapsed 7→3; each skill's Constraints cites `core/output`; `lsa-init` Step 2 retains refactor's mechanical mode detection (audit-B D1). `conventions.md` unchanged. |

**Why 0.4.0, not 0.3.x:** `core@0.3.0` and `lsa@0.3.0`/`0.3.1` are reserved by the simplification refactor + its KISS patch. The credo rollout adds new observable contracts on top of that baseline — `0.4.0` is the next minor for both plugins.

**PR 1 / PR 2 split confirmed (audit-C):**
- **PR 1 (`feature/credo-core`):** Layer 1 (ground-rules content additions) + Layer 1.6 (NEW `core/output` skill + Knowledge surface) + Layer 3 core-side (Vision §0/§2/§9/changelog; `core/CLAUDE.md` collapse; `core/README.md`; `core/VERIFICATION.md`; `core/tests/repo-anchored.md`; repo root `CLAUDE.md`) + Layer 4 core. Bumps `core@0.3.0 → 0.4.0`.
- **PR 2 (`feature/credo-lsa`):** Layer 2 (per-component formats applied to all LSA skills + tier-selector cites `core/output`) + Layer 3 lsa-side (`lsa/README.md` credo section; `lsa/ARCHITECTURE.md` Version bump + new §1 sub-section) + Layer 4 lsa. Bumps `lsa@0.3.1 → 0.4.0`.

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

---

## PR 1 verification — SUPERSEDED by audit-C 2026-05-20

> **🚫 SUPERSEDED.** This section documents the PR 1 commit (`3dc1828`) + fix-up (`53d7c58`) that shipped the OLD architecture (`ground-rules` 4→8 rules including Rules 6/7 for output format). Audit-C found that structure violates `CONTRIBUTING.md` DRY/KISS/SRP (Rules 6/7 = format concern in a content-concern file; `core/CLAUDE.md` restated all 8 rules; per-rule probes). The audit-C plan above replaces this structure: `ground-rules` 4→6 content rules + new `core/output` skill for format. The two PR 1 commits will be discarded by `git reset --hard 01126d1` on `feature/credo-core` once this plan is approved. **Content below preserved as audit artifact only — do not act on it.**

Branch: `feature/credo-core`. Scope: Layer 1 + Layer 3 core-side + Layer 4 core + Vision §0 / §2 / changelog v0.5.

**Verdict.** `✅ PASS — every PR 1 plan item walked against file state via grep/wc/sed; three honesty flags filed below; one out-of-scope working-tree modification surfaced for separate handling.**

### Deliberate in-scope follow-ons (not literally in the plan)

Two edits were made as logical consequences of plan items, surfaced for transparency rather than pre-approved (Rule 4 minor — filed as self-review finding I4):

1. **`core/.claude-plugin/plugin.json` `description` extension.** Plan Layer 4 called for the version bump only. But the prior description enumerated *"fact-grounding (sources + quotes), no fake-confidence hedging, read-before-write, only-required-output"* — the 4 original rules. Bumping the rule count to 8 without updating this description would have left a stale claim about what contracts the plugin enforces. Extended description to enumerate all 8.
2. **`vision/VISION.md` `**Version:**` line bump 0.4 → 0.5.** Plan Layer 3 called for prepending a new v0.5 changelog entry. The file's `**Version:**` line at L4 reads *"0.4 — draft for review"*; leaving it would have created a Version-vs-changelog mismatch. Bumped to *"0.5 — draft for review"* to match the top changelog entry.

Both are file-level consistency repairs, not new contracts. Filing here so the next reviewer doesn't need to spot them against the plan.

### Walk every plan item against file state

| # | Plan item | Verification | Status |
|---|---|---|---|
| L1-1 | `ground-rules` frontmatter — append four new rules | `sed -n '3p' core/skills/ground-rules/SKILL.md` mentions "eight rules" + lists all 8 | ✅ |
| L1-2 | Body — Rule 0 first, then 1–4, then 5–7 | `grep -E "^## [0-7]\\. " core/skills/ground-rules/SKILL.md` = 8 lines, in order 0–7 | ✅ |
| L1-3 | Rule 0 — ownership-over-automation + cite VISION:60 | Rule 0 body present; `vision/VISION.md:60` cited verbatim | ✅ |
| L1-4 | Rule 1 amendment — Scope + Illustrative content | `**Scope.**` + `**Illustrative content.**` both present in Rule 1 body | ✅ |
| L1-5 | Rule 5 — No filler | `## 5. No filler` present; banned phrasings listed | ✅ |
| L1-6 | Rule 6 — Decisions surface options + outcomes | `## 6. Decisions surface options + outcomes` present; canonical option-block shape rendered | ✅ |
| L1-7 | Rule 7 — Structured-first output + verdict table | `## 7. Structured-first output` present; all 10 verdict-vocabulary terms in the table (`PROPOSED`, `READY`, `PASS`, `PASS WITH WARNINGS`, `FAIL`, `BLOCKED`, `DRIFT`, `CLEAN`, `APPLIED`, `REJECTED`) | ✅ |
| L1-8 | "What this skill never does" — add 4 lines | **NOT applied** — section was removed by the 0.3.0 refactor as a Knowledge-vs-Actor boundary violation (per `core/CHANGELOG.md:14`). Re-adding for new rules would re-introduce the redundancy. **Honesty flag F1.** | 🚩 deferred-deliberately |
| L3-1 | `vision/VISION.md` §0 — append credo sentence | L13 contains `"the system does not think for the human; it makes the human think."` | ✅ |
| L3-2 | `vision/VISION.md` §2 — insert principle 1a | `grep "1a\\. Ownership over automation" vision/VISION.md` matches | ✅ |
| L3-3 | `vision/VISION.md` changelog — prepend v0.5 entry | v0.5 entry above v0.4; Version field at top bumped 0.4 → 0.5 | ✅ |
| L3-4 | `core/CLAUDE.md` — 8-rule enumeration | `grep -cE "^\- \*\*Rule [0-7] —" core/CLAUDE.md` = 8 | ✅ |
| L3-5 | `CLAUDE.md` (repo root) — append credo line | "operating credo is **ownership over automation**" present in Always-on rules section | ✅ |
| L3-6 | `core/README.md` — replace "Enforces:" tail with pointer | `ground-rules` row points to `core/CLAUDE.md` for canonical list | ✅ |
| L3-7 | `core/VERIFICATION.md` — append Probes D/E/F/G | `grep -cE "^\*\*Probe [DEFG] " core/VERIFICATION.md` = 4 | ✅ |
| L3-8 | `core/tests/repo-anchored.md` — append A5–A8 | `grep -cE "^### A[5-8] " core/tests/repo-anchored.md` = 4 | ✅ |
| L3-9 | `core/tests/repo-anchored.md` — A3 expects "Eight" not "Four" | A3 PASS line now expects "Eight" + eight headings | ✅ (in-scope follow-on) |
| L4-1 | `core/.claude-plugin/plugin.json` — version 0.3.0 → 0.4.0 | `"version": "0.4.0"`; `python3 -c "import json; json.load(...)"` validates | ✅ |
| L4-2 | `core/.claude-plugin/plugin.json` — description extended | New tokens present: ownership-over-automation, no-filler, decision-shape, structured-first | ✅ (in-scope follow-on) |
| L4-3 | `core/CHANGELOG.md` — insert [0.4.0] above [0.3.0] | [0.4.0] at L7, [0.3.0] at L32 | ✅ |

### Honesty flags

- **F1 — "What this skill never does" section NOT re-added.** The plan's Layer 1 last item said *"Add 4 lines mirroring new rules"* to that section. But the 0.3.0 refactor explicitly removed the section as a Knowledge-vs-Actor boundary violation (per `core/CHANGELOG.md:14` — *"removed the trailing 'What this skill never does' block"*). Adding it back for 4 new rules would re-introduce the same redundancy. Skipped deliberately; aligns with the refactor's own DRY logic.
- **F2 — frontmatter description consolidated, not literally "appended."** The plan's Layer 1 row for the frontmatter directs verbatim: *"Append: 'Also enforces ownership-over-automation, no-filler, decision-shape (options + outcomes), and structured-first output.'"* — that would make 3 sentences. `CONTRIBUTING.md` enforces (§"This file (and every contribution)…") *"≤2-sentence frontmatter descriptions with trigger phrases preserved."* Consolidated into the existing "Enforces …" sentence by bumping the count to "eight rules" and listing all 8 in compact form. Same content, 2 sentences instead of 3.
- **F3 — Vision changelog split: v0.5 (PR 1) + v0.6 (PR 2).** The plan's Layer 3 row for `VISION.md:255` proposed a single v0.5 entry covering both the credo principles *and* the LSA-skill refit. Writing that single entry now (PR 1) would claim work that ships in PR 2 has already shipped. Split into v0.5 (this PR — credo concept + Rules 0/5/6/7 in core) and v0.6 (next PR — LSA-skill refit + `conventions.md §Prompt shape`). The v0.5 entry says *"The LSA-skill refit lands as Vision v0.6 alongside `lsa` plugin v0.4.0."* — forward link maintains traceability.

### Out-of-scope working-tree change (surfaced, not committed)

- `vision/specs/roadmap.md` shows a working-tree modification (Tech Picture adoption block — 3 new rows + new "Tech Picture adoption — 2026-05-20" section). `[cannot externally verify — based on session tool-log: no Edit or Write call ever targeted vision/specs/roadmap.md, so the modification was introduced from outside this session.]` The session-start git-status snapshot did not list it (the system reminder's `gitStatus:` block at the top of the conversation showed only `?? vision/plans/2026-05-20-credo-rollout-plan.md` and four `.DS_Store` / temp paths as untracked, with zero `M` files), so the change landed during the session via some channel other than this agent. Per `CONTRIBUTING.md` *"prefer adding specific files by name rather than using `git add -A` or `git add .`"* + Rule 4 *"Deliver only what was asked"*, PR 1 stages only the credo-rollout files and leaves `vision/specs/roadmap.md` modified in the working tree for separate handling by the user.

### Cannot mechanically verify (deferred to live session)

- **V1 — installs cleanly.** Requires `/plugin install core@nz-vision` + `/help` in a Claude Code session. Not runnable from this terminal.
- **V2 — description-match triggers reliably.** Probes A–G need fresh Claude Code sessions per `core/VERIFICATION.md`. Each probe described in the file; deferred to user-driven dogfood across 2 weeks per `core/VERIFICATION.md`'s falsifiable threshold (≥ ~90% trigger rate).
- **V3 — behavior change is observable.** Compare-runs of the same task with/without `core` enabled per `core/VERIFICATION.md`. Deferred to dogfood.

PR 1 ships the static deliverable (rules + docs + probes); the falsifiable-threshold V2/V3 verdict comes from dogfood, not from this report.
