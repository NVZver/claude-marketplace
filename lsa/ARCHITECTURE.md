# Living Spec Architecture (LSA)
**Version:** 0.2.0 (plugin)
**Author:** Nikita Zverev
**Status:** 0.2.0 — Vision-aligned; dogfooded on `claude-marketplace` itself. See [`vision/specs/2026-05-20-lsa-v0.2.0-design.md`](../vision/specs/2026-05-20-lsa-v0.2.0-design.md).

---

## 1. Purpose

LSA is a spec-first development methodology where specs are the permanent source of truth and code (or any other behavior-bearing artifact) is always agent-generated to match them.

Humans write and own specs. Agents write and own artifacts. Direct artifact edits are absorbed into the spec via the **reconcile loop** rather than blocked (`vision/VISION.md:135`).

---

## 2. Core Principles

| # | Principle |
|---|-----------|
| P1 | Specs are written before any code is generated |
| P2 | Code (or artifact) always follows specs — never the other way around |
| P3 | The human is the source of truth at every decision gate |
| P4 | Fact-grounding per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 1 — every factual claim carries a source + searchable quote |
| P5 | Every code/artifact change must trace to a spec requirement |
| P6 | Feature specs are temporary. Module specs are permanent |
| P7 | Nothing proceeds past a gate without explicit human approval |
| P8 | Ceremony scales to the weight of the task (`core/tier-selector`, Vision §4) — T1/T2/T3 — chain-of-thought visible, human-confirmed |

---

## 3. Directory Structure

```
/
├── CLAUDE.md                          ← Always-on entry; loaded every session.
├── .lsa.yaml                          ← LSA configuration (optional; v0.1.1 defaults if absent)
├── .lsa-sync-state.json               ← Per-module last-sync SHA (written by lsa-sync; consumed by lsa-reconcile + drift hook)
├── core/                              (the core plugin — independent of LSA)
│   ├── CLAUDE.md                      ← Always-on fragment shipped in core (ground-rules + tier-selector)
│   └── skills/
│       ├── ground-rules/SKILL.md
│       ├── actor-template/SKILL.md
│       └── tier-selector/SKILL.md
├── lsa/
│   ├── hooks/
│   │   ├── hooks.json                 ← Single-file plugin hook manifest (SessionStart drift-check)
│   │   └── session-start-drift-check.sh
│   └── skills/
│       ├── lsa-init/SKILL.md
│       ├── lsa-discover/SKILL.md      ← NEW in v0.2.0 — Phase 0
│       ├── lsa-specify/SKILL.md
│       ├── lsa-plan/SKILL.md
│       ├── lsa-verify/SKILL.md
│       ├── lsa-sync/SKILL.md
│       ├── lsa-reconcile/SKILL.md     ← NEW in v0.2.0 — ad-hoc phase
│       └── lsa-revise-constitution/SKILL.md
└── ${specs_root}/                     (defaults to /specs/; configured via .lsa.yaml)
    ├── main.spec.md                   ← App-level behavior, module index, global contracts
    ├── roadmap.md                     ← Prioritized feature backlog
    ├── research-backlog.md            ← Mid-feature ideas, deferred decisions
    ├── metrics.md                     ← Optional aggregate (one row per archived feature)
    ├── standards/
    │   ├── code.md
    │   ├── testing.md
    │   └── agents.md
    ├── modules/
    │   └── <module-name>/
    │       └── spec.md                ← Permanent module spec (never deleted)
    ├── features/
    │   └── <feature-name>/
    │       ├── requirements.md
    │       ├── test-suites.md
    │       ├── contract.yaml          (only when contract trigger fires)
    │       ├── design.md
    │       └── tasks.md
    └── archive/
        └── YYYY-MM-DD-<feature-name>/
            ├── (the archived feature spec files)
            └── metrics.md             (written by lsa-verify on clean T3 PASS)
```

`${specs_root}` is configurable via `.lsa.yaml` (see §4.10). The defaults match v0.1.1 (`/specs/`).

---

## 4. Components

### 4.1 Constitution (configurable path; default `/CLAUDE.md`)

| | |
|---|---|
| **Purpose** | Single root document defining how this project operates |
| **Role** | Every agent reads this first, on every task, without exception |
| **Path** | Configured by `.lsa.yaml: constitution`; default `/CLAUDE.md` |
| **Owns** | Project name, tech stack, directory structure, coding conventions, agent rules |
| **Written by** | Human |
| **Updated by** | Human via constitution revision (see §8) |
| **Never contains** | Feature requirements, implementation details, business logic |

---

### 4.2 Standards (`${specs_root}/standards/`)

| | |
|---|---|
| **Purpose** | Technical standards that apply across all features |
| **Role** | Loaded by agents when relevant to the current task |
| **Files** | `code.md` — patterns, naming, file structure |
| | `testing.md` — TDD rules, test types, coverage thresholds |
| | `agents.md` — how agents behave, escalation rules, human gates |
| **Written by** | Human (extracted from the constitution during init) |
| **Updated by** | Constitution revision skill after human approval |
| **Relationship to constitution** | Constitution = what the project is. Standards = how to build it |

---

### 4.3 Main Spec (`${specs_root}/main.spec.md`)

| | |
|---|---|
| **Purpose** | App-level behavioral contract and module index |
| **Role** | Source of truth for cross-module contracts, global NFRs, and module inventory |
| **Owns** | Module index, cross-module API contracts, global non-functional requirements |
| **Updated by** | `lsa-sync` after each feature merge (human reviews each update) |
| **Never contains** | Feature-level requirements, implementation details |

---

### 4.4 Roadmap (`${specs_root}/roadmap.md`)

| | |
|---|---|
| **Purpose** | Prioritized list of upcoming features |
| **Role** | Reviewed before every feature. Prevents building the wrong thing next |
| **Format** | Ordered table: Feature / Priority / Status / Notes |
| **Updated by** | Human during replanning phase |
| **Key rule** | A feature cannot start without appearing on the roadmap first |

---

### 4.5 Module Specs (`${specs_root}/modules/<name>/spec.md`)

| | |
|---|---|
| **Purpose** | Permanent behavioral record of each module |
| **Role** | Describes what a module does, its contracts, constraints, and behaviors |
| **Contains** | Functional behaviors, non-functional constraints, cross-module contracts |
| **Never contains** | Code, implementation details, feature history |
| **Created** | By `lsa-init` (brownfield: inferred; greenfield: first feature touching the module) |
| **Updated** | By `lsa-sync` (append, tagged with source feature) and by `lsa-reconcile` (in-place edit or append, tagged `<!-- reconciled: YYYY-MM-DD -->`) |
| **Deleted** | Never |

---

### 4.6 Feature Spec (`${specs_root}/features/<name>/`)

| | |
|---|---|
| **Purpose** | Captures everything needed to implement one feature |
| **Role** | Source of truth for agents during implementation of that feature only |
| **Lifecycle** | Created by `lsa-specify` → approved by human → used during implementation → archived by `lsa-sync` |
| **Files** | `requirements.md`, `test-suites.md`, optional `contract.yaml`, `design.md`, `tasks.md` |
| **After merge** | Delta extracted to module specs → entire directory moved to `${specs_root}/archive/` |
| **Deleted** | Never — archived, not deleted |

---

### 4.7 Research Backlog (`${specs_root}/research-backlog.md`)

| | |
|---|---|
| **Purpose** | Captures mid-feature ideas and deferred decisions without polluting the current branch |
| **Role** | Parking lot. Nothing here blocks current work |
| **Format** | Date / Topic / Summary / Recommendation / Status |
| **Updated by** | Human, agent during any phase, or `lsa-reconcile` when a delta is rejected |
| **Consumed by** | Human during replanning — promotes entries to roadmap or discards them |

---

### 4.8 LSA Discover (`lsa/skills/lsa-discover/SKILL.md`) — NEW in v0.2.0

| | |
|---|---|
| **Purpose** | Light discovery phase at the start of every T2 and T3 task |
| **Role** | Three-question probe: (a) which module(s)? (b) change in one sentence? (c) acceptance criterion in one sentence? |
| **Output** | T2: oral context paragraph (no file). T3: scratch `discovery.md` consumed by `lsa-specify`. |
| **Gate** | None of its own; downstream gates fire in the next phase |
| **Never** | Asks more than three questions; writes to `${specs_root}/`; invents module names |

---

### 4.9 LSA Reconcile (`lsa/skills/lsa-reconcile/SKILL.md`) — NEW in v0.2.0

| | |
|---|---|
| **Purpose** | Absorb direct artifact edits into module specs — Level 2.5 (`vision/VISION.md:138`) |
| **Trigger (auto)** | SessionStart drift warning (see §4.10 hook) |
| **Trigger (manual)** | `/lsa:reconcile` |
| **Process** | Per-module `git diff <recorded-sha> -- <artifact_paths>` (working-tree vs recorded SHA — catches uncommitted edits) → classify class (a) or (b) → per-module hard confirm → reverse-sync in-place or append; both tagged `<!-- reconciled: YYYY-MM-DD -->` |
| **State** | Updates `.lsa-sync-state.json` per module on confirm |
| **Never** | Blocks, reverts, or reformats the artifact edits (Vision §4 `vision/VISION.md:144`); leaves the spec self-contradictory (class (a) replaces, not appends-next-to) |

---

### 4.10 `.lsa.yaml` configuration

LSA is path-configurable via `.lsa.yaml` at the repo root. Schema (all keys optional; defaults applied when absent):

```yaml
# .lsa.yaml — Living Spec Architecture configuration
# Schema version: 1 (matches lsa plugin major version 0.x.y)

constitution: vision/VISION.md       # default: /CLAUDE.md
specs_root: vision/specs/            # default: /specs/
mode: docs                           # docs | code | mixed. default: code

modules:
  <module-name>:
    spec: <path-relative-to-repo-root>
    artifact_paths:
      - <glob>
      - <glob>
```

- `constitution` — every LSA skill reads this first.
- `specs_root` — every `${specs_root}/...` reference resolves under this prefix.
- `mode` —
  - `code` — v0.1.1 behavior; verify diffs `/src/`.
  - `docs` — verify diffs each module's `artifact_paths` against `main`; no `/src/`.
  - `mixed` — both; either failing fails verify.
- `modules.<name>.spec` — path to that module's spec.md.
- `modules.<name>.artifact_paths` — globs (repo-root-relative) that implement this module; consumed by verify (doc-mode), reconcile (drift diff), and the SessionStart hook.

**When absent**, LSA falls back to v0.1.1 behavior: `constitution: /CLAUDE.md`, `specs_root: /specs/`, `mode: code`, `modules: {}`. This preserves all existing behavior for projects that haven't opted in.

The SessionStart hook (`lsa/hooks/hooks.json` declares `matcher: "startup"`) invokes `lsa/hooks/session-start-drift-check.sh`. If any module's `artifact_paths` differ from the SHA recorded in `.lsa-sync-state.json`, the hook prints a one-line notice; control returns to the user, who chooses when to invoke `/lsa:reconcile`. The hook exits 0 always — it must never block session start.

---

## 5. Workflow Phases

### Pre-Feature Checklist (AI Fatigue Prevention)

Before every new feature, verify:

- [ ] Previous feature branch merged to main
- [ ] `${specs_root}/features/` is empty (sync complete)
- [ ] Agent context cleared
- [ ] Roadmap reviewed — next feature confirmed correct

---

### Tier selection (every non-trivial task)

Before any phase below fires, the agent invokes `core/tier-selector` (when installed; always-on per `core/CLAUDE.md`) to classify the task as T1, T2, or T3. The human confirms or overrides.

- **T1** — return; no phase below fires. Single-pass response under `core/ground-rules`.
- **T2** — Phase 0 (discover) → implement (TDD) → Phase 5 (verify). No specify / plan / sync.
- **T3** — Phase 0 (discover) → Phase 1 (specify) → Phase 2 (plan) → Phase 3 (implement) → Phase 4 (sub-agent review) → Phase 5 (verify) → Phase 6 (sync) → Phase 7 (replan).

---

### Phase 0 — Discover (`lsa-discover`) — NEW in v0.2.0

| | |
|---|---|
| **Tiers** | T2 and T3 |
| **Input** | Confirmed tier from `core/tier-selector` |
| **Process** | Three-question probe (module, change, AC) |
| **Output (T2)** | Oral context paragraph — implementation begins |
| **Output (T3)** | Scratch `discovery.md` — consumed by `lsa-specify` |
| **Gate** | None of its own; the next phase carries the gate |

---

### Phase 1 — Specify (`lsa-specify`)

| | |
|---|---|
| **Tiers** | T3 only |
| **Input** | Human's feature description; optional `discovery.md` from Phase 0 |
| **Process** | Agent asks clarifying questions → human answers → agent writes spec files in order |
| **Produces branch** | `feature/<feature-name>` |

**Confirm gate types:**
- **Hard Confirm:** Stop completely. Do not proceed until human explicitly approves. No implicit approval.
- **Soft Confirm:** Present artifact. Wait for approval or corrections. Human may approve, correct inline, or delegate corrections to agent.

| Step | Output | Gate type |
|------|--------|-----------|
| 1 | `requirements.md` | Hard confirm. Evaluate contract trigger after confirmation |
| 2 | `test-suites.md` | Hard confirm |
| 3 | `contract.yaml` | Soft confirm. Skip if contract trigger = no |
| 4 | `design.md` | Soft confirm |
| 5 | Full spec review | Integration check — verify: every AC has a journey, design matches contract, Open Questions resolved |

---

### Phase 2 — Plan (`lsa-plan`) — T3 only

| | |
|---|---|
| **Input** | Approved `requirements.md`, `test-suites.md`, and `design.md` |
| **Process** | Agent decomposes into ≤5 parallel-safe epics, runs self-verification |
| **Output** | `tasks.md` with epic details, ACs, test plans, branch names, integration checklist |
| **Gate** | Human reviews and explicitly approves tasks.md |

---

### Phase 3 — Implement — T2 (free-form TDD) and T3 (epic branches)

| | |
|---|---|
| **Input (T2)** | The Phase-0 context paragraph |
| **Input (T3)** | Approved `tasks.md` |
| **Process (T3)** | Each epic assigned to a sub-agent on its own branch |
| **Source of truth (T3)** | `tasks.md` — one file, one source. Each agent reads its epic section and writes status updates only to that section |
| **Context** | All agents inherit from the configured constitution. No scoped overrides |
| **Agents must** | Meet all ACs, write tests per TDD policy (§6), update their epic status in `tasks.md` (T3) |
| **Agents may** | Create subtasks within their epic scope, recorded in their `tasks.md` section (T3) |
| **Agents must not** | Touch files outside their declared scope or write to another epic's section |
| **Branch per epic (T3)** | `feature/<feature-name>-e<N>` |

---

### Phase 4 — Sub-Agent Deep Review — T3

| | |
|---|---|
| **Input** | Completed epic or assembled feature branch |
| **Process** | Spawn fresh sub-agents to review the full project with this change applied |
| **Purpose** | Preserves main agent context. Catches issues a first-pass agent misses |
| **Output** | List of issues and recommendations |
| **Gate** | Human reviews findings. Decides what to fix before verify |

---

### Phase 5 — Verify (`lsa-verify`)

| | |
|---|---|
| **Tiers** | T2 and T3 |
| **Input** | Implemented code/artifact + feature spec |
| **Core check** | Every change traces to a spec requirement. No untraced changes allowed |
| **Process (code-mode)** | `git diff main -- ${specs_root}/features/<name>/` vs `git diff main -- src/` |
| **Process (doc-mode)** | For each module in `.lsa.yaml`: `git diff main -- <artifact_paths>` vs feature spec |
| **Process (mixed)** | Both; either failing fails the whole verify |
| **Tracing in doc-mode** | (a) feature spec names the file or its containing directory in an AC, OR (b) diff is wholly mechanical (rename, whitespace, formatting) — judged by agent and reported |
| **Output** | Verification report with PASS / FAIL / PASS WITH WARNINGS |
| **Metrics** | On clean PASS for a T3 feature: write `${specs_root}/archive/<feature>/metrics.md` (accuracy / facts-with-sources / only-required-changes; pass/fail counts only) |
| **Gate** | FAIL or BLOCKER → stop, fix, re-verify. PASS → proceed to sync on human approval |

If invoked without an active feature spec, `lsa-verify` errors with *"no active feature — use `/lsa:reconcile` for direct-edit absorption"* — clarifying the boundary between feature verification and drift reconciliation.

---

### Phase 6 — Sync (`lsa-sync`) — T3

| | |
|---|---|
| **Input** | Verified feature branch |
| **Process** | Extract system-level decisions → merge into module specs → update main.spec.md → archive feature spec |
| **Gate** | Human reviews delta summary before any files are written |
| **State** | Writes `.lsa-sync-state.json` (HEAD SHA + ISO timestamp per touched module) |
| **Metrics** | If `lsa-verify` wrote a per-feature `metrics.md`, append a one-row aggregate to `${specs_root}/metrics.md` |
| **Output** | Updated module specs, updated `main.spec.md`, feature archived |
| **Post-sync** | `${specs_root}/features/` is empty (for this feature). Branch ready for PR to main |

---

### Phase Reconcile (ad-hoc, not numbered)

| | |
|---|---|
| **Trigger** | SessionStart drift warning, or `/lsa:reconcile` manual invocation |
| **Input** | `.lsa.yaml`, `.lsa-sync-state.json`, git working tree |
| **Process** | Per-module `git diff <recorded-sha> -- <artifact_paths>` → classify (a) update existing / (b) new behavior → per-module hard confirm → reverse-sync (in-place edit or append, tagged `<!-- reconciled: YYYY-MM-DD -->`) → update `.lsa-sync-state.json` |
| **Gate** | One module at a time. Never bundled. Hard confirm per module |
| **Never** | Blocks, reverts, or reformats the artifact edits |

---

### Phase 7 — Replan — T3

| | |
|---|---|
| **Input** | Merged feature |
| **Process** | Review roadmap. Promote research backlog items. Revise constitution if needed |
| **Output** | Updated roadmap. Optional: constitution revision (triggers §8) |
| **Key question** | Does the next roadmap item still make sense? |

---

## 6. Testing Policy

Source of truth: `${specs_root}/standards/testing.md`.

### E2E Tests

| Rule | Definition |
|------|------------|
| Driven by | `test-suites.md` — every journey and every path must have a corresponding test |
| Frontend | Page Object Model. One Page Object per page or component. No direct DOM selectors in tests |
| Coverage | All paths in test-suites.md covered. No path may be skipped without human approval |
| Framework | Defined in the constitution |

**test-suites.md format:**

```markdown
## Journey: [Name]

**Goal:** [What problem/task the user is trying to solve]
**Covers:** AC1, AC2

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | action → action → success |
| 2 | Alternate | action → action → success (different route) |
| 3 | Error | action → system rejects → user sees feedback |

**Expected outcome:** [What success looks like for happy paths. What feedback the user sees for error paths.]
```

### Unit Tests

| Rule | Definition |
|------|------------|
| Approach | Industry standard. Test per function/method |
| Location | Co-located with source or in `__tests__/` per the constitution |
| Written | Before implementation (TDD) |
| Coverage | All new functions/methods. No exceptions without human approval |

### Integration Tests

| Rule | Definition |
|------|------------|
| Approach | Industry standard. Module boundary tests |
| Coverage | All module boundaries touched by the feature |
| Written | Before integration (TDD) |

### General Rules

| Rule | Definition |
|------|------------|
| TDD | Tests written before implementation for unit and integration. E2E written before implementation phase begins |
| Every AC | Must be covered by at least one test |
| Test command | Defined in the constitution. Agents run it before marking any work complete |
| Exceptions | Must be explicitly approved by human and noted in `tasks.md` |

---

## 7. Fact-Check Policy

Fact-grounding is governed by the [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) skill — Rule 1 (every factual claim carries a source + searchable quote) and Rule 2 (no fake confidence). LSA does not restate those rules; it requires every spec, verification report, and constitution change to follow them.

**Marker convention (v0.2.0):** lowercase `[assumption: <why>]` and `[cannot verify]` everywhere, matching `core/skills/ground-rules/SKILL.md`. Historical LSA `[ASSUMPTION: ...]` (uppercase) has been swept across all 6 reshaped skills + the 2 new skills.

**Knowledge vs. Actor reminder.** Every LSA skill is an *Actor* (Goal / Input / Steps / Output / Constraints; see `core/actor-template`). Boundary signals, classification tables, and other declarative rules belong in *Knowledge* surfaces (the constitution, the standards files, or a Knowledge skill) — not embedded in an Actor's body. The one current exception is `core/tier-selector`, which embeds its boundary signals + classification table inside Steps because the signals are read *during* execution; revisit if a second skill restates them.

**Verifier responsibility unchanged.** `lsa-verify` checks that every change traces to a spec requirement — LSA's distinct core contract, separate from fact-grounding.

---

## 8. Constitution Revision (`lsa-revise-constitution`)

Single responsibility: propose and apply changes to the configured constitution path (default `/CLAUDE.md`) and to `${specs_root}/standards/` files. This skill does nothing else.

| | |
|---|---|
| **Trigger (auto)** | After feature merge, during replan phase |
| **Trigger (manual)** | `/lsa:revise-constitution` |
| **Input** | Completed feature spec + human's proposed change description |
| **Process** | Agent proposes specific changes with diff format. Human reviews each change individually |
| **Gate** | No change is written without explicit human approval per change |
| **Output** | Updated constitution and/or `${specs_root}/standards/` files |
| **Branch** | `constitution/<change-description>` |
| **Traceability** | Every change tagged: `<!-- revised: [feature-name] [YYYY-MM-DD] -->` |
| **Scope** | Constitution and standards only. Never touches specs, src, or skills |

---

## 9. Branch Management

### Naming Convention

| Branch Type | Pattern | Example |
|---|---|---|
| Feature (parent) | `feature/<feature-name>` | `feature/user-auth` |
| Epic | `feature/<feature-name>-e<N>` | `feature/user-auth-e1` |
| Constitution | `constitution/<change-description>` | `constitution/add-testing-rules` |
| Replanning | `replan/<description>` | `replan/roadmap-q2-update` |

### Merge Strategy

```
epic branches → feature branch (after verify per epic)
feature branch → main (after lsa-sync + human PR review)
constitution branch → main (after human approval, independent of features)
```

### Rules

- `main` is always stable and spec-synced
- No direct commits to `main`
- Feature branch is created during `lsa-specify`
- Epic branches are created during `lsa-plan`
- Feature branch is deleted after merge. Epic branches are deleted after merging into feature branch

---

## 10. Skills Index

| Skill | Tier(s) | Trigger (auto) | Manual | Purpose |
|---|---|---|---|---|
| `lsa-init` | once per repo | constitution exists but `${specs_root}/` does not | `/lsa:init` | Initialize spec structure |
| `lsa-discover` | T2, T3 | After tier-selector confirms T2/T3 | `/lsa:discover` | Three-question probe; T2 oral, T3 scratch `discovery.md` |
| `lsa-specify` | T3 | Human describes a feature | `/lsa:specify` | Create feature spec |
| `lsa-plan` | T3 | Feature spec approved | `/lsa:plan` | Decompose into epics |
| `lsa-verify` | T2, T3 | Epic or feature marked implemented | `/lsa:verify` | Verify spec ↔ artifact alignment; emit `metrics.md` on clean T3 PASS |
| `lsa-sync` | T3 | Verify passed | `/lsa:sync` | Sync spec to modules, archive feature, write `.lsa-sync-state.json` |
| `lsa-reconcile` | ad-hoc | SessionStart drift hook | `/lsa:reconcile` | Absorb direct artifact edits into module specs (Level 2.5) |
| `lsa-revise-constitution` | replan | After feature merge (replan phase) | `/lsa:revise-constitution` | Propose and apply constitution changes |

Eight skills total in v0.2.0 (six in v0.1.1 plus `lsa-discover` and `lsa-reconcile`).

---

## 11. Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| OQ1 | Sub-agent source of truth | `tasks.md` is the single source. Each agent reads and writes only its own epic section |
| OQ2 | Epic agent context | All agents inherit the configured constitution. No scoped overrides |
| OQ3 | Constitution revision | Separate skill `lsa-revise-constitution`. Single Responsibility — one skill, one job |
| OQ4 | Research backlog mid-feature | Kept. Updated by human or agent to a known file without branching. Reviewed during replan |
| OQ5 | Path configuration | `.lsa.yaml` at repo root. Falls back to v0.1.1 defaults when absent |
| OQ6 | T2 path | `lsa-discover` (three-question probe) → implement (TDD) → `lsa-verify`. No specify, no plan, no sync, no per-feature metrics |
| OQ7 | Reconcile placement | New skill `lsa-reconcile` (SRP, mirrors LSA's one-skill-per-phase pattern) |
| OQ8 | Drift detection | `.lsa-sync-state.json` records last-sync commit SHA per module. SessionStart hook diffs current ↔ recorded; surfaces a one-line notice if non-empty |
