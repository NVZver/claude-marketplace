# Living Spec Architecture (LSA)
**Version:** 0.4.0 (plugin)
**Author:** Nikita Zverev
**Status:** 0.4.0 — Vision-aligned; dogfooded on `claude-marketplace`; each skill cites `core/output` for output discipline. See [`../vision/specs/2026-05-20-lsa-v0.2.0-design.md`](../vision/specs/2026-05-20-lsa-v0.2.0-design.md) for the earlier baseline and [`../vision/plans/2026-05-20-credo-rollout-plan.md`](../vision/plans/2026-05-20-credo-rollout-plan.md) for the credo-rollout restructure.

---

## 1. Purpose

LSA is a spec-first development methodology where specs are the permanent source of truth and code (or any other behavior-bearing artifact) is always agent-generated to match them.

Humans write and own specs. Agents write and own artifacts. Direct artifact edits are absorbed into the spec via the **reconcile loop** rather than blocked (`vision/VISION.md:135`).

### How `core/output` constrains LSA

Every LSA skill's human-facing prompt and output adopts a component-specific format (the S1–S17 samples in `vision/plans/2026-05-20-credo-rollout-plan.md`) that satisfies the five golden rules in [`../core/skills/output/SKILL.md`](../core/skills/output/SKILL.md): structured, minimal, formatted, sourced, concrete. The mechanical consequences across LSA:

- **`lsa-discover` Output is a 3-row table** (Module / Change / AC), not a paragraph — verdict-first, scannable.
- **`lsa-specify` collapses 7 confirm stops to 3 bundled User Verifications** (1: Requirements + Contract Trigger; 2: Test Suites + Contract + Design; 3: Final Integration) — fewer interruptions, same coverage. Renamed from `Gate N` in `lsa` v0.6.2; prior CHANGELOG entries use the old name.
- **`lsa-verify` reports lead with the verdict** (`✅ PASS` / `❌ FAIL` / `⚠️ PASS WITH WARNINGS`); metadata moves below the fold.
- **Every decision-bearing prompt uses `AskUserQuestion`** in Claude Code (per `vision/VISION.md` §2 principle 9 — *"Substrate-native first"*); text decision-blocks are the fallback for plain-text rendering.

This document is the design-rationale narrative for `lsa`. For other concerns, see:

- **Operating constitution + first principles** — [`../vision/VISION.md`](../vision/VISION.md)
- **Per-skill behavior** — [`skills/*/SKILL.md`](./skills/) (each `SKILL.md` is the source of truth for its skill)
- **User-facing skill list + install** — [`README.md`](./README.md)
- **Module-level invariants** — [`../vision/specs/modules/lsa/spec.md`](../vision/specs/modules/lsa/spec.md)
- **Content discipline** — [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) (6 rules)
- **Output discipline** — [`../core/skills/output/SKILL.md`](../core/skills/output/SKILL.md) (4 golden rules)
- **Flow types (Quick / Standard / Extended — was T1/T2/T3) + boundary signals** — [`../vision/VISION.md`](../vision/VISION.md) §4
- **Testing policy** — [`../vision/specs/standards/testing.md`](../vision/specs/standards/testing.md)

---

## 2. Directory Structure

```
/
├── CLAUDE.md                          ← Slim Claude Code entry point.
├── .lsa.yaml                          ← LSA configuration (optional; defaults applied if absent)
├── .lsa-sync-state.json               ← Per-module last-sync SHA (written by lsa-sync)
├── core/                              (the core plugin — independent of LSA)
│   ├── CLAUDE.md                      ← The canonical always-on fragment
│   └── skills/
│       ├── ground-rules/SKILL.md
│       ├── actor-template/SKILL.md
│       └── flow-selector/SKILL.md           (renamed from tier-selector in core v0.5.2)
├── lsa/
│   ├── hooks/
│   │   ├── hooks.json
│   │   └── session-start-drift-check.sh
│   └── skills/                        (eight skills — see README.md for the table)
└── ${specs_root}/                     (defaults to /specs/)
    ├── main.spec.md                   ← App-level behavior, module index, global contracts
    ├── roadmap.md                     ← Prioritized feature backlog
    ├── research-backlog.md            ← Mid-feature ideas, deferred decisions
    ├── metrics.md                     ← Optional aggregate (one row per archived feature)
    ├── standards/
    │   ├── code.md
    │   └── testing.md
    ├── modules/
    │   └── <module-name>/
    │       └── spec.md                ← Permanent module spec
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
            └── metrics.md             (written by lsa-verify on clean Extended-flow PASS — was T3)
```

`${specs_root}` is configurable via `.lsa.yaml` (see §3). Defaults match v0.1.1 (`/specs/`).

---

## 3. `.lsa.yaml` configuration

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
  - `code` — verify diffs `/src/`.
  - `docs` — verify diffs each module's `artifact_paths` against `main`; no `/src/`.
  - `mixed` — both; either failing fails verify.
- `modules.<name>.spec` — path to that module's spec.md.
- `modules.<name>.artifact_paths` — globs (repo-root-relative) that implement this module; consumed by verify (doc-mode), reconcile (drift diff), and the SessionStart hook.

**When absent**, LSA falls back to v0.1.1 behavior: `constitution: /CLAUDE.md`, `specs_root: /specs/`, `mode: code`, `modules: {}`. This preserves all existing behavior for projects that haven't opted in.

The SessionStart hook (`hooks/hooks.json` declares `matcher: "startup"`) invokes `hooks/session-start-drift-check.sh`. If any module's `artifact_paths` differ from the SHA recorded in `.lsa-sync-state.json`, the hook prints a one-line notice; control returns to the user, who chooses when to invoke `/lsa:reconcile`. The hook exits 0 always — it must never block session start.

---

## 4. Branch Management

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

## 5. Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| OQ1 | Sub-agent source of truth | `tasks.md` is the single source. Each agent reads and writes only its own epic section |
| OQ2 | Epic agent context | All agents inherit the configured constitution. No scoped overrides |
| OQ3 | Constitution revision | Separate skill `lsa-revise-constitution`. Single Responsibility — one skill, one job |
| OQ4 | Research backlog mid-feature | Kept. Updated by human or agent to a known file without branching. Reviewed during replan |
| OQ5 | Path configuration | `.lsa.yaml` at repo root. Falls back to v0.1.1 defaults when absent |
| OQ6 | Standard-flow path (was T2) | `lsa-discover` (three-question probe) → implement (TDD) → `lsa-verify`. No specify, no plan, no sync, no per-feature metrics |
| OQ7 | Reconcile placement | New skill `lsa-reconcile` (SRP, mirrors LSA's one-skill-per-phase pattern) |
| OQ8 | Drift detection | `.lsa-sync-state.json` records last-sync commit SHA per module. SessionStart hook diffs current ↔ recorded; surfaces a one-line notice if non-empty |
