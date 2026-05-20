# Living Spec Architecture (LSA)
**Version:** 0.1.0 (plugin)
**Author:** Nikita Zverev
**Status:** Installable as `lsa@nz-vision` — pending stress test on actual project use. See [`CHANGELOG.md`](./CHANGELOG.md) Unreleased for known v0.2.0 adaptations.

---

## 1. Purpose

LSA is a spec-first development methodology where specs are the permanent source of truth and code is always agent-generated to match them.

Humans write and own specs. Agents write and own code.

---

## 2. Core Principles

| # | Principle |
|---|-----------|
| P1 | Specs are written before any code is generated |
| P2 | Code always follows specs — never the other way around |
| P3 | The human is the source of truth at every decision gate |
| P4 | Fact-grounding per [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) Rule 1 — every factual claim carries a source + searchable quote |
| P5 | Every code change must trace to a spec requirement |
| P6 | Feature specs are temporary. Module specs are permanent |
| P7 | Nothing proceeds past a gate without explicit human approval |

---

## 3. Directory Structure

```
/
├── CLAUDE.md                          ← Root constitution (mandatory, always read first)
├── .claude/
│   └── skills/
│       ├── lsa-init/SKILL.md
│       ├── lsa-specify/SKILL.md
│       ├── lsa-plan/SKILL.md
│       ├── lsa-verify/SKILL.md
│       ├── lsa-sync/SKILL.md
│       └── lsa-revise-constitution/SKILL.md
├── specs/
│   ├── main.spec.md                   ← App-level behavior, module index, global contracts
│   ├── roadmap.md                     ← Prioritized feature backlog
│   ├── research-backlog.md            ← Mid-feature ideas, deferred decisions
│   ├── standards/
│   │   ├── code.md                    ← Code structure, patterns, conventions
│   │   ├── testing.md                 ← Test structure, coverage requirements, TDD rules
│   │   └── agents.md                  ← Agent behavior, human interaction rules
│   ├── modules/
│   │   └── <module-name>/
│   │       └── spec.md                ← Permanent module spec (never deleted)
│   ├── features/
│   │   └── <feature-name>/
│   │       ├── requirements.md        ← Functional + non-functional requirements (human confirms)
│   │       ├── test-suites.md         ← E2E user journeys (human confirms)
│   │       ├── contract.yaml          ← OpenAPI 3.x contract (human soft-confirms, if applicable)
│   │       ├── design.md              ← Technical approach, derived from contract when present
│   │       └── tasks.md               ← Epics, ACs, test plans, status
│   └── archive/
│       └── YYYY-MM-DD-<feature-name>/ ← Completed feature specs (read-only)
└── src/
    └── ...                            ← Always agent-generated. Never hand-edited.
```

---

## 4. Components

### 4.1 Constitution (`/CLAUDE.md`)

| | |
|---|---|
| **Purpose** | Single root document defining how this project operates |
| **Role** | Every agent reads this first, on every task, without exception |
| **Owns** | Project name, tech stack, directory structure, coding conventions, agent rules |
| **Written by** | Human |
| **Updated by** | Human via constitution revision (see §8) |
| **Never contains** | Feature requirements, implementation details, business logic |

---

### 4.2 Standards (`/specs/standards/`)

| | |
|---|---|
| **Purpose** | Technical standards that apply across all features |
| **Role** | Loaded by agents when relevant to the current task |
| **Files** | `code.md` — patterns, naming, file structure |
| | `testing.md` — TDD rules, test types, coverage thresholds |
| | `agents.md` — how agents behave, escalation rules, human gates |
| **Written by** | Human (extracted from CLAUDE.md during init) |
| **Updated by** | Constitution revision skill after human approval |
| **Relationship to constitution** | Constitution = what the project is. Standards = how to build it |

---

### 4.3 Main Spec (`/specs/main.spec.md`)

| | |
|---|---|
| **Purpose** | App-level behavioral contract and module index |
| **Role** | Source of truth for cross-module contracts, global NFRs, and module inventory |
| **Owns** | Module index, cross-module API contracts, global non-functional requirements |
| **Updated by** | `lsa-sync` after each feature merge (human reviews each update) |
| **Never contains** | Feature-level requirements, implementation details |

---

### 4.4 Roadmap (`/specs/roadmap.md`)

| | |
|---|---|
| **Purpose** | Prioritized list of upcoming features |
| **Role** | Reviewed before every feature. Prevents building the wrong thing next |
| **Format** | Ordered table: Feature / Priority / Status / Notes |
| **Updated by** | Human during replanning phase |
| **Key rule** | A feature cannot start without appearing on the roadmap first |

---

### 4.5 Module Specs (`/specs/modules/<name>/spec.md`)

| | |
|---|---|
| **Purpose** | Permanent behavioral record of each module |
| **Role** | Describes what a module does, its contracts, constraints, and behaviors |
| **Contains** | Functional behaviors, non-functional constraints, cross-module contracts |
| **Never contains** | Code, implementation details, feature history |
| **Created** | By `lsa-init` (brownfield: inferred; greenfield: first feature touching the module) |
| **Updated** | By `lsa-sync` after each feature merge — append only, tagged with source feature |
| **Deleted** | Never |

---

### 4.6 Feature Spec (`/specs/features/<name>/`)

| | |
|---|---|
| **Purpose** | Captures everything needed to implement one feature |
| **Role** | Source of truth for agents during implementation of that feature only |
| **Lifecycle** | Created by `lsa-specify` → approved by human → used during implementation → archived by `lsa-sync` |
| **Files** | `requirements.md` — functional + non-functional requirements, ACs. **Human confirms** |
| | `test-suites.md` — E2E user journeys with goal, actions, and alternative paths. **Human confirms** |
| | `contract.yaml` — OpenAPI 3.x contract. **Human soft-confirms.** Only created when feature introduces or modifies an API endpoint, request/response shape, database schema, or shared data type |
| | `design.md` — technical approach, modules affected. Derived from contract when contract exists |
| | `tasks.md` — epics, branches, ACs, test plans, status, integration checklist |
| **After merge** | Delta extracted to module specs → entire directory moved to `/specs/archive/` |
| **Deleted** | Never — archived, not deleted |

---

### 4.7 Research Backlog (`/specs/research-backlog.md`)

| | |
|---|---|
| **Purpose** | Captures mid-feature ideas and deferred decisions without polluting the current branch |
| **Role** | Parking lot. Nothing here blocks current work |
| **Format** | Date / Topic / Summary / Recommendation / Status |
| **Updated by** | Human or agent during any phase when an idea arises |
| **Consumed by** | Human during replanning — promotes entries to roadmap or discards them |

---

## 5. Workflow Phases

### Pre-Feature Checklist (AI Fatigue Prevention)

Before every new feature, verify:

- [ ] Previous feature branch merged to main
- [ ] `/specs/features/` is empty (sync complete)
- [ ] Agent context cleared
- [ ] Roadmap reviewed — next feature confirmed correct

---

### Phase 1 — Specify (`lsa-specify`)

| | |
|---|---|
| **Input** | Human's feature description |
| **Process** | Agent asks clarifying questions → human answers → agent writes spec files in order |
| **Produces branch** | `feature/<feature-name>` |

**Confirm gate types:**
- **Hard Confirm:** Stop completely. Do not proceed until human explicitly approves. No implicit approval.
- **Soft Confirm:** Present artifact. Wait for approval or corrections. Human may approve, correct inline, or delegate corrections to agent.

**Gate sequence — each step requires explicit human approval before next step begins:**

| Step | Output | Gate type |
|------|--------|-----------|
| 1 | `requirements.md` | Hard confirm. Evaluate contract trigger after confirmation |
| 2 | `test-suites.md` | Hard confirm |
| 3 | `contract.yaml` | Soft confirm. Skip if contract trigger = no |
| 4 | `design.md` | Soft confirm |
| 5 | Full spec review | Integration check — verify: every AC has a journey, design matches contract, Open Questions resolved |

**Contract trigger condition:** feature introduces or modifies any of:
- API endpoint (path, method, request, response)
- Request or response schema
- Database schema or table structure
- Shared data type used across modules

---

### Phase 2 — Plan (`lsa-plan`)

| | |
|---|---|
| **Input** | Approved `requirements.md`, `test-suites.md`, and `design.md` |
| **Process** | Agent decomposes into ≤5 parallel-safe epics, runs self-verification |
| **Output** | `tasks.md` with epic details, ACs, test plans, branch names, integration checklist |
| **Gate** | Human reviews and explicitly approves tasks.md |
| **Self-verification** | Traceability, accuracy, consistency, test coverage, completeness checks |

---

### Phase 3 — Implement

| | |
|---|---|
| **Input** | Approved `tasks.md` |
| **Process** | Each epic assigned to a sub-agent on its own branch |
| **Source of truth** | `tasks.md` — one file, one source. Each agent reads its epic section and writes status updates only to that section. Orchestrator reads the full file |
| **Context** | All agents inherit from root `/CLAUDE.md`. No scoped overrides |
| **Each agent must** | Meet all ACs, write tests per TDD policy (§6), update its epic status in tasks.md |
| **Agents may** | Create subtasks within their epic scope, recorded in their tasks.md section |
| **Agents must not** | Touch files outside their declared scope or write to another epic's section |
| **Branch per epic** | `feature/<feature-name>-e<N>` |

---

### Phase 4 — Sub-Agent Deep Review

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
| **Input** | Implemented code + feature spec |
| **Core check** | Every code change traces to a spec requirement. No untraced changes allowed |
| **Process** | `git diff main -- specs/features/<name>/` vs `git diff main -- src/` |
| **Checklist** | Scope, accuracy, test coverage, code quality |
| **Output** | Verification report with PASS / FAIL / PASS WITH WARNINGS |
| **Gate** | FAIL or BLOCKER → stop, fix, re-verify. PASS → proceed to sync on human approval |

---

### Phase 6 — Sync (`lsa-sync`)

| | |
|---|---|
| **Input** | Verified feature branch |
| **Process** | Extract system-level decisions → merge into module specs → update main.spec.md → archive feature spec |
| **Gate** | Human reviews delta summary before any files are written |
| **Output** | Updated module specs, updated main.spec.md, feature archived |
| **Post-sync** | `/specs/features/` is empty. Branch ready for PR to main |

---

### Phase 7 — Replan

| | |
|---|---|
| **Input** | Merged feature |
| **Process** | Review roadmap. Promote research backlog items. Revise constitution if needed |
| **Output** | Updated roadmap. Optional: constitution revision (triggers §8) |
| **Key question** | Does the next roadmap item still make sense? |

---

## 6. Testing Policy

Source of truth: `/specs/standards/testing.md`

### E2E Tests

| Rule | Definition |
|------|------------|
| Driven by | `test-suites.md` — every journey and every path must have a corresponding test |
| Frontend | Page Object Model. One Page Object per page or component. No direct DOM selectors in tests |
| Coverage | All paths in test-suites.md covered. No path may be skipped without human approval |
| Framework | Defined in CLAUDE.md |

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
| Location | Co-located with source or in `__tests__/` per CLAUDE.md |
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
| Test command | Defined in CLAUDE.md. Agents run it before marking any work complete |
| Exceptions | Must be explicitly approved by human and noted in tasks.md |

---

## 7. Fact-Check Policy

Fact-grounding is governed by the [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) skill — Rule 1 (every factual claim carries a source + searchable quote) and Rule 2 (no fake confidence). LSA does not restate those rules; it requires every spec, verification report, and constitution change to follow them.

**Marker reconciliation pending.** Historical LSA uses `[ASSUMPTION: <reason>]` (uppercase). Core uses `[assumption: <why>]` / `[cannot verify]` (lowercase). To be aligned in LSA v0.2.0; see [`CHANGELOG.md`](./CHANGELOG.md) Unreleased.

**Verifier responsibility unchanged.** `lsa-verify` checks that every code change traces to a spec requirement — LSA's distinct core contract, separate from fact-grounding.

---

## 8. Constitution Revision (`lsa-revise-constitution`)

Single responsibility: propose and apply changes to `/CLAUDE.md` and `/specs/standards/` files. This skill does nothing else.

| | |
|---|---|
| **Trigger (auto)** | After feature merge, during replan phase |
| **Trigger (manual)** | `/lsa:revise-constitution` |
| **Input** | Completed feature spec + human's proposed change description |
| **Process** | Agent proposes specific changes with diff format. Human reviews each change individually |
| **Gate** | No change is written without explicit human approval per change |
| **Output** | Updated `/CLAUDE.md` and/or `/specs/standards/` files |
| **Branch** | `constitution/<change-description>` |
| **Traceability** | Every change tagged: `<!-- revised: [feature-name] [YYYY-MM-DD] -->` |
| **Scope** | CLAUDE.md and standards only. Never touches specs, src, or skills |

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

| Skill | Trigger (auto) | Manual | Purpose |
|---|---|---|---|
| `lsa-init` | CLAUDE.md exists but /specs/ does not | `/lsa:init` | Initialize spec structure |
| `lsa-specify` | Human describes a feature | `/lsa:specify` | Create feature spec |
| `lsa-plan` | Feature spec approved | `/lsa:plan` | Decompose into epics |
| `lsa-verify` | Epic or feature marked implemented | `/lsa:verify` | Verify spec ↔ code alignment |
| `lsa-sync` | Verify passed | `/lsa:sync` | Sync spec to modules, archive feature |
| `lsa-revise-constitution` | After feature merge (replan phase) | `/lsa:revise-constitution` | Propose and apply constitution changes |

---

## 11. Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| OQ1 | Sub-agent source of truth | `tasks.md` is the single source. Each agent reads and writes only its own epic section |
| OQ2 | Epic agent context | All agents inherit root `/CLAUDE.md`. No scoped overrides |
| OQ3 | Constitution revision | Separate skill `lsa-revise-constitution`. Single Responsibility — one skill, one job |
| OQ4 | Research backlog mid-feature | Kept. Updated by human or agent to a known file without branching. Reviewed during replan |
