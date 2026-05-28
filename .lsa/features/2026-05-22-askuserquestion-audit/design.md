# Design: Audit + tighten `AskUserQuestion` call sites (Helper + LSA)

> Source: `.lsa/roadmap.md` §"2026-05-22 backlog detail" #3 (`.lsa/roadmap.md:116-120`).

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `core` (`core/skills/output/SKILL.md`) | Modify — add "Genuine-fork test" sub-rule under Rule 5 |
| `helper` (`helper/agents/helper.md`, `helper/commands/help.md`, `helper/knowledge/output-discipline.md`) | Modify — drop reflexive pickers; keep substrate-native cite for genuine forks |
| `lsa` (subset of `lsa/skills/**/SKILL.md`) | Modify — per per-call-site verdicts in inventory |
| `core/CLAUDE.md` operational checkpoint #1 | Modify — clarify checkpoint is *substrate selection given a fork*, not *fork existence* |

## Technical Approach

Three sequenced changes (one PR per plugin, per `CLAUDE.md` "Per-plugin SemVer"):

1. **PR-A (`core`)** — add Rule 5 sub-rule "Genuine-fork test" to `core/skills/output/SKILL.md`. Citing Principle 9 (`.lsa/VISION.md:66`) by link. Update `core/CLAUDE.md` operational checkpoint #1 to make the orthogonality explicit. Bump `core/plugin.json` minor version; entry in `core/CHANGELOG.md`. **Ships first** — Helper and LSA PRs cite this rule.
2. **PR-B (`lsa`)** — apply verdicts to the 13 LSA call sites in the inventory below. Bump `lsa/plugin.json`; `lsa/CHANGELOG.md` entry. Independent of PR-C.
3. **PR-C (`helper`)** — apply verdicts to the 4–5 Helper call sites in the inventory. **Sequencing:** lands *after* backlog #1 (Helper command-router refactor) — otherwise #1's dispatch rewrite re-introduces removed pickers. See `tasks.md`.

## Call-site Inventory

Generated from `grep -rn "AskUserQuestion" helper/agents/ helper/commands/ helper/knowledge/ helper/.claude-plugin/ lsa/skills/` on 2026-05-23 (re-run during plan revision). **Canonical denominator: 43 actor-surface hits across `helper/{agents,commands,knowledge,.claude-plugin}/ lsa/skills/`** (29 Helper + 14 LSA). Broad-scope grep `grep -rn "AskUserQuestion" helper/ lsa/ core/` returns 69 hits but includes `CHANGELOG.md`, `README.md`, `VERIFICATION.md`, and `core/CLAUDE.md` mentions that are documentation/changelog text, not runtime call sites — excluded from inventory. The earlier "57" and "55" figures are retracted.

**Classification legend:**
- `keep` — genuine fork the agent cannot resolve from context (destructive, two valid architectures, missing info, per-row triage).
- `remove` — confirmatory or rephrasing picker; replace with direct cited answer / direct action.
- `convert-to-closing-offer` — not a fork mid-flow, but a *next-step* offer the user can override; keep as one optional closing picker, not a mid-flow gate.
- `meta-reference` — not a runtime call site; a constraint, glossary entry, or descriptive prose that references the primitive. No code-effective change.

### Helper

| # | `file:line` | Current context (verbatim, abridged) | Verdict | Reason |
|---|-------------|--------------------------------------|---------|--------|
| H1 | `helper/agents/helper.md:34` | Signal (a) opening: *"Want me to explain what this User Verification is checking? — Yes / No"* | `keep` | Genuine fork — user just rejected twice; they may want explanation OR may want to move on. Both branches differ in body content. |
| H2 | `helper/agents/helper.md:35` | Step 4: *"Start `lsa-specify` for password reset? — Yes / No"* before `Skill()` handoff | `keep` | Destructive in the sense that it spawns a multi-turn skill flow; substrate-native confirm is correct per Principle 9. |
| H3 | `helper/agents/helper.md:36` | Step 5: closing next-step picker (2–3 narrow options) | `convert-to-closing-offer` | Today this is **mandatory** ("the closing picker appears" is observable result). After this row, it's *optional* — only when a real next step exists. A response that fully answered the question may close with no picker. |
| H4 | `helper/commands/help.md:18` | No-argument starter-topic picker (3 starter topics) | `keep` | Genuine fork — user invoked `/help` with no argument; the agent has no input to resolve. The picker is the input source. |
| H5a | `helper/agents/helper.md:3` | Frontmatter `description` — *"hands off … under explicit `AskUserQuestion` confirmation"* | `meta-reference` | Glossary voice in agent metadata. No runtime call site. |
| H5b | `helper/agents/helper.md:4` | Frontmatter `tools:` list including `AskUserQuestion` | `meta-reference` | Tool declaration, not a call site. |
| H5c | `helper/agents/helper.md:32` | Step 1 — *"exit with no output (no `AskUserQuestion`, no preamble…)"* | `meta-reference` | Describes the cooldown silent-exit; references the primitive in negative voice. |
| H5d | `helper/agents/helper.md:42` | Output contract — *"closed by an `AskUserQuestion` picker"* | `meta-reference` | Restates H3's binding rule; relaxes when H3 + `output-discipline.md:20` relax. Cross-ref only. |
| H5e | `helper/agents/helper.md:50` | Constraint — cannot-ground fallback offers `AskUserQuestion` next steps | `meta-reference` | Conditional reference; the call site is at H1/H3, not here. |
| H5f | `helper/agents/helper.md:52` | Constraint — substrate-native decisions use `AskUserQuestion`, never `[a]/[b]/[c]` | `meta-reference` | Restates Principle 9 binding (`.lsa/VISION.md:66`). |
| H5g | `helper/agents/helper.md:54` | Constraint — long answers split, ending with `AskUserQuestion` for `"show more"` | `meta-reference` | Conditional reference; live call site only fires on overflow. |
| H5h | `helper/agents/helper.md:56` | Constraint — `Skill()` handoff is always preceded by explicit `AskUserQuestion` | `meta-reference` | Restates H2 binding from a different voice. |
| H5i | `helper/commands/help.md:14` | Command body — describes Helper's response shape (cited answer + closing `AskUserQuestion`) | `meta-reference` | Documentation prose. |
| H5j | `helper/commands/help.md:29` | Constraint — never render `[a] / [b] / [c]`, always `AskUserQuestion`. Cites `.lsa/VISION.md:66` Principle 9. | `meta-reference` | Restates Principle 9. |
| H5k | `helper/knowledge/output-discipline.md:17` | Rule — long answers end with `AskUserQuestion` | `meta-reference` | Restates H5g. |
| H5l | `helper/knowledge/output-discipline.md:19` | Rule — substrate-native decisions use `AskUserQuestion` | `meta-reference` | Restates Principle 9 binding. |
| H5m | `helper/knowledge/output-discipline.md:20` | **Binding rule — *"Closing picker. Every response (except `Skill()` handoff) closes with `AskUserQuestion`…"*** | **(binding rule conflicts with H3 — relax)** | NOT meta-reference: this IS the rule that forces H3's mandatory closing picker. Must be relaxed to *"close with `AskUserQuestion` WHEN a real next step exists"* in PR-C. |
| H5n | `helper/knowledge/output-discipline.md:25` | Anti-pattern — text `[a]/[b]/[c]` instead of `AskUserQuestion` | `meta-reference` | Restates Principle 9 anti-pattern. |
| H5o | `helper/knowledge/output-discipline.md:33` | Truncation behavior — opens `AskUserQuestion` for `"show full answer"` / `"narrow"` | `meta-reference` | Conditional reference; live call site only on truncation. |
| H5p | `helper/knowledge/friction-signals.md:14` | Signal-b definition — excludes `AskUserQuestion` answer slots | `meta-reference` | Detection-logic reference, not a call site. |
| H5q | `helper/knowledge/friction-signals.md:19` | Cooldown — `AskUserQuestion → No` decline signal | `meta-reference` | Detection-logic reference. |
| H5r | `helper/knowledge/friction-signals.md:29-30` | Cooldown — `AskUserQuestion → No` / `→ Skip` | `meta-reference` | Detection-logic reference. Adjust per C4 if Step 5 closes without a picker. |
| H5s | `helper/knowledge/friction-signals.md:51` | Diagnostic — read the immediately-following `AskUserQuestion` answer | `meta-reference` | Detection-logic reference. |
| H5t | `helper/knowledge/friction-signals.md:65` | Signal-skip rule — `?` inside an active `AskUserQuestion` answer | `meta-reference` | Detection-logic reference. |
| H5u | `helper/knowledge/friction-signals.md:66` | Signal-skip rule — `what is X?` typed as an `AskUserQuestion` answer | `meta-reference` | Detection-logic reference. |
| H5v | `helper/knowledge/knowledge-scope.md:25` | Cannot-ground fallback offers `AskUserQuestion` next steps | `meta-reference` | Restates H5e. |

**Helper net effect:** 2 `keep` (H1, H2), 1 `convert-to-closing-offer` (H3), 1 `keep` (H4 — no-arg starter), 21 `meta-reference` rows (H5a–H5v) of which **H5m is a binding-rule fix** (relaxes the mandatory closing picker). Net live-call-site reduction: ~1 mandatory picker becomes optional.

### LSA (8 skills)

| # | `file:line` | Skill / step | Verdict | Reason |
|---|-------------|--------------|---------|--------|
| L1 | `lsa/skills/lsa-init/SKILL.md:57` | `lsa-init` brownfield — *"Write `<N>` inferred module specs?"* with `[a]/[b]/[c]` | `keep` | Genuine fork — destructive (writes spec tree). Three branches differ materially: write-all / write-some / reject. |
| L2 | `lsa/skills/lsa-discover/SKILL.md:33` | Three-question discovery probe — module / change / AC | `keep + tighten` | Genuine fork in principle (real classification choices), but Step 2 already says "Silence on a line = approval" (`lsa-discover/SKILL.md:26`). When Step 1 yields a single unambiguous candidate per line, the per-line picker is redundant. Tighten: skip per-line picker when N=1 candidate AND surface confirmation as one batched picker only if any line has ≥2 candidates or `custom`. Maps to AC3. |
| L3 | `lsa/skills/lsa-specify/SKILL.md:40` | Step opening — *"answers captured; human approval logged"* | `keep` | Genuine fork — spec content the user must own (per `.lsa/VISION.md:15` "ownership over automation"). |
| L4 | `lsa/skills/lsa-specify/SKILL.md:99` | Per-requirement clarification — *"Add password reset endpoint?"* | `keep` | Real per-row triage; already enforces subject-voice per `core/output` Rule 5. No reflexive-picker pathology. |
| L5 | `lsa/skills/lsa-specify/SKILL.md:196` | Batched multi-question on consistency-check failures | `keep` | Genuine fork — destructive resolution of `✗` rows; batched correctly per existing skill text. |
| L6 | `lsa/skills/lsa-specify/SKILL.md:204` | Same batched-picker mechanism — different presentation step | `keep` | Same as L5. Both pointers describe one mechanism. |
| L7 | `lsa/skills/lsa-specify/SKILL.md:213` | Integration check sign-off | `keep` | Gate before `lsa-plan` runs. Destructive in flow-sequencing sense. |
| L8 | `lsa/skills/lsa-plan/SKILL.md:120` | Plan approval — before implementation starts | `keep` | Destructive; human owns intent per `.lsa/VISION.md:64` Principle 7. |
| L9 | `lsa/skills/lsa-verify/SKILL.md:87` | Verdict picker (`PASS` / `FAIL` / `PASS WITH WARNINGS`) | `keep + tighten` (verdict-picker pattern) | Borderline: per `lsa/skills/lsa-verify/SKILL.md:89` "the report's decision block IS the gate" — the user is picking *next action given the verdict*, not choosing between two architectures. This is a **verdict-picker pattern** (its own category, neither pure fork nor closing-offer). Keep; tighten by surfacing the verdict in the picker prompt itself (e.g., *"Verdict: FAIL — block merge? — Yes (block) / No (override)"*) so the human's choice is framed as a next-action decision, not a re-verdict. |
| L10 | `lsa/skills/lsa-verify/SKILL.md:89` | Same decision, gate restatement | `meta-reference` | Restatement of L9 in the same skill body. No second call site at runtime. |
| L11 | `lsa/skills/lsa-sync/SKILL.md:59` | Pre-sync delta approval (`apply` / `modify` / `reject`) | `keep` | Destructive (edits module specs); three branches differ materially. |
| L12 | `lsa/skills/lsa-sync/SKILL.md:131` | Post-sync PR-or-hold picker | `convert-to-closing-offer` | Not mid-flow — sync is complete. Two-option offer (create PR vs hold) is a true closing offer; permissible as one optional closing picker. Today the skill renders this as a mandatory gate ("human decision logged"); soften to optional closing offer with sensible default (`hold` if user is silent). |
| L13 | `lsa/skills/lsa-reconcile/SKILL.md:35` | Per-module drift decision (`apply` / `reject`) | `keep` | Per-row triage on actual divergence; this is the "gold standard" gate per `MEMORY.md` `feedback_lsa_reconcile_gold_standard.md`. |
| L14 | `lsa/skills/lsa-revise-constitution/SKILL.md:61` | Per-change constitution edit (`apply` / `modify` / `reject`) | `keep` | Destructive (writes constitution). Per-change picker is correct. |
| L15 | `core/skills/flow-selector/SKILL.md:50` | Flow proposal — Quick / Standard / Extended | `keep` | Genuine fork — flow choice drives downstream skill chain. |
| L16 | `core/skills/ground-rules/SKILL.md:28` | Descriptive prose — names `AskUserQuestion` as substrate primitive | `meta-reference` | Not a call site. |
_(L17 row deleted — earlier "duplicate of L6" was a phantom; `lsa-specify/SKILL.md:204` has only one grep hit, already captured as L6.)_

**LSA net effect:** 10 `keep`, 2 `keep + tighten` (L2 `lsa-discover`, L9 `lsa-verify` verdict-picker), 1 `convert-to-closing-offer` (L12), 2 `meta-reference` (L10, L16). The LSA picker discipline is largely correct; the tightening is concentrated on (a) `lsa-discover` per-line redundancy when single candidate present, (b) `lsa-sync` post-completion picker becoming optional, and (c) `lsa-verify` verdict-picker prompt voice.

**Totals (live call sites only, excluding `meta-reference`):**
- Helper: 4 sites — 3 `keep`, 1 `convert-to-closing-offer`.
- LSA: 13 sites — 10 `keep`, 2 `keep + tighten`, 1 `convert-to-closing-offer`.
- **Grand total live: 17 sites. `keep` (incl. `keep + tighten`): 15. `convert-to-closing-offer`: 2. `remove`: 0.**
- **Meta-reference total: 23 rows** (21 Helper H5a–H5v + 2 LSA L10, L16). Of these, H5m is a binding-rule fix, not a pure reference.

The audit confirms the *posture* problem the user reported lives primarily in **Helper's mandatory closing picker** (H3 + `output-discipline.md:20`) rather than in LSA's substantive gates. This validates the "partially orthogonal to #1" framing in `.lsa/roadmap.md:116`.

## Operational Checklist — the Genuine-fork test

Apply per call site. Picker is justified only if **at least one** is true:

1. **Destructive write** — the next action edits a file, deletes a row, calls an external service, or starts a multi-turn skill flow that is hard to roll back.
2. **Two named designs in scope and neither overrides the other** — the agent has identified ≥2 reasonable continuations from in-scope sources (`.lsa/VISION.md:63` Principle 6: in-repo config → in-repo docs → code → external → ask) and no source ranks one above the other.
3. **A fact required by the next step is absent from working context and cannot be derived** — spec, repo, and prior turns do not supply it (e.g., user invoked `/help` with no argument; a required field is missing from `requirements.md` + repo + prior conversation).
4. **Per-row triage in a batch** — N items each need an independent decision (e.g., `lsa-specify` consistency-check failures, `lsa-reconcile` per-module drift).

If none of the above: replace the picker with a direct cited answer and (optionally) ONE closing offer for the user to override the agent's default.

**Subject voice still applies** (`core/skills/output/SKILL.md:35-40`) — even when a picker IS justified, the prompt names the real-world subject, not the spec ID.

## Proposed `core/output` Rule 5 expansion of "Must-decide only"

**Overlap acknowledged.** `core/skills/output/SKILL.md:39` already contains a "Must-decide only" bullet: *"Surface as picker questions only choices that meaningfully change the outcome. Bundle consistency checks; defer nice-to-decide to non-blocking summary lines."* This is substantially the same concept as the audit's intent. The new sub-rule is therefore framed as an **expansion** of the existing bullet — adding the operational checklist that makes "meaningfully change the outcome" testable — not a net-new orthogonal rule.

Replace the existing "Must-decide only" bullet at `core/skills/output/SKILL.md:39` with the expanded version below:

```markdown
- **Must-decide only — Genuine-fork test.** Surface as picker questions only choices that meaningfully change the outcome. Before opening a picker, the agent answers: *is there a real fork I cannot resolve from in-scope sources?* A fork is real when **at least one** holds: (a) **destructive** — the next action edits a file, deletes a row, calls an external service, or starts a multi-turn skill flow; (b) **two named designs in scope and neither overrides the other** — the agent has identified ≥2 reasonable continuations from in-scope sources (`.lsa/VISION.md:63` Principle 6) and no source ranks one above the other; (c) **a fact required by the next step is absent from working context and cannot be derived** — spec, repo, and prior turns do not supply it; (d) **per-row triage** — N items each need an independent decision (batched into one multi-question picker). If none apply, deliver the cited answer directly and offer at most ONE closing picker for the user to override. Substrate selection (which primitive) is governed by `.lsa/VISION.md:66` Principle 9.
```

(Body copy is one bullet — fits NF2 ≤6 lines once rendered as wrapped markdown.)

**`core/CLAUDE.md` operational checkpoint #1** ("Substrate-native pickers", currently at `core/CLAUDE.md` ~line 14) gets one clarifying line:

```markdown
This checkpoint is downstream of the Rule 5 "Genuine-fork test" in `core/skills/output/SKILL.md` — *if* a picker is justified, *then* use `AskUserQuestion`. Don't render a picker that wasn't justified in the first place.
```

## Interaction with backlog #1

Backlog #1 (Helper command-router refactor, `.lsa/roadmap.md:104-108`) rewrites Helper's **default flow** to lead with a cited answer, demoting dispatch to a side effect. The overlap with this row is at H3 and `output-discipline.md:20` (the mandatory closing picker).

**Boundary line:**
- Backlog #1 owns: Helper Steps 1–5 reordering, the dispatch posture, the cited-answer-first principle in `helper/agents/helper.md` and `helper/commands/help.md`.
- This row (#3) owns: the per-call-site classification + the `core/output` Rule 5 sub-rule + LSA call-site sweep.

**Sequencing:** PR-A (`core`) ships first (rubric publication). PR-B (`lsa`) ships next (independent of Helper). PR-C (`helper`) ships **after** backlog #1's Helper PR — otherwise #1 re-introduces the dispatch reflex. If #1 is delayed, PR-C can ship in parallel iff #1's branch rebases onto PR-C cleanly; record the decision in `tasks.md` at the time.

## Cross-Module Contracts

- `core/output` Rule 5 sub-rule is the canonical statement. `helper/knowledge/output-discipline.md` and any LSA prose that references "when to pick vs answer" links to it — does not restate (per `core/skills/output/SKILL.md:8` canonical-source rule).
- LSA skills that batch multi-question pickers (L5, L6, L13, L14) continue to do so per existing skill text — the Genuine-fork test passes once per row in the batch, not once per call site.

## Open Questions

- **OQ1.** Sub-rule name: "Genuine-fork test" vs "Real-fork test" vs "Fork-existence test". Subject-voice prefers "Genuine fork" (user-readable); "Fork-existence" is more precise relative to Principle 9. Decide in PR-A code review.
- **OQ2.** Closing-offer cap — should the rubric explicitly forbid TWO closing offers in one turn (e.g., one at end of body + one after a "want me to run X" line)? Inventory does not show two-in-one-turn today; documenting the cap is defensive.
- **OQ3.** Does L2 (`lsa-discover` per-line tightening) need a `lsa` minor bump or patch bump? Behavior change (silent acceptance when N=1) is user-visible — likely minor. Confirm against `lsa/CHANGELOG.md` precedent.
- **OQ4.** Does `helper/knowledge/output-discipline.md:20` ("Closing picker on every response except `Skill()` handoff") get **deleted** or **relaxed to "when a real next step exists"**? Inventory verdict on H3 implies relax, not delete. Confirm in PR-C.
- **OQ5.** Does L12 (`lsa-sync` PR-or-hold) need a default-on-silence policy (e.g., default to `hold`)? Sensible default removes the picker entirely for the silent-user path; explicit picker stays for users who want to override.
- **OQ6.** Should a separate VISION-citation-refresh PR ride along on PR-A? Beyond this feature dir, the repo has stale `.lsa/VISION.md` line citations from prior reorders (e.g., `:55`, `:57`, `:63`, `:201` patterns may point at the wrong principle elsewhere). A repo-wide grep + refresh sweep is one extra commit in PR-A; alternatively, defer to `lsa-reconcile`. Recommend: piggyback on PR-A — citations are part of "trustworthy output" (`.lsa/VISION.md:15`).
