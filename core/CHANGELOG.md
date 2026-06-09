# Changelog

All notable changes to the `core` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.11.2] — 2026-06-08

Marketplace-audit cleanup.

### Changed

- **`core/.claude-plugin/plugin.json`** — description de-counts components ("Skills:" not "Four skills"), per the new no-volatile-component-counts convention.
- **`core/README.md`** — fast-path consumer list drops the removed `lsa:next`.

## [0.11.1] — 2026-06-08

Reference fixes surfaced by the cross-plugin prompt review.

### Fixed

- **`core/skills/output/SKILL.md`** — six stale links to renamed/removed LSA skills: `lsa-reconcile` → `reconcile` (Rule 7 body), `lsa-sync` → `verify` and `lsa-specify` → `specify` (the show-changes worked-example tables). The `lsa-` prefixes and the `sync` skill were dropped in `lsa` 0.16.
- **`core/skills/flow-selector/SKILL.md`**, **`core/CLAUDE.md`** — the Extended-flow loop referenced the removed `lsa:plan` / `lsa:implement` skills; now `discover → specify → verify → delegate → reconcile`.
- **`core/skills/ground-rules/SKILL.md`**, **`flow-selector`**, **`CLAUDE.md`** — drifted `.lsa/VISION.md` line-number citations (`:60`, `:122`, `:124`) replaced with §/principle references (drift-proof, per this plugin's own canonical-citation guidance).

## [0.11.0] — 2026-06-02

Relax `core/output` to advisory — one hard rule, six guidance. Fact-grounding stays mandatory; the six shape rules become outcomes to aim for, not a per-response checklist. Frees simple answers to be short prose instead of a six-block template, and lets non-Claude substrates use their own voice.

### Changed

- **`skills/output/SKILL.md`** — split the seven golden rules into ONE hard rule (Rule 4, Sourced — fact-grounding + file-load trace + citation format) and SIX guidance rules (1-3, 5-7, applied when they serve the answer). Rule numbering preserved verbatim (other files cite by number); no rule content removed — only the enforcement posture changed. The canonical-source clause now hard-protects only Rule 4 and forbids re-promoting a guidance rule to a marketplace-wide hard requirement.
- **`CLAUDE.md`** — always-on output block reframed to "one hard rule + six pieces of guidance". The four operational checkpoints are re-tagged: file-load trace (#3) stays hard (part of Rule 4); substrate-native pickers (#1), 1–1.5 screen budget (#2), and show-changes-inline (#4) become strongly-recommended guidance. The show-changes-inline note clarifies the discipline is still held at the skill / verify level (per v0.10.0), independent of the `core/output` posture.
- **`core/tests/repo-anchored.md`** — probe D1 reworded from "satisfies all seven golden rules = PASS" to "hard rule (Sourced) holds + guidance applied where it serves"; the FAIL bar is now a missing source / unquoted claim (hard), with prose-first / padding demoted to guidance weaknesses.
- **`core/README.md`** — output bullet describes the new hard-vs-guidance posture.

### Why

Per `.lsa/pitches/relax-core-output-to-advisory.md` (user, 2026-05-28: *"it feels like we restriced Claude too much … keep the hard requirements to provide Sources + Quotes but in a free format so Claude OR any other tool can shine"*). Safe to relax because show-changes-inline enforcement now lives at the skill / verify level (core v0.10.0), not the `core/output` posture. The prerequisite verdict-tag grep ran first: no automated tooling parses the verdict labels as data (no test harness this release), so reclassifying them as guidance breaks nothing.

## [0.10.0] — 2026-06-02

Show-changes-inline enforcement. Rule 7 gains a *How this gets enforced* sub-section; the operational checkpoint spells out the write → show → comment order; two warning-only regression checks (prompt-review for prompt sources, lsa:verify for runtime artifacts) now hold the discipline.

### Added

- **`skills/output/SKILL.md`** — Rule 7 *How this gets enforced* sub-section: names the per-skill cite locations, the two regression checks (`prompt-engineer:prompt-review` author-time over prompt sources; `lsa:verify` PR-time over runtime artifacts, both warning-only), and the `lsa:reconcile` 8-element drift block as the gold-standard exemplar. Rule 7's content and template are unchanged.

### Changed

- **`CLAUDE.md`** — operational checkpoint #4 now spells out the fixed write → show → comment order, the compressed-inspection-table threshold, the `lsa:reconcile` Step 4 reference, and both regression-check surfaces.

## [0.9.0] — 2026-06-02

Fast-path navigation contract. New shared knowledge file establishing the single-source-of-truth fast-path pattern cited by `lsa:next`, `management:roadmap`, the `project-manager` agent, and Helper's onboarding catalog.

### Added

- **`knowledge/fast-path-source-of-truth.md`** — the shared single-source-of-truth navigation fast-path contract: a navigation-class question ("what's next", "how do I get started") maps to one source-of-truth file at a known path → direct `Read` + cited `file:line` quote-back, no sub-agent / `context7` / multi-round `Grep`. Documents the pattern shape, exact-phrase detection (not semantic similarity), the fall-through-on-failure rule (no regression to the deep-research path), and the `file:line` citation format. `core/README.md` gains a Knowledge section; root `knowledge/index.md` count 14 → 15.

## [0.5.7] — 2026-05-27

Prompt audit remediation — cross-reference fixes, Rule 7 trimming, wording polish.

### Fixed

- **`skills/output/SKILL.md`** — fixed 2 broken `lsa-reconcile` links → `reconcile` (renamed in lsa v0.8.0).
- **`skills/ground-rules/SKILL.md`** — removed stale rule count ("five format golden rules" → "the format golden rules") per output SKILL.md line 8 prohibition on restating the count.
- **`knowledge/output-vocabulary.md`** — added missing markdown link to `lsa/knowledge/conventions.md`.

### Changed

- **`skills/output/SKILL.md`** — Rule 7 trimmed from ~93 to ~57 lines: removed 2 of 3 worked examples (kept single-file edit) and inheritance meta-commentary section. Rules 1 and 3 tightened to make their distinct value clear (Rule 1 = explicit skeleton, Rule 3 = pick the right markdown primitive).
- **`skills/ground-rules/SKILL.md`** — trimmed opening paragraph that restated frontmatter.
- **`skills/flow-selector/SKILL.md`** — deduplicated rename-history mentions (4→1 canonical in frontmatter).
- **`CLAUDE.md`** — removed `(was Tn)` tags from flow outcomes list.

## [0.5.6] — 2026-05-24

Cross-reference update for LSA v0.8.0 command rename. Updated `core/CLAUDE.md` flow outcomes to use new LSA skill names (`lsa:discover`, `lsa:plan`, `lsa:verify` — dropped former `lsa-discover` → `lsa-specify` → `lsa-plan` → `lsa-verify` → `lsa-sync` chain). Updated `core/skills/flow-selector/SKILL.md` and `core/knowledge/output-vocabulary.md` references. Also incorporates core v0.6.0–v0.8.0 content that landed on main in parallel (Rules 5 expansion, Rule 6, Rule 7, 5→7 golden rules bump).

### Changed
- **`core/CLAUDE.md`** — flow outcomes updated: Standard is now `lsa:discover` → TDD → `lsa:verify`; Extended is now `lsa:discover` → `lsa:plan` → implement → `lsa:verify` (sync removed, specify merged into discover).
- **`core/skills/flow-selector/SKILL.md`** — LSA skill name references updated to new names.
- **`core/knowledge/output-vocabulary.md`** — `lsa-verify` → `verify` in example references.
- **`core/skills/output/SKILL.md`** — Rule 5 expanded with Genuine-fork test; Rule 6 (what-and-why preamble) and Rule 7 (show changes inline) added; rule count 5 → 7.
- **`core/CLAUDE.md` § Output discipline** — seven format golden rules; four operational checkpoints (substrate-native pickers, 1–1.5 screen budget, file-load trace, show changes inline).
- **`core/.claude-plugin/plugin.json` `description`** — rule-count updated to 7; rule list extended with what-and-why preamble and show-changes-inline.

## [0.8.0] — 2026-05-24

Adds **Rule 7 — Show changes inline (write, show, comment)** to `core/output`. Every write, edit, or mark performed by an agent must be echoed back inline before commentary — single-change block (path:line + verbatim previous + verbatim new + reason + source + type tag) for one edit; compressed inspection table (`#` / `file:line` / `type` / `summary` / `pointer`) when the turn produces more than ~5 file changes or more than ~10 lines of new content. Generalizes the 8-element drift block from `lsa-reconcile` (user-endorsed gold standard, 2026-05-22). Adds operational checkpoint #4 in `core/CLAUDE.md`. Per `.lsa/features/2026-05-22-show-changes-inline/`. Standard flow.

### Added
- **`core/skills/output/SKILL.md` Rule 7 "Show changes inline — write, show, comment"** — new top-level rule appended after Rule 6. Body carries: 7-element single-change template (what / where / previous / new / reason / source / type tag), batch compressed-inspection-table template, the "what this rule forbids" list, three worked examples (single-file edit / multi-file batch / state mark), and an inheritance-and-gaps clause naming Rules 2/3/4/5. Cites `lsa-reconcile` 8-element drift block as the in-repo exemplar by markdown link.
- **`core/CLAUDE.md` operational checkpoint #4 — Show changes inline.** Sibling to checkpoints #1 (Substrate-native pickers) / #2 (1–1.5 screen budget) / #3 (File-load trace). Cites Rule 7 by markdown link.

### Changed
- **`core/skills/output/SKILL.md` frontmatter `description:`** — "six golden rules" → "seven golden rules"; rule list extended with *"show-changes-inline"*.
- **`core/skills/output/SKILL.md` H1 lead-in + canonical-source clause** — *"Six golden rules"* → *"Seven golden rules"*; *"these six rules"* → *"these seven rules"*.
- **`core/CLAUDE.md` § Output discipline** — rule-count line updated from *"six format golden rules"* → *"seven format golden rules"*; rule list extended; checkpoint header *"Three operational checkpoints"* → *"Four operational checkpoints"*.
- **`core/README.md` `output` row** — rule-count updated 6 → 7; rule list extended; appended a one-sentence summary of Rule 7 with citation to `lsa-reconcile` exemplar.
- **`core/.claude-plugin/plugin.json` `description`** — rule-count updated 6 → 7; rule list extended with *"show-changes-inline"*.
- **`CLAUDE.md` (repo root) § Always-on rules** — rule-count line updated 6 → 7; rule list extended.

### Notes
- **Minor bump rationale.** New rule with marketplace-wide reach — every plugin that writes/edits/marks anything inherits the obligation by virtue of citing `core/output`. User-visible discipline change driven by 2026-05-22 user feedback (*"they say 'I put something in a file...' and make the user to go and search"*); not a refactor.
- **Sibling LSA bump.** `lsa` v0.8.1 in the same feature sweeps the 16 `Observable result:` lines across 7 LSA skill bodies (`lsa-sync`, `lsa-specify`, `lsa-init`, `lsa-plan`, `lsa-revise-constitution`, `lsa-verify`, `lsa-discover`) to cite Rule 7 and name the quote-back format (full single-change block vs. compressed inspection table). Optional Epic 4 adds a one-line forward-link from `lsa-reconcile` to Rule 7.
- **Rule-numbering coordination resolved.** Rule 6 = *What-and-why preamble* (row #4, shipped v0.7.0); Rule 7 = *Show changes inline* (this feature, row #5). Spec drafts mention "Rule 6" because they were written before row #4 locked the slot; implementation renumbers per the explicit coordination note in `.lsa/features/2026-05-22-lsa-what-why-preamble/` archived tasks.md.
- **Spec source.** `.lsa/features/2026-05-22-show-changes-inline/design.md` §"The new core/output Rule 6 — drafted in full" carries the verbatim Rule body used here; `requirements.md` AC1–AC7 + F1–F8.
- **Helper Constraint deferred.** Epic 3 (Helper `## Constraints` bullet citing Rule 7) ships in a separate follow-up PR after PR #19's helper changes merge, to avoid conflicts.

## [0.7.0] — 2026-05-24

Adds **Rule 6 — What-and-why preamble** to `core/output`. Every emission of a verdict label from `core/knowledge/output-vocabulary.md` §"Verdicts" must be preceded in the same paragraph by a one-sentence preamble naming (a) the action in plain English in the user's frame, and (b) the concrete consequence if the human does not act. Canonical format: `<context sentence>. <VERDICT> verdict + <details>.` A bare verdict line fails the rule. Per `.lsa/features/2026-05-22-lsa-what-why-preamble/`. Standard flow.

### Added
- **`core/skills/output/SKILL.md` Rule 6 "What-and-why preamble — verdicts carry a one-sentence frame"** — new top-level rule appended after Rule 5. Cites `core/knowledge/output-vocabulary.md` §"Verdicts" by link. Body kept short (≤6 wrapped lines per NF1). Not a sub-bullet under Rule 5 — Rule 5 governs picker-prompt voice (decision prompts), Rule 6 governs action-framing (verdict emissions). Different categories. See `.lsa/features/2026-05-22-lsa-what-why-preamble/design.md` §"Where the rule lives".

### Changed
- **`core/skills/output/SKILL.md` frontmatter `description:`** — "five golden rules" → "six golden rules"; rule list extended with *"what-and-why preamble"*.
- **`core/skills/output/SKILL.md` H1 lead-in** — *"Five golden rules"* → *"Six golden rules"*.
- **`core/CLAUDE.md` § Output discipline** — rule-count line updated from *"five format golden rules"* → *"six format golden rules"*; rule list extended.
- **`core/README.md` `output` row** — rule-count updated 5 → 6; rule list extended; appended a one-sentence summary of Rule 6 with citation to `core/knowledge/output-vocabulary.md`.
- **`core/.claude-plugin/plugin.json` `description`** — rule-count updated 5 → 6; rule list extended.
- **`CLAUDE.md` (repo root) § Always-on rules** — rule-count line updated 5 → 6; rule list extended.

### Notes
- **Minor bump rationale.** New rule with marketplace-wide reach — every plugin that emits verdict labels inherits the obligation by virtue of citing `core/output`. User-visible discipline change; not a refactor.
- **Sibling LSA bump.** `lsa` v0.8.0 in the same feature sweeps the 5 LSA skill bodies that currently emit verdict labels (`lsa-init`, `lsa-reconcile`, `lsa-sync`, `lsa-revise-constitution`, `lsa-verify`) to render preamble-first verdicts citing Rule 6 by link.
- **Spec source.** `.lsa/features/2026-05-22-lsa-what-why-preamble/requirements.md` F5 fixes the rule's location at `core/output`; `design.md` §"Where the rule lives" resolves OQ1 to *new Rule 6, not a sub-bullet under Rule 5*.
- **Roadmap coordination.** Rule 6 = *What-and-why preamble* (this feature, row #4). Rule 7 = *Show changes inline (write-show-comment)* will be claimed by roadmap row #5 when it lands.

## [0.6.0] — 2026-05-24

Rule 5 expansion — **Genuine-fork test** as a new operational sub-rule under "Must-decide only". Replaces the prior one-line "Must-decide only" bullet at `core/skills/output/SKILL.md:39` with a checklist that makes "meaningfully change the outcome" testable: a picker is justified only when at least one of four conditions holds (destructive write / two named designs in scope / fact absent from context / per-row triage). Orthogonal to `.lsa/VISION.md:66` Principle 9 — Principle 9 governs *which* substrate (`AskUserQuestion` vs `[a]/[b]/[c]`); the Genuine-fork test governs *whether to ask at all*. Per `.lsa/features/2026-05-22-askuserquestion-audit/`. Standard flow.

### Changed
- **`core/skills/output/SKILL.md` Rule 5 "Must-decide only"** — bullet replaced (in place, not appended) with the expanded "Must-decide only — Genuine-fork test" version. Names the four real-fork categories with operational criteria; closes with "deliver the cited answer directly and offer at most ONE closing picker for the user to override". Cites `.lsa/VISION.md:63` Principle 6 (in-scope source ranking) and `.lsa/VISION.md:66` Principle 9 (substrate selection). Body ≤6 wrapped markdown lines per NF2 in the feature requirements.
- **`core/CLAUDE.md` operational checkpoint #1 ("Substrate-native pickers")** — one clarifying line appended: *"This checkpoint is downstream of the Rule 5 'Genuine-fork test' in `core/skills/output/SKILL.md` — if a picker is justified, then use `AskUserQuestion`. Don't render a picker that wasn't justified in the first place."* Makes the orthogonality explicit at the checkpoint surface so reviewers don't conflate fork-existence with primitive choice.

### Notes
- **Minor bump rationale.** New operational sub-rule with user-visible enforcement — Helper and LSA call-site sweeps in sibling PRs cite this rule. No existing behavior breaks; every prior caller that already passed the old "must-decide" filter passes the new checklist (which is strictly more permissive at the upstream gate but more demanding inside it).
- **Sibling LSA patch.** `lsa` v0.7.1 in the same feature sweeps the 2 LSA call sites the rule reclassifies (L2 `lsa-discover` per-line tighten, L12 `lsa-sync` closing-offer) plus the L9 `lsa-verify` verdict-picker prompt voice. Helper call-site sweep (Epic C) ships in a separate later PR — blocks on `helper` v0.3.0.
- **Spec source.** `.lsa/features/2026-05-22-askuserquestion-audit/design.md` §"Proposed `core/output` Rule 5 expansion of 'Must-decide only'" carries the exact bullet text used here; `tasks.md` Epic A enumerates A1–A4.

## [0.5.5] — 2026-05-22

Declare `core/output` as the marketplace-wide canonical source-of-truth for output discipline. Adds a canonical-source clause + a regression probe (`core/tests/repo-anchored.md` D2) that catches future drift. Sweeps known Core-internal drift; LSA sweep ships in sibling `lsa` v0.6.5. Per user request 2026-05-22 (*"Core/output is the source of truth. All goes to it adheres it or extend but never breaks"*). Standard flow.

### Added
- **`core/skills/output/SKILL.md` Canonical-source clause** — blockquote above the H1 declaring this file the marketplace-wide source-of-truth; other plugins MAY cite + MAY add component-specific formats; MUST NOT restate the rule count or rule names outside this file (citation by markdown link only); MUST NOT override or relax any rule. Re-grounded summaries are permitted when they cite this file by link at the top (per `helper/knowledge/output-discipline.md:5` precedent).
- **`core/tests/repo-anchored.md` D2 — Output discipline canonical invariant** — regression probe with a grep recipe that fails on `(N golden rules)` count-restatements outside Core and on the 4-name list `structured, minimal, formatted, sourced` not followed by `, concrete` and not within 5 lines of a `core/skills/output/SKILL.md` link. Recipe excludes `archive/`, `plans/`, `CHANGELOG.md`.

### Fixed
- **`core/skills/flow-selector/SKILL.md:68`** — Stale 4-name list (was missing *concrete*) → citation-only.

### Changed
- **`.lsa/modules/core/spec.md`** — Skill list reflects four skills (was three; `core/output` was missing); fixed stale version pin v0.5.2 → v0.5.5; added **Output discipline canonical** Invariant bullet citing D2.
- **`.lsa/VISION.md:267`** — v0.5 changelog entry rewritten to be drift-resistant (count + rule names → version-anchored note pointing at canonical).

### Notes
- **Rationale.** Discipline alone produced 11 drift sites (8 LSA-skill footers missing *concrete*; `lsa/ARCHITECTURE.md:30` saying "(4 golden rules)"; `core/skills/flow-selector/SKILL.md:68` missing *concrete*; `.lsa/VISION.md:267` historical changelog 4-name list). The canonical declaration + D2 probe convert a verbal convention into a checkable invariant.
- **Minor bump rationale.** Adds a new marketplace-wide contract (canonical-source declaration). No existing behavior breaks: every prior caller satisfies the new contract once the citation footers are updated (sibling `lsa` v0.6.5).
- **Adherent example preserved.** `helper/knowledge/output-discipline.md` is untouched — it already cites canonical at line 5 and adds plugin-specific extensions, which is precisely the legitimate pattern the new probe D2 condition (c) permits.
- **Sibling LSA patch.** `lsa` v0.6.5 sweeps the 9 known LSA drift sites in the same PR.

## [0.5.4] — 2026-05-22

File-load trace patch. Replaces the v0.5.3 single-line `[plugin:skill]` marker — which did not give the human enough signal about which marketplace files actually shaped a turn — with a per-file trace directive hardcoded at the top of every marketplace instructional file. On load, the agent prints `=============== [<file>] [<plugin>] ===============` verbatim, one line per loaded file, in load order, before the response body. Per user request 2026-05-22 ("markers do not work … print the file name and current plugin using it"). Quick flow.

### Changed
- **`core/skills/output/SKILL.md` Rule 4 (Sourced).** *Output marker* sub-section replaced by *File-load trace*. The agent no longer prepends one `[plugin:skill]` label per response; instead, each loaded marketplace file prints its own one-line trace.
- **`core/CLAUDE.md` § Output discipline** — third operational checkpoint *Output marker (`[plugin:skill]`)* replaced by *File-load trace*. Same Rule 4 citation.
- **`core/README.md`** — `output` row description updated to reference v0.5.4 trace directive instead of the v0.5.3 marker.

### Added
- **Trace directive at the top of every marketplace instructional file** — all 4 `core/skills/*/SKILL.md`, `core/knowledge/output-vocabulary.md`. Sibling plugins (`lsa`, `helper`) and `vision/**` files apply the same directive — those bumps land in their own CHANGELOGs.

### Notes
- **Patch bump rationale.** Rule 4 still exists with the same intent (provenance for the human). Only the output form changes — one line per loaded file instead of one label per response. No new rule, no count change (stays 5 golden rules). The v0.5.3 marker did not survive a full session in practice; the trace lines do because each file enforces its own.
- **Directive placement.** For files with YAML frontmatter (`---` block), the directive lands right after the closing `---`. For files without frontmatter, it lands at the very top, before the H1.

## [0.5.3] — 2026-05-22

Output-marker patch. Adds a source-attribution marker (`[plugin:skill]`) to every substantive agent response so the human can see at-a-glance which marketplace skill is shaping the current turn vs. background model output. Per `.lsa/roadmap.md` row *"Output marker — source-attribution prefix"* (user request 2026-05-22). Quick flow.

### Added
- `core/skills/output/SKILL.md` Rule 4 (Sourced) — new sub-section **Output marker**. Form: `[plugin:skill]`, never bare `[skill]` (e.g., `[core:output]`, `[lsa:lsa-specify]`). Placement: first line of the response, treated as a label. Pick: the most-specific *currently-active* skill — defaults to `[core:output]` when no explicit skill is invoked. Skip only for trivial one-line replies (Rule 2 wins).
- `core/CLAUDE.md` § Output discipline — third operational checkpoint **Output marker (`[plugin:skill]`)** under the existing pointer to `core/output`. Header bumped from *Two operational checkpoints* → *Three*. Cites Rule 4.

### Notes
- **No count bump.** Stays 5 golden rules — the marker rides inside Rule 4 (Sourced) as a sub-section because both concerns are forms of provenance (factual claims cite their factual source; agent responses disclose their skill source). Re-evaluate promotion to a separate Rule 6 if marker scope grows beyond a single `[plugin:skill]` label per turn.
- **Format decision.** `[plugin:skill]` always, never bare `[skill]` — selected by user via `AskUserQuestion` 2026-05-22. The alternative (`[skill]` for core, `[plugin:skill]` for plugins) was rejected for uniformity / lint-ability.

## [0.5.2] — 2026-05-22

Naming clarity patch — renames the `core/tier-selector` skill to `core/flow-selector` and replaces the `T1` / `T2` / `T3` tier labels with `Quick` / `Standard` / `Extended` across `core/CLAUDE.md`, `core/README.md`, `core/VERIFICATION.md`, the skill body, and the plugin description. Per `.lsa/roadmap.md` row *"Rename `T1` / `T2` / `T3` → `Flow: Quick` / `Flow: Standard` / `Flow: Extended`"*. Bundle B (Naming clarity) of the 2026-05-22 fixing session.

### Changed
- **Skill rename: `core/skills/tier-selector/` → `core/skills/flow-selector/`.** Directory + frontmatter `name:` + slash-command slug (`/core:tier-selector` → `/core:flow-selector`). The skill body adopts the new vocabulary (Quick / Standard / Extended) and notes the rename at the top so existing-user lookups still resolve.
- **`core/CLAUDE.md` § Tier selection → § Flow selection.** Section heading + body language switch from `T1 / T2 / T3` → `Quick / Standard / Extended`. Each tier bullet annotates the prior name (e.g., *"Quick (was `T1`)"*) so historical references in plans, CHANGELOGs, and archive files remain interpretable.
- **`core/README.md`.** `tier-selector` row + invocation example + CLAUDE-merge note updated.
- **`core/VERIFICATION.md` Probe C** — heading + label switch; `T3` → `Extended` in the expected behavior.
- **`core/.claude-plugin/plugin.json` `description`** — `tier-selector (T1/T2/T3 chain-of-thought)` → `flow-selector (Quick/Standard/Extended chain-of-thought — renamed from tier-selector in v0.5.2)`.

### Notes
- **Breaking surface change, treated as patch.** Strictly per [SemVer §4](https://semver.org/#spec-item-4), renaming a slug is breaking. Pre-1.0 SemVer lets the maintainer's discretion shape the bump; for this personal marketplace with no external consumers, a patch is defensible. Future external consumers should pin to v0.5.1 if they rely on `/core:tier-selector` literally.
- **Historical entries left untouched.** `core/CHANGELOG.md` [0.4.1] / [0.3.0] / [0.2.0] still reference `tier-selector` and `T1 / T2 / T3` — they describe past state and the rename note in the new entries (and `core/CLAUDE.md` body) makes them traceable.
- **Sibling lsa patch** — `lsa` v0.6.2 in the same Bundle B PR sweeps the `T1/T2/T3` and `tier-selector` references throughout `lsa/` and also renames the lsa-specify "Gate N" → "User Verification N".

## [0.5.1] — 2026-05-22

Output-discipline enforcement patch. Elevates the two `core/output` rules that the user observed as routinely skipped in practice (substrate-native pickers and the response screen-budget) to always-on operational checkpoints in `core/CLAUDE.md`, and tightens `core/output` Rule 2 (Minimal) with concrete budget shape. Per `.lsa/roadmap.md` row *"core/output discipline enforcement (AskUserQuestion + output length)"*.

### Added
- `core/CLAUDE.md` § Output discipline — two new always-on operational checkpoints under the existing pointer to `core/output`: (1) **Substrate-native pickers** — every decision-bearing prompt uses `AskUserQuestion` in Claude Code; never render `[a]/[b]/[c]` text blocks when the picker is available; (2) **1–1.5 screen budget per turn** — default ~30–50 rendered markdown lines, split decisions into separate turns, pull don't push.
- `core/skills/output/SKILL.md` Rule 2 (Minimal) — three concrete sub-bullets: 1–1.5 screen budget (verdict + single next decision above the fold), split into turns (separate decision from supporting detail), pull-don't-push (no pre-emptive option/artifact/consideration dump).

### Changed
- `core/skills/output/SKILL.md` Rule 5 heading — now reads *"Concrete (decision prompts) — prompt voice"* for memorability. The sub-bullets (subject-first, no project jargon, must-decide only, one decision per question) are unchanged.

### Notes
- **No new rules.** Both checkpoints derive from existing material — Substrate-native first is `.lsa/VISION.md` §2 principle 9 (already cited in `core/ground-rules` Rule 0); the screen budget is implicit in Rule 2's *"every line earns its place"*. This patch lifts both from "implicit" to "always-on" because the user observed them routinely skipped.
- **Sibling LSA patch.** `lsa` v0.6.1 ships in the same Bundle A PR — applies the prompt-voice scaffolding inside `lsa-specify` / `lsa-plan` / `lsa-init` gate prompts so the user-facing pickers stop using `Gate N` / `F<n>` / `epic decomposition` jargon.
- Sibling rename PRs (Gate N → User Verification; T1/T2/T3 → Flow) land in Bundle B.

## [0.5.0] — 2026-05-21

Adds **Rule 5 (Concrete)** to `core/output` — decision-prompt voice discipline. Surfaced during Help-agent-persona refinement (2026-05-21) when the user flagged LSA gates as unusable: *"I have no IDEA what it means…wording is too…i don't know, it just means nothing to me…I want concrete questions to make decisions with clear problem to solve. I do not give a fuck about minor things."* Per `.lsa/roadmap.md` row *"LSA gate prompts must be concrete"* (Must priority).

### Added
- `core/skills/output/SKILL.md` **Rule 5 — Concrete (decision prompts)** with four sub-bullets: subject-first (resolve `F3`/`AC2`/`OQ5` to the real-world subject in prompts; IDs stay in files), no project jargon (`contract-trigger`, `Hard Confirm`, `diagonal coverage` stay in skill bodies, not prompts), must-decide only (bundle consistency checks; surface only outcome-changing choices), one decision per question.

### Changed
- `core/.claude-plugin/plugin.json` `description` — `output (4 format golden rules — structured, minimal, formatted, sourced)` → `output (5 format golden rules — structured, minimal, formatted, sourced, concrete)`.
- Live citations of "four golden rules" updated to "five golden rules" across `core/CLAUDE.md`, `core/skills/ground-rules/SKILL.md`, `core/tests/repo-anchored.md`, repo `README.md`, `.lsa/VISION.md`, `lsa/README.md`, `lsa/ARCHITECTURE.md`. Historical references (older CHANGELOG entries, archived plans) left as-is — they describe past state.

### Notes
- **Behavior change, not a refactor.** Existing `AskUserQuestion` calls across `lsa/skills/*/SKILL.md` do not yet conform to Rule 5 (they reference `F1` / `Hard Confirm` / etc.). The new rule will surface their non-conformance immediately. Follow-up sweep tracked in `.lsa/roadmap.md` row *"LSA gate prompts must be concrete"*.
- Sibling LSA work is queued, not blocking: the "Gate N → User Verification" rename (`.lsa/roadmap.md`) and "T1/T2/T3 → Flow: Quick/Standard/Extended" rename land together with the prompt-voice sweep.

## [0.4.1] — 2026-05-21

Credo rollout PR 2 — `core/tier-selector` adopts its component-specific output format that satisfies `core/output` golden rules. Patch bump: skill contract unchanged (still proposes tier + waits for human confirm); only the render format updates. Per [`.lsa/plans/2026-05-20-credo-rollout-plan.md`](../.lsa/plans/2026-05-20-credo-rollout-plan.md) Layer 2.

### Changed
- `core/skills/tier-selector/SKILL.md` Step 4 — confirm prompt describes data + decision options + outcomes inline; defers format to `core/output` (no embedded template). `AskUserQuestion` is the canonical decision primitive in Claude Code.
- `core/skills/tier-selector/SKILL.md` Constraints — adds one citation line: *"Outputs follow `core/output` golden rules."*
- `core/skills/tier-selector/SKILL.md` footer — updated to mention both `core/ground-rules` (content) and `core/output` (format) as the two always-on disciplines.

### Notes
- No behavior change. The boundary signals + tier-classification logic + wait-for-confirm gate are unchanged.
- Sibling LSA-skill refit ships as `lsa` v0.4.0 (PR 2) and Vision v0.6.

## [0.4.0] — 2026-05-21

Codifies the user-authored credo *"LSA doesn't automate your thinking — it makes you own it."* with a DRY/KISS/SRP-clean structure. Extends `ground-rules` 4 → 6 content rules; extracts output discipline to a new dedicated skill; lifts the verdict vocabulary to a new Knowledge surface. Per [`.lsa/plans/2026-05-20-credo-rollout-plan.md`](../.lsa/plans/2026-05-20-credo-rollout-plan.md) PR 1 (audit-C restructure). Corresponds to Vision v0.5 (`.lsa/VISION.md` changelog).

### Added
- **NEW skill `core/skills/output/SKILL.md`** — single source of truth for output discipline. Four golden rules: (1) Structured, (2) Minimal, (3) Formatted, (4) Sourced (cites `core/ground-rules` Rule 1). Every other skill / agent / artifact cites this; nothing restates it. Body ≤30 lines.
- **NEW Knowledge surface `core/knowledge/output-vocabulary.md`** — 10-row verdict label table (`PROPOSED` / `READY` / `PASS` / `PASS WITH WARNINGS` / `FAIL` / `BLOCKED` / `DRIFT` / `CLEAN` / `APPLIED` / `REJECTED`) lifted out of any Actor body (SRP). Components whose chosen format uses a verdict line cite this surface by section name.
- `core/skills/ground-rules/SKILL.md` Rule 0 — *Ownership over automation* (the human owns the thinking; surfaces facts, lays out options, demands a choice). Per `.lsa/VISION.md:60`.
- `core/skills/ground-rules/SKILL.md` Rule 5 — *No filler* (every sentence carries a fact, an owned opinion, or an action).
- `core/skills/ground-rules/SKILL.md` Rule 1 amendments — *Scope* (every artifact, no draft exception) + *Illustrative content* (placeholder references tagged `[illustrative]`).
- `core/skills/ground-rules/SKILL.md` footer — back-reference to `core/output` (makes the cross-link bidirectional alongside output's existing cite to ground-rules Rule 1).
- `core/VERIFICATION.md` — **Probe D (output)** — single composed probe testing all four golden rules together (NOT per-rule).
- `core/tests/repo-anchored.md` — A5 (Rule 0 Ownership) + A6 (Rule 5 No filler) + new Set D = D1 (output composed test against `core/.claude-plugin/plugin.json`).
- `.lsa.yaml` `modules.core.artifact_paths` — added `core/knowledge/**/*.md` to track the new Knowledge surface (matches the lsa-side pattern).

### Changed
- `core/skills/ground-rules/SKILL.md` frontmatter `description:` — *"four rules"* → *"six content rules"* (enumerated).
- `core/CLAUDE.md` — collapsed from a per-rule restatement to ~3 pointer lines (one per always-on skill: ground-rules + output + tier-selector). No rule enumeration. Audit-C C5 — eliminates the DRY violation introduced by an earlier draft.
- `core/README.md` — `ground-rules` row: *"6 content rules — see `core/CLAUDE.md`."* Added new `output` row: *"4 format golden rules — see `core/CLAUDE.md`."* `/core:output` added to the invocation list.
- `core/tests/repo-anchored.md` A3 — expected count updated 4 → 6 with the six headings listed.
- `core/.claude-plugin/plugin.json` `description` — rewritten to enumerate the four skills (ground-rules + output + actor-template + tier-selector), not individual rules. Audit-C C7.
- `CLAUDE.md` (repo root) — appends pointers to `core/output` + the credo, alongside the existing ground-rules + tier-selector citation.

### Notes
- The *"What this skill never does"* section is deliberately NOT re-added to `ground-rules` — the 0.3.0 refactor removed it as a Knowledge-vs-Actor violation; re-adding would reverse that refactor.
- This is an audit-C restructure of an earlier PR-1 attempt (commits `3dc1828` + `53d7c58`) that violated `CONTRIBUTING.md` DRY/KISS/SRP by adding format rules (Rules 6/7) into `ground-rules` and restating the 8 rules in `core/CLAUDE.md`. Those commits were discarded by `git reset --hard 01126d1` on `feature/credo-core` before this rebuild. Full rationale: `.lsa/plans/2026-05-20-credo-rollout-plan.md` §"Audit-C resolutions" (C1–C7).
- The LSA-skill refit (per-component formats from the plan's Layer 1.5 applied to all LSA skills + `tier-selector` confirm; each skill's Constraints adds one citation to `core/output`) lands in `lsa` v0.4.0 (PR 2 of the credo rollout, `feature/credo-lsa`). PR 1 is the core constitutional change; PR 2 is the propagation across LSA skills.

## [0.3.0] — 2026-05-20

Knowledge-vs-Actor boundary tightening across all three core skills. Per [`.lsa/plans/2026-05-20-simplification-refactor-plan.md`](../.lsa/plans/2026-05-20-simplification-refactor-plan.md) PR 2.

### Changed
- `core/skills/tier-selector/SKILL.md` — Step 1 and Step 2 no longer inline the boundary-signal checklist or the four-row classification table. Both now cite `.lsa/VISION.md` §4 as the single source of truth. Resolves the self-flagged debt at the prior `lsa/ARCHITECTURE.md:459` ("revisit if a second skill restates them"). Body shrunk by ~16 lines.
- `core/skills/actor-template/SKILL.md` — removed the duplicate "Rules" section (which restated the three rules already embedded in the "Five required sections" descriptions) and the trailing "What this skill never does" block (which restated those rules negatively). The five-section spec + worked example + copy-paste template remain authoritative.
- `core/skills/ground-rules/SKILL.md` — removed the trailing "What this skill never does" block. The four numbered rules + their examples remain authoritative.
- `core/skills/tier-selector/SKILL.md` — frontmatter `description:` trimmed by one sentence (removed implementation-detail tail; trigger phrases preserved).

### Notes
- No skill behavior changes. The Goal / Input / Steps / Output / Constraints shape and the tier-selector chain-of-thought protocol are preserved; only restatements removed. `core/skills/ground-rules/SKILL.md` and `core/skills/actor-template/SKILL.md` frontmatter `description:` fields left as-is — already at ≤2 sentences with trigger phrases intact.
- Per `.lsa/VISION.md` §4 (*"ceremony scales to the weight of the task"*): citing the canonical table at VISION §4 means a future change to the tier classification rules is a single-edit operation, not a multi-file sweep.

## [0.2.1] — 2026-05-20

Docs-only patch — marks `core/CLAUDE.md` as the canonical source for the always-on rules block. Part of the repo-wide DRY / SRP prune in [`.lsa/plans/2026-05-20-simplification-refactor-plan.md`](../.lsa/plans/2026-05-20-simplification-refactor-plan.md) PR 1.

### Changed
- `core/CLAUDE.md` — added a header blockquote declaring the file as *"the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules."* No change to the Ground rules or Tier selection sections.

### Notes
- The repo's `/CLAUDE.md` was shrunk in the same change-set (~108 → 34 lines) and now points to `core/CLAUDE.md` instead of duplicating its content. That edit is tracked in the repo-level refactor plan, not in this plugin's CHANGELOG.

## [0.2.0] — 2026-05-20

### Added
- `core/skills/tier-selector/SKILL.md` — Actor skill that classifies a task into T1/T2/T3 by applying Vision §4 boundary signals, then waits for human confirmation. Per `.lsa/2026-05-20-lsa-v0.2.0-design.md` §4.1.
- `core/CLAUDE.md` — opt-in always-on fragment declaring both `ground-rules` and `tier-selector` as required pre-task invocations. Mirrors the always-on/on-demand split from `.lsa/VISION.md:106`.
- `core/tests/repo-anchored.md` — dogfood self-tests (4 `ground-rules` probes, 2 `actor-template` probes, 1 V3 behavior-comparison task) anchored in this repo as the source of truth. Complements `VERIFICATION.md` (generic, portable) with repo-specific probes whose expected answers can be checked against actual file content. (Previously listed under `[Unreleased]`; rolled into 0.2.0 release.)

### Changed
- `core/README.md` — adds `tier-selector` to "What's here" and adds a "Merge the CLAUDE.md fragment" install step.
- `core/VERIFICATION.md` — adds Probe C for `tier-selector` under V2.
- Plugin description in `core/.claude-plugin/plugin.json` extended to mention `tier-selector` (T1/T2/T3) chain-of-thought.

### Notes
- `core/registry` (the lazy-load map-not-territory skill) remains deferred to v0.3.0. `.lsa/VISION.md:177` notes Claude Code's per-component plugin discovery partially subsumes its role.

## [0.1.0] — 2026-05-20

First release. Two domain-neutral skills installable natively on Claude Code (via plugin marketplace) and Claude.ai (via Skills upload), with zero custom build steps.

### Added
- `ground-rules` skill — four discipline rules enforced together on every substantive task: (1) fact-grounding (every factual claim carries a source + searchable quote), (2) no fake-confidence hedging, (3) read the real source before answering, (4) deliver only what was asked. Each rule has a worked example; a "never does" tail closes the file.
- `actor-template` skill — the Goal / Input / Steps / Output / Constraints shape for any actor (Skill, slash command, or workflow). Demands every Step produce an observable result and forbids Knowledge bleed. Includes a PR-summary worked example and a copy-paste template.
- Plugin manifest (`core/.claude-plugin/plugin.json`) at v0.1.0.
- `README.md` with install paths for Claude Code and Claude.ai.
- `VERIFICATION.md` with V1 (install), V2 (description-match), V3 (behavior-change) probes plus the ~90% trigger-rate falsifiable threshold.

[0.1.0]: https://github.com/NVZver/claude-marketplace/releases/tag/core-v0.1.0
