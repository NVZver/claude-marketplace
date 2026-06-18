# Changelog

All notable changes to the `manager` plugin (formerly `management`) are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.15.1] – 2026-06-18

Closes the last open finding (**C7**) from the TripAnchor `manager:implement` dogfood. Observation log: [`.lsa/observations/2026-06-17-tripanchor-manager-implement.md:80`](../.lsa/observations/2026-06-17-tripanchor-manager-implement.md).

### Changed

- **C7 — worktree isolation is required, not optional.** `manager/knowledge/parallel-dispatch.md` §3 + `manager/skills/implement/SKILL.md` *Isolation* constraint: the contract now states that each epic agent is dispatched with `isolation: worktree` and that a **single shared working tree with convention-only file-ownership is non-conforming** (no OS-level isolation — a stray edit to a peer's "disjoint" file silently corrupts that peer). If a per-epic worktree cannot be created, the epic is **held back as an open item**, never silently dispatched single-tree. Resolves the spec-vs-behavior seam observed on TripAnchor (the live run used a single tree); direction chosen is *enforce worktrees* — it aligns behavior to the contract + memory `project_parallel_worktree_workflow` and preserves the pitch's safety differentiator. No user-facing surface changed (`manager/README.md` already documents "isolated git worktree").
- **`manager/.claude-plugin/plugin.json`** — version 0.15.0 → 0.15.1.

## [0.15.0] – 2026-06-17

Seam-level fixes from the **first live `manager:implement` run on an external project** (TripAnchor-1). The core engine worked (gate-proven done, disjoint-code parallelism, high throughput); these close the integration-seam defects the run surfaced. Observation log: [`.lsa/observations/2026-06-17-tripanchor-manager-implement.md`](../.lsa/observations/2026-06-17-tripanchor-manager-implement.md). Feature: [`.lsa/features/2026-06-17-parallel-engine-findings/`](../.lsa/features/2026-06-17-parallel-engine-findings/epic.md).

### Changed

- **C4 — shared-ledger lock.** `manager/knowledge/serialized-merge.md` + `parallel-dispatch.md`: generalized the roadmap-status write-lock into a **shared-ledger lock** covering `CHANGELOG.md`, `plugin.json` version, and roadmap content + status. Per-epic agents now *propose* their ledger entries (a CHANGELOG line, a version-bump intent, a roadmap delta) in their payload; only the serialized-merge step writes the shared ledgers — eliminating the cross-fork `git merge` conflict observed on TripAnchor.
- **C2 — stable epic identity.** `manager/knowledge/epic-decomposition.md` + `manager/skills/decompose/SKILL.md` + `manager/agents/project-manager.md`: epic key is now a stable slug (`<feature-slug>/<short-kebab-scope>`) assigned once at decompose and immutable through commit message, branch name, and PR title — replacing the drift-prone global ordinal `<N>` (resolves the contradiction with epic-decomposition anti-pattern 2 and the observed three-range ID drift E14–18→E19–23→E31–35 + duplicate "E27").
- **C1/C5 — discoverability + autonomy doc.** `manager/skills/implement/SKILL.md` description gains explicit parallel/fleet trigger phrasing; `manager:implement` surfaced in `manager:next` + `manager/README.md` as the parallel build-execution entry point; `autonomy-policy.md` documents the intended default and per-level scope of unattended multi-PR churn (manual = human checkpoint at every merge).
- **C6 — gate-signal hygiene.** `manager/knowledge/fleet-rollup.md`: the roll-up distinguishes **blocking** (required-correctness) from **non-blocking** (infra/deploy) check status — a deploy-permission ✗ (e.g. Vercel access) reports on a Non-blocking line, never as a failed gate.
- **`manager/.claude-plugin/plugin.json`** — version 0.14.0 → 0.15.0.

## [0.14.0] – 2026-06-17

Epic 4 of parallel-agent-delivery (`.lsa/features/2026-06-17-parallel-agent-delivery-epic-4/`) — the final epic. Adds the **fleet-scope roll-up** + **`auto` autonomy** (deploy + healthcheck), completing the autonomy ladder. Builds on Epics 1–3.

### Added

- **`manager/knowledge/fleet-rollup.md`** (new) — the end-of-run report contract: per-epic table (epic · agent · wave · gate verdict · state · proof), files-changed section reusing the `core/output` Rule 7 inspection table grouped by Conventional-Commits `type(scope)`, proven-facts line, open-items line. **No new table format** — the "one report contract" is `core/output` Rule 7 (pitch rabbit-hole 7). Documents the relationship to the standalone `lsa-stage-reports` backlog feature: both reuse Rule 7, so they are consistent by construction; the fleet roll-up consumes per-epic `conformance.md` + gate artifacts and does not block on it.

### Changed

- **`manager/knowledge/autonomy-policy.md`** — `auto` rung un-deferred: deploy + healthcheck (report `deployed` only after the healthcheck passes, `core/ground-rules` Rule 7), still gated by the same green gate, with a defined rollback on healthcheck failure (pitch rabbit-hole 6); no deploy/healthcheck tool hardcoded; `main` still human-owned; default stays `manual`.
- **`manager/skills/implement/SKILL.md`** — Step 5 adds the `auto` deploy+healthcheck+rollback branch; Step 6 now emits the fleet roll-up (was a flat status list); Input + intro + Constraints describe the full ladder; auto→semi clamp removed. Frontmatter description updated.
- **`manager/README.md`** — `manager:implement` row describes the full autonomy ladder + the fleet roll-up.
- **`manager/.claude-plugin/plugin.json`** — version 0.13.0 → 0.14.0.

## [0.13.0] – 2026-06-17

Epic 3 of parallel-agent-delivery (`.lsa/features/2026-06-17-parallel-agent-delivery-epic-3/`). Implements **`semi` autonomy** — auto-merge on green — as the second rung of the autonomy ladder. Builds on Epic 2 (the engine) + Epic 1 (the gate). Requires `lsa` 0.19.0 (the `.lsa.yaml` `autonomy:` schema).

### Added

- **`manager/knowledge/autonomy-policy.md`** (new) — the `manual | semi | auto` ladder (default `manual`), each bound to an SDLC outcome: `manual` = human merges; `semi` = auto-merge on green into the integration branch (no per-merge prompt; human still owns the merge to `main` + deploy); `auto` = + deploy + healthcheck (Epic 4, clamps to `semi`). The gate is identical at every level — autonomy removes only the post-green prompt, never the gate. Escalation gated on the prior level proving safe (pitch `:26`).

### Changed

- **`manager/skills/implement/SKILL.md`** — Input + Steps 1 & 5 + Constraints now resolve and honor the autonomy level: `semi` auto-merges each gate-green PR via the serialized-merge step without a per-merge prompt; `auto` clamps to `semi`; `manual` unchanged. The gate must be green at every level.
- **`manager/knowledge/serialized-merge.md` + `parallel-dispatch.md`** — the "Autonomy boundary" sections rewritten from "manual only" to the full ladder (cite `autonomy-policy.md`); no level auto-merges into `main`.
- **`manager/.claude-plugin/plugin.json`** — version 0.12.0 → 0.13.0.

## [0.12.0] – 2026-06-17

Epic 2 of parallel-agent-delivery (`.lsa/features/2026-06-17-parallel-agent-delivery-epic-2/` R1–R10). Promotes `manager:implement` from a **read-only preview stub to the parallel execution engine**: disjoint-epic decomposer → wave plan → propose → isolated-worktree dispatch → independent gate → serialized merge, at `manual` autonomy. Builds on Epic 1 (`core` 0.14.0 Rule 7, `lsa` 0.18.0 grader/gate, `manager` 0.11.0 serialized-merge/lock).

### Added

- **`manager/knowledge/parallel-dispatch.md`** (new) — the net-new dispatch layer: the **disjoint-epic decomposer** (file/module overlap · output dependency · shared new data structure; conservative default = overlapping), **wave planning** (parallel within a wave, sequential across; a later wave starts only after the prior wave merged), the **dispatch policy** (one worktree+branch+agent+PR per epic, concurrency cap ~4, mandatory teardown), the `manual`-autonomy boundary, and the honesty contract (`merged @ <sha>` only when gate-proven).

### Changed

- **`manager/skills/implement/SKILL.md`** — rewritten from preview stub to execution engine (Goal/Input/Steps/Output/Constraints): resolve targets + autonomy (clamp to `manual`) → compute wave plan → **propose (human gate before any dispatch)** → dispatch each wave in isolated worktrees, each gated by the independent `lsa:reconcile` + `gate:` checks → serialized merge (manual: stop at merge boundary for the human) → gate-proven per-epic report. `--sequential` / `--parallel` overrides. No-arg form preserved as the read-only preview. Frontmatter description updated.
- **`manager/README.md`** — `manager:implement` row rewritten from preview-stub to execution-engine description.
- **`manager/.claude-plugin/plugin.json`** — version 0.11.0 → 0.12.0.

## [0.11.0] – 2026-06-17

Epic 1 / S3 of parallel-agent-delivery (`.lsa/features/2026-06-17-parallel-agent-delivery-epic-1/` R10–R12) — closes Epic 1. Defines the **serialized-merge + roadmap-write-lock contract** that the (Epic 2) `manager:implement` engine will follow: how N per-epic PRs converge without turning the integration branch red, and that only the serialized-merge step writes roadmap status. Builds on `core` 0.14.0 Rule 7 + `lsa` 0.18.0 (independent grader + gate contract).

### Added

- **`manager/knowledge/serialized-merge.md`** (new) — serialized-merge contract (merge only the tested SHA against the up-to-date base; GitHub merge queue `merge_group` when available, else local rebase-onto-main + re-gate before each merge; one PR at a time) + the **roadmap-write lock** (only the serialized-merge step writes `${specs_root}/roadmap.md` status; per-epic agents propose "done", the merge step commits it after the SHA is known — defends the concurrent-write race, pitch rabbit-hole 8). Scoped to `manual` autonomy this epic; human owns the final merge to `main` (pitch no-go #2).

### Changed

- **`manager/knowledge/roadmap-orchestration.md`** — new Constraint: during a parallel run, status writes serialize through the merge step (cites `serialized-merge.md`); single-feature roadmap edits stay agent-owned.
- **`manager/skills/implement/SKILL.md` Step 4** — the deferral notice now cites the `serialized-merge.md` contract the engine will follow, while keeping the dispatch engine itself deferred to Epic 2.
- **`manager/README.md`** — `manager:implement` row cites the serialized-merge contract.
- **`manager/.claude-plugin/plugin.json`** — version 0.10.0 → 0.11.0.

## [0.10.0] – 2026-06-16

Adds `manager:implement` as a **read-only preview stub** — Epic 3 of the `function-command-naming-and-manager-rename` pitch. Names the command surface ahead of the `parallel-agent-delivery` execution engine; the engine itself is explicitly out of scope.

### Added

- **`manager/skills/implement/SKILL.md`** (`manager:implement [epics] [--parallel|--sequential]`) — read-only preview stub. Reads `${specs_root}/roadmap.md` per the fast-path discipline (`core/knowledge/fast-path-source-of-truth.md`), quotes the last X (~5) `backlog`/`not started` rows with `file:line` citations, and gives an explicitly-INDICATIVE parallel-vs-sequential note. Prominently states that the execution engine (dependency-wave planning, isolated git-worktree dispatch, per-PR gating, serialized merge, autonomy levels) is **not yet implemented** and is owned by the `parallel-agent-delivery` feature (`.lsa/pitches/parallel-agent-delivery.md`). Writes nothing and dispatches no implementer; with args it still only previews and never implies execution ran (embodies "done is a gate-proven predicate"). Name follows `manager/knowledge/command-naming.md`.

### Why

Third epic of the `management` → `manager` rename arc. Names the `manager:implement` command surface now — with an honest read-only preview — so the surface reads truthfully ahead of the deferred parallel-agent-delivery engine, which is explicitly out of scope here (no worktree/merge/autonomy/dependency-graph logic). Prevents a future false "it runs" claim by shipping the stub with the deferral stated up front.

## [0.9.0] – 2026-06-16

Splits the 3-in-1 `manager:roadmap` skill into three function-named verb skills — Epic 4 of the `function-command-naming-and-manager-rename` pitch. `manager:roadmap` *was* one noun bundling three verbs; it is now `manager:next` / `manager:decompose <pitch>` / `manager:check`, each dispatching the same `project-manager` agent with a distinct intent. Realizes the `command-naming.md` convention the anti-pattern flagged. Clean break, **no alias** — `manager:roadmap` no longer exists. Pre-1.0, so a breaking change ships as a minor bump per SemVer §4.

### Added

- **`manager/skills/next/SKILL.md`** (`manager:next`) — recommend what to work on next. Keeps the Step 0 fast-path (plain "what's next" → first `backlog`/`not started` row quoted with `file:line`, no dispatch, per `core/knowledge/fast-path-source-of-truth.md`); dispatches the `project-manager` (`intent: recommend-next` / `sequence-backlog`) for "recommend an order" / "what should I pick" and runs the pick gate. No `lsa:discover` handoff.
- **`manager/skills/decompose/SKILL.md`** (`manager:decompose <pitch>`) — decompose a pitch (slug/path argument) into epics. Dispatches the `project-manager` (`intent: decompose <pitch>`), runs the approve/reject/adjust epic gate, and on approval invokes the staged `lsa:discover` handoff with the first-epic seed.
- **`manager/skills/check/SKILL.md`** (`manager:check`) — check roadmap hygiene. Dispatches the `project-manager` (`intent: hygiene-check`) and gates each proposed row diff one by one; re-renders the rows the agent applies.
- **`manager/knowledge/roadmap-orchestration.md`** — the shared dispatch → gate → re-render contract extracted (DRY) from the former roadmap skill's Step 2 + Constraints. The three verb skills cite it instead of restating the orchestration loop.

### Removed

- **`manager/skills/roadmap/SKILL.md`** — the 3-in-1 skill. Clean break, no alias.

### Changed

- **`manager/skills/shape/SKILL.md`** — handoff `manager:roadmap` → `manager:decompose` (description, Step 4, Output, constraints) since decomposition is now its own verb.
- **`manager/agents/project-manager.md`** — `manager:roadmap` references retargeted: description (dispatching skills list), Mode 0 wrapper note (`manager:next`), Step 12 + example (`manager:decompose`), constraints (three-verb list). Behavior unchanged — the agent is shared; each skill passes an explicit intent.
- **`manager/knowledge/command-naming.md`** — the worked anti-pattern rephrased as resolved: `manager:roadmap` *was* the noun bundling three verbs; the split is now the live state. Citation kept valid.
- **Cross-references swept to the matching verb** — `manager/README.md` (skill/agent tables, flow diagram, fast-path section), `.lsa/modules/manager/spec.md` (invariants), `.claude-plugin/marketplace.json` (description), `knowledge/index.md` (fast-path caller), `helper/knowledge/onboarding-fast-path.md` (row 7 → `manager:decompose`, "what's next" owner → `manager:next`), `core/knowledge/fast-path-source-of-truth.md` (caller table → `manager:next`), `core/README.md` (fast-path caller list).

### Why

Fourth and final epic of the `management` → `manager` rename. Epic 1 (0.7.0) defined the command-naming convention; this epic realizes it on the roadmap surface — one verb per action, arguments explicit, nothing hidden behind a noun. The three verbs share one agent + one orchestration contract (`roadmap-orchestration.md`), so the split adds clarity without duplicating logic.

## [0.8.0] – 2026-06-16

Renames the plugin `management` → `manager` and the shaping command `management:start-feature` → `manager:shape` — Epic 2 of the `function-command-naming-and-manager-rename` pitch. The plugin is now named for the **actor** (`manager`) rather than the activity; it still *does* product and project management. Clean break, **no aliases** — the old `management:` command namespace and `management/` plugin path no longer exist. Pre-1.0, so a breaking change ships as a minor bump per SemVer §4.

### Changed

- **Plugin renamed `management` → `manager`** — directory `management/` → `manager/`, manifest `name`, command namespace `management:` → `manager:`, `.lsa.yaml` module key, module-spec path `.lsa/modules/management/` → `.lsa/modules/manager/`, and all trace-header plugin tags `[management]` → `[manager]`.
- **`management:start-feature` → `manager:shape`** — skill directory `skills/start-feature/` → `skills/shape/`; behavior unchanged (orchestrator that dispatches `product-manager`, runs the gates, hands off to `manager:roadmap`).
- **`management:roadmap` → `manager:roadmap`** — namespace-only rename; the `roadmap` verb is retained for now (the 3-in-1 split into `next` / `decompose` / `check` is a later epic).
- **Cross-references swept** — marketplace manifest, root + per-plugin READMEs, module specs, knowledge files, and in-flight backlog pitches updated to the new identity tokens; English domain prose ("management discipline") preserved.

### Why

Second of the rename epics (Epic 1 shipped the command-naming convention in 0.7.0). Names the plugin for the actor and aligns the entry command with the `<actor>:<verb>` convention from `manager/knowledge/command-naming.md`. Clean break chosen over aliases because the marketplace is pre-1.0 and single-owner — no external installs to migrate.

## [0.7.0] – 2026-06-16

Adds the function-like command-naming convention as a citable knowledge file — Epic 1 of the `management` → `manager` rename (pitch `function-command-naming-and-manager-rename`). Establishes the convention before the rename so the new command surface is named once.

### Added

- **`management/knowledge/command-naming.md`** — the convention `<actor>:<action>-<modifier> args` (commands are verbs you call with arguments, not nouns you browse; zero metaphor). Worked anti-pattern: `management:roadmap` (one noun bundling three verbs — `management/skills/roadmap/SKILL.md:3`) vs the verb split `manager:next` / `manager:decompose <pitch>` / `manager:check`. Plus a "How to apply" for authoring future commands.

### Changed

- **`management/README.md`** — inline reference to the new convention from the project-manager entry.
- **`.lsa/modules/management/spec.md`** — knowledge list updated + new "Command naming is canonical" invariant.

### Why

First of 4 epics renaming `management` → `manager` (Epics 2-4: atomic dir/namespace rename, the `roadmap` 3-in-1 verb split, and the `manager:implement` preview stub). Defining the convention first prevents naming the renamed surface twice. Decided 2026-06-14 during the parallel-agent-delivery Epic-0 design.

## [0.6.0] – 2026-06-12

Adopts the `core` 0.13.0 **gate-delivery contract** (Rule 5 *Self-contained gates*, Rule 7 *Authorization boundary* + *Delivery test*). Completes the 0.5.0 inversion: 0.5.0 moved the *gates* to the skills but left the *pitch write* before the gate and the *show-obligation* inside the invisible subagent payload — producing the live failure (2026-06-12) where the user faced "Approve?" for a pitch they never saw, written to disk before they answered.

### Changed

- **`management/agents/product-manager.md`** — `tools:` drops `Write`; Step 4 composes the pitch and returns its **full content in the payload** instead of writing `${specs_root}/pitches/<slug>.md` as a draft; Step 5/Output return content + proposed slug + pending gates. The agent writes no files.
- **`management/skills/start-feature/SKILL.md` Step 3** — now *delivers* the pitch first (turn-final message or gate `preview` — the agent's payload is invisible per the Rule 7 *Delivery test*), then gates. **Approve** → this skill `Write`s the pitch with `Status: approved` + gate decisions and quotes it inline (show → approve → write). **Reject** → *no file is written* (was: file existed "regardless of outcome" with `Status: rejected`). Output + constraints updated accordingly.
- **`management/skills/roadmap/SKILL.md` Step 2 + constraints** — gates must be self-contained (subject in question text / option descriptions / `preview`) or preceded by turn-final delivery; this skill re-renders the agent's applied-row quotes (the payload is invisible).
- **`management/agents/project-manager.md` Steps 7/10** — payload quotes are marked as dispatcher-re-render material; Step 10 returns the full epic list for delivery.
- **`management/knowledge/pitch-structure.md`** — status lifecycle documented: `draft` exists only in the agent payload (never on disk); on-disk pitches are always `Status: approved`; `rejected` removed from the metadata enum.

### Removed

- **Rejected-pitch files.** A rejected pitch no longer leaves `${specs_root}/pitches/<slug>.md` on disk — rationale stays in the conversation. (User decision, 2026-06-12: "save to file ONLY after approve".)

### Why

Sibling of `core` 0.13.0 (contract definition), `lsa` 0.17.0, `helper` 0.5.0, `prompt-engineer` 0.7.0. The triggering failure and full audit live in `core/CHANGELOG.md` 0.13.0 §Why.

## [0.5.0] – 2026-06-12

Gate contract inverted: agents propose, skills gate. `AskUserQuestion` and the `Skill` tool are unavailable in subagent context — in live runs (2026-06-09 and 2026-06-12) both agents returned *"AskUserQuestion isn't available in this subagent context"* and produced un-gated outputs while the docs promised agent-side gating.

### Changed

- **`management/agents/product-manager.md`** — `tools:` drops `AskUserQuestion`; Step 1 records the adopted role + rationale as a pending gate instead of asking; Step 4 writes the pitch as `Status: draft` and never flips it; Step 5 returns pitch path + an ordered pending-gates list (role confirmation, shaping forks with recommended defaults, final approve/reshape/reject). New constraint: *Gates belong to the dispatcher.*
- **`management/agents/project-manager.md`** — `tools:` drops `AskUserQuestion` and `Skill`; Steps 5/7/10 return decision payloads (options + recommended default) instead of asking; Step 7 applies hygiene rows only after the dispatcher returns approvals (continuation), quoting each written row inline; Steps 11-12 stage the `lsa:discover` handoff as ready-to-use seed text instead of invoking the `Skill` tool. Same new constraint.
- **`management/skills/start-feature/SKILL.md`** — new Step 3 *"Run the returned gates"*: presents the agent's pending gates via `AskUserQuestion`, flips pitch `Status:` to `approved`/`rejected` and records the gate decisions in the pitch header via `Edit`, re-dispatches on reshape. "No silent handoff" constraint rewritten: the gates live in the skill; the agent proposes.
- **`management/skills/roadmap/SKILL.md`** — Steps 1-3 reworked: receive the agent's payload, run each decision via `AskUserQuestion`, send decisions back via `SendMessage` continuation for the agent-owned roadmap writes, and invoke `lsa:discover` via the `Skill` tool with the agent's staged seed. "No silent handoff" constraint rewritten to match. Step 0 fast-path untouched.
- **`management/knowledge/epic-decomposition.md`** — scope note (audit finding): the rules govern epics within one pitch; cross-feature sequencing between pitches is `sequencing-heuristics.md` Factor 1 (dependency order).
- **`management/knowledge/role-adaptation.md`** — the too-vague-to-select-a-domain "ask the user" clause glossed: when dispatched as a subagent, the ask travels as a pending gate run by the dispatching skill.
- **`management/README.md`** — handoff prose and agent/skill tables now state that the orchestrator skills run the human gates (the agents prepare them).
- **`management/.claude-plugin/plugin.json`** — version 0.4.3 → 0.5.0; description aligned with the agents-propose/skills-gate contract.
- **`.lsa/modules/management/spec.md`** — stale `v0.3.0` pins → `v0.5.0`; "Human gate before every handoff" invariant updated to the agents-propose/skills-gate contract.

### Why

When dispatched via the `Agent` tool by their orchestrator skills, the agents cannot use `AskUserQuestion` or invoke skills, so the documented agent-side gates could never run; the main-loop assistant had to improvise them. The human gates stay — they move to the orchestrator skills, which run in the main loop and have both tools. MINOR bump: documented decision-flow contract change.

## [0.4.3] – 2026-06-08

Marketplace-audit cleanup — removed-skill drift + Role sections + de-count.

### Fixed

- **`management/agents/project-manager.md`** — handoff invoked the removed `lsa:new`; now `lsa:discover` only.
- **`management/README.md`** — replaced the "vs `lsa:next`" section (removed skill) with `management:roadmap`'s own fast-path-vs-full-flow description.

### Changed

- **`management/agents/{product-manager,project-manager}.md`** — added explicit `## Role` sections (consistency across agents).
- **`management/.claude-plugin/plugin.json`** — description de-counts agents.

## [0.4.2] – 2026-06-08

Wording, citation, and LSA-loop reference cleanup surfaced by the cross-plugin prompt review.

### Fixed

- **`management/README.md`**, **`management/knowledge/epic-decomposition.md`** — the LSA build-cycle reference named the removed `lsa:plan` / `lsa:implement` skills; now `lsa:discover → lsa:specify → lsa:verify → lsa:delegate → lsa:reconcile`.

### Changed

- **`management/agents/product-manager.md`**, **`management/knowledge/sequencing-heuristics.md`**, **`management/knowledge/role-adaptation.md`** — removed filler adverbs ("progressively", "naturally", "fresh").
- **`management/knowledge/role-adaptation.md`** — `.lsa/VISION.md:127` citation → `§4` (drift-proof).

## [0.4.1] – 2026-06-02

Show-changes-inline cites on roadmap/pitch writes.

### Changed

- **`management/agents/project-manager.md`** — Step 7 and a new Constraints bullet require each written roadmap row to be quoted inline before the verdict, per `core/output` Rule 7; never "roadmap updated" without the row.
- **`management/skills/roadmap/SKILL.md`**, **`start-feature/SKILL.md`** — new Constraints bullets: the dispatched agent's quoted-inline roadmap/pitch writes are surfaced verbatim by the orchestrator, never reduced to "roadmap updated" / "pitch created".

## [0.4.0] – 2026-06-02

Fast-path "what's next" for `management:roadmap` and the `project-manager` agent — answer in seconds without the full agent dispatch.

### Added

- **`management/skills/roadmap/SKILL.md`** — new Step 0 branch before the unconditional agent dispatch: a plain "what's next" returns the first `backlog`/`not started` roadmap row quoted with a `file:line` citation and exits, no agent spawned. The full `project-manager` dispatch (dependency/risk/value sequencing, decomposition, hygiene) is reserved for "recommend an order" / "what should I pick" / "sequence the backlog" questions.
- **`management/agents/project-manager.md`** — new Mode 0 early-exit so direct agent invocation (bypassing the skill) also short-circuits a plain "what's next" to the cited roadmap row.

Both cite `core/knowledge/fast-path-source-of-truth.md`. README skill-table + "`management:roadmap` vs `lsa:next`" section updated.

## [0.3.0] – 2026-05-28

Paths parametrized on `${specs_root}`. Management now interoperates with LSA's configurable spec tree instead of hardcoding `vision/specs/`.

### Changed

- **`management/agents/product-manager.md`**, **`management/agents/project-manager.md`** — Input sections declare `specs_root` (read from `.lsa.yaml`, defaults per `lsa/knowledge/conventions.md`). Steps, Output, and Constraints reference `${specs_root}/pitches/<slug>.md`, `${specs_root}/roadmap.md`, and `${specs_root}/features/*/` instead of hardcoded `vision/specs/...`.
- **`management/skills/start-feature/SKILL.md`** — Same parametrization. Description updated to use `${specs_root}/pitches/<slug>.md`. Note: v0.2.1 had already refactored the hand-off to `management:roadmap`; v0.3.0 retains that structure and only parametrizes path strings.
- **`management/knowledge/sequencing-heuristics.md`**, **`management/knowledge/pitch-structure.md`** — `vision/specs/roadmap.md` and `vision/specs/pitches/<slug>.md` → `${specs_root}/roadmap.md` and `${specs_root}/pitches/<slug>.md`. Worked-example tables use repo-root-relative `pitches/<slug>.md` links.
- **`management/knowledge/epic-decomposition.md`** — epic-format template uses `../../pitches/<slug>.md` (relative to a feature file at `${specs_root}/features/<slug>/`) instead of `../../vision/specs/pitches/<slug>.md`. The previous template included a redundant `vision/specs/` segment that produced an incorrect path when resolved.
- **`management/.claude-plugin/plugin.json`** — version 0.2.2 → 0.3.0.

### Why

Before this change, management hardcoded `vision/specs/...` in six files. Any project whose `.lsa.yaml` set `specs_root` to something else — e.g., the new LSA default of `.lsa/` — would have management writing pitches and roadmap entries to a directory LSA didn't read from. Parametrization aligns management with the `specs_root` contract.

## [0.2.2] – 2026-05-27

Prompt audit remediation — knowledge deduplication and boundary fix.

### Changed

- **`agents/project-manager.md`** — Steps 4 and 9 now reference `knowledge/sequencing-heuristics.md` and `knowledge/epic-decomposition.md` by path instead of restating their rules inline. Removed duplicate "Inherits core/ground-rules and core/output" from frontmatter description (kept in Constraints). Removed "No unexplained jargon" constraint (covered by core/output).
- **`skills/start-feature/SKILL.md`** — replaced inline roadmap-write logic (Step 3a-e) with clean handoff to `management:roadmap`, making project-manager the single owner of roadmap writes.
- **`skills/roadmap/SKILL.md`** — removed no-op Step 1 ("Accept invocation"); renumbered remaining steps.

## [0.2.1] – 2026-05-27

### Fixed

- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). Step 4 now hands off to `management:roadmap` (project-manager → epic decomposition) instead of `lsa:new`. Completes the intended flow: product-manager → pitch + roadmap → project-manager → epics → LSA.
- **README** ([`./README.md`](./README.md)). Skill table and flow diagram updated to reflect the corrected handoff.
- **Product-manager agent** ([`./agents/product-manager.md`](./agents/product-manager.md)). Completion signal and constraint references updated from `lsa:new` to `management:roadmap`.

## [0.2.0] – 2026-05-26

Project-manager agent and roadmap skill. Bridges the gap between shaping (product-manager → pitch) and building (LSA cycle) with structured roadmap stewardship.

### Added

- **Project-manager agent** ([`./agents/project-manager.md`](./agents/project-manager.md)). Roadmap steward with three modes: (1) Recommend next — applies sequencing heuristics (dependency order, technical risk, value delivery) from linked pitches to recommend what to build next; (2) Tidy — flags stale items, missing pitches, and status inconsistencies; (3) Decompose — breaks a chosen pitch into independently-shippable epics per `management/knowledge/epic-decomposition.md`. Hands first epic to LSA. Read-only on everything except roadmap (writes require explicit user approval). Inherits `core/ground-rules` and `core/output`.
- **Roadmap skill** ([`./skills/roadmap/SKILL.md`](./skills/roadmap/SKILL.md)). Single entry point for project management. Dispatches the project-manager agent; agent handles recommendation, hygiene, decomposition, and LSA handoff internally.
- **Knowledge file: epic decomposition** ([`./knowledge/epic-decomposition.md`](./knowledge/epic-decomposition.md)). Rules for breaking pitches into epics: 5 quality criteria (independently shippable, one-sentence scope, one LSA cycle, clear definition of done, parent pitch link), 3 boundary-finding signals, 4 anti-patterns.
- **Knowledge file: sequencing heuristics** ([`./knowledge/sequencing-heuristics.md`](./knowledge/sequencing-heuristics.md)). Three-factor sequencing model grounded in this repo's data sources. Documents the roadmap table format for agent parsing.

### Changed

- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). Added Step 3: after pitch approval, optionally adds a roadmap backlog entry (title, user-confirmed priority, status `backlog`, pitch link) to `.lsa/roadmap.md`. Skippable at user's discretion.
- **Plugin manifest** ([`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)). Version 0.1.0 → 0.2.0. Description updated to cover both agents and both skills.

## [0.1.0] – 2026-05-26

Initial release. Plugin scaffold, knowledge files, product-manager agent, and start-feature skill.

### Added

- **Plugin manifest** ([`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)) at v0.1.0. Declares `dependencies: ["core"]`.
- **Knowledge file: pitch structure** ([`./knowledge/pitch-structure.md`](./knowledge/pitch-structure.md)). Defines the 5-section pitch format with metadata header, markdown template, and worked example. Inspiration: Basecamp Shape Up shaping phase [unverified].
- **Knowledge file: role adaptation** ([`./knowledge/role-adaptation.md`](./knowledge/role-adaptation.md)). Defines how the product-manager agent self-selects a `<domain> product manager` role per invocation via visible chain-of-thought reasoning, with override via `AskUserQuestion`.
- **Product-manager agent** ([`./agents/product-manager.md`](./agents/product-manager.md)). Interactive shaping agent: adapts domain-expert role per invocation, drives multi-turn conversation to extract requirements, produces structured pitches per pitch-structure knowledge, gates on human approval. Inherits `core/ground-rules` and `core/output`.
- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). User-facing entry point. Accepts a problem description, dispatches the product-manager agent, hands off to `lsa:new` on approval. Orchestrator only — no shaping logic, no branch-creation logic.
- **Module spec** ([`.lsa/modules/management/spec.md`](../.lsa/modules/management/spec.md)). Module-level invariants and artifact paths.
- **Registrations** (`.lsa.yaml`, `.lsa/main.spec.md`). Management module registered with artifact paths and cross-module contracts.
- **README** ([`./README.md`](./README.md)). Install instructions, dependency on `core`, skill and agent tables, flow diagram.
- **Pitches directory** ([`.lsa/pitches/`](../.lsa/pitches/)). Empty directory (`.gitkeep`) for pitch output files.
