# Discover — Marketplace AI-Engineering Audit

> **Trace.** `=============== [lsa/skills/discover/SKILL.md] [lsa] ===============`  
> Role: requirements analyst. Goal: intent + cited codebase facts for later fix work.  
> **Posture:** gather and prepare only — no marketplace remediation in this turn.

## Intent

| Field | Value |
|---|---|
| **User flow** | Freeze the AI-engineering audit as repo artifacts; enrich each recommendation with concrete `file:line` quotes and suggested improvements so a later session can implement fixes without re-auditing. |
| **Module** | Cross-module (all five: `core`, `lsa`, `manager`, `prompt-engineer`, `observer`) — index in `.lsa.yaml` `modules:`. |
| **Deliverables this turn** | `report.md` (findings as-is) + this `discover.md` (facts + suggested improvements). |
| **Not this turn** | Editing shipped prompts/scripts/versions to implement recommendations. |

## Read summary (discover Step 1)

| Source | One-liner |
|---|---|
| `.lsa.yaml` | Five modules; `gate:` + `routing:` + `reconcile.runs: 3` + `implement.concurrency: 4`. |
| `.lsa/VISION-digest.md` | Spine: fact-grounding + spec-grounding; principle 5 map-not-territory; principle 10 deterministic work is scripted. |
| `project-map.yaml` | Depth-3 dirs atlas; feature pack under `.lsa/features/marketplace-ai-engineering-audit/`. |
| `report.md` / Canvas | Prioritized P0/P1 roadmap already drafted; this file attaches verifiable quotes. |

---

## Codebase facts → suggested improvements

Each row is a later fix unit. **Quote** is verbatim from the live tree. **Suggested improvement** is preparation guidance, not an authorized edit.

### F01 — Ship the scripts the prompts require · P0

**Facts**

| Cite | Searchable quote |
|---|---|
| `.claude-plugin/marketplace.json:17-18` | `"name": "manager",` / `"source": "./manager",` |
| `scripts/roadmap-query.sh:6` | `Repo-internal — NOT shipped; no version bump / CHANGELOG.` |
| `scripts/roadmap-row.sh:12` | `Repo-internal — NOT shipped in any plugin; no version bump / CHANGELOG.` |
| `manager/skills/next/SKILL.md:24` | `**Run the roadmap-row extractor** (this repo: \`bash scripts/roadmap-row.sh\`, which prints that item + its \`path:line\` deterministically from the YAML — Pro-safe, zero model tokens)` |
| `manager/agents/project-manager.md:24` | `Query the ledger on demand via \`scripts/roadmap-query.sh\` ... never whole-file-read it on the happy path` |

**Suggested improvement (later)**

1. Move `roadmap-row.sh` / `roadmap-query.sh` under `manager/scripts/` (or a shared shipped helpers plugin path).
2. Resolve via `${CLAUDE_PLUGIN_ROOT}/scripts/...` in skill/agent bodies.
3. Keep a one-release root shim that execs the plugin path for source-repo callers.
4. Add install fixture: empty repo + installed `manager@NVZver` → helpers resolve; no whole-file fallback forced by missing binary.
5. Mirror pattern for any other root scripts that shipped actors *require* (digest is constitution-side; project-map already ships under `lsa/scripts/`).

---

### F02 — Compile actor-specific prompt envelopes · P0

**Facts**

| Cite | Searchable quote |
|---|---|
| `core/CLAUDE.md:40` | `load only the file the current step acts on.` |
| `core/CLAUDE.md:41-42` | `Escalation triggers — load that ONE full skill only:` |
| `.lsa/VISION.md:62` | `Load registries always; load full definitions only on match. Context is a budget.` |
| `core/skills/output/SKILL.md:24` | `Every factual claim carries source + exact quote` |
| `core/skills/output/SKILL.md:26` | `One line per loaded file, in load order.` |

**Suggested improvement (later)**

1. Define a **Prompt ABI** manifest per actor: `intent`, `evidence`, `invariants`, `tools`, `output_schema`, `budget`, `escalate_when`.
2. Compile at author time (or install time) a short envelope that includes only rules that apply to that actor’s mode.
3. Keep examples / rationale behind escalation links (card already points this way).
4. Add lint: transitive loaded lines/tokens per actor must stay under a budget; fail closed if a hard rule is omitted from the compile set.
5. Pilot on `manager:next` fast-path + `observer:verify-checkpoint` (highest collision density).

---

### F03 — Separate telemetry from user output · P0

**Facts**

| Cite | Searchable quote |
|---|---|
| `core/skills/output/SKILL.md:24` | `Every factual claim carries source + exact quote` |
| `core/skills/output/SKILL.md:26` | `One line per loaded file, in load order. ... **Hard — print it.**` |
| `observer/skills/verify-checkpoint/SKILL.md:54` | `A no-signal cycle produces zero output and ends here` |
| `observer/skills/verify-checkpoint/SKILL.md:79-83` | Example block prints the skill’s own trace line then `cycle 1 — no checkpoint signal` |

**Suggested improvement (later)**

1. Split **hard Sourced** into: (a) working-context evidence ledger with stable IDs; (b) human-facing expansion only for decisions, disputes, and completion claims.
2. Make file-load traces **debug telemetry** (opt-in / harness channel), not mandatory user-visible bytes.
3. Explicitly exempt silent-cycle actors (`verify-checkpoint` no-signal, `observe` silence) from trace printing.
4. Fix the Example Output so it cannot demonstrate a silence violation.
5. Validation: fixture where no checkpoint exists → stdout/user channel is exactly empty.

---

### F04 — Replace visible chain-of-thought with decision records · P0

**Facts**

| Cite | Searchable quote |
|---|---|
| `core/skills/flow-selector/SKILL.md:3` | `with visible chain-of-thought reasoning over boundary signals` |
| `core/skills/flow-selector/SKILL.md:38` | `**State the chain-of-thought as a one-paragraph summary**` |
| `manager/agents/product-manager.md:27` | `Reason (visible chain-of-thought) about which domain-expert role` |
| `.lsa/VISION.md:255` | `Orchestrator selects flow by visible chain-of-thought over boundary signals` |

**Suggested improvement (later)**

1. Replace “visible chain-of-thought” with a fixed **decision record** schema: signals · evidence cites · selected option · confidence · unresolved fork · next action.
2. Update VISION §4 / §7 wording to “visible decision record” (ownership preserved; private reasoning not forced into tokens).
3. Add lint C-new: forbid the phrase `visible chain-of-thought` in Actor bodies; allow `decision record`.
4. Snapshot tests for flow-selector and product-manager role gate: only decision-record fields required.

---

### F05 — Make every agent boundary typed · P0

**Facts**

| Cite | Searchable quote |
|---|---|
| `manager/agents/product-manager.md:33` | `return its **full content in the payload** — write NO file.` |
| `manager/agents/project-manager.md:75` | `A sequenced recommendation, proposed hygiene row diffs, a decomposed epic list, and a staged \`lsa:discover\` seed` |
| `observer/skills/verify-checkpoint/SKILL.md:26-37` | Required fields table: `target` · `since` · `spec` · `status`; path owned externally |
| `.lsa/standards/code.md:69` | `writes the artifact to a file and returns a pointer + a decision-relevant summary + any pending gates` |

**Suggested improvement (later)**

1. Discriminated JSON (or JSON-in-fence) payloads: `{intent, status, artifact_pointer, pending_gates, writes, next_action}`.
2. Rewire product-manager / project-manager to the artifact hand-off standard already in `code.md` (pointer + summary; dispatcher re-renders for humans).
3. Schema-validate checkpoint notes before grading; reject malformed notes as BLOCK with a named reason.
4. Fixtures for every intent + continuation + stale/malformed note.
5. Allow a bounded `notes` string so rigidity does not erase nuance.

---

### F06 — Finish selective loading: pitches and feature packs · P1

**Facts**

| Cite | Searchable quote |
|---|---|
| `manager/agents/project-manager.md:39` | `For each candidate item, read its linked pitch file (from Notes column or at \`${specs_root}/pitches/<slug>.md\`).` |
| `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md:155` | `Pitch corpus ≈ **48.6k tok**; Mode 1 still *"For each candidate item, read its linked pitch"*` |
| `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md:165` | `this epic ~2.9k tok vs features corpus ~92k tok (**~31×** over-read if agents pull the whole tree)` |
| `lsa/skills/discover/SKILL.md:29` | `consult the project map ... before walking the tree; fall back to a tree-walk if it is absent` |

**Suggested improvement (later)**

1. `scripts/pitch-query.sh outline <slug>` → Problem / Appetite / Rabbit holes / No-gos headers only.
2. Mode 1 reads outlines for N candidates; full pitch only for the selected slug.
3. `scripts/feature-pack-resolve.sh` → request-scoped feature dirs + byte budget from `.lsa.yaml` artifact_paths / path hints.
4. Wiring tests mirroring `no-wholefile-ledger-read.sh` for pitches (`no-wholefile-pitch-read.sh`).
5. Document deterministic full-read fallback reason when outline cannot answer a dependency question.

---

### F07 — Finish inline manager orchestration · P1

**Facts**

| Cite | Searchable quote |
|---|---|
| `lsa/agents/orchestrator.md:30` | `carry facts forward so each stage **reuses** what the last read instead of re-reading it` |
| `.lsa/standards/code.md:65` | `Everything else — spec authoring, shaping, decomposition, recommendation, review, cited lookup — runs inline.` |
| `manager/skills/shape/SKILL.md:26` | `**Dispatch product-manager agent.** Invoke the \`product-manager\` agent via the \`Agent\` tool` |
| `lsa/knowledge/model-routing.md:70-73` | Rows for shape/decompose/next/check marked transitional / wired |

**Suggested improvement (later)**

1. Inline `manager:shape`, `decompose`, `next` (non-fast-path), `check` in the main thread per Dispatch efficiency standard.
2. Keep Agent dispatch only for: external implementer, independent graders, worktree fan-out.
3. Benchmark: shape → decompose → discover Agent-dispatch count = 0 before implementation.
4. Preserve gate ownership in the skill layer (AskUserQuestion stays with dispatcher).

---

### F08 — Turn semantic gates into deterministic skeletons · P1

**Facts**

| Cite | Searchable quote |
|---|---|
| `lsa/skills/reconcile/SKILL.md:34` | `an **orphan hunk** (in the diff, in no row) is drift` |
| `lsa/skills/reconcile/SKILL.md:36` | `First run \`bash scripts/coverage-skeleton.sh <feature-dir>\` to get the enumerated skeleton` |
| `lsa/skills/verify/SKILL.md:30` | `For each module / function / type the spec names: resolve it in the codebase (cite \`file:line\`) or mark it \`new\`.` |
| `prompt-engineer/commands/prompt-review.md:27-39` | Mechanical checklist 3a–3l run per file via model Grep/judgment |

**Branch-state fact (do not re-do blindly)**

- `scripts/coverage-skeleton.sh` and reconcile Step 4 wiring are **already present** on this branch as in-flight deterministic-work work. Later fix session should **reconcile remaining gaps** (verify reference-map script, prompt-lint extraction, epic-overlap graph) rather than re-landing coverage-skeleton.

**Suggested improvement (later)**

1. Keep semantic mapping in the model; never let the skeleton script emit PASS.
2. Add `scripts/resolve-refs.sh` for verify Step 1 existence map.
3. Extract prompt-review 3a–3l structural subset into `scripts/prompt-lint.sh`; model assigns severity only on ambiguous hits.
4. Add `scripts/epic-overlap.sh` for file/module write-set edges (judgment edges stay model-side).

---

### F09 — Route by capability and confidence · P1

**Facts**

| Cite | Searchable quote |
|---|---|
| `lsa/knowledge/model-routing.md:34` | `Three surfaces do so today: \`manager:next\` and \`manager:check\`` |
| `lsa/knowledge/model-routing.md:52-54` | `Absent or unavailable ⇒ \`inherit\`.` |
| `.lsa.yaml:47-50` | `manager:next: sonnet` / `manager:check: haiku` / `lsa:delegate.verify-checkpoint: sonnet` |
| `lsa/knowledge/model-routing.md:46-50` | Floored set always resolves `inherit` |

**Suggested improvement (later)**

1. Introduce capability classes: `deterministic` · `bounded-judgment` · `synthesis` · `safety-critical`.
2. Map classes → substrate tiers; keep floors for reconcile / delegate / implement.
3. Escalate on: bytes over budget · unresolved forks · schema failure after one repair · repeated BLOCK · grader disagreement · Extended flow.
4. Unit-test the resolver matrix; echo every resolved tier in the dispatch line (already required).
5. Budget ceiling so auto-escalation cannot surprise-spend Opus.

---

### F10 — Cross-tier behavioral regression lab · P1

**Facts**

| Cite | Searchable quote |
|---|---|
| `.lsa/standards/testing.md:13` | `No automated harness in this release` |
| `.lsa/standards/testing.md:50-55` | `Behavioral evals ... run on **Sonnet**` / `a guard verified only on a stronger model is untested on the model the marketplace guarantees.` |
| `observer/skills/verify-checkpoint/SKILL.md:58` | `Run each **as reasoning** against the increment` / `this module carries no test-runner harness.` |

**Suggested improvement (later)**

1. Deterministic harness self-test first (stub outputs → exact scores/schema/routing).
2. Small golden corpus run on cheapest supported model **and** session model; log disagreement.
3. Prefer executable tests for docs-mode gate paths; keep execution-as-reasoning only where no runner exists.
4. Independent judge session for adversarial probes (observer pattern already proven).
5. Never let benchmark green override `gate.sh` / executable exits.

---

## Inventory checklist (R1 facts)

| Class | Exists @ |
|---|---|
| Five modules | `.lsa.yaml:52-103` |
| Always-on card | `core/CLAUDE.md` |
| Core skills (6) | `core/skills/{actor-template,doctor,flow-selector,ground-rules,output,reuse-first}/SKILL.md` |
| LSA agent + skills (1+7) | `lsa/agents/orchestrator.md`; `lsa/skills/{init,discover,specify,verify,delegate,reconcile,revise-constitution}/SKILL.md` |
| Manager agents + skills (2+5) | `manager/agents/{product,project}-manager.md`; `manager/skills/{shape,next,check,decompose,implement}/SKILL.md` |
| Prompt-engineer (1+3) | `prompt-engineer/agents/prompt-engineer.md`; `commands/{prompt-create,prompt-optimize,prompt-review}.md` |
| Observer skills (2) | `observer/skills/{observe,verify-checkpoint}/SKILL.md` |
| Routing table | `lsa/knowledge/model-routing.md:69-78` |
| Aggregate gate | `.lsa.yaml:14-18` + `scripts/gate.sh` |

---

## Open assumptions / gaps

| Tag | Note |
|---|---|
| `[assumption]` | Agent over-read rate of full `.lsa/features/**` is not instrumented; ~31× is headroom from corpus sizes, not a measured miss rate. |
| `[assumption]` | Haiku failure rate on `manager:check` vs Sonnet is unmeasured (route exists; eval suite is Sonnet-standard). |
| `[cannot verify]` | Independent OS/filesystem write isolation for reconcile grader — stated in prompts as “no write access”; not proven by a mount/CI mutation test in this discover pass. |
| Branch note | Coverage-skeleton work is in flight on this branch; F08 suggestions should complement, not duplicate, that epic. |

---

## Handoff for later fix sessions

1. Start from [`report.md`](./report.md) (frozen findings) + this file (quotes + suggested improvements).
2. Pick the next F0x unit; run `core/flow-selector` for that unit’s weight.
3. Implement via normal LSA loop for that unit only — do not “fix the whole audit” in one pass.
4. Prefer order: **F01 → F03 → F04 → F05 → F02 → F06 → F07 → F08-remainder → F09 → F10**.

## Discover output shape

| Module | Change | Acceptance |
|---|---|---|
| marketplace (all five) | Persist audit + discover enrichment for later remediation | Report + discover cite every P0/P1 with `file:line` quote and a concrete later improvement; no recommendation implemented this turn |
