# Changelog

All notable changes to the `lsa` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.28.0] — 2026-07-19

`verify`'s Step 1 reference resolution is now scripted (second instance of `.lsa/VISION.md` §2 principle 10, after `reconcile`'s coverage skeleton). Behavior change to `verify` Step 1 → minor bump. The resolver script + its test are repo-level (outside every `artifact_paths`) and drive no bump on their own — only the `verify/SKILL.md` edit does.

### Changed

- **`skills/verify/SKILL.md`** — Step 1 now instructs the model to identify the named modules / functions / types (its judgment) and pass them to `bash scripts/resolve-refs.sh`, citing the per-symbol resolution (`exists @ file:line` | `new` | `MISSING` | `OUT-OF-RANGE`) as the reference map instead of multi-round `Grep`; the GROUNDED / NOT-GROUNDED verdict stays the model's, per principle 10. No existing verify check weakened — Step 2 (feasibility), Step 3 (`[ASSUMPTION]` visibility), and Step 4 (the `gate:` block) are unchanged.
- **`README.md`** — the `verify` skill row names `scripts/resolve-refs.sh` as Step 1's per-symbol resolver.

### Notes

- **Repo-level, unshipped** — `scripts/resolve-refs.sh` and `scripts/tests/resolve-refs-test.sh` live outside every plugin's `artifact_paths` (like the other `scripts/` gate helpers) and ship in no plugin; they trigger no version bump or CHANGELOG entry of their own. Spec: `.lsa/features/2026-07-19-deterministic-work-scripted-resolve-refs/requirements.md` (R1–R10).
- **Input contract — arguments take precedence.** `resolve-refs.sh` reads stdin **only** when no arguments are given (conventional `grep`/`cat` precedence); with args present it never touches stdin. This is what makes it safe for its primary consumer: `lsa:verify` calls it from an agent harness, where stdin is an open pipe that never sends EOF, so a mixed args-plus-stdin read would block forever. A regression case in the test suite runs an arg-only invocation against a never-EOF FIFO and fails if it hangs.

## [0.27.0] — 2026-07-19

`reconcile`'s coverage-table enumeration is now scripted (first instance of `.lsa/VISION.md` §2 principle 10 applied to the N×-repeated reconcile surface). Behavior change to `reconcile` Step 4 → minor bump. The enumeration script + its test are repo-level (outside every `artifact_paths`) and drive no bump on their own — only the `reconcile/SKILL.md` edit does.

### Changed

- **`skills/reconcile/SKILL.md`** — Step 4 now begins by running `bash scripts/coverage-skeleton.sh <feature-dir>` to obtain the deterministic skeleton (every requirement ID as a table row, every changed file as a candidate hunk, spec files under `<feature-dir>` excluded); the grader fills only the semantic mapping column and reads off orphans / uncovered, citing principle 10 (enumeration is scripted; the does·only·all judgment stays the model's). No existing reconcile check weakened — the coverage-table shape, the `does`/`only`/`all` questions, and the independence rules are unchanged.
- **`README.md`** — the `reconcile` skill row names `scripts/coverage-skeleton.sh` as the enumeration source for Step 4's two axes.

### Notes

- **Repo-level, unshipped** — `scripts/coverage-skeleton.sh` and `scripts/tests/coverage-skeleton-test.sh` live outside every plugin's `artifact_paths` (like the other `scripts/` gate helpers) and ship in no plugin; they trigger no version bump or CHANGELOG entry of their own. Spec: `.lsa/features/2026-07-19-deterministic-work-scripted-coverage-skeleton/requirements.md` (R1–R10).

## [0.26.0] — 2026-07-16

YAML roadmap is the default for new projects; AI migration runbook added (closes the LSA product-docs / `init` gap deferred from epic `yaml-ledger-selective-load/read-cutover`). Behavior change to `init` → minor bump.

### Added

- **`knowledge/migration-instructions-ai.md`** — AI-actionable runbook: detect → migrate (`roadmap-migrate.sh`) → verify (schema + query scripts + lossless spot-check) → rewire consumers → cite-sweep → cleanup (delete `roadmap.md`) → final gates. Hard rules: single SoT, no happy-path whole-file Read, no silent cleanup on failed verify.

### Changed

- **`skills/init/SKILL.md`** — greenfield scaffolds **`roadmap.yaml`** (empty `version`/`items`/`shipped_history`) and **never** creates `roadmap.md`; if a markdown roadmap already exists, Step 3 points at the migration runbook instead of inventing a second SoT. Step 2 quotes the new ledger inline per `core/output` Rule 7 (prompt-review 3l).
- **`knowledge/migration-instructions-ai.md`** — header marks procedure-as-knowledge (AI runbook, not an Actor) so separation-of-concerns reviews do not false-HIGH the ordered Steps.
- **`ARCHITECTURE.md`, `README.md`, `CORE.md` §9, `tests/scenarios.md`** — live docs and the illustrative status-command fixture retargeted from `roadmap.md` to `roadmap.yaml`.

## [0.25.1] — 2026-07-16

Roadmap read-cutover cite-sweep (epic `yaml-ledger-selective-load/read-cutover`, `.lsa/features/2026-07-16-yaml-ledger-read-cutover/requirements.md` F12; parent pitch `.lsa/pitches/yaml-ledger-selective-load.md`). Citation-only — no routing behavior changed → patch bump.

### Changed

- **`knowledge/model-routing.md`** — the two inline-dispatch citations that pointed at the now-deleted `.lsa/roadmap.md:62` retargeted to name the `reduce-sub-agent-dispatch-fan-out-for-sonnet` item in `.lsa/roadmap.yaml`, keeping `scripts/check-citations.sh` green after the markdown ledger's removal.

### Notes

- **Measured context win lives in `manager` 0.18.0** — sequencing / get / hygiene drop from ~22,958 tok (whole-file `.lsa/roadmap.md`) to ~70–185 tok (script slices); see [`manager/CHANGELOG.md`](../manager/CHANGELOG.md) §`[0.18.0]` *Notes — measured context win*. This `lsa` patch is the cite-sweep that keeps model-routing green after the markdown ledger's removal.

## [0.25.0] — 2026-07-15

Pro-tier token affordability (parent pitch `.lsa/pitches/pro-tier-token-affordability.md`, WS1–WS4). One entry for the whole feature — net delta vs 0.24.4.

### Added

- **`scripts/project-map-build.sh` + `scripts/project-map-check.sh` + `scripts/tests/test-project-map.sh`** (WS2) — a deterministic, no-model builder for repo-root `project-map.yaml`: a **directories-only** navigational map (depth ≤ 3), held under a **1k-token budget** (`scripts/lint.sh` C13, ~534 tokens), with historical subtrees (`.lsa/archive`) excluded. `project-map-check.sh` rebuilds and fails on any git porcelain, so freshness is a gate, not a silent auto-commit.
- **`knowledge/model-routing.md`** (WS4) — the single source of truth for per-Agent-dispatch model routing: the `.lsa.yaml` `routing:` map schema, the resolution algorithm (floored surfaces → `inherit`; map lookup; absent/unavailable → `inherit`, never a hard error; pass as the `Agent` `model` parameter + echo the tier), and the per-dispatch tier table with a `Wired?` column. Wired down-routes today: `manager:next` (sonnet), `manager:check` (haiku), `lsa:delegate.verify-checkpoint` (sonnet).

### Changed

- **`knowledge/conventions.md`** (WS1) — the mandatory constitution read is now the script-generated digest `.lsa/VISION-digest.md` (staleness-gated by `scripts/lint.sh` C12); full `${constitution}` loads only for constitutional tasks. §"Read protocol" and the AskUserQuestion substrate cite retargeted to `.lsa/VISION.md` canon.
- **`knowledge/conventions.md`, `skills/discover/SKILL.md`, `skills/init/SKILL.md`, `agents/orchestrator.md`** (WS2) — discovery consults `project-map.yaml` to locate the directory a request touches before walking the tree; `init` builds the map for new projects; the orchestrator names the map in its inline discover step so the agent that runs discovery actually reaches it. Absent map ⇒ graceful tree-walk fallback (backward-compatible).
- **`skills/delegate/SKILL.md`** (WS4) — Step 5 resolves surface-key `lsa:delegate.verify-checkpoint` per the routing contract; Step 3 marks the external implementer a **floored** surface. **`skills/reconcile/SKILL.md`** — the independent grader is floored (`lsa:reconcile` never routes below `inherit`).
- **`skills/verify/SKILL.md`, `skills/reconcile/SKILL.md`** (WS3) — where the repo provides an aggregate gate runner (`bash scripts/gate.sh`), run the `.lsa.yaml gate:` block in one pass and cite its consolidated output; absent a runner, run each configured command as before (backward-compatible).
- **`ARCHITECTURE.md`, `README.md`** — document the shipped scripts, root `project-map.yaml` (directory map), and the gate layer.

## [0.24.4] — 2026-07-02

Public-readiness documentation pass (docs only, no skill behavior change).

### Fixed

- **`ARCHITECTURE.md`** — the header's hardcoded `**Version:** 0.20.1 (plugin)` had drifted from `plugin.json` (0.24.3), and the adjacent `**Status:** 0.4.0` read as a second, conflicting version. Both numbers removed; the header now points at `.claude-plugin/plugin.json` and `CHANGELOG.md` so it cannot drift again.

## [0.24.3] — 2026-07-02

Fixes from the repo-wide prompt review (run with `prompt-engineer` 0.8.0 discipline; 5 MEDIUM findings in this plugin — stale anchors + duplication, no behavior change).

### Fixed

- **`skills/delegate/SKILL.md`** — both independence cites repointed `../reconcile/SKILL.md:44-45` → `:58` (the old anchor landed on the coverage-table markdown example, not the *Independence must be observable* constraint); the four-field checkpoint-signal table is no longer restated — the field names remain, their meanings are cited from the single owner, `observer/skills/verify-checkpoint/SKILL.md` §"The checkpoint-signal contract" (KISS/DRY 2).
- **`skills/reconcile/SKILL.md`** — the independence rationale + verbatim TripAnchor-1 observation quote now live only in `knowledge/quality-gate-contract.md` §"Independence rule"; the two constraints keep the behavioral boundaries and cite it (was circular duplication). The N-runs pass threshold is stated once (Step 1); the constraint references it instead of re-deriving the 3/3 arithmetic.
- **`agents/orchestrator.md`** — the Steps preamble no longer restates the Pro-tier/inline-execution rationale; it points to the *Run spec-authoring inline* constraint that owns it (Context Budget 2).
- **`knowledge/quality-gate-contract.md`** — back-pointer tightened to "Enforced by `reconcile` §Constraints" now that this file is the single owner of the independence rationale.

## [0.24.2] — 2026-07-02

Cross-plugin link fix following the manager 0.16.0 rename of `manager/knowledge/fleet-rollup.md` → `parallel-rollup.md` (`sonnet-robustness-consistency-sweep` pitch, workstream 3). No behavior change.

### Fixed

- **`lsa/knowledge/quality-gate-contract.md`** — the roll-up cross-reference now points at [`manager/knowledge/parallel-rollup.md`](../manager/knowledge/parallel-rollup.md) ("the `manager` parallel-implementation roll-up"); the old `fleet-rollup.md` target no longer exists.
- **`lsa/.claude-plugin/plugin.json`** — version 0.24.1 → 0.24.2.

## [0.24.1] — 2026-07-02

Manifest + model-name alignment — the `lsa-manifest-and-pro-tier` epic of the `sonnet-robustness-consistency-sweep` pitch (`.lsa/pitches/sonnet-robustness-consistency-sweep.md`, Decision 2a + Problem "Manifest drift" / "A model name in instructional bodies"). Prose-only; no behavior change.

### Changed

- **`plugin.json` description matches the inline orchestrator.** The manifest still advertised the pre-0.21 dispatch-per-stage framing ("reads each sub-agent's Inputs, resolves them via discover, delegates, collects output"); it now states the orchestrator runs discover → specify → verify inline in one context and crosses a context boundary only at delegate (the external implementer) and reconcile (an independent grader) — consistent with the refreshed `marketplace.json` entry and `lsa/agents/orchestrator.md:3`. The skill list is tightened in the same pass to keep the description ≤1,024 characters (1,020) — no skill added or removed.
- **Bare "Sonnet" generalized to "the Pro-tier model" (Decision 2a).** The token-efficiency rationale in `lsa/CORE.md` §2, `lsa/agents/orchestrator.md` (Steps preamble + Constraints), and `lsa/README.md` (orchestrator paragraph) now says "the Pro-tier model (see `.lsa/standards/code.md` §"Model policy")" instead of naming a specific model — the policy the sentence cites is the one meant to keep model names out of instructional bodies. Sentence meaning unchanged. CHANGELOG history entries keep their original wording.

## [0.24.0] — 2026-07-02

Reconcile deterministic backstop — the `reconcile-deterministic-backstop` epic of the `eval-coverage-tracks-complexity` pitch (`.lsa/pitches/eval-coverage-tracks-complexity.md`, Decisions Forks 4+5): the merge gate stops riding on model judgment for run count, coverage, and gate execution.

### Added

- **N is defined: 3 runs by default.** `lsa/skills/reconcile/SKILL.md` (Step 1, Inputs, Constraints) and `lsa/CORE.md` §6 now state N = 3 wherever "run each Gherkin scenario N times" appeared, with the integer arithmetic spelled out — at N = 3, "≥95% of runs" means **all 3 runs pass** (a 2/3 scenario fails); at a larger N, pass = ≥95% of runs.
- **`.lsa.yaml` escape hatch `reconcile.runs`** — raises N for high-stakes epics; **default 3 when the key (or the file) is absent**. Documented in the reconcile Inputs table, this repo's `.lsa.yaml` (key + comment), and the README schema block.
- **Requirement ↔ hunk coverage table is the `conformance.md` contract.** Step 4 + Output now require one row per requirement ID (F1…Fn from `requirements.md`) × implementing diff hunks/files × proving scenario runs × verdict, plus an orphan-hunk list — the *only* check reads the table in reverse (every hunk appears in a requirement row; an orphan hunk is drift) and the *all* check reads it forward (a row with no hunk and no covering test fails). The judge cites the table; prose-only verdicts are out. Output carries a synthetic table example.

### Changed

- **The `gate:` step is unconditional.** Step 1's "Where `.lsa.yaml` defines a `gate:` block…" became: the `gate:` block is **required input**; when a repo defines none, reconcile reports an explicit `gate: NOT-RUNNABLE — no gate: block in .lsa.yaml` status in `conformance.md` and alongside the verdict, instead of silently skipping. No new machinery — only the skip is now impossible to hide.
- **`lsa/README.md`** — the `reconcile` skill row, the "two checks" section, and the OpenSpec comparison now state N = 3 (default) and the coverage-table contract; the `.lsa.yaml` schema block gains `reconcile.runs`.
- **`.lsa/standards/testing.md`** — gains the "Evals run on Sonnet" clause (cites `.lsa/standards/code.md` §Model policy) and states the N = 3 default in the adversarial-dogfooding section.

## [0.23.0] — 2026-07-02

Wires checkpoint-mode paired verification into `lsa:delegate` — the writer half of the `paired-verify` pitch (the reader half, `observer:verify-checkpoint`, shipped in observer 0.2.0). Feature: [`.lsa/features/2026-07-02-paired-verify-lsa-delegate-wiring/requirements.md`](../.lsa/features/2026-07-02-paired-verify-lsa-delegate-wiring/requirements.md).

### Added

- **`lsa/skills/delegate/SKILL.md` reads `.lsa.yaml paired_verify`** (`off` \| `checkpoint` \| `async`, default `off`) and branches:
  - **`off` / absent** — byte-for-byte today's delegation: package → dispatch → await, no pause instruction, no verifier (backward compatible).
  - **`async`** — errors `not yet implemented` (concurrent-interrupt model reserved for a later pitch) and does **not** fall back — no silent degradation.
  - **`checkpoint`** — when the implementer is agent-dispatched, injects a pause+signal protocol so the implementer, after each plan task F-K, writes a checkpoint-signal note carrying exactly `target`/`since`/`spec`/`status` (matching the reader contract at [`observer/skills/verify-checkpoint/SKILL.md:22-37`](../observer/skills/verify-checkpoint/SKILL.md)) and stops; delegate dispatches `observer:verify-checkpoint` per increment and gates on the verdict (CLEAR auto-proceeds with no human interrupt; BLOCK surfaces to the human before the next task). The verifier stays read-only and independent — its verdict is never folded into the implementer's authoring context ([`lsa/skills/reconcile/SKILL.md:44-45`](./skills/reconcile/SKILL.md)). For a non-agent/human/Cursor implementer the pause-protocol is stated as **advisory** (no silent claim of enforcement). The final whole-diff `lsa:reconcile` still runs after delegation — checkpoint mode does not replace it.
- **`.lsa.yaml` gains an optional `paired_verify` key** — documented in [`ARCHITECTURE.md`](./ARCHITECTURE.md) §3 (schema block + per-key bullet) and the [`knowledge/conventions.md`](./knowledge/conventions.md) `.lsa.yaml` defaults (default `off`).
- **Checkpoint-note path is delegate-owned and shared** (harmonized with observer 0.2.1). `delegate` Step 4/5 now states delegate OWNS the checkpoint-signal note path and passes the SAME **ephemeral** (scratchpad / gitignored, not committed) path to both the implementer (writer) and `observer:verify-checkpoint` (reader). The four contract fields (`target`/`since`/`spec`/`status`) are unchanged — the path locates the note, the fields are its contents. Step 5 also aligns wording to dispatch `verify-checkpoint` in its **per-increment invocation mode** (its first-class entry point, distinct from its standalone `/loop` mode).

### Changed

- **`lsa/README.md`** — the `delegate` skill row and Configuration section now document the `paired_verify` modes (`off` / `checkpoint` / `async`).

## [0.22.0] — 2026-07-01

Wires the deterministic doc-lint gate into the grounding check. Feature: [`.lsa/features/2026-07-01-deterministic-doc-lint-gate/requirements.md`](../.lsa/features/2026-07-01-deterministic-doc-lint-gate/requirements.md). (Atop 0.21.0 from the orchestrator-inline change; 0.21.0 → 0.22.0.)

### Added

- **`lsa/skills/verify/SKILL.md` now reads the `.lsa.yaml` `gate:` block.** New Step 4 runs each configured gate check and cites its command + exit code as the Rule-7 grounding evidence instead of re-deriving grep recipes by hand; a non-zero exit **blocks** the `GROUNDED` verdict (a broken citation, dangling link, or violated invariant is a real defect). Inputs table gains the optional `gate:` row and Constraints gain the blocking rule — matching the shape `reconcile` already uses.
- **`.lsa.yaml` gains a docs-mode `gate:` block** with three repo-internal structural probes: `docs-invariants: bash scripts/lint.sh`, `citations: bash scripts/check-citations.sh`, `links: bash scripts/check-links.sh`. The scripts are repo-internal (outside every plugin's `artifact_paths`), so they carry no plugin version.

### Changed

- **`lsa/README.md`** — the skill table's `verify` row and the `.lsa.yaml` schema prose now note that `verify` (not only `reconcile`) consumes the `gate:` block, and name this repo's three-probe docs-mode gate.

## [0.21.0] — 2026-07-01

Token-efficiency change from the marketplace model/token assessment: the `orchestrator` now runs the spec-authoring stages **inline in one context** instead of dispatching a fresh sub-agent per stage. A full designed cycle drops from ~6 dispatched contexts to ~3 — each avoided dispatch was reloading the CLAUDE.md floor + memory and re-reading the same spec files. The saving is what keeps the full flow affordable under Claude Pro usage caps (Sonnet). Grounded in `.lsa/standards/code.md` §"Model policy" and the deferred roadmap item it resolves.

### Changed

- **`lsa/agents/orchestrator.md`** — the delegation loop is now an in-context loop. `discover`, `specify`, and `verify` run inline (invoked via `Skill`, artifacts written from the orchestrator context, facts carried forward and reused rather than re-read). Tools gain `Skill`, `Write`, `Edit`. A context boundary is crossed only twice: `delegate` (the implementer must be external — LSA writes no code) and `reconcile`.
- **Independence preserved.** `reconcile` remains the one LSA-owned stage that is **dispatched, not inlined** — running it inline would give the grader write access to the `.feature` scenarios `specify` wrote in the same context, violating the *Independence must be observable* rule (`lsa/skills/reconcile/SKILL.md`). It runs in a context that is neither the implementer's nor the spec-author's, verdict in a separate commit.
- **`lsa/CORE.md` §2**, **`.lsa/modules/lsa/spec.md`**, **`lsa/README.md`** — updated to describe the inline loop + the two boundary crossings.

## [0.20.2] — 2026-06-18

Removes a contradictory orphan knowledge file surfaced by the repository quality audit (iteration 2).

### Removed

- **`lsa/knowledge/spec-templates.md`** (deleted) — defined an artifact set (`requirements.md` with a Functional-Requirements priority table, plus `test-suites.md` and `design.md`) that **contradicts** the canonical templates in [`lsa/CORE.md`](./CORE.md) §8 (`requirements.md` = Summary · User Flows · EARS · Out of Scope; `<flow>.feature` Gherkin; `grounding.md`). No skill consumed it (only an index row + an illustrative example referenced it); a reader finding it would have built the wrong artifacts. The canonical templates live in `CORE.md` §8.

## [0.20.1] — 2026-06-18

Doc-accuracy fixes surfaced by a repository quality audit.

### Fixed

- **`lsa/ARCHITECTURE.md`** — stale version header (`0.16.5` → `0.20.1`) and a wrong cross-reference: `core/ground-rules` was cited as "(6 rules)" but it defines **eight** content rules (numbered 0–7, per `core/skills/ground-rules/SKILL.md:13` + `README.md:13`). Corrected to "(8 rules)".

## [0.20.0] — 2026-06-17

Gate-observability fixes from the first live `manager:implement` run on an external project (TripAnchor-1). Observation log: [`.lsa/observations/2026-06-17-tripanchor-manager-implement.md`](../.lsa/observations/2026-06-17-tripanchor-manager-implement.md). Feature: [`.lsa/features/2026-06-17-parallel-engine-findings/`](../.lsa/features/2026-06-17-parallel-engine-findings/epic.md).

### Changed

- **C3 — independent grader is now observable, not asserted.** `lsa/skills/reconcile/SKILL.md` + `lsa/knowledge/quality-gate-contract.md`: reconcile runs in a separate context and lands its verdict (`conformance.md` + `reconcile: PASS|FAIL @ <graded-sha>`) as a distinct gate artifact in a commit separate from the implementation — a run that folds reconcile inline (as observed on TripAnchor) now fails the contract.
- **C6 — required vs. non-required checks.** `lsa/knowledge/quality-gate-contract.md` classifies gate checks as required (correctness, blocking) vs. non-required (infra/deploy, non-blocking), so an infra-permission failure no longer reads as a correctness failure.
- **`lsa/.claude-plugin/plugin.json`** — version 0.19.0 → 0.20.0.

## [0.19.0] — 2026-06-17

Epic 3 of parallel-agent-delivery (autonomy knob). Documents the optional `.lsa.yaml` `autonomy:` key — the schema side of the manual/semi/auto ladder consumed by `manager:implement`.

### Changed

- **`lsa/ARCHITECTURE.md` §3** — `.lsa.yaml` schema gains `autonomy: manual | semi | auto` (default `manual`) + a bullet: how much human-in-the-loop a parallel `manager:implement` run uses at the merge boundary; the gate is identical at every level (autonomy removes only the prompt after green). Semantics live in `manager/knowledge/autonomy-policy.md`.
- **`lsa/README.md`** — `.lsa.yaml` schema block + prose gain the `autonomy:` knob.
- **`lsa/.claude-plugin/plugin.json`** — version 0.18.0 → 0.19.0.

## [0.18.0] — 2026-06-17

Epic 1 / S2 of parallel-agent-delivery (`.lsa/features/2026-06-17-parallel-agent-delivery-epic-1/` R6–R9). Wires `reconcile` as the **independent grader** and defines the **quality-gate script contract** — the LSA half of the pitch's safety core (the grader the work cannot edit + the configurable gate that proves "done"). Consumes `core` 0.14.0 Rule 7 (`done = a gate-proven, cited predicate`).

### Added

- **`lsa/knowledge/quality-gate-contract.md`** (new) — the repo-local `.lsa.yaml` `gate:` contract: per-check name → command, passes iff the command exits `0`, reportable only with the command + output cited (the Rule 7 gate artifact). Hardcodes no lint/test/migration/deploy tool (pitch rabbit-hole 5). Carries the **independence rule** — the `gate:` block + acceptance `.feature` scenarios are not editable within the same epic's change they grade (reward-hacking defense, pitch no-go #5 / arxiv 2406.10162v3). Includes a docs-mode note (this marketplace's gate is the LSA checks + structural probes, not a compiler) and an illustrative code-repo example.

### Changed

- **`lsa/skills/reconcile/SKILL.md`** — new Inputs row for the `gate:` checks; Step 1 *"does it work"* now also runs each configured gate check and cites its command + output as proof; new Constraint *"Independent grader"* — reconcile runs in a context with no write access to the tests, `.feature` scenarios, or `gate:` config it grades, and the implementer's diff never edits its own grader.
- **`lsa/ARCHITECTURE.md` §3** — `.lsa.yaml` schema gains the optional `gate:` block + a bullet describing its semantics.
- **`lsa/README.md`** — reconcile skill-table row notes the independent-grader role; `.lsa.yaml` schema block gains `gate:` + a paragraph linking the contract.
- **`lsa/.claude-plugin/plugin.json`** — version 0.17.0 → 0.18.0.

## [0.17.0] — 2026-06-12

Adopts the `core` 0.13.0 **gate-delivery contract** (Rule 5 *Self-contained gates*, Rule 7 *Authorization boundary* + *Delivery test*) — completes the "agents propose, skills gate" inversion that `management` 0.5.0 started. Fixes the class behind approve-without-seeing: gates asked about content that lived only in subagent transcripts or same-turn pre-tool-call text, and spec files landed on disk before their approval.

### Changed

- **`lsa/skills/specify/SKILL.md` Steps 2–4 + Output** — *write → approve* inverted to **show → approve → write**: Steps 2–3 now *draft* (nothing on disk), Step 4 shows the full draft spec per the Rule 7 *Delivery test*, takes approval, and only then writes `requirements.md` + `<flow>.feature`. Output states "written only after the Step 4 approval".
- **`lsa/agents/orchestrator.md` Step 5** — collecting a sub-agent's `## Output` now requires **surfacing it verbatim to the human** (a sub-agent transcript is invisible) and running any returned pending gates.
- **`lsa/agents/orchestrator.md` Constraints + `tools:`** — new *"Gates belong to whoever talks to the human"* constraint (mirrors `management/agents/product-manager.md`): as a subagent, never attempt `AskUserQuestion` — return pending gates + the content under decision to the dispatcher. `tools:` drops `AskUserQuestion` (dead in subagent context; the frontmatter list only applies there).
- **`lsa/knowledge/conventions.md` § AskUserQuestion convention** — gains the gate-delivery prerequisite paragraph: gates are self-contained or preceded by turn-final delivery; subagent-transcript / pre-tool-call content counts as not shown; approval-gated artifacts follow show → approve → write.
- **`lsa/skills/reconcile/SKILL.md` Step 4** — drift presentation now cites the Rule 7 *Delivery test* (ordering was already present → approve → edit).
- **`lsa/README.md`** — specify row + quickstart step 3 + orchestrator note updated to the new approval moment.
- **`lsa/knowledge/conventions.md` § Output discipline** — *"the seven golden rules"* → *"the `core/output` rules"* (restated count/name violated the canonical-source note at `core/skills/output/SKILL.md:8`).

### Why

`core` 0.13.0 (same date) defines the contract; this release wires LSA to it. The triggering failure and audit are documented in `core/CHANGELOG.md` 0.13.0 §Why.

## [0.16.5] — 2026-06-12

Doc-drift sweep (80/20 audit, 2026-06-12). No behavior change.

### Fixed

- **`lsa/ARCHITECTURE.md` Version line** — stale `0.16.1 (plugin)` → current plugin version (drifted three releases behind `plugin.json`).
- **Repo-side, same commit:** `.lsa.yaml` lsa module `artifact_paths` gains `lsa/CORE.md` + `lsa/CHANGELOG.md` (the SessionStart drift hook was blind to edits of CORE.md — the contract file every LSA skill cites); the `.lsa.yaml` header comment's schema pointer corrected `§4.10` → `§3` (ARCHITECTURE.md has no §4.10).

## [0.16.4] — 2026-06-09

Production-hardening of `lsa/README.md` — correct the OpenSpec comparison + add a least-privilege note.

### Fixed

- **`lsa/README.md` "How LSA compares" table** — the OpenSpec column no longer overclaims. "Verifies the diff *after*" was `drift-prone`; OpenSpec ships `/opsx:verify` (completeness · correctness · coherence) — corrected to *"`/opsx:verify` — non-blocking, no hunk trace"*. "Permanent, drift-absorbing spec" was `proposal → archive`; OpenSpec reconciles spec↔code at archive via a delta-merge into a living `openspec/specs/` set — corrected to *"✓ living `specs/` (delta-merge)"*. Verified against OpenSpec's docs ([`concepts.md`](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md), [`workflows.md`](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md)).

### Changed

- **`lsa/README.md`** — added a prose line under the comparison table stating LSA's *genuine* edge over OpenSpec: `reconcile` is a blocking PASS gate (`/opsx:verify` "won't block archive, but it surfaces issues"), the `only` check maps every changed hunk to a requirement, and the `does` check runs each scenario N times for ≥95% — versus OpenSpec's single-pass, non-blocking verify with no hunk→requirement trace.
- **`lsa/README.md`** — added a **Security & least privilege** subsection: the `orchestrator` agent carries no `Write` / `Edit` / `Bash` tools (cites `lsa/agents/orchestrator.md` frontmatter `tools:`), LSA's autonomous write surface is bounded to spec files, and gates are advisory (Level 2.5; cites `.lsa/VISION.md` §7 decision 1). Links the repo `SECURITY.md` for the full threat model.

### Why

Production-hardening: don't overclaim against a competitor that closed the drift gap — OpenSpec has after-the-fact verify and a living spec layer, so the honest, defensible edge is the *shape* of LSA's reconcile (blocking · hunk-level · N-run), not OpenSpec's absence of verification.

## [0.16.3] — 2026-06-08

Marketplace-audit cleanup — restore file-load traces + de-count descriptions.

### Fixed

- **All 8 actors (`orchestrator` + 7 skills)** — re-added the `> **Trace.**` file-load directive the re-base dropped (hard rule per `core/CLAUDE.md` #3; every other plugin carries it).

### Changed

- **`lsa/.claude-plugin/plugin.json`**, **`lsa/README.md`**, **`lsa/ARCHITECTURE.md`** — descriptions de-count components.

## [0.16.2] — 2026-06-08

Knowledge-file reference fixes surfaced by the cross-plugin prompt review.

### Fixed

- **`lsa/knowledge/conventions.md`** — dropped the reference to the removed `lsa:implement` skill in the Library documentation protocol.
- **`lsa/knowledge/spec-templates.md`** — removed the stale "`lsa:discover` Extended flow" framing and fixed the pre-migration `vision/VISION.md` path → `.lsa/VISION.md`.

## [0.16.1] — 2026-06-08

`reconcile` completeness check + conformance report. Closes the gap left when the re-base dropped the orphan-AC predicate: a diff could pass every Gherkin scenario yet silently skip a non-scenario requirement.

### Changed

- **`lsa/skills/reconcile/SKILL.md`** — the after-delegation check is now three questions, **does · only · all**: (1) scenarios pass ×N, (2) every hunk traces to a requirement (no over-delivery), (3) every requirement maps to a change or covering test (no under-delivery). Emits `conformance.md` (requirement → satisfying change/test) — the durable "changes vs plan" record. No new step — folded into the existing after-check (same inputs, same time).
- **`lsa/CORE.md`** §6 + §9 and **`.lsa/modules/lsa/spec.md`** — updated to the does/only/all framing + `conformance.md` state file.

## [0.16.0] — 2026-06-08

Re-base to the technology-agnostic two-verb model. LSA is no longer the implementer: it authors a grounded spec (EARS + Gherkin) and runs two checks — `verify` (ground the spec against the codebase, *before*) and `reconcile` (run the Gherkin scenarios against the diff N times, *after*) — then delegates code-writing to any implementer. Aligns the plugin with `.lsa/VISION.md` v0.10.

### Added

- **`lsa/CORE.md`** — the one-page contract every skill and agent follows (principle, loop, user flows, instruction pattern, standards, the two checks, templates, worked example).
- **`lsa/skills/specify/SKILL.md`** — authors EARS requirements + user flows + Gherkin `.feature` scenarios.
- **`lsa/skills/delegate/SKILL.md`** — hands the grounded spec to any external implementer; collects the returned diff.
- **`lsa/agents/orchestrator.md`** — entry-point conductor; drives `discover → specify → verify → delegate → reconcile`, reading each sub-agent's `## Inputs` and resolving them via `discover`.

### Changed

- **`verify`** — refocused to the *before*-delegation grounding check (every spec reference resolves to real code; every flow is buildable). Removed the orphan-AC / `metrics.md` machinery.
- **`reconcile`** — refocused to the *after*-delegation correctness check: run each Gherkin scenario against the diff N times (≥95% pass); absorb drift.
- **`discover`** — refocused to intent extraction + codebase-fact gathering; the universal input-resolver.
- Every skill + agent rewritten to the uniform Role / Goal / Inputs / Steps / Output pattern (`CORE.md` §4).
- `plugin.json` description updated to "Seven skills + one agent".

### Removed

- **`lsa/skills/plan/`**, **`lsa/skills/implement/`**, **`lsa/skills/new/`**, **`lsa/skills/next/`**, and the **`developer`** agent — epic decomposition and TDD execution are the external implementer's job (Spec Kit / the coding agent), not LSA's.

## [0.15.0] — 2026-06-02

Show-changes-inline enforcement — PR-time regression check + skill-body sweep. The v0.8.0 sweep touched only `Observable result:` lines; this adds the instruction to the step bodies and a verify-time check.

### Added

- **`lsa/skills/verify/SKILL.md`** — new warning-only show-changes-inline scan over the feature's runtime artifacts / PR diff: flags banned "go check the file" phrasing and bare change-claims ("I added X to Y", "marked X", "updated Z") with no inline quote of the changed content. Mechanical/templated phrasings inside spec scaffolds are filtered first. PR-time half of Rule 7 enforcement; the author-time half lives in `prompt-engineer:prompt-review`. README skill-table row updated.

### Changed

- **`lsa/skills/plan/SKILL.md`**, **`discover/SKILL.md`**, **`init/SKILL.md`**, **`revise-constitution/SKILL.md`**, **`implement/SKILL.md`** — every step that writes / edits / marks now carries an explicit "quote the changed content inline before the verdict" instruction in the step body (the `Observable result:` line keeps the verdict; the body carries the instruction — no duplication). `lsa:reconcile`'s gold-standard drift block is unchanged.

## [0.14.0] — 2026-06-02

`lsa:next` fast-path for "what's next". Generalizes the Helper onboarding fast-path (helper v0.3.0) to the roadmap-navigation surface.

### Added

- **`lsa/skills/next/SKILL.md`** — new Step 0 fast-path: a "what's next" invocation reads `.lsa/roadmap.md` §`## Feature Backlog` directly and quotes the first `backlog`/`not started` row with a `file:line` citation in seconds — no sub-agent, no `context7`, no multi-round grep. Cites `core/knowledge/fast-path-source-of-truth.md`. Falls through to the existing flow (with an observable note) if the `## Feature Backlog` anchor is missing, the table is empty, or the question carries selection intent. README skill-table row updated.

## [0.13.0] — 2026-05-28

Default workspace moves to `.lsa/`. `lsa:init`'s tail message now points at the management plugin instead of `/lsa:discover`.

### Changed

- **`lsa/knowledge/conventions.md`** — default `specs_root: /specs/` → `.lsa/`; default `constitution: /CLAUDE.md` → `.lsa/VISION.md`. The entire LSA workspace (constitution + specs + roadmap + pitches + standards + archive) now lives under a single directory the user can `rm -rf` to fully detach. Projects with a pre-existing `/CLAUDE.md` or `/specs/` should set both keys explicitly in `.lsa.yaml`.
- **`lsa/skills/init/SKILL.md`** — final "Report to human" step now suggests `/management:roadmap` as the next entry point (with `/lsa:new` as fallback when management isn't installed). The brownfield `[a]` option's tail updated to match. Drops the stale `/lsa:specify` reference already removed in v0.12.0.
- **`lsa/ARCHITECTURE.md` §2 + §3** — directory-structure tree, `.lsa.yaml` example, and "When absent" paragraph reflect the new defaults; defers to `conventions.md` for the literal default values.
- **`lsa/README.md`** — Configuration block uses the new defaults; Naming note rewrites `LSA's /specs/standards/` to `${specs_root}/standards/ (default: .lsa/standards/)`.
- **`lsa/.claude-plugin/plugin.json`** — version 0.12.0 → 0.13.0.

### Migration

Existing repos with `.lsa.yaml` set are unaffected — `.lsa.yaml` is canonical when present. This repo's own migration from `vision/` → `.lsa/` (flat: no `specs/` subdir, constitution and spec tree share the workspace root) is documented in commit history.

## [0.12.0] — 2026-05-27

Prompt audit remediation — DRY cleanup, template extraction, cross-reference fixes, and wording polish.

### Added

- **`knowledge/spec-templates.md`** — markdown templates for requirements.md, test-suites.md, and design.md spec artifacts. Extracted verbatim from discover SKILL.md (~74 lines).

### Fixed

- **`skills/init/SKILL.md`** — removed dead reference to `/lsa:specify` (merged into `lsa:discover` in v0.8.0).

### Changed

- **`knowledge/conventions.md`** — expanded with 3 new conventions: output discipline (cite core/output, never restate), AskUserQuestion convention, prompt voice convention. Absorbs boilerplate that was repeated across 9 skill files.
- **`skills/discover/SKILL.md`** — 237→163 lines. Three inline spec-artifact templates extracted to `knowledge/spec-templates.md`; replaced with section-targeted references. Boilerplate replaced with convention references.
- **`skills/verify/SKILL.md`** — merged overlapping Steps 4+5 into one step; removed `(was Tn)` rename-history tags.
- **`skills/plan/SKILL.md`** — removed "Maximum 5 epics" duplication from Steps (kept in Constraints); replaced per-epic DoD checkboxes with convention reference.
- **`agents/developer.md`** — compressed motivational paragraph to one actionable sentence.
- **All 9 skills** — replaced repeated "Outputs follow core/output" constraint, "AskUserQuestion in Claude Code" boilerplate, and "Prompt voice" coaching blocks with convention references.

## [0.11.0] — 2026-05-26

### Added

- **`lsa/agents/developer.md`** — principal-engineer implementation agent. Dispatched by `lsa:implement` once per epic. Four phases: **(1) Design brief** — produces a single artifact covering conventions (`file:line` cited), user flow, e2e data flow with reuse/extend/new classification, risk assessment (security, performance, observability, edge cases) with mitigations, dependency/migration evaluation, and trade-off articulation; **(2) Test plan** — testing-pyramid selection (unit/integration/e2e) with per-behavior justification; **(3) TDD** — RED→GREEN→REFACTOR per subtask; **(4) Self-review** — run full suite, diff-review against design brief, present structured summary. Spec/plan push-back: stops and reports divergence instead of silently deviating. Judgment-scaled — depth of each section matches the epic's complexity.

### Changed

- **`lsa/skills/implement/SKILL.md`** — refactored from monolithic TDD executor to orchestrator. No longer contains implementation, design, or test-strategy logic — dispatches each epic to the `developer` agent via the `Agent` tool, handles inter-epic human gates, escalates spec/plan divergence reported by the agent. Human gate now shows test counts by type (unit/integration/e2e) and trade-offs made.
- **`lsa/.claude-plugin/plugin.json`** — version 0.11.0, description updated: adds developer agent, implement described as orchestrator.
- **`lsa/README.md`** — skill table updated: implement entry notes developer agent dispatch; new "Agents" section documents the developer agent.

## [0.10.0] — 2026-05-24

### Added

- **`lsa/skills/implement/SKILL.md`** — TDD implementation skill. Executes approved `tasks.md` epic-by-epic using strict RED→GREEN→REFACTOR discipline: write failing test, implement minimum code to pass, refactor while green. Per-epic checkpoint with human approval gate before proceeding. Auto-detects project tooling (test runner, type checker, linter) from constitution and project config. Handles flow interruptions (errors → fix in place; new requirements → pause and ask; scope changes → suggest re-discover). Closes the "implement" gap in the main flow: `discover → plan → implement → verify`. Addresses the critical bug where `lsa:plan` output had no enforced TDD structure downstream — the skill itself is the enforcement mechanism. Adapted from `dev-plugin`'s TDD workflow (developer agent, verifier agent, quality rules) with all project-specific content (GoGlobal, NextJS, moon tasks) removed.

### Changed

- **`lsa/skills/discover/SKILL.md`** — new Step 1.5 (prompt refinement): before inferring module/change/AC, the agent refines the user's original description for ambiguities and implicit assumptions, presents original vs. refined side-by-side, and confirms before proceeding.
- **`lsa/skills/verify/SKILL.md`** — three new checklist groups: **Imports** (every import resolves to a real exported symbol, type imports use `import type`), **Test quality** (assertions test actual requirements not tautologies, happy + error paths covered, no brittle coupling to internals), **Implementation accuracy** (logic matches requirement, edge cases handled, no unrelated side effects). Added iterative re-check: on FAIL/WARN, re-read cited files to confirm findings are real, max 3 iterations.
- **`lsa/knowledge/conventions.md`** — new §"Library documentation protocol": context7 MCP lookup → WebSearch fallback → state unknown. Referenced by discover (proactive) and implement (on-demand).
- **`lsa/.claude-plugin/plugin.json`** — version 0.10.0, description updated: nine → ten skills, `implement (TDD execution)` added to skill list.

## [0.9.0] — 2026-05-24

### Removed

- `.lsa-sync-state.json` baseline-SHA file deleted. The per-module last-sync SHA + ISO timestamp the file held is recoverable from `git log -1 --format=%H -- <module-spec-path>`; switched `reconcile` (Inputs, Step 1 prose, Step 5 substep + Observable, Output, Constraints) and `lsa/hooks/session-start-drift-check.sh` (full rewrite — consolidated YAML parsing into one awk pattern mirroring `emit_module_paths`, dropped JSON parser and cache layer) to derive the SHA from git history instead. Documentation refs cleared in `lsa/ARCHITECTURE.md` (directory diagram, SessionStart paragraph, OQ8 row), `lsa/README.md` (SessionStart paragraph), `.lsa/main.spec.md` (out-of-scope-files table), and `.lsa/modules/lsa/spec.md` (State files table). Closes the orphan introduced by v0.8.0's `lsa-sync` removal. Per the custom-inventions sweep at `.lsa/features/2026-05-22-custom-inventions-sweep/design.md` inventory row #1.

### Behavior — baseline-SHA semantics

The substitution is **not** a pure substrate swap. Baseline semantics shifted: the previous `last_sync_sha` was written only by `lsa-sync` (since removed in v0.8.0) and `reconcile`, so direct spec edits made for any other reason (typo fix, restructuring, adding a new requirement) did not advance the baseline. Under `git log -1 -- <spec-path>`, **any** commit that touches the spec file advances the baseline. The case that matters: if accumulated artifact drift is unreconciled when an unrelated direct spec edit is committed, that drift is silently absorbed by the new baseline — `reconcile` will not surface it on the next run. The previous behavior would have continued to surface it until an explicit reconcile cycle. Treat direct spec edits as implicit reconciliations; if drift is suspected, run `/lsa:reconcile` *before* editing the spec for unrelated reasons.

## [0.8.0] — 2026-05-24

Command rename + flow simplification. All LSA skills drop the `lsa-` directory prefix (commands become `lsa:discover`, `lsa:plan`, etc. instead of `lsa:lsa-discover`). `lsa-specify` and `lsa-discover` merged into a single `discover` skill with Standard/Extended flow branch. `lsa-sync` removed entirely. Two new entry-point skills: `new` (creates branch → flow-selector → discover) and `next` (reads roadmap → confirms pick → creates branch → discover). Every skill description rewritten to state input/output and make the workflow order (discover → plan → implement → verify) self-evident. Also incorporates lsa v0.7.2–v0.9.0 content that landed on main in parallel (genuine-fork test, what-and-why preamble, show-changes-inline sweep, Hard/Soft Confirm vocabulary removal). Minor bump — skill slugs, invocation names, and workflow structure all change.

### Added
- **`lsa/skills/new/SKILL.md`** — entry-point skill: accepts feature name, creates branch, runs flow-selector, hands off to discover.
- **`lsa/skills/next/SKILL.md`** — entry-point skill: reads roadmap, presents highest-priority backlog item, confirms, creates branch, hands off to discover.

### Changed
- **All skill directories** — renamed from `lsa/skills/lsa-X/` to `lsa/skills/X/` (dropped `lsa-` prefix). Commands now `lsa:discover`, `lsa:plan`, `lsa:verify`, `lsa:init`, `lsa:reconcile`, `lsa:revise-constitution`.
- **`lsa/skills/discover/SKILL.md`** — merged former `lsa-discover` + `lsa-specify` into one skill. Standard flow: infer-then-confirm → 3-row table → stop. Extended flow: infer-then-confirm → clarify → create spec dir → User Verification 1 → User Verification 2 → User Verification 3.
- **All skill YAML frontmatter `description` fields** — rewritten to state input required and output produced. Main-flow skills include position marker (step N of 4).
- **`lsa/.claude-plugin/plugin.json`** — version 0.8.0, description updated with nine skills and main flow.
- **`lsa/README.md`** — skill table rewritten with new names and descriptions.
- **`lsa/ARCHITECTURE.md`** — directory tree, branch management, resolved decisions updated.
- **`lsa/knowledge/conventions.md`** — "Confirm gate types" section removed (plain-English phrasing used at each cite site instead; per main's v0.9.0 Hard/Soft Confirm vocabulary removal).
- **Cross-references** — all active files across `core/`, `vision/`, `helper/`, root swept for old names.

### Removed
- **`lsa/skills/lsa-sync/`** — deleted entirely. Feature specs are the permanent record; no promotion into module specs.
- **`lsa/skills/lsa-specify/`** — deleted (content merged into `discover`).

## [0.9.0] — 2026-05-24

Remove the LSA-internal "Hard Confirm" / "Soft Confirm" vocabulary. The named distinction was custom LSA invention with no upstream mandate; substituted plain-English phrasing inline at each cite site. Minor bump — the documented convention section in `lsa/knowledge/conventions.md` and its inline references across 4 skill bodies are user-visible. Matches the `c226623` (v0.7.0) precedent for documented-convention removal. Per `.lsa/features/2026-05-22-custom-inventions-sweep/` Task T1 (inventory row #3). T2 (`.lsa-sync-state.json` removal) ships in a separate follow-up PR.

### Removed
- **`lsa/knowledge/conventions.md` §"Confirm gate types"** — section deleted (was lines 40-50). Defined `Hard Confirm` (stop, present, wait for explicit approval) and `Soft Confirm` (present, allow inline corrections). No upstream standard mandated the two-shape distinction; plain-English phrasing is clearer at each cite site.

### Changed
- **`lsa/skills/lsa-specify/SKILL.md`** (4 lines — `:21` Goal preamble + Steps 4 / 5 / 6 section headers) — *"All three Verifications in this skill are **Hard Confirm**"* → *"All three Verifications stop until the human explicitly approves; no implicit approval is accepted."* Section headers `User Verification N: ... → Hard Confirm` → `User Verification N: ... (stop and present; do not proceed without explicit approval)`. The parenthetical citing `conventions.md` §"Confirm gate types" (used to clarify why lsa-specify drops Soft) is also gone — the defining section no longer exists.
- **`lsa/skills/lsa-reconcile/SKILL.md`** (2 lines — preamble at `:11` + Step 4 name at `:37`) — *"One module at a time, hard confirm per module."* → *"One module at a time — stop and present each delta individually; do not proceed without explicit approval."* Step 4 *"Per-module hard confirm."* → *"Per-module — stop and present each delta individually; do not proceed without explicit approval."* PR #21 verdict preamble citing [`../../../core/skills/output/SKILL.md`](../skills/output/SKILL.md) Rule 6 preserved verbatim immediately after the new step name.
- **`lsa/skills/lsa-revise-constitution/SKILL.md`** (1 line — Constraints at `:87`) — *"Hard confirm per change."* → *"Stop and present each proposed change individually; do not proceed without explicit approval."* Step 3 (`:61`) "Human review gate." sentence + PR #21 verdict preamble citing Rule 6 preserved verbatim — Step 3 did not carry the vocabulary directly, so no edit needed at `:61`.
- **`lsa/README.md`** (1 line — `lsa-reconcile` skill table row at `:21`) — *"Per-module hard confirm."* → *"One delta at a time — stop and present each individually; do not proceed without explicit approval."* Keeps the README description aligned with the renamed skill body per the same-commit README rule in `/CLAUDE.md`.

### Notes
- **Minor bump rationale.** Matches the `c226623` precedent (`lsa/CHANGELOG.md` v0.7.0 entry — trace-tag removal moved `0.6.5` → `0.7.0` for a user-visible documented-convention removal). This PR removes another user-visible documented convention section (`conventions.md` §"Confirm gate types") plus its inline references in 4 skill bodies and 1 README cell. Anyone who learned the Hard / Soft vocabulary sees it disappear.
- **`lsa-sync` carries no Hard / Soft Confirm references.** Verified via `grep -n "Hard\|Soft" lsa/skills/lsa-sync/SKILL.md` (only matches were in unrelated words like "Verdict" — no vocabulary site). No edit needed in `lsa-sync` for this sweep.
- **`grep -rn "Hard Confirm\|Soft Confirm" lsa/`** returns zero hits in active files after this sweep. Historical CHANGELOG entries (pre-v0.9.0) keep their original wording — they are frozen records of how the convention existed at the time, and nothing parses them.
- **T2 deferred.** `.lsa-sync-state.json` removal (inventory row #1) ships as a separate PR — medium blast radius (7 files + 1 hook script) plus adjacent-line-citation conflicts with PR #22 (Show actual changes inline) warrant the split.
- **Spec source.** `.lsa/features/2026-05-22-custom-inventions-sweep/design.md` §"Invention inventory" row #3; `tasks.md` §"T1 — PR: Remove 'Hard Confirm' / 'Soft Confirm' vocabulary".

## [0.8.1] — 2026-05-24

Apply the new `core` v0.8.0 **Rule 7 — Show changes inline (write, show, comment)** to every LSA skill body whose `Observable result:` line currently names a file write/edit/append/mark without naming what is quoted back. 16 lines edited across 7 LSA skills (`lsa-sync` ×6, `lsa-specify` ×3, `lsa-init` ×2, `lsa-revise-constitution` ×2, `lsa-plan` ×1, `lsa-verify` ×1, `lsa-discover` ×1). Each touch is a one-line replacement — no surrounding-content rewrite, no behavior change; the clause now names the quote-back format (full single-change block when ≤10 lines, compressed inspection table when larger) and the type tag (add / edit / replace / append / mark). One-line forward-link added to `lsa-reconcile` naming its 8-element drift block as the in-repo exemplar Rule 7 generalizes from. Per `.lsa/features/2026-05-22-show-changes-inline/`. Standard flow.

### Changed
- **`lsa/skills/lsa-sync/SKILL.md`** (6 lines — Steps 2 / 3 / 4 / 5 / 6 / 7) — `Observable result:` lines for the delta scratch, per-module diff, `main.spec.md` diff, archive `mv`, `.lsa-sync-state.json` write, and `metrics.md` row append now cite [`core/output`](../skills/output/SKILL.md) Rule 7 and name the quote-back format. Verdict-emission step at line 131 (closing-offer) untouched — already cites Rule 6 for the preamble.
- **`lsa/skills/lsa-specify/SKILL.md`** (3 lines — Steps 3 / 4 / 5) — `Observable result:` lines for the spec-dir + branch creation, `requirements.md` write, and the three-file write (`test-suites.md` / `contract.yaml` / `design.md`) now cite Rule 7 and name the quote-back format.
- **`lsa/skills/lsa-init/SKILL.md`** (2 lines — Step 2 brownfield / Step 3) — `Observable result:` lines for the brownfield spec-tree write and the three-file write (`main.spec.md` / `roadmap.md` / `research-backlog.md`) now cite Rule 7 and name the compressed-inspection-table format given the multi-file batch size.
- **`lsa/skills/lsa-revise-constitution/SKILL.md`** (2 lines — Steps 4 / 5) — `Observable result:` lines for the per-file edit (`${constitution}` / `${specs_root}/standards/*`) and the branch + commit creation now cite Rule 7 and name the quote-back format.
- **`lsa/skills/lsa-plan/SKILL.md`** (1 line — Step 4) — `Observable result:` line for the `tasks.md` write now cites Rule 7 and names the per-epic compressed-table format.
- **`lsa/skills/lsa-verify/SKILL.md`** (1 line — Step 6) — `Observable result:` line for the conditional `metrics.md` write (only on clean PASS) now cites Rule 7 and names the quote-back format. Borderline-write per `design.md` §"Inventory" row 15 — resolved to (a) "treat as a write step, apply Rule 7" per the implementor's call (the recommended branch).
- **`lsa/skills/lsa-discover/SKILL.md`** (1 line — Step 4 Extended) — `Observable result:` line for the `discovery.md` scratch write now cites Rule 7 and names the full single-change block format with the three captured answers.

### Added
- **`lsa/skills/lsa-reconcile/SKILL.md` ## Steps preamble** — one-line forward-link near the top of `## Steps`: *"The 8-element drift block below is the exemplar that [`core/output`](../skills/output/SKILL.md) Rule 7 generalizes from."* Closes the cross-cite — `core/output` Rule 7 already cites `lsa-reconcile` as the exemplar; this is the reverse pointer.

### Notes
- **Patch bump rationale.** Output-discipline only — no behavior change. Each edit is a one-line touch; per-skill `## Goal` / `## Constraints` / `## Output` sections untouched (per `requirements.md` NF3). The user-visible delta is each touched `Observable result:` line now names the quote-back format the human sees, instead of only that the file changed.
- **Sibling core minor bump.** `core` v0.8.0 in the same feature ships the canonical Rule 7 these LSA edits cite (`core/skills/output/SKILL.md` Rule 7 *"Show changes inline — write, show, comment"*). LSA cites by markdown link, never restates.
- **`lsa-reconcile` is excluded from the sweep.** It is the exemplar Rule 7 generalizes from; touching its `Observable result:` lines would risk circular drift (per `requirements.md` Constraint *"Do not edit `lsa-reconcile`. It is the exemplar"*). The one-line forward-link added to `lsa-reconcile` `## Steps` is the only edit — additive, not a rewrite.
- **Helper Constraint deferred.** Epic 3 (Helper `## Constraints` bullet citing Rule 7) ships in a separate follow-up PR after PR #19's helper changes merge, to avoid conflicts. The 16-line sweep + `lsa-reconcile` cross-cite ship together in this LSA patch.
- **42 `Observable result:` lines total in `lsa/skills/` after sweep.** 16 cite Rule 7 (the violation set); 26 are read-only (read-protocol prints, in-memory captures, verdict reports already covered by Rule 6, exemplar `lsa-reconcile`) and require no Rule 7 citation per the audit framing in `design.md` §"Inventory".
- **Spec source.** `.lsa/features/2026-05-22-show-changes-inline/design.md` §"Inventory — current Observable result: violations" enumerates the 16 lines; §"Step B — LSA skill sweep" carries the before/after template; `tasks.md` Epics 1–2 + 4.

## [0.8.0-main] — 2026-05-24

Apply the new `core` v0.7.0 **Rule 6 — What-and-why preamble** to every LSA skill body that currently emits a verdict label from `core/knowledge/output-vocabulary.md` §"Verdicts". 5 skill bodies updated; 7 emission sites gain a one-sentence preamble in the user's frame, naming (a) what the verdict means and (b) the concrete consequence if the user does not act. PR #20 work (verdict-named picker prompts in `lsa-verify`, closing-offer reframe in `lsa-sync`) preserved intact — preambles land BEFORE the verdict line without disturbing the existing prompt voice. Per `.lsa/features/2026-05-22-lsa-what-why-preamble/`. Standard flow.

### Changed
- **`lsa/skills/lsa-init/SKILL.md` Step 2 brownfield** — `PROPOSED` verdict at the "Stop" sub-step now carries a preamble in the user's frame: *"I scanned this repo and drafted `<N>` module specs from /src/ so future LSA steps can attach changes to a specific module — without these specs the next /lsa:discover has nothing to pick."* Citation line added: *"Verdict carries a preamble per `core/output` Rule 6."* PR #20's prompt-voice scaffold (Rule 5 picker question naming the project subject) preserved unchanged. Maps to AC1.
- **`lsa/skills/lsa-reconcile/SKILL.md` Step 4** — `DRIFT` verdict at the per-module hard confirm now carries a preamble in the user's frame: *"The auth spec says sessions expire after 24 hours, but the code now sets 7 days — one needs to win, otherwise the next review will block the merge until you pick one."* (adapted per delta at runtime). Citation line added. Maps to AC2.
- **`lsa/skills/lsa-sync/SKILL.md` Step 8** — `APPLIED` verdict at the post-completion report now carries a preamble in the user's frame: *"Module specs for `<modules>` now reflect the merged feature — the docs are current, and the next decision is just whether to open the PR now or later."* Citation line added. PR #20's closing-offer reframe (silent-default `hold`, Rule 5 Genuine-fork-test citation) preserved unchanged. Maps to AC4.
- **`lsa/skills/lsa-revise-constitution/SKILL.md` Step 3** — `PROPOSED` verdict at the per-change human review gate now carries a preamble in the user's frame: *"Last feature surfaced a rule worth making permanent: I'm offering to add a 'no inline secrets' line to CLAUDE.md — accepting makes it enforced on every future change; rejecting means the next contributor can still paste a secret without a warning."* (adapted per change at runtime). Citation line added. Maps to AC5.
- **`lsa/skills/lsa-verify/SKILL.md` Step 4** — all three variant verdicts (`PASS` / `FAIL` / `PASS WITH WARNINGS`) now carry a one-sentence preamble before the verdict line, naming what the verdict means and the consequence in the user's frame. Single citation line added at the top of Step 4 covering all three variants. PR #20's verdict-named `AskUserQuestion` prompts (*"Verdict: PASS — sync now? …"* etc.) preserved unchanged. Maps to AC3.

### Notes
- **Minor bump rationale.** 5 skill bodies' user-visible output shape changes — every verdict emission now leads with a plain-English preamble instead of a bare label. Per `.lsa/VISION.md` *"Distribution + versioning"* — observable behavior change across multiple skills is minor-bump territory.
- **Sibling core minor bump.** `core` v0.7.0 in the same feature ships the canonical Rule 6 these LSA edits cite (`core/skills/output/SKILL.md` Rule 6 *"What-and-why preamble — verdicts carry a one-sentence frame"*). The rule lives at the marketplace layer alongside the verdict vocabulary itself (`core/knowledge/output-vocabulary.md`); LSA cites by link, never restates.
- **Three LSA skills with zero verdict emissions stay untouched.** `lsa-discover`, `lsa-specify`, `lsa-plan` emit no verdict label per the inventory in `.lsa/features/2026-05-22-lsa-what-why-preamble/design.md` §"Verb-headline inventory". The rule still ships in `core/output`, so the moment any of them adds a verdict emission the preamble obligation attaches automatically. (`lsa-plan` uses `PASS / FAIL` as in-table cell values, not verdict headlines — Open Question 2 resolution.)
- **Spec source.** `.lsa/features/2026-05-22-lsa-what-why-preamble/requirements.md` AC1–AC8 + F1–F7; `design.md` §"Worked examples" carries the verbatim preamble strings used at each emission site; `tasks.md` Epics 0–5 enumerate the edits.

## [0.7.2] — 2026-05-24

Apply the `core` v0.6.0 *Genuine-fork test* to 3 LSA call sites — tightening `lsa-discover`'s per-line picker (composes with v0.7.1 infer-then-confirm), softening `lsa-sync`'s post-completion picker, and renaming `lsa-verify`'s verdict-picker prompt. Per `.lsa/features/2026-05-22-askuserquestion-audit/` Epic B (rows L2 / L9 / L12 in the design inventory). Standard flow. Renumbered from v0.7.1 → v0.7.2 to coexist with the v0.7.1 infer-then-confirm release that landed independently.

### Changed
- **`lsa/skills/lsa-discover/SKILL.md` Step 2 (L2 — `keep + tighten`)** — added "Skip per-line picker when N=1 candidate AND no `custom`" semantics on top of v0.7.1's infer-then-confirm reshape. When Step 1 yields a single unambiguous candidate for a line and the human hasn't asked for `custom`, the skill accepts the candidate silently. Remaining picks batch into ONE multi-question `AskUserQuestion`.
- **`lsa/skills/lsa-sync/SKILL.md` Step 8 (L12 — `convert-to-closing-offer`)** — post-completion PR-or-hold picker reframed as an *optional closing offer*, not a mandatory gate. **Silent-default = `hold`** — `gh pr create` runs only on explicit `Yes`. Cites `core/output` Rule 5 Genuine-fork test.
- **`lsa/skills/lsa-verify/SKILL.md` Step 4 + Step 5 (L9 — `keep + tighten` verdict-picker prompt voice)** — verdict-picker prompts rewritten to name the verdict in the subject: *"Verdict: PASS — sync now?"* / *"Verdict: FAIL — block merge?"* / *"Verdict: PASS WITH WARNINGS — accept the warnings and sync?"*. Human picks the next action; verdict itself is already settled by the checklist.

### Notes
- **Patch bump rationale.** L2 (skip when N=1) + L12 (closing-offer) change observable behavior; L9 (verdict prompt) is prompt-text only. Cumulative effect is on the patch/minor boundary; chose patch — no rule/skill added or removed, only existing pickers' wording and conditional rendering changed.
- **Sibling `core` minor bump.** `core` v0.6.0 in the same feature ships the canonical rule this changelog cites (`core/skills/output/SKILL.md` Rule 5 *Genuine-fork test*). LSA edits are downstream of the rule.
- **Out of scope for this PR.** Helper-side call-site sweep (Epic C — H1, H2, H3, H4, H5m in the inventory) ships in a later PR; it folds with feature 5's Epic 3 since most Epic C work was substantially done by helper v0.3.0 (PR #19).
- **Spec source.** `.lsa/features/2026-05-22-askuserquestion-audit/design.md` §"Call-site Inventory" rows L2, L9, L12 carry the verdict + reason; `tasks.md` Epic B enumerates B1–B6.

## [0.7.1] — 2026-05-23

`lsa-discover` infer-then-confirm. The agent now reads the codebase to determine module, change framing, and acceptance criterion — then presents all three as a pre-filled table for human override in a single `AskUserQuestion`. Previously the skill asked three questions the agent should have answered itself. Same pattern as the `lsa-init` v0.3.1 fix (greenfield/brownfield mechanical detection). Per user feedback 2026-05-23.

### Changed
- **`lsa/skills/lsa-discover/SKILL.md` Step 2** — replaced "Ask the three-question discovery probe" with "Infer all three discovery answers — then confirm." New sub-steps 2a (module inference via artifact_paths cross-reference), 2b (change framing from module spec), 2c (AC from task description + spec invariants), 2d (single confirmation prompt). The agent does the discovery work; the human confirms or overrides.
- **`lsa/skills/lsa-discover/SKILL.md` Goal** — updated to reflect agent-inferred, human-confirmed pattern.
- **`lsa/skills/lsa-discover/SKILL.md` Constraints** — first bullet changed from "Three questions, no more" to "Infer, don't ask" with the rule that the agent never asks for information derivable from repo state.
- **`lsa/README.md`** — `lsa-discover` row updated from "Light three-question probe" to "Infer-then-confirm discovery."

### Notes
- **Patch bump rationale.** Behavioral improvement to an existing skill — discovery answers are now agent-inferred rather than human-provided. The three-answer shape and downstream handoff (Standard oral / Extended scratch) are unchanged.
- **Precedent.** Mirrors `lsa-init` v0.3.1 (`lsa/CHANGELOG.md:163-166`) which replaced the redundant "Greenfield or brownfield?" question with mechanical detection.

## [0.7.0] — 2026-05-22

Remove the trace-tag convention and stop emitting `<!-- added/reconciled/revised: ... -->` HTML comments. The format was opaque to non-LSA collaborators and not required by EARS (`.lsa/VISION.md:187-206`) or any other adopted 3rd-party standard. Minor bump — three skills' observable output changes.

### Removed
- **`lsa/knowledge/conventions.md` §"Trace-tag format"** — section deleted (was lines 53-75).
- **`lsa/skills/lsa-sync/SKILL.md`** — 5 trace-tag references removed: the "(tagged)" mention in Step 2's decision block, the `Tag each addition` substep in Step 3, the `Tag each change` bullet in Step 4, the "(tagged)" qualifier in Output, and the **Tag every addition** constraint.
- **`lsa/skills/lsa-reconcile/SKILL.md`** — 3 trace-tag references removed: the `Tag the edited line(s)` sentence in Class (a), the `Tag with` sentence in Class (b), and the "both tagged" qualifier in Output.
- **`lsa/skills/lsa-revise-constitution/SKILL.md`** — 3 trace-tag references removed: the "tagged" mention in Step 3's decision block, the `Tag the change` substep in Step 4, and the "each tagged" qualifier in Output.

### Changed
- **`.lsa/VISION.md`** (2 sites — `:59`, `:206`), **`.lsa/main.spec.md:18`**, **`.lsa/modules/lsa/spec.md`** (2 sites — `:36`, `:37`) — stripped the 5 HTML comment tags from living specs. Archive files (`.lsa/plans/2026-05-20-*`, `.lsa/2026-05-20-lsa-v0.2.0-design.md`) intentionally untouched per user choice — they remain as frozen historical records.

### Notes
- **Minor bump rationale.** Three skills change observable output (no more tagged HTML comments in their edits) — that's user-visible behavior change, not a patch-class fix. Per `.lsa/VISION.md` "Distribution + versioning".
- **No migration step needed.** Existing tags in archive files are valid Markdown comments; nothing parses them and nothing breaks.
- **User trigger.** Working with a collaborator on a downstream project (TripAnchor), the user flagged that `<!-- revised: manual 2026-05-22 -->` is unintelligible to anyone without LSA context. "If it's not a requirement from EARS or other 3rdparty we adopted - get rid of it." Confirmed not required by EARS (which is purely AC-phrasing per `.lsa/VISION.md:187-206`); no other adopted standard mandated provenance HTML comments.

## [0.6.5] — 2026-05-22

Replace 9 snapshot restatements with citation-by-link to satisfy `core` v0.5.5's new canonical-source contract for output discipline. No behavior change. Patch flow.

### Fixed
- **`lsa/ARCHITECTURE.md:30`** — Stale *"(4 golden rules)"* count snapshot (Core has five) → citation-only descriptor.
- **All 8 `lsa/skills/*/SKILL.md` Constraints footers** — *"golden rules (structured, minimal, formatted, sourced)"* (missing *concrete*) → *"citation by link, never restated."* Files: `lsa-discover`, `lsa-init`, `lsa-plan`, `lsa-reconcile`, `lsa-revise-constitution`, `lsa-specify`, `lsa-sync`, `lsa-verify`.

### Notes
- **Patch bump rationale.** Mechanical citation cleanup; no skill behavior change. The rules LSA outputs adhere to are exactly the rules `core/output` has always defined — only the prose changes. The next time `core/output` grows or shrinks a rule, LSA's citations will resolve to the new list automatically (no LSA edit needed).
- **Sibling core patch.** `core` v0.5.5 in the same PR declares `core/output` canonical + adds the D2 regression probe that prevents this drift class from recurring.

## [0.6.4] — 2026-05-22

File-load trace adoption. All 8 `lsa/skills/*/SKILL.md` and `lsa/knowledge/conventions.md` carry the new one-line trace directive at their top, per `core` v0.5.4 Rule 4 (Sourced) → *File-load trace*. On load, each file prints `=============== [<file>] [lsa] ===============` verbatim. Replaces the v0.5.3 `[plugin:skill]` marker scheme that did not survive in practice. Per user request 2026-05-22. Quick flow.

### Added
- **Trace directive in 9 files** — `lsa/knowledge/conventions.md` plus all 8 LSA skill bodies (`lsa-discover`, `lsa-init`, `lsa-plan`, `lsa-reconcile`, `lsa-revise-constitution`, `lsa-specify`, `lsa-sync`, `lsa-verify`). Hardcoded path + plugin name in each; on load the agent prints the line verbatim before the response body.

### Notes
- **Patch bump rationale.** No skill behavior change beyond the trace line. Same User Verification flow, same artifacts. The trace replaces the v0.5.3 single-line marker as a provenance mechanism — see `core` v0.5.4.

## [0.6.3] — 2026-05-22

Adopt the now-supported `dependencies` field in the Claude Code plugin manifest. Clears the "Marketplace dependency field" row from `.lsa/roadmap.md` (status was `blocked` per `.lsa/2026-05-20-lsa-v0.2.0-design.md` §14). Verified field availability against [code.claude.com/docs/en/plugin-dependencies](https://code.claude.com/docs/en/plugin-dependencies) and [code.claude.com/docs/en/plugins-reference](https://code.claude.com/docs/en/plugins-reference) on 2026-05-22 — `dependencies` is a top-level array (entries are bare strings or `{ name, version?, marketplace? }` objects) and ships in current Claude Code.

### Added
- **`lsa/.claude-plugin/plugin.json` `dependencies`** — bare-string declaration `"dependencies": ["core"]`. Claude Code now auto-resolves and installs `core` when a user installs `lsa`, and refuses to disable `core` while `lsa` is enabled (per the same-marketplace cascade rules in the docs above). No version constraint this cycle — `core` and `lsa` ship from the same repo on the same release cadence, so versions move in lockstep. A future row in the roadmap can add a `>=` floor + tagged-release flow if a downstream consumer outside this repo materializes.

### Changed
- **`lsa/.claude-plugin/plugin.json` `description`** — dropped trailing prose `Depends on \`core\` (cites \`core/ground-rules\` for fact-grounding and \`core/flow-selector\` for flow selection).` The structured `dependencies` field now carries the same intent; the cite-specific skills detail moves nowhere (it was illustrative, not load-bearing for the manifest).
- **`lsa/README.md`** — "Depends on" section: the line claiming the manifest does not enforce a `dependencies` field is now stale; replaced with a note that the structured field exists and Claude Code auto-resolves on install.

### Notes
- **Patch bump rationale** — manifest declaration moves from prose to structured, expressing the same intent. The user-visible install-behavior change (auto-resolve + enable/disable cascade) is additive and aligns with the prior `/plugin install core` → `/plugin install lsa` documented sequence. Treating as patch per the same pre-1.0 maintainer-discretion clause used for the v0.6.2 sibling-rename patch.
- **Sibling release** — `core` is unchanged. The dependency edge is declared from the dependent side only, per the documented schema.

## [0.6.2] — 2026-05-22

Naming clarity patch — two sibling renames:

1. **`lsa-specify` "Gate N" → "User Verification N: <name>"** — the prior `Gate 1` / `Gate 2` / `Gate 3` carried position but no meaning to a first-time user. New names: `User Verification 1: Requirements + Contract Trigger`, `User Verification 2: Test Suites + Contract + Design`, `User Verification 3: Final Integration`.
2. **Tier flow `T1` / `T2` / `T3` → `Quick` / `Standard` / `Extended`** — sibling to `core` v0.5.2's `tier-selector` → `flow-selector` rename. The new names describe the *process shape*, not a hierarchy.

Per `.lsa/roadmap.md` rows *"Rename `lsa-specify` 'Gate N' → 'User Verification: <name>'"* and *"Rename `T1` / `T2` / `T3` → `Flow: Quick` / `Flow: Standard` / `Flow: Extended`"*. Bundle B (Naming clarity) of the 2026-05-22 fixing session.

### Changed
- **`lsa/skills/lsa-specify/SKILL.md`** — Goal sentence + Steps 4/5/6 section headers + cross-references updated to `User Verification N: <name>`; Constraints "Three bundled gates" → "Three bundled User Verifications"; "(determined at Gate 1)" comment + "re-run Gate 3" amend rule updated; "tier" / "T3" annotations in description + Input + Step 1.
- **`lsa/skills/lsa-discover/SKILL.md`** — `T2 / T3` → `Standard / Extended`; `tier-selector` → `flow-selector`; "tier" → "flow" throughout.
- **`lsa/skills/lsa-init/SKILL.md`** — Step 4 report message updated to name `Standard / Extended` entry path.
- **`lsa/skills/lsa-verify/SKILL.md`** — Step 6 + Output + Constraints updated: `T3` → `Extended`, `T2` → `Standard`, `T1` → `Quick`.
- **`lsa/skills/lsa-sync/SKILL.md`** — Step 7 aggregate-metrics description updated: `T3 feature` → `Extended-flow feature (was T3)`.
- **`lsa/README.md`** — `lsa-specify` row notes the User Verification rename; `lsa-discover` + `lsa-verify` rows replace `T2 / T3` with `Standard / Extended`; LSA's "expression of the credo" reads *"Every LSA User Verification is a decision..."*.
- **`lsa/ARCHITECTURE.md`** — "Tier flow (T1/T2/T3)" → "Flow types (Quick/Standard/Extended — was T1/T2/T3)"; "tier-selector" → "flow-selector"; OQ6 row in resolved-decisions table; metrics archive path comment.
- **`lsa/.claude-plugin/plugin.json` `description`** — "human gates" → "human User Verifications"; "Tier-aware (T1/T2/T3) via core/tier-selector" → "Flow-aware (Quick/Standard/Extended — renamed from T1/T2/T3 in lsa v0.6.2) via core/flow-selector".

### Cross-spec updates (active files only)
- **`.lsa/VISION.md`** — §3 directory diagram (`tier-selector` → `flow-selector` slot); §3 prose ("Core rules are always-on; flows govern workflow"); §3 always-on-vs-on-demand resolution; §4 tier-table + worked-examples table renamed; §7 open-decisions "Tier boundaries" → "Flow boundaries"; §2 sub-principle 2a + §6 Adjust #1 RESOLVED cross-cite Gate 2 → User Verification 2; Changelog gains v0.7 + v0.8 entries.
- **`.lsa/main.spec.md`** — module index version bumps + cross-module-contract `tier-selector` → `flow-selector`.
- **`.lsa/modules/core/spec.md`** — `core/tier-selector` row + `core/CLAUDE.md` invariants citation updated.
- **`.lsa/modules/lsa/spec.md`** — `core/tier-selector` dependency + `lsa-specify Gate 2` invariants → `lsa-specify User Verification 2`; metrics-table T3 annotations + lsa v0.6.2 version bump.
- **`.lsa/standards/testing.md`** — `core/tier-selector` reference + T3 annotation.
- **`.lsa/metrics.md`** — header line: `archived T3 feature` → `archived Extended-flow feature (was T3)`.
- **`.lsa/roadmap.md`** — both rename rows marked `shipped — lsa v0.6.2`; Recently merged gains the Bundle B entry; row 11 (Diagonal cross-artifact analysis row) + Tech Picture §3 updated to use `User Verification 2` with back-link to the old `Gate 2` name.
- **Repo root** — `CLAUDE.md` + `README.md` + `CONTRIBUTING.md` reference `core/flow-selector` and `Quick / Standard / Extended`.

### Notes
- **Breaking surface change, treated as patch** — same rationale as `core` v0.5.2 (sibling patch): pre-1.0 SemVer leaves this to maintainer discretion, and there are no external consumers of `/lsa:specify`'s `Gate N` literals.
- **Historical files left as-is.** Past entries in `core/CHANGELOG.md` / `lsa/CHANGELOG.md` (entries before 0.5.2 / 0.6.2) and every file under `.lsa/archive/**/` keep their original `Gate N` / `T1/T2/T3` / `tier-selector` wording. The new entries (and the renamed surface) note the rename so historical lookup still resolves. `.lsa/plans/2026-05-20-*.md` files are pre-merge plans — also untouched.
- **Sibling core patch** — `core` v0.5.2 in the same Bundle B PR renames the `tier-selector` skill directory + slug.

## [0.6.1] — 2026-05-22

Gate-prompt voice patch. Applies `core/output` Rule 5 (Concrete — *prompt voice*) inside the user-facing pickers of `lsa-specify` / `lsa-plan` / `lsa-init` so the picker question names the feature subject (e.g., *"Approve the requirements for `<feature-name>`?"*) instead of meta-jargon (*"Approve Gate 1?"*, *"Approve F3?"*, *"Approve epic decomposition?"*). Per `.lsa/roadmap.md` row *"LSA gate prompts must be concrete (no IDs, no jargon, must-decide only)"* (Must priority).

### Changed
- `lsa/skills/lsa-specify/SKILL.md` Step 2 (clarification) — Present block adds an explicit **Prompt voice** scaffold citing `core/output` Rule 5: picker question names the feature; option labels name the next outcome; never render `[a]/[b]/[c]` text blocks when the picker is available (per `core/CLAUDE.md` operational checkpoint #1).
- `lsa/skills/lsa-specify/SKILL.md` Step 4 (Gate 1) — Present block adds the same scaffold; explicit rule that `F<n>` / `NF<n>` / `AC<n>` IDs stay in `requirements.md`, not in the picker question.
- `lsa/skills/lsa-specify/SKILL.md` Step 5 (Gate 2) — Present block adds the same scaffold; failing-row pickers (Rule 6 decision blocks for `✗` diagonal rows) cite the two artifact lines in conflict, not the row number.
- `lsa/skills/lsa-specify/SKILL.md` Step 6 (Gate 3) — Present block adds the same scaffold; picker question is *"Final approval — start implementation planning for `<feature-name>`?"*.
- `lsa/skills/lsa-plan/SKILL.md` Step 5 (human review) — Present block adds the scaffold; picker question names the epic count and feature; `epic decomposition` reserved for skill body.
- `lsa/skills/lsa-init/SKILL.md` Step 2 (brownfield) — Present block adds the scaffold; picker question names the project subject; `brownfield` reserved for skill body.

### Notes
- **Cosmetic on the SKILL.md side, behavioral on the user-facing side.** The Gate names, the Hard Confirm gates, and the trace predicates are unchanged. Only the user-facing picker text is normalized.
- **Depends on `core` v0.5.1** (sibling patch in same Bundle A PR) — that patch elevates the substrate-native picker rule and screen-budget to always-on, which this patch's `core/CLAUDE.md` operational checkpoint #1 citation relies on.
- Sibling rename PRs (Gate N → User Verification; T1/T2/T3 → Flow) land in Bundle B.

## [0.6.0] — 2026-05-21

EARS + journey-shape AC discipline. Tightens `lsa-specify` Gate 2 along two axes (EARS pattern conformance + journey-shape) and extends `lsa-verify` with dual trace predicates sourced from a new `**Covers:**` line in `lsa-plan`'s epic template. Per `.lsa/archive/2026-05-21-ears-journey-shape-ac/`.

### Added
- **`lsa-specify` Gate 2 — two new diagonal rows.** Row **1a** (EARS-pattern) checks each AC matches one of the five EARS patterns per `.lsa/VISION.md:201`. Row **1b** (Journey-shape) checks each AC describes a user-observable behavior at the user/system boundary per `.lsa/VISION.md` §2 sub-principle 2a. `✗` rows surface as Rule 6 decision blocks via the existing failing-row render at `lsa/skills/lsa-specify/SKILL.md:165-180`.
- **`lsa-specify` Gate 1 template — AC sub-block in EARS form.** Template at `lsa/skills/lsa-specify/SKILL.md:48-80` cites `.lsa/VISION.md` §2 sub-principle 2a (journey-shape) and `:201` (EARS patterns) inline so the agent reads the rule before authoring.
- **`lsa-plan` epic template — `**Covers:**` line.** New line under each epic's `### Scope` citing requirement IDs (`F<n>`, `NF<n>`, `AC<n>`) the epic implements. Parallel to the existing `**Covers:**` on `test-suites.md` Journeys. Sourced by `lsa-verify` trace predicates.
- **`lsa-plan` self-verification — AC-coverage row.** New row checking every AC in `requirements.md` appears in at least one epic's `**Covers:**`.
- **`lsa-verify` — orphan-diff predicate (broad).** Every non-trivial diff hunk must have an epic in `tasks.md` whose `### Scope` covers the hunk and whose `**Covers:**` cites ≥1 requirement ID. FAIL: `<artifact-file>:<line> has no requirement trace`. Mechanical hunks (whitespace, rename, formatting) are filtered before this check. Replaces the prior loose trace rule.
- **`lsa-verify` — orphan-AC predicate (narrow).** Every AC ID in feature `requirements.md` § Acceptance Criteria must be cited by ≥1 epic's `**Covers:**`. FAIL: `requirements.md:<AC-line> has no covering implementation`. Enforces behavior-coverage strictness.
- **`.lsa/VISION.md` §2 sub-principle 2a.** *"Acceptance criteria are journey-shaped"* — the standing principle that operationalizes principle 2's *"code traces to specs"* clause at the AC level. Authored via `lsa-revise-constitution`.
- **`.lsa/VISION.md` §6 Adjust #1 RESOLVED marker.** Records the EARS adjust as adopted, parallel to the §6 Adjust #4 RESOLVED marker at `.lsa/VISION.md:237`. Authored via `lsa-revise-constitution`.
- **`.lsa/modules/lsa/spec.md` § Invariants** — new bullet documenting the Gate 2 EARS + journey-shape rows, the epic `**Covers:**` line, and the `lsa-verify` dual trace predicates. Parallel to the diagonal-coverage invariant at line 34.

### Changed
- **`lsa-verify` Scope checklist** — replaced the prior loose "Every change traces to a requirement in `requirements.md`" rule (which checked file-name presence in an AC) with the dual orphan-diff + orphan-AC predicates above. Mechanical-hunk exemption preserved. The Constraint *"FAIL on any untraced change"* updated to cite the orphan-diff predicate.
- **`.lsa/main.spec.md`** — module index `lsa` row v0.5.0 → v0.6.0.
- **`.lsa/modules/lsa/spec.md`** — plugin manifest tag v0.5.0 → v0.6.0; *"Currently v0.5.0"* → *"Currently v0.6.0"*.
- **`.lsa/roadmap.md`** — row "EARS notation in AC block" status → `shipped — lsa v0.6.0`. Row "Diagonal cross-artifact analysis at `lsa-specify` Gate 2" status → `shipped — lsa v0.5.0` (reconciles stale row from prior merge). Recently merged gains rows for v0.6.0 and v0.5.0.
- **`lsa/README.md` skill table** — `lsa-specify` row updated from "4-row" → "6-row" diagonal table (5 with contract skipped); `lsa-plan` row mentions the epic `**Covers:**` field; `lsa-verify` row mentions the dual orphan-diff + orphan-AC predicates.

### Notes
- **Forward-only.** No `requirements.md` under `.lsa/archive/**/` is modified. Existing archived specs keep their GWT-style ACs; the rule applies only to new specs authored after merge.
- **Broadened `**Covers:**` from AC-only to any requirement ID.** F4 + F8 of the feature `requirements.md` were originally AC-only; broadened during planning to align with `.lsa/main.spec.md` NFR2 *"every artifact change traces to a spec requirement"* (constitution / CHANGELOG / version edits trace to F/NF requirements, not behavioral ACs). The dual predicate split (broad orphan-diff per AC3, narrow orphan-AC per AC4) keeps behavior coverage strict.
- **Vision-edit routing.** Per the feature's Gate 3 decision, the `.lsa/VISION.md` edits (§2 sub-principle 2a + §6 Adjust #1 RESOLVED marker) were authored via `lsa-revise-constitution`, then bundled into this feature commit per the precedent set by `feature/diagonal-cross-artifact-analysis` (commit `7235e17`).
- Corresponds to Vision v0.7.

## [0.5.0] — 2026-05-21

Diagonal cross-artifact analysis at `lsa-specify` Gate 2 — extends the existing AC→Journey coverage check to a 4-row diagonal coverage table (AC→Journey, Journey→Design, Design→Contract, Contract→test-suites). Failing rows surface as Rule 6 decision blocks. Per the 2026-05-20 Tech Picture adoption (`.lsa/roadmap.md:64-75`).

### Added
- **`lsa-specify` Gate 2 — diagonal coverage.** Step 5 of `lsa/skills/lsa-specify/SKILL.md` now renders a 4-row coverage table after the AC-coverage check, citing every compared artifact pair in `<file>:<line> ↔ <file>:<line>` format. Failing rows surface as Rule 6 decision blocks; when multiple rows fail, all surface together in a single multi-question `AskUserQuestion` (batched). Approval blocks until every `✗` row resolves. When Gate 1 contract-trigger = NO, the two contract-touching rows render as `N/A — contract skipped`. Source: `.lsa/archive/2026-05-21-diagonal-cross-artifact-analysis/`.
- **`.lsa/modules/lsa/spec.md` § Invariants** — new bullet documenting the Gate 2 diagonal coverage discipline. Cites SKILL.md:154 + the archived feature spec.

### Changed
- **`lsa/README.md` skill table** — `lsa-specify` row description corrected from stale "hard/soft confirm gates per file" to "three bundled hard-confirm gates; Gate 2 renders a 4-row diagonal cross-artifact coverage check". Aligns with the audit-C gate collapse landed in v0.4.0.
- **`.lsa/modules/lsa/spec.md`** — version references refreshed: plugin manifest tag v0.2.1 → v0.5.0; "Currently v0.2.1" → "Currently v0.5.0"; core dependency floor v0.2.0 → v0.4.0 (when `core/output` was added and cited from every LSA skill).
- **`.lsa/main.spec.md`** — module index `lsa` row v0.2.0 → v0.5.0. Closes the version-drift gap that opened during the credo rollout (PRs that bumped lsa to v0.4.0 did not update main.spec.md).

## [0.4.0] — 2026-05-21

Credo rollout PR 2 — every LSA skill (+ `core/tier-selector`) adopts a component-specific output format that satisfies the four golden rules in `core/output` (structured, minimal, formatted, sourced). Builds on `core` v0.4.0 (PR 1). Per [`.lsa/plans/2026-05-20-credo-rollout-plan.md`](../.lsa/plans/2026-05-20-credo-rollout-plan.md).

### Added
- `lsa/README.md` — *"LSA's expression of the credo"* section right after the H1 with the user's verbatim line *"LSA doesn't automate your thinking — it makes you own it."* and links to `core/CLAUDE.md` + Rule 0.
- `lsa/ARCHITECTURE.md` §1 — new sub-section *"How `core/output` constrains LSA"* naming the four mechanical consequences (tabular discovery output; 7→3 gate collapse in `lsa-specify`; verdict-first verify reports; `AskUserQuestion` for every decision).

### Changed
- **`lsa-specify` gates 7 → 3.** Hard-confirm stops collapse to **Gate 1** (`requirements.md` + AC + contract-trigger, bundled), **Gate 2** (`test-suites.md` + `contract.yaml` + `design.md`, bundled), **Gate 3** (final integration). The contract-trigger check is folded into Gate 1 (no longer a separate human prompt). Step count drops from 9 to 6.
- **`lsa-discover` Output is a 3-row table** (Module / Change / Acceptance) instead of a single-paragraph context summary. Step 2 questions (b) and (c) shift to assume-then-override (agent proposes 2 candidate framings; human picks).
- **`lsa-verify` report is verdict-first** with three explicit variants (PASS / FAIL / PASS WITH WARNINGS). Metadata (date / branch / mode) moves below the verdict. Issues table is failures only.
- **All 8 LSA skills + `core/tier-selector`** — Constraints sections gain one citation line: *"Outputs follow [`core/output`](path) golden rules."* No restatement of format mechanics inside any skill.
- **Every decision-bearing prompt** in every skill describes data + decision options + outcomes; format defers to `core/output`; in Claude Code, `AskUserQuestion` is the canonical primitive (per `.lsa/VISION.md` §2 principle 9). The text decision-block is the fallback for plain-text rendering.
- `lsa/README.md` "Naming note" — `ground-rules` description updated 4 → 6 content rules; adds `core/output` as the format-discipline peer skill.
- `lsa/ARCHITECTURE.md` Version bumped from 0.2.1 to 0.4.0; Status line updated.

### Notes
- `lsa/knowledge/conventions.md` is **unchanged.** The audit-B D2 proposal to add a *"Prompt shape"* section was superseded by audit-C (output discipline lives in `core/output`; LSA skills cite it directly, not via a conventions.md alias).
- The S1–S17 component-specific output formats in the credo plan's Layer 1.5 stay as illustrative reference, not as embedded templates inside skill bodies (audit-C tight-pattern revision — each skill describes data + decisions, defers format to `core/output`).
- **Behavior change — `contract.yaml` + `design.md` Soft → Hard Confirm in `lsa-specify`.** Pre-PR-2, Steps 7 (`contract.yaml`) and 8 (`design.md`) were Soft Confirm (human may delegate corrections inline). After the 7→3 gate collapse, both live inside Gate 2 which is Hard Confirm. The Soft type still exists in `conventions.md` for other skills' use; `lsa-specify` no longer uses Soft. (Surfaced by Round-3 self-review finding L2.)
- **Pre-existing path-fix in `lsa-init` Constraints.** The cite to `core/skills/ground-rules/SKILL.md` was at the wrong relative depth (`../../core/skills/ground-rules/` — pointed at `lsa/core/skills/...` which doesn't exist). Repaired to `../../../core/skills/ground-rules/` during the Constraints edit. Pre-existing bug, not a credo-rollout regression. (Surfaced by Round-3 self-review finding L1.)
- Corresponds to Vision v0.6.

## [0.3.1] — 2026-05-20

KISS surgical edits. Per [`.lsa/plans/2026-05-20-simplification-refactor-plan.md`](../.lsa/plans/2026-05-20-simplification-refactor-plan.md) PR 3.

### Changed
- `lsa-init/SKILL.md` Step 2 — replaced the redundant human question *"Greenfield or brownfield?"* with mechanical detection: *"If `${specs_root}/modules/` is empty AND `.lsa.yaml: modules.*` contains no `artifact_paths`, the mode is greenfield; otherwise brownfield. Print the determination and ask the human to confirm."* The gate is preserved; the question is no longer wasted on something derivable from repo state.
- `lsa-plan/SKILL.md` Step 2 — added the missing rationale for the ≤5 epics ceiling: *"chosen to keep epic-level human review tractable; if the work cannot be decomposed in five, the feature is too large and should be split at the spec level rather than at the plan level"*. Closes the magic-number gap surfaced in the simplification round-2 review.
- `lsa-specify/SKILL.md` — split contract trigger out of Step 4 into its own Step 5 *"Determine contract requirement"* so each step has one Goal/Output (round-2 finding). Renumbered subsequent steps: old Step 5 (`test-suites.md`) → 6, old 6 (`contract.yaml`) → 7, old 7 (`design.md`) → 8, old 8 (Final review) → 9. Updated cross-references inside the file (spec-tree comment, contract-step reference, Amending section).

### Removed
- Pre-Feature Checklist orphan — already deleted in 0.2.1 when `lsa/ARCHITECTURE.md` §5 (Workflow Phases) was pruned. Listed here for traceability against the round-2 finding.

### Notes
- Kept `.lsa.yaml: mode: mixed` as-is per the plan ("marginal complexity, removing would break an existing config surface").
- No behavioral semantics changed by these edits. The contract trigger still gates `contract.yaml` (now via Step 5 → Step 7); the ≤5 epics rule still escalates (now with the why); greenfield/brownfield still gates with explicit confirm (now mechanically pre-filled).

## [0.3.0] — 2026-05-20

Knowledge-vs-Actor boundary tightening across all eight LSA skills. New `lsa/knowledge/conventions.md` Knowledge surface owns cross-skill conventions formerly duplicated in skill bodies. Per [`.lsa/plans/2026-05-20-simplification-refactor-plan.md`](../.lsa/plans/2026-05-20-simplification-refactor-plan.md) PR 2.

### Added
- `lsa/knowledge/conventions.md` — single Knowledge file holding (1) `.lsa.yaml` defaults, (2) the Read Protocol, (3) Hard / Soft Confirm gate type definitions, (4) the unified trace-tag format `<!-- <action>: <source> YYYY-MM-DD -->`. Each section was formerly restated in 6–7 skill bodies.
- `lsa/knowledge/**/*.md` added to `.lsa.yaml: modules.lsa.artifact_paths` so future Knowledge files are tracked by `lsa-verify` doc-mode.

### Changed
- All 8 LSA skill bodies (`lsa-init`, `lsa-discover`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-reconcile`, `lsa-revise-constitution`) — Step 1 read prose now cites `../knowledge/conventions.md` §"Read protocol" instead of inlining the `.lsa.yaml` defaults block + per-skill read protocol. Inputs cite conventions for the defaults.
- `lsa-specify/SKILL.md` — "Confirm gate definitions" section deleted; cited `../knowledge/conventions.md` §"Confirm gate types" instead.
- `lsa-sync/SKILL.md` — trace-tag format changed from `<!-- added: [feature-name] [YYYY-MM-DD] -->` to `<!-- added: <feature-name> YYYY-MM-DD -->` (unified shape per conventions.md).
- `lsa-reconcile/SKILL.md` — trace-tag format changed from `<!-- reconciled: YYYY-MM-DD -->` (no source slot) to `<!-- reconciled: drift YYYY-MM-DD -->` (with source slot, per conventions.md). Closes a round-2 finding that `reconciled` was the outlier.
- `lsa-revise-constitution/SKILL.md` — trace-tag format changed from `<!-- revised: [feature-name] [YYYY-MM-DD] -->` to `<!-- revised: <feature-name> YYYY-MM-DD -->` (unified shape).
- 6 LSA skills (`lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`) — removed the redundant `[assumption: <why>]` / `[cannot verify]` Constraints line from each. The marker convention is owned by `core/skills/ground-rules/SKILL.md` Rule 1; LSA skills cite it instead of restating.
- All 8 LSA skill frontmatter `description:` fields trimmed to ≤2 sentences (verb + trigger phrases). Implementation detail moved to skill body. Trigger phrases preserved so description-match triggering is unaffected.

### Notes
- No behavioral semantics changed. Hard/Soft Confirm gates fire identically; tag-format changes are mechanical and apply only to newly written tags.
- `lsa/.lsa.yaml` for this repo now includes `lsa/knowledge/**/*.md` under `modules.lsa.artifact_paths` so the new Knowledge surface is tracked by `lsa-verify` doc-mode.
- The "tag format change" is non-breaking: historical tags using the old shape (e.g., `<!-- added: [user-auth] [2026-05-15] -->`) remain valid in already-written specs; only new tags use the unified shape. No spec rewrite required.

## [0.2.1] — 2026-05-20

Pure DRY / SRP / KISS docs prune. No skill behavior change. Per [`.lsa/plans/2026-05-20-simplification-refactor-plan.md`](../.lsa/plans/2026-05-20-simplification-refactor-plan.md) PR 1.

### Changed
- `ARCHITECTURE.md` — shrunk ~540 → ~145 lines. Kept §1 Purpose, §2 Directory Structure, §3 `.lsa.yaml` configuration, §4 Branch Management, §5 Resolved Decisions. Deleted §2 (8 first principles — duplicated `.lsa/VISION.md` §2), §4.1–§4.9 component definitions (duplicated each `SKILL.md`), §5 Workflow Phases (duplicated each `SKILL.md`), §6 Testing Policy (duplicated `.lsa/standards/testing.md`), §7 Fact-Check Policy (duplicated `core/skills/ground-rules/SKILL.md`), §8 Constitution Revision (duplicated `lsa-revise-constitution/SKILL.md`), §10 Skills Index (duplicated `README.md`). Each deleted section's content survives at its canonical source.
- `README.md` — "Naming note" no longer lists `agents.md` (file deleted).
- `lsa/skills/lsa-init/SKILL.md` — greenfield template no longer includes `standards/agents.md` (mechanical sweep; file deleted).
- `lsa/skills/lsa-revise-constitution/SKILL.md` — Step 1 read list no longer includes `${specs_root}/standards/agents.md` (mechanical sweep; file deleted).

### Removed
- *(repo-level, not plugin-level, but listed here for traceability)* `.lsa/standards/agents.md` deleted. The file self-declared as a digest of upstream sources; every section now lives at its canonical home (`.lsa/VISION.md` §2 for the eight first principles; `core/skills/ground-rules/SKILL.md` for the marker convention; `lsa/skills/lsa-specify/SKILL.md` for the gate types; `.lsa/VISION.md:124` for the boundary signals).

### Notes
- Out of scope for this patch: skill body deduplication (PR 2), KISS surgical edits (PR 3).
- Module specs at `.lsa/modules/{core,lsa}/spec.md` were shrunk in the same change-set (not part of this plugin's CHANGELOG; tracked in the repo-level refactor plan).
- Repo `/CLAUDE.md` was shrunk in the same change-set; the always-on rules block now points to `core/CLAUDE.md` as the canonical source instead of restating it.

## [0.2.0] — 2026-05-20

Closes the seven Vision-alignment gaps between v0.1.1 and `.lsa/VISION.md` v0.4. Per `.lsa/2026-05-20-lsa-v0.2.0-design.md`.

### Added
- `lsa/skills/lsa-discover/SKILL.md` — light three-question discovery probe at the start of every T2 and T3 task (Phase 0). T2 oral; T3 emits scratch `discovery.md` consumed by `lsa-specify`. Design §4.3.
- `lsa/skills/lsa-reconcile/SKILL.md` — absorbs direct artifact edits into module specs (Level 2.5, `.lsa/VISION.md:138`). Per-module hard confirm; reverse-sync in-place (class a) or append (class b); both tagged `<!-- reconciled: YYYY-MM-DD -->`. Updates `.lsa-sync-state.json` on confirm. Design §4.4.
- `lsa/hooks/hooks.json` + `lsa/hooks/session-start-drift-check.sh` — SessionStart drift-warning hook (matcher `startup`, type `command`, timeout 10s). Diffs `artifact_paths` against `.lsa-sync-state.json`'s recorded SHA per module; surfaces a one-line notice when drift is detected. Design §7.
- `.lsa.yaml` loader across every reshaped skill — `constitution`, `specs_root`, `mode` (code / docs / mixed), and per-module `{spec, artifact_paths}`. Defaults preserve v0.1.1 behavior when the file is absent. Design §6.
- Doc-mode in `lsa-verify` — when `.lsa.yaml: mode` is `docs` or `mixed`, verify diffs each module's `artifact_paths` against `main`. Tracing satisfied by (a) feature spec naming the file/dir in an AC, or (b) the diff being wholly mechanical. Design §8.
- `.lsa-sync-state.json` writer in `lsa-sync` (records HEAD SHA + ISO timestamp per touched module; preserves untouched modules' entries). Consumed by `lsa-reconcile` and the SessionStart hook. Design §7.
- Per-feature `metrics.md` writer in `lsa-verify` — emitted only on clean T3 PASS to `${specs_root}/archive/<feature>/metrics.md`; pass/fail counts for accuracy / facts-with-sources / only-required-changes. Design §9.
- Aggregate metrics row appended to `${specs_root}/metrics.md` by `lsa-sync` when per-feature `metrics.md` exists.
- Dependency note on `core` v0.2.0 (uses `core/tier-selector` upstream of T2/T3 paths). Carried in plugin description.

### Changed
- All six existing skills (`lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`) reshaped to the `core/actor-template` five-section shape: Goal / Input / Steps / Output / Constraints (replacing the historical `## Step 1 — ...`, `## Step 2 — ...` headers). Step content preserved as numbered sub-items under a single `## Steps` block, with each Step now stating its observable result. Design §5.
- Hardcoded `/CLAUDE.md` and `/specs/...` paths replaced with `${constitution}` and `${specs_root}/...` reads from `.lsa.yaml` (with defaults). Design §5.
- `lsa-init` brownfield mode scans `modules.*.artifact_paths` from `.lsa.yaml` (falling back to `/src/` when the file is absent).
- Marker convention swept to lowercase `[assumption: <why>]` and `[cannot verify]` across all 8 skills + `ARCHITECTURE.md` §7. Matches `core/skills/ground-rules/SKILL.md`. The historical `[ASSUMPTION: ...]` (uppercase) and `[INFERRED — verify]` markers are removed.
- `ARCHITECTURE.md` — major update: new §4.8/§4.9 (lsa-discover, lsa-reconcile), §4.10 (`.lsa.yaml`), Phase 0 + ad-hoc Phase Reconcile in §5, Knowledge-vs-Actor note in §7, OQ5–OQ8 in §11. Status line bumped to 0.2.0.
- `README.md` — skills table now lists all 8 skills; new "Configuration" section documents `.lsa.yaml`.
- Plugin description in `lsa/.claude-plugin/plugin.json` extended to mention all 8 skills + tier-awareness + `.lsa.yaml` configurability.

### Notes
- `.lsa.yaml` schema version is informational (`# Schema version: 1`); a future LSA major (1.x.y) will introduce a hard `schema_version: N` key if a breaking schema change is needed. v0.2.0 additions remain non-breaking.
- Claude Code's plugin manifest still does not expose a `dependencies` field. The LSA→Core dependency stays prose-only in `README.md` and `plugin.json` description (`lsa/CHANGELOG.md:21` carries forward).
- `core/registry` (the lazy-load map-not-territory skill) stays deferred — now to core v0.3.0 — per `.lsa/VISION.md:177`.

## [0.1.1] — 2026-05-20

### Changed
- `ARCHITECTURE.md` §2 P4 and §7 Fact-Check Policy now defer to [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) rather than restating its content. Eliminates a DRY violation against the marketplace's "core + packs" architecture (`.lsa/VISION.md` §3).
- `README.md` adds a **Depends on** section: install `core` before `lsa`.
- Plugin manifest `description` notes the dependency on `core`.

### Notes
- Claude Code's plugin manifest does not (as of writing) expose a `dependencies` field. The LSA→Core dependency is prose-only in `README.md` and `plugin.json` `description`. If a manifest field becomes available, adopt it in a future patch.

## [0.1.0] — 2026-05-20

First release. Migrates the six pre-vision LSA skill drafts into a proper Claude Code plugin.

### Added
- Six skills: `lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`. Each enforces a phase with explicit human gates per `ARCHITECTURE.md` §5.
- `ARCHITECTURE.md` — the LSA methodology document migrated from pre-v1 `LSA/LSA-ARCHITECTURE.md`.
- Plugin manifest at v0.1.0.

### Changed
- Migrated from `LSA/` (flat layout, repo root) to `lsa/` (plugin layout) per the marketplace's "core + packs" architecture (`.lsa/VISION.md` §3).
- Renamed LSA-internal `/specs/ground-rules/` → `/specs/standards/` (across 4 files) to remove name collision with Core's `ground-rules` discipline skill.
- `ARCHITECTURE.md` status updated from "Draft — Pending stress test" to "0.1.0 — Installable; pending stress test on actual project use".

[0.1.0]: https://github.com/NVZver/claude-marketplace/releases/tag/lsa-v0.1.0
