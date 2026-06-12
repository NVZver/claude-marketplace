# Living Spec Architecture (LSA)
**Version:** 0.16.5 (plugin)
**Author:** Nikita Zverev
**Status:** 0.4.0 — Vision-aligned; dogfooded on `claude-marketplace`; each skill cites `core/output` for output discipline. See [`../.lsa/2026-05-20-lsa-v0.2.0-design.md`](../.lsa/2026-05-20-lsa-v0.2.0-design.md) for the earlier baseline and [`../.lsa/plans/2026-05-20-credo-rollout-plan.md`](../.lsa/plans/2026-05-20-credo-rollout-plan.md) for the credo-rollout restructure.

---

## 1. Purpose

LSA is a spec-first development methodology where specs are the permanent source of truth and code (or any other behavior-bearing artifact) is always agent-generated to match them.

Humans write and own specs; an **external implementer** (any coding agent, or a human) writes the code. LSA is **technology-agnostic** and is **not** the implementer — it runs two grounding checks using EARS + Gherkin: `verify` before delegation (ground the spec against the codebase) and `reconcile` after (run the scenarios against the diff). Direct code edits are absorbed into the spec via the **reconcile loop** rather than blocked (`.lsa/VISION.md:135`).

### How `core/output` constrains LSA

Every LSA skill's human-facing prompt and output adopts a component-specific format (the S1–S17 samples in `.lsa/plans/2026-05-20-credo-rollout-plan.md`) that satisfies the golden rules in [`../core/skills/output/SKILL.md`](../core/skills/output/SKILL.md) (canonical list lives there — no rule restatement here per the canonical-source clause). The mechanical consequences across LSA:

- **`discover` Standard-flow output is a 3-row table** (Module / Change / AC), not a paragraph — verdict-first, scannable. Extended-flow continues into 3 bundled User Verifications (1: Requirements + Contract Trigger; 2: Test Suites + Contract + Design; 3: Final Integration) — fewer interruptions, same coverage. Formerly split across `lsa-discover` + `lsa-specify`; merged in v0.8.0.
- **`verify` reports lead with the verdict** (`✅ PASS` / `❌ FAIL` / `⚠️ PASS WITH WARNINGS`); metadata moves below the fold.
- **Every decision-bearing prompt uses `AskUserQuestion`** in Claude Code (per `.lsa/VISION.md` §2 principle 9 — *"Substrate-native first"*); text decision-blocks are the fallback for plain-text rendering.

This document is the design-rationale narrative for `lsa`. For other concerns, see:

- **Operating constitution + first principles** — [`../.lsa/VISION.md`](../.lsa/VISION.md)
- **Per-skill behavior** — [`skills/*/SKILL.md`](./skills/) (each `SKILL.md` is the source of truth for its skill)
- **User-facing skill list + install** — [`README.md`](./README.md)
- **Module-level invariants** — [`../.lsa/modules/lsa/spec.md`](../.lsa/modules/lsa/spec.md)
- **Content discipline** — [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) (6 rules)
- **Output discipline** — [`../core/skills/output/SKILL.md`](../core/skills/output/SKILL.md) (canonical source-of-truth; cite by link, never restate the count)
- **Flow types (Quick / Standard / Extended — was T1/T2/T3) + boundary signals** — [`../.lsa/VISION.md`](../.lsa/VISION.md) §4
- **Testing policy** — [`../.lsa/standards/testing.md`](../.lsa/standards/testing.md)

---

## 2. Directory Structure

```
/
├── CLAUDE.md                          ← Slim Claude Code entry point.
├── .lsa.yaml                          ← LSA configuration (optional; defaults applied if absent)
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
│   ├── CORE.md                        ← the one-page contract every skill follows
│   ├── agents/orchestrator.md         ← entry-point conductor
│   └── skills/                        (the spec-loop skills — see README.md for the table)
└── ${specs_root}/                     (defaults to .lsa/ — also holds constitution at .lsa/VISION.md)
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
    │       ├── requirements.md        ← EARS requirements + user flows (specify)
    │       ├── <flow>.feature         ← Gherkin acceptance scenarios (specify)
    │       └── grounding.md           ← per-reference grounding result (verify)
    └── archive/
        └── YYYY-MM-DD-<feature-name>/
            └── (the archived feature spec files)
```

`${specs_root}` is configurable via `.lsa.yaml` (see §3). Default is `.lsa/` — chosen so the entire LSA workspace (constitution + specs + roadmap + pitches + standards + archive) lives under a single directory the user can `rm -rf` to fully detach.

---

## 3. `.lsa.yaml` configuration

LSA is path-configurable via `.lsa.yaml` at the repo root. Schema (all keys optional; defaults applied when absent):

```yaml
# .lsa.yaml — Living Spec Architecture configuration
# Schema version: 1 (matches lsa plugin major version 0.x.y)

constitution: .lsa/VISION.md         # default: .lsa/VISION.md
specs_root: .lsa/                    # default: .lsa/
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

**When absent**, LSA applies the defaults documented in [`knowledge/conventions.md`](./knowledge/conventions.md) §"`.lsa.yaml` defaults": `constitution: .lsa/VISION.md`, `specs_root: .lsa/`, `mode: code`, `modules: {}`. A fresh `lsa:init` scaffolds the spec tree under `.lsa/` so the entire LSA workspace is one removable directory.

The SessionStart hook (`hooks/hooks.json` declares `matcher: "startup"`) invokes `hooks/session-start-drift-check.sh`. For each module, the hook resolves the baseline SHA as the last commit that modified the module's spec file (`git log -1 --format=%H -- <spec-path>`); if any of the module's `artifact_paths` differ from that SHA, the hook prints a one-line notice; control returns to the user, who chooses when to invoke `/lsa:reconcile`. The hook exits 0 always — it must never block session start.

---

## 4. Branch Management

### Naming Convention

| Branch Type | Pattern | Example |
|---|---|---|
| Feature | `feature/<feature-name>` | `feature/user-auth` |
| Constitution | `constitution/<change-description>` | `constitution/add-testing-rules` |

### Merge Strategy

```
feature branch → main (after lsa:reconcile passes + human PR review)
constitution branch → main (after human approval, independent of features)
```

### Rules

- `main` is always stable and spec-synced
- No direct commits to `main`
- Feature branch is created when a feature enters the loop (the `orchestrator`, or `lsa:discover` in Extended flow)
- Feature branch is deleted after merge

---

## 5. Resolved Decisions

| # | Question | Decision |
|---|----------|----------|
| OQ1 | Sub-agent source of truth | *(superseded v0.16 — epic/implement model removed; code-writing delegated to an external implementer)* |
| OQ2 | Epic agent context | *(superseded v0.16 — no epic agents; the external implementer owns execution)* |
| OQ3 | Constitution revision | Separate skill `revise-constitution`. Single Responsibility — one skill, one job |
| OQ4 | Research backlog mid-feature | Kept. Updated by human or agent to a known file without branching. Reviewed during replan |
| OQ5 | Path configuration | `.lsa.yaml` at repo root. Falls back to v0.1.1 defaults when absent |
| OQ6 | Standard-flow path (was T2) | `discover` → `specify` (light, 1 scenario) → `verify` → `delegate` → `reconcile`. Code-writing is the external implementer's. |
| OQ7 | Reconcile placement | Skill `reconcile` (SRP, mirrors LSA's one-skill-per-phase pattern) |
| OQ8 | Drift detection | Baseline SHA per module is resolved on demand from `git log -1 --format=%H -- <spec-path>` (the last commit that touched the module's spec file). SessionStart hook diffs current ↔ baseline; surfaces a one-line notice if non-empty. |
