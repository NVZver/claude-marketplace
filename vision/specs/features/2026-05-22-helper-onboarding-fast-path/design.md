> **Trace.** On load, print first: `=============== [vision/specs/features/2026-05-22-helper-onboarding-fast-path/design.md] [vision] ===============`

# Design: Helper fast-path for onboarding questions

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #2 (`vision/specs/roadmap.md:110-114`). Requirements: `./requirements.md`.

## Modules Affected

| Module | Change Type | Files |
|--------|-------------|-------|
| `helper` (Actor) | Modify | `helper/agents/helper.md` — insert new Step 1.5 between existing Step 1 (cooldown) and Step 2 (scope-order read); add one bullet to Constraints. |
| `helper` (Knowledge) | Add | `helper/knowledge/onboarding-fast-path.md` — new file. Trigger catalog + excerpt-mapping table + negative examples. |
| `helper` (CHANGELOG + plugin manifest) | Modify | `helper/CHANGELOG.md` (Keep a Changelog entry, v0.3.0); `helper/.claude-plugin/plugin.json` (SemVer bump). |
| `helper` (README) | Modify | `helper/README.md` — one-line addition under "Status" describing the fast-path. Per `CLAUDE.md` *"READMEs are living documents"* rule. |
| `vision` (roadmap) | Modify | `vision/specs/roadmap.md` — correct `helper/skills/helper/SKILL.md` reference in row #2 to `helper/agents/helper.md`; mark the row shipped on merge. |

**Not affected:** `core/`, `lsa/`, any other plugin. The `core/output` and `core/ground-rules` skills are *cited* by the new Knowledge file but not modified.

**Cross-row Helper v0.3.0 bundling.** Helper #1 (assistant refactor) and this row (onboarding fast-path) ship as a SINGLE v0.3.0 PR per user decision 2026-05-23. CHANGELOG entries fold together.

## Landing surface (exact paths + line ranges to edit)

| Path | Current state | Change |
|---|---|---|
| `helper/agents/helper.md:30-37` | Steps 1-5 (Recognise signal / Read sources / Compose / Skill handoff / Closing picker). Step 1 ends at the cooldown-or-proceed observable. | Insert new **Step 1.5 — Onboarding fast-path** between current line 32 and current line 33 (between Step 1 and Step 2). **Insertion-style: do NOT renumber Steps 2-5.** Existing Steps 2 / 3 / 4 / 5 keep their numbers and bodies; Step 1.5 is the only new label, minimising blast radius and downstream cite churn (e.g., `helper/agents/helper.md:34` *"skip to Step 5"* note stays valid). |
| `helper/agents/helper.md:46-58` (Constraints) | 9 bullets. | Add one bullet: *"**Fast-path-first for onboarding subjects.** Step 1.5 consults `helper/knowledge/onboarding-fast-path.md`; on catalog match, respond directly from the README excerpt without Step 2's scope-order read. Per `helper/knowledge/onboarding-fast-path.md` §`Fall-through rules`."* |
| `helper/knowledge/onboarding-fast-path.md` | Does not exist. | Create. Content shape in §"New Knowledge file content" below. |
| `helper/CHANGELOG.md` | Top entry is v0.2.1 (file-load trace). | Prepend v0.3.0 entry: *"Onboarding fast-path. Helper short-circuits to README excerpts for install / start / what-is-X / how-do-I-run patterns. Latency ≤5s wall-clock for catalog-matched questions vs. ~3min deep-research baseline (2026-05-22). Knowledge: `helper/knowledge/onboarding-fast-path.md` (new). Actor: `helper/agents/helper.md` Step 1.5 (new). Per `vision/specs/features/2026-05-22-helper-onboarding-fast-path/`."* |
| `helper/.claude-plugin/plugin.json` | `version: "0.2.1"`. | Bump to `"0.3.0"` (minor — new user-visible behavior). |
| `helper/README.md` | Status table lists steps 1-4. | Add one-line note under "Status — v0.2.0 feature-complete" header: *"v0.3.0 adds onboarding fast-path — README-cited answer in seconds for install / start / what-is questions; deep-research path unchanged for everything else."* |
| `vision/specs/roadmap.md:114` | *"Pattern classifier lives in `helper/skills/helper/SKILL.md`."* | Replace with *"Pattern classifier lives in `helper/knowledge/onboarding-fast-path.md`; Step 1.5 in `helper/agents/helper.md` invokes it."* |

## Technical Approach

### Three-stage flow inside Helper

```
User question arrives
  │
  ▼
Step 1: cooldown check (unchanged)
  │ proceed
  ▼
Step 1.5: onboarding fast-path classifier (NEW)
  │
  ├─ catalog match + excerpt mapped → respond from excerpt → Step 5 (closing picker)
  ├─ catalog match + no excerpt mapped → fall through to Step 2
  └─ no catalog match → fall through to Step 2
  │
  ▼
Step 2: scope-order read (unchanged)
  │
  ▼
Steps 3-5: compose / handoff / close (unchanged)
```

**Numbering convention.** Insertion-style: Step 1.5 is the only new label. Steps 2-5 keep their existing numbers, so all in-file cites like `helper/agents/helper.md:34` (*"skip to Step 5"*) and external cites stay valid. Per `requirements.md` constraint inversion + `design.md` Landing-surface row decision.

### Classifier algorithm (chosen approach)

**Hybrid: keyword catalog + LLM judgement.** Rationale:
- Pure regex (`/install|how do i (install|start|use)|what is (lsa|core|helper)/i`) is deterministic and testable but brittle on phrasing (*"how do I get going with LSA"* misses *"start"*).
- Pure LLM judgement scales with phrasing but is non-deterministic and hard to assert in `test-suites.md`.
- **Hybrid:** the catalog file is plain Markdown with two columns: `trigger phrase OR keyword set` and `README excerpt path:lines`. The LLM reads the catalog as part of Step 1.5 and matches the user's question against any row in plain English — same shape as how `helper/agents/helper.md` already matches subjects against `helper/knowledge/knowledge-scope.md`. The catalog seeds phrasing breadth; the LLM closes the gap on natural variants. Determinism is achieved at the *catalog content* level (curated rows), not at the matching algorithm level.

**Single bounded LLM pass.** No multi-turn classification, no chain-of-thought scaffolding. The agent reads catalog + reads the user's question + outputs one of: (a) catalog row N matched / (b) no match. This keeps NF1's ≤5s latency target reachable.

### New Knowledge file content (`helper/knowledge/onboarding-fast-path.md`) — structure

The file shall contain the following sections, in this order:

1. **Trace directive** (the standard `===============` header per `core/output` Rule 4 *file-load trace*).
2. **Purpose statement** (1-2 sentences): "When the user asks an onboarding-flavored question, Helper consults this catalog before Step 2's scope-order read. If a row matches, Helper responds directly from the cited README excerpt."
3. **Catalog table** (the data — see §"README excerpt mapping table" below).
4. **Matching rules** (3-5 bullets):
   - Match on intent, not literal keywords (e.g., *"how do I get going"* matches the *start* row).
   - First match wins; closing `AskUserQuestion` may offer subsequent matches as follow-ups (OQ4 resolution).
   - All four canonical plugin/marketplace subjects (`marketplace`, `core`, `lsa`, `helper`) are catalog subjects. Other plugin names (`dev-plugin`, `atlassian`, `supabase`) are NOT — they live in scope 2 of `knowledge-scope.md` and require deep-read.
5. **Negative examples** (4-6 bullets): questions that look onboarding-shaped but do not qualify — e.g., *"why was `flow-selector` renamed"* (history question, not onboarding), *"how do I configure `.lsa.yaml`"* (`lsa/ARCHITECTURE.md` §4.10, not a top-level README), *"what does `lsa-verify`'s orphan-AC do"* (mechanism question, lives in skill body).
6. **Fall-through rules**: explicit list of conditions that send the request to Step 2 — no match, match but excerpt missing, match but range stale (heading not found at line), match against negative-example pattern.

### README excerpt mapping table (the catalog content)

Initial six rows. Each line range was verified at spec time (2026-05-23) against the live README; the test-suites Journey 1 probe re-verifies on every test run.

| # | Trigger intent (plain English) | Example phrasings | Excerpt path:lines | What it answers |
|---|---|---|---|---|
| 1 | Install the marketplace | "how do I install", "install marketplace", "/plugin install commands", "set me up" | `README.md:73-83` | The four-line install block + the "install `core` first" caveat. |
| 2 | Get started with LSA | "how do I get started with LSA", "where do I start with LSA", "first steps LSA" | `README.md:73-83` (install) + `lsa/README.md:49-60` (Depends on / install order) | Install both plugins, then invoke `/lsa:init`. |
| 3 | What is the marketplace | "what is this marketplace", "what is `claude-marketplace`", "what is NVZver" | `README.md:1-12` + `vision/VISION.md:13-15` | One-sentence frame + the three-plugin list. |
| 4 | What is `core` | "what is core", "what does core do", "what is `core/ground-rules`" | `README.md:25-49` | Three always-on skills + four supporting bullets. Glosses each. |
| 5 | What is `lsa` | "what is LSA", "what does lsa do", "what is Living Spec Architecture" | `README.md:51-68` + `lsa/README.md:1-9` | Definition + 8-skill table + credo quote. |
| 6 | What is `helper` | "what is helper", "what does helper do", "what is `/help`" | `helper/README.md:1-10` | Two surfaces + invocation paths. |

Total catalog size: **6 rows** v1. Roadmap allows for expansion as new onboarding patterns emerge; spec NF2 names the floor.

### Step 1.5 — exact wording to insert in `helper/agents/helper.md`

```
1.5. **Onboarding fast-path** per [`../knowledge/onboarding-fast-path.md`](../knowledge/onboarding-fast-path.md). Read the catalog. If the user's question matches a trigger row AND the row maps to a concrete `file:line` excerpt, Read that excerpt directly, compose the response with the excerpt quoted inline + its citation, and proceed to Step 5 (closing picker). Otherwise, proceed to Step 2 (scope-order read) unchanged. Observable result: either Helper responds from a README excerpt within ≤5s OR Step 2 runs as today. No `Grep`, no `Glob`, no `context7` in this step — onboarding answers live in named READMEs only.
```

(Existing Steps 2 / 3 / 4 / 5 stay at their current numbers — insertion-style. Only Step 1.5 is new. No downstream renumber.)

## Data Model Changes

None. No state files written. No new fields in `plugin.json` beyond the version bump.

## API / Interface Changes

- **Helper agent's `tools` frontmatter** (`helper/agents/helper.md:4`) stays the same. No new tools required (fast-path uses `Read` which is already listed).
- **Helper agent's `description` frontmatter** (`helper/agents/helper.md:3`) stays the same. Trigger conditions for the agent itself don't change; the fast-path is internal to the agent's Steps.
- **`/help` command (`helper/commands/help.md`)** stays the same. The fast-path takes effect for both empty-arg (3-option starter picker) and arg-supplied invocations because both ultimately call `Skill(helper)` (`helper/commands/help.md:14`, `helper/commands/help.md:24`).

## Cross-Module Contracts

- **With `lsa-specify` (`helper/agents/helper.md:24-27`).** Signal (a) friction auto-engage path is *not affected* — its trigger is `[c] reject` at a User Verification, not a free-form question. Step 1.5 will classify the auto-engage Verification-explanation as non-onboarding (no catalog match for *"what is User Verification N checking"*) and fall through to today's behavior. Tested in `test-suites.md` Journey 5.
- **With `core/output`.** New Knowledge file inherits `core/output` Rule 4 (Sourced) via the file-load trace directive (the `===============` header line). New Step 1.5 inherits `core/output` Rule 5 (Concrete — closing `AskUserQuestion` subject-named, per `core/skills/output/SKILL.md` Rule 5). No changes to `core/`.
- **With `core/ground-rules`.** F7 (cannot-ground fallback) preserved unchanged. Step 1.5 never produces a fabricated answer; on excerpt-missing, falls through to Step 2 which is already governed by `core/ground-rules` Rule 2.
- **With roadmap row #1.** Boundary defined in `requirements.md` §"Interaction with roadmap row #1". F2's *"one closing `AskUserQuestion`"* may relax to *"zero or one"* under row #1; catalog content stays.

## Open Questions

- **OQ1.** **Should the catalog mark certain rows as "Helper's preferred starter answer" vs. "any reasonable phrasing"?** Concretely: row 2 (*"get started with LSA"*) is THE golden test from the roadmap row (`vision/specs/roadmap.md:113`). Should it carry a `priority: golden` tag so test-suites pins it as the canonical regression? **Tentative resolution: yes — single `priority` column added to the catalog table, values `golden | standard`; golden rows must each have a dedicated `test-suites.md` Journey.**
- **OQ2.** **Catalog drift surfacing.** The `lsa-reconcile` SessionStart hook (`lsa/hooks/hooks.json`) checks `artifact_paths` for drift. Should the fast-path catalog be added to a similar drift check so that when `README.md` changes line numbers, the catalog gets a heads-up? **Tentative resolution: out of scope here; raise as a follow-up if drift bites in practice. Catalog uses heading anchors as secondary hints to ease manual re-pin.**
- **OQ3.** **Empty-arg `/help` starter-topic dispatch.** `helper/commands/help.md:18-24` opens a 3-option picker (*Install / Pick a skill / Explain a concept*) and then dispatches to `Skill(helper)` with the picked topic. *Install* and *Explain a concept* should both flow through the fast-path; *Pick a skill* probably should not (it is a curation question, not an onboarding excerpt). **Tentative resolution: catalog adds two rows mapping starter-picker labels directly — *Install* → row 1; *Explain a concept* → opens an in-Helper sub-question (no fast-path); *Pick a skill* → falls through to Step 2.**
- **OQ4.** **First-match-wins vs. ranked-match.** When *"how do I install LSA and what does it do"* matches rows 1, 2, and 5, the catalog's first-row-wins rule (per §"Matching rules") fires row 1. Should the closing `AskUserQuestion` then offer rows 2 and 5 as follow-ups? **Tentative resolution: yes — closing picker offers up to 2 additional matched rows as labelled options; if no other matches, picker offers a generic "different question" option.**
- **OQ5.** **Should `vision/VISION.md` excerpts count as README-class for fast-path?** Row 3 currently cites both `README.md:1-12` and `vision/VISION.md:13-15`. `vision/VISION.md` is the constitution, not a README, but it has the canonical one-sentence definition. **Tentative resolution: include — the constraint in F4 is *"named in the catalog"*, not *"literally a README"*; the catalog is the authority.**
