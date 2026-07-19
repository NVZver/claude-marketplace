# Marketplace AI-Engineering Audit Report

**Status:** preparation only — recommendations gathered, not implemented  
**Date:** 2026-07-19  
**Branch context:** `feature/deterministic-work-scripted` (report saved for later fix work)  
**Canvas twin:** `/Users/nvz/.cursor/projects/Users-nvz-github-claude-marketplace/canvases/marketplace-ai-engineering-audit.canvas.tsx`  
**Discover enrichment:** [`discover.md`](./discover.md) (concrete quotes + suggested improvements)  
**Adversarial critique:** [`critique.md`](./critique.md) (two harsh passes — use before implementing)

> This file freezes the audit findings **as delivered**. Later sessions should start from here + `discover.md` when implementing fixes. Do not treat this file as a shipped change to marketplace prompts.

---

## Executive verdict

The project is ahead on deterministic structural gates and selective loading, but its control plane is still prose-enforced. The next order-of-magnitude gain is not “more scripts” alone: compile smaller prompts, type every agent boundary, enforce portable helper paths, and escalate model capability only from observable risk or failure.

**First blocker (portability):** manager prompts require root-level scripts that declare themselves “Repo-internal — NOT shipped”.

**Highest-leverage program (do later, in order):**
1. Ship plugin-local helpers.
2. Compile task-scoped Prompt ABI envelopes.
3. Move traces into telemetry with an evidence ledger.
4. Type every agent boundary.
5. Finish pitch/feature slicing.
6. Add adaptive routing and cross-tier evaluation.

---

## Measured wins already shipped

| Operation | Before | After | Observed reduction | Source |
|---|---:|---:|---:|---|
| Constitution read | ~8,197 tok | ~423 tok | ~19.4× less | `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md:80-99` |
| Roadmap sequencing | ~22,958 tok | ~176 tok | ~130× less | `README.md:16-27` |
| Single roadmap item | ~22,958 tok | ~70 tok | ~328× less | `README.md:16-27` |
| Roadmap hygiene | ~22,958 tok | ~185 tok | ~124× less | `README.md:16-27` |

Token method: bytes÷4 (repository convention). Future savings in the ranked roadmap below are **estimates** until runtime prompt captures exist.

---

## Ranked recommendations (P0 / P1)

### 01 · P0 — Ship the scripts the prompts require

| Field | Value |
|---|---|
| **Finding** | Manager actors mandate root-level roadmap scripts, but the marketplace packages only `./manager` and the scripts declare themselves repo-internal. |
| **Action** | Move consumer-facing helpers under each plugin, invoke them through `CLAUDE_PLUGIN_ROOT`, and test an install in an empty fixture repository. |
| **Small models** | Prevents silent fallback to whole-file reads and missing-command failures. |
| **Top tier** | Preserves selective-load savings instead of spending premium inference on recovery. |
| **Validation** | Install fixture: every mandatory helper resolves without repository-root scripts. |
| **Impact / Effort / Risk** | Critical / Medium / Path migration can break source-repo callers; retain a compatibility shim for one release. |
| **Source** | `.claude-plugin/marketplace.json:12-18`; `scripts/roadmap-query.sh:4-7`; `manager/skills/next/SKILL.md:24` |
| **Quote** | `"source": "./manager"` · `"Repo-internal — NOT shipped"` · `"Run the roadmap-row extractor ... bash scripts/roadmap-row.sh"` |

### 02 · P0 — Compile actor-specific prompt envelopes

| Field | Value |
|---|---|
| **Finding** | The always-on card says to load one matched full skill, while that loaded skill can add mandatory trace, per-claim quote, gate, and delivery contracts to the task context. |
| **Action** | Generate a task-scoped Prompt ABI: goal, allowed inputs, applicable invariants, decision fields, output schema, tool budget, and escalation rules. Keep rationale and examples on demand. |
| **Small models** | Reduces lost-in-the-middle failures and conflicting-instruction load. |
| **Top tier** | Leaves context for repository reasoning instead of compliance ceremony. |
| **Validation** | Transitive prompt-budget test per actor plus before/after conformance probes. |
| **Impact / Effort / Risk** | Critical / High / A compiler can omit a load-bearing rule; manifest coverage must fail closed. |
| **Source** | `core/CLAUDE.md:39-43`; `.lsa/VISION.md:62`; `core/skills/output/SKILL.md:20-25` |
| **Quote** | `"load only the file the current step acts on"` · `"Context is a budget"` · `"Every factual claim carries source + exact quote"` · `"One line per loaded file"` |

### 03 · P0 — Separate telemetry from user output

| Field | Value |
|---|---|
| **Finding** | Mandatory traces and exact quotes on every factual clause consume output tokens and directly collide with actors that must emit zero bytes. |
| **Action** | Put file-load traces into debug telemetry. Replace per-clause quote repetition with an evidence ledger: stable evidence IDs in working context, expanded quotes only for decisions, disputed claims, and completion gates. |
| **Small models** | Removes instruction collisions and copy-heavy output. |
| **Top tier** | Creates room for synthesis, uncertainty, and trade-off analysis. |
| **Validation** | A no-signal observer fixture must emit exactly zero bytes; citation expansion must retain source and quote integrity. |
| **Impact / Effort / Risk** | Critical / Medium / Over-compression can weaken fact-grounding; the ledger must preserve full quotes. |
| **Source** | `core/skills/output/SKILL.md:20-25`; `observer/skills/verify-checkpoint/SKILL.md:52-55,78-86` |
| **Quote** | `"every factual claim carries source + exact quote"` · `"zero output"` · example: `"cycle 1 — no checkpoint signal"` |

### 04 · P0 — Replace visible chain-of-thought with decision records

| Field | Value |
|---|---|
| **Finding** | Several actors explicitly request visible chain-of-thought, producing variable, verbose output without improving the contract. |
| **Action** | Standardize a concise decision record: observed signals, cited evidence, selected option, confidence, unresolved fork, next action. |
| **Small models** | Bounds output and makes classification reproducible. |
| **Top tier** | Allows deep private reasoning while exposing only auditable conclusions. |
| **Validation** | Lint rejects “visible chain-of-thought”; snapshots require the decision-record fields. |
| **Impact / Effort / Risk** | High / Low / Too little rationale can hide a bad choice; retain evidence, uncertainty, and alternatives when material. |
| **Source** | `core/skills/flow-selector/SKILL.md:37-39`; `manager/agents/product-manager.md:25-27` |
| **Quote** | `"State the chain-of-thought"` · `"Reason (visible chain-of-thought)"` |

### 05 · P0 — Make every agent boundary typed

| Field | Value |
|---|---|
| **Finding** | Manager agents return multi-mode full-content payloads in prose. [Audit inference] Observer checkpoint state is a four-field Markdown contract with an externally supplied ephemeral path, while the actor names no machine validator. |
| **Action** | Use discriminated JSON payloads and versioned state records. Validate before continuation. Store large artifacts in scratch files and pass pointer + summary + pending gates. |
| **Small models** | Reduces omitted gates, mode confusion, and malformed continuation state. |
| **Top tier** | Enables safe parallel orchestration and machine-rendered gates. |
| **Validation** | JSON Schema fixtures for every intent, rejection, continuation, stale state, and cleanup path. |
| **Impact / Effort / Risk** | High / Medium / Rigid schemas can suppress useful nuance; allow a bounded evidence/notes field. |
| **Source** | `manager/agents/product-manager.md:32-39`; `observer/skills/verify-checkpoint/SKILL.md:24-37`; `.lsa/standards/code.md:67-78` |
| **Quote** | `"return its full content in the payload"` · `"Its required fields"` · `"pointer + a decision-relevant summary + any pending gates"` |

### 06 · P1 — Finish selective loading: pitches and feature packs

| Field | Value |
|---|---|
| **Finding** | Roadmap slicing is measured and effective, but Mode 1 still reads every candidate pitch and discovery scoping remains advisory. |
| **Action** | Add pitch-outline and feature-pack resolvers with bounded stdout. Read full bodies only after selection or when the compact slice reports an unresolved dependency. |
| **Small models** | Protects narrow context windows from corpus fan-out. |
| **Top tier** | Eliminates expensive but low-value full reads. |
| **Validation** | Golden fixtures plus byte caps and no-whole-file-read wiring tests. |
| **Impact / Effort / Risk** | High / Medium / Slices can hide dependency clues; expose a deterministic full-read fallback reason. |
| **Source** | `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md:150-166`; `manager/agents/project-manager.md:35-40` |
| **Quote** | `"Pitch corpus ≈ 48.6k tok"` · `"For each candidate item, read its linked pitch file"` · `"~31× over-read"` |

### 07 · P1 — Finish inline manager orchestration

| Field | Value |
|---|---|
| **Finding** | LSA correctly reuses one context for discover → specify → verify, while manager shape, decompose, next, and check still dispatch fresh contexts. |
| **Action** | Inline non-isolation manager stages. Preserve fresh contexts only for external implementation, independent grading, and worktree fan-out. |
| **Small models** | Avoids repeated card/config/file loading on Pro-tier flows. |
| **Top tier** | Stops spending top-tier tokens on orchestration round-trips. |
| **Validation** | Dispatch-count benchmark: shape → decompose → discover should cross no boundary before implementation. |
| **Impact / Effort / Risk** | High / Medium / Inlining can blur isolation; preserve separate contexts for graders and worktree writers. |
| **Source** | `lsa/agents/orchestrator.md:29-36`; `.lsa/standards/code.md:57-65`; `manager/skills/shape/SKILL.md:26` |
| **Quote** | `"carry facts forward"` · `"Everything else ... runs inline"` · `"Dispatch product-manager agent"` |

### 08 · P1 — Turn semantic gates into deterministic skeletons

| Field | Value |
|---|---|
| **Finding** | Reconcile builds requirement↔hunk coverage, orphan detection, and reference maps in-model; prompt-review repeats many structural checks already suited to lint. |
| **Action** | Generate coverage skeletons, reference maps, overlap graphs, and prompt-lint findings by script. Keep only semantic attribution and severity with the model. |
| **Small models** | Makes set-difference and completeness checks exact. |
| **Top tier** | Reserves reasoning for whether a hunk satisfies intent, not whether it exists. |
| **Validation** | Fixture diffs must produce exact requirement rows and orphan lists; ambiguous attribution remains explicitly unresolved. |
| **Impact / Effort / Risk** | High / Medium / Regex attribution can create false confidence; scripts produce candidates, never semantic PASS. |
| **Source** | `lsa/skills/reconcile/SKILL.md:31-37`; `lsa/skills/verify/SKILL.md:30`; `prompt-engineer/commands/prompt-review.md:27-42` |
| **Quote** | `"an orphan hunk ... is drift"` · `"resolve it in the codebase"` · `"For each file, check"` |
| **Note (branch state)** | On `feature/deterministic-work-scripted`, `scripts/coverage-skeleton.sh` and reconcile Step 4 wiring already exist as in-flight work — treat as partial progress, not audit-driven completion. |

### 09 · P1 — Route by capability and confidence, not static names

| Field | Value |
|---|---|
| **Finding** | Only three dispatch surfaces read the routing map; routing is static and tier names are substrate-specific. |
| **Action** | Route capability classes: deterministic, bounded judgment, synthesis, safety-critical. Escalate on input size, unresolved forks, schema failure, verifier disagreement, or repeated BLOCK. |
| **Small models** | Keeps bounded work cheap and escalates only after observable failure. |
| **Top tier** | Uses premium reasoning for decomposition, synthesis, and adversarial grading. |
| **Validation** | Resolver matrix: signals × available models × floors × budget, with every route echoed and logged. |
| **Impact / Effort / Risk** | High / Medium / Automatic escalation can create surprise cost; echo routes and enforce a budget ceiling. |
| **Source** | `lsa/knowledge/model-routing.md:31-40,42-57`; `.lsa.yaml:47-50` |
| **Quote** | `"Three surfaces do so today"` · `"Absent or unavailable ⇒ inherit"` |

### 10 · P1 — Build a cross-tier behavioral regression lab

| Field | Value |
|---|---|
| **Finding** | Structural gates are strong, but behavioral probes are manual, Sonnet-only, and execution-as-reasoning remains the core reconcile mechanism. |
| **Action** | Run a small golden corpus across the cheapest supported model and the session model. Record schema validity, decision accuracy, citations, scope creep, tokens, latency, and grader disagreement. |
| **Small models** | Makes “works on small models” a measured release property. |
| **Top tier** | Detects overreach and proves when stronger reasoning changes outcomes. |
| **Validation** | Deterministic harness self-test: fixed stub outputs must yield exact scores, schema verdicts, and routing decisions; live N-run model trials are a separate measurement layer. |
| **Impact / Effort / Risk** | Critical / High / A benchmark can overfit prompt edits; rotate held-out tasks and keep executable gates authoritative. |
| **Source** | `.lsa/standards/testing.md:7-13,50-55`; `observer/skills/verify-checkpoint/SKILL.md:56-59` |
| **Quote** | `"No automated harness in this release"` · `"Behavioral evals ... run on Sonnet"` · `"Run each as reasoning"` |

---

## Five-module surface inventory

| Module | Actors / prompts | Knowledge | Scripts / gates / routing |
|---|---|---|---|
| **core** | Always-on: `core/CLAUDE.md`. Skills: actor-template, doctor, flow-selector, ground-rules, output, reuse-first. | fast-path-source-of-truth.md; output-vocabulary.md | No Agent dispatch. Root lint/digest/gate scripts. Routing: none. |
| **lsa** | Agent: orchestrator. Skills: init, discover, specify, verify, delegate, reconcile, revise-constitution. | CORE.md; conventions.md; migration-instructions-ai.md; model-routing.md; quality-gate-contract.md | Boundaries: delegate, verify-checkpoint, reconcile. SessionStart hook. project-map scripts. Routing: floors + verify-checkpoint→sonnet. |
| **manager** | Agents: product-manager, project-manager. Skills: shape, next, check, decompose, implement. | autonomy-policy, command-naming, epic-decomposition, parallel-dispatch, parallel-rollup, pitch-structure, roadmap-orchestration, role-adaptation, sequencing-heuristics, serialized-merge | Roadmap scripts root-local / NOT shipped. Routing: next→sonnet, check→haiku, implement floored. |
| **prompt-engineer** | Agent: prompt-engineer. Commands: prompt-create, prompt-optimize, prompt-review. | actor-ground-rules.md; quality-checks.md; separation-of-concerns.md | No plugin-local script. Mechanical route reverted. |
| **observer** | Skills: observe, verify-checkpoint. | roles.md; checkpoint note contract in verify-checkpoint | No shipped test runner. verify-checkpoint wired sonnet via lsa:delegate. |

### Executable surfaces

| Class | Paths |
|---|---|
| Aggregate / invariant gates | `scripts/gate.sh`; `lint.sh`; `check-citations.sh`; `check-links.sh`; `check-version-changelog.sh` |
| Selective-load / generation | `build-vision-digest.sh`; `roadmap-row.sh`; `roadmap-query.sh`; `generate-for-cursor.sh` |
| LSA plugin scripts / hook | `lsa/scripts/project-map-build.sh`; `project-map-check.sh`; `hooks/session-start-drift-check.sh`; `hooks/hooks.json` |
| Repo hook | `.claude/hooks/commit-discipline-check.sh` |
| Deterministic regression tests | `scripts/tests/no-wholefile-ledger-read.sh`; `generate-for-cursor-test.sh`; `lsa/scripts/tests/test-project-map.sh` |

### Routing paths (from `lsa/knowledge/model-routing.md`)

| Dispatch surface | Tier today | Boundary status |
|---|---|---|
| manager:shape → product-manager | inherit | Transitional; should inline |
| manager:decompose → project-manager | inherit | Transitional; should inline |
| manager:next → project-manager | sonnet | Wired; fast path has no dispatch |
| manager:check → project-manager | haiku | Wired mechanical hygiene route |
| manager:implement fan-out | inherit | Floored worktree writer |
| lsa:delegate implementer | inherit | Floored external writer |
| lsa:delegate → verify-checkpoint | sonnet | Wired bounded grader |
| lsa:reconcile grader | inherit | Floored independent grader |
| prompt-engineer dispatches | inherit | Mechanical route reverted; no wired key |

---

## Small-model robustness by module (R3)

| Module | Density | Ambiguity | Hidden state | Long-context | Branching | Schema | Error recovery | Deterministic validation |
|---|---|---|---|---|---|---|---|---|
| core | Compact card; matched output expands traces/quotes | Five named flow signals | Flow confirmation between turns | Load one matched skill | Quick/Standard/Extended + override | Markdown pickers | Override/reconsider; doctor one-line fixes | Root lint; triggering manual |
| lsa | Seven stage actors + CORE/knowledge | does·only·all explicit; scenarios as reasoning | Artifacts + checkpoint notes | Inline authoring reuses reads | paired_verify off/async/checkpoint | Markdown specs + coverage table | NOT-GROUNDED blocks; async refuses | gate.sh exact; scenario grading model-side |
| manager | Two agents + five skills | Intent selects modes | Full payloads + pending gates | Roadmap sliced; pitches full-read | Modes 0/1/1b/2 + handoff | Free-form payloads | Script fallback; reshape/resequence | Roadmap exact; payload unvalidated |
| prompt-engineer | Checklist 3a–3m per file | Severity/contested judgment | Checklist + targets in-context | Frontmatter-only directory inventory | File/dir/no-target | Markdown table | Drop non-recurring findings | Root lint subset; probes manual |
| observer | Checkpoint combines state/modes/silence | Silence vs trace/example | Ephemeral four-field note | Bounded by since + F-id | Dispatch vs /loop; CLEAR vs BLOCK | One prose verdict line | Absent status → no-signal; BLOCK stops | No test runner; example vs zero-output |

---

## Top-tier leverage by module (R4)

| Module | Parallelism | Adaptive depth | Context reuse | Critique independence | Uncertainty | Script delegation |
|---|---|---|---|---|---|---|
| core | N/A (no worker dispatch) | Human-selected flow | Always-on card + one-file escalation | Rule 7 → inaccessible gate | assumption / cannot-verify markers | Deterministic-work principle |
| lsa | Parallel via manager epics | Flow depth + reconcile N | discover→specify→verify inline | Separate reconcile context (OS isolation not named) | NOT-GROUNDED / NOT-RUNNABLE | Gate aggregation scripted; semantics model-side |
| manager | Worktree waves, concurrency 4 | Static concurrency; risk/value sequencing | Fresh agents re-read | Serialized merge/reconcile | Conservative overlap default | Roadmap sliced; pitch/overlap judgment remain |
| prompt-engineer | Sequential multi-target | Same checklist depth | Three knowledge files per review | Same-agent self-consistency | Drop non-recurring findings | Mechanical 3a–3m script-extraction target |
| observer | One grader per increment | Fixed does·only | Fresh checkpoint context | Distinct grader artifact; hard FS isolation not named | CLEAR/BLOCK + cited check | Signal detection deterministic; scenario meaning semantic |

---

## Target architecture (proposed, not implemented)

1. **Evidence compiler** — resolve scope, slice files, normalize citations, enforce byte budgets → scripts  
2. **Prompt compiler** — assemble only applicable goal/invariants/schema/tools/escalation → scripts + manifests  
3. **Semantic worker** — decide ambiguous intent/design/attribution → small or top-tier model  
4. **Contract validator** — reject malformed payloads, missing evidence, orphan hunks → JSON Schema + scripts  
5. **Independent verifier** — grade risky semantic outcomes against immutable tests → separate model + protected gate  
6. **Budget router** — escalate only from observable complexity/failure/disagreement/risk → deterministic policy  

### Prompt ABI fields (proposed)

`intent` · `evidence` · `invariants` · `tools` · `output_schema` · `budget` · `escalate_when`

---

## Model strategy (one marketplace, two profiles)

| Layer | Small-model profile | Top-tier profile |
|---|---|---|
| Input | One bounded evidence pack; explicit byte ceiling | Broader pack only when uncertainty/deps demand it |
| Prompt | Compiled Prompt ABI; one mode; typed output | Same ABI + optional critique/alternatives appendix |
| Tools | Scripts do enumeration/lookup/parsing/set-difference | Models arbitrate ambiguous semantics |
| Routing | Start cheapest capable; escalate on failed checks | Premium for synthesis, independent review, reconcile |
| Verification | Schema + executable gate + narrow golden fixtures | Independent adversarial grader + same deterministic floor |
| Output | Decision record + evidence IDs | Decision record first; deeper rationale on demand |

---

## 90-day sequence (planning only)

| Phase | Title | Exit |
|---|---|---|
| 0–30 days | Close correctness leaks (helpers, telemetry, decision records, schemas) | No mandatory command depends on repo-root files; every agent boundary validates |
| 31–60 days | Compile and slice (pitch/feature resolvers, Prompt ABI, skeletons, inline manager) | Prompt and evidence bytes measured per flow; no unbounded happy-path reads |
| 61–90 days | Prove model-tier behavior (capability router, golden corpus, executable reconcile fixtures) | Small-model support and top-tier lift are release metrics |

---

## Out of scope for this audit

- Editing marketplace prompts, scripts, specs, or plugin versions as audit remediation.
- Paid external model evaluations.
- Claiming unmeasured token/latency wins as facts.

## Related files

- Spec: [`requirements.md`](./requirements.md)
- Scenario: [`audit-report.feature`](./audit-report.feature)
- Grounding: [`grounding.md`](./grounding.md)
- Discover facts + fix prep: [`discover.md`](./discover.md)
