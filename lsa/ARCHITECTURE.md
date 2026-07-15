# Living Spec Architecture (LSA)
**Author:** Nikita Zverev
**Status:** Vision-aligned; dogfooded on `claude-marketplace`; each skill cites `core/output` for output discipline. The current plugin version lives in [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json); its history in [`CHANGELOG.md`](./CHANGELOG.md). See [`../.lsa/2026-05-20-lsa-v0.2.0-design.md`](../.lsa/2026-05-20-lsa-v0.2.0-design.md) for the earlier baseline and [`../.lsa/plans/2026-05-20-credo-rollout-plan.md`](../.lsa/plans/2026-05-20-credo-rollout-plan.md) for the credo-rollout restructure.

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
- **Content discipline** — [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) (8 rules)
- **Output discipline** — [`../core/skills/output/SKILL.md`](../core/skills/output/SKILL.md) (canonical source-of-truth; cite by link, never restate the count)
- **Flow types (Quick / Standard / Extended — was T1/T2/T3) + boundary signals** — [`../.lsa/VISION.md`](../.lsa/VISION.md) §4
- **Testing policy** — [`../.lsa/standards/testing.md`](../.lsa/standards/testing.md)

---

## 2. Directory Structure

```
/
├── CLAUDE.md                          ← Slim Claude Code entry point.
├── project-map.yaml                   ← GENERATED 3-level repo atlas (lsa/scripts/project-map-build.sh; discovery scoping)
├── .lsa.yaml                          ← LSA configuration (optional; defaults applied if absent)
├── scripts/                           ← Repo-internal gates (outside every plugin's artifact_paths)
│   ├── lint.sh                        ← the C1–C12 invariant lint (CI-enforced)
│   ├── build-vision-digest.sh         ← regenerates .lsa/VISION-digest.md from .lsa/VISION.md
│   ├── gate.sh, roadmap-row.sh        ← aggregate gate runner + first-backlog-row extractor
│   └── …
├── core/                              (the core plugin — independent of LSA)
│   ├── CLAUDE.md                      ← The canonical always-on card
│   └── skills/                        (the six discipline skills — see core/README.md for the table)
├── lsa/
│   ├── hooks/
│   │   ├── hooks.json
│   │   └── session-start-drift-check.sh
│   ├── scripts/
│   │   ├── project-map-build.sh       ← emits repo-root project-map.yaml (shipped)
│   │   ├── project-map-check.sh       ← rebuild + porcelain freshness gate (shipped)
│   │   └── tests/test-project-map.sh
│   ├── CORE.md                        ← the one-page contract every skill follows
│   ├── agents/orchestrator.md         ← entry-point conductor
│   └── skills/                        (the spec-loop skills — see README.md for the table)
└── ${specs_root}/                     (defaults to .lsa/ — also holds constitution at .lsa/VISION.md)
    ├── VISION.md                      ← The constitution (full)
    ├── VISION-digest.md               ← GENERATED structural digest of VISION.md (build-vision-digest.sh; the mandatory constitution read)
    ├── main.spec.md                   ← App-level behavior, module index, global contracts
    ├── roadmap.md                     ← Prioritized feature backlog
    ├── research-backlog.md            ← Mid-feature ideas, deferred decisions
    ├── metrics.md                     ← Optional aggregate (one row per archived feature)
    ├── pitches/                       ← Shaped pitches (manager:shape) awaiting decomposition
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
    │       ├── grounding.md           ← per-reference grounding result (verify)
    │       └── conformance.md         ← requirement ↔ hunk coverage table (reconcile)
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

gate:                                # optional; the quality-gate script contract (default: {})
  <check-name>: <command>            # e.g. test: npm test

autonomy: manual                     # manual | semi | auto. default: manual
paired_verify: off                   # off | checkpoint | async. default: off

routing:                             # optional; per-dispatch model tier map (default: {} → inherit everywhere)
  <surface-key>: <tier>              # e.g. manager:check: haiku. tier ∈ inherit | sonnet | haiku
```

- `constitution` — every LSA skill reads this first.
- `specs_root` — every `${specs_root}/...` reference resolves under this prefix.
- `mode` —
  - `code` — verify diffs `/src/`.
  - `docs` — verify diffs each module's `artifact_paths` against `main`; no `/src/`.
  - `mixed` — both; either failing fails verify.
- `modules.<name>.spec` — path to that module's spec.md.
- `modules.<name>.artifact_paths` — globs (repo-root-relative) that implement this module; consumed by verify (doc-mode), reconcile (drift diff), and the SessionStart hook.
- `gate` — per-check name → command; each check passes iff its command exits `0`, and a completion state may be reported only with the command + output cited (`core/ground-rules` Rule 7). Consumed by `reconcile` and, in parallel runs, mapped to GitHub required-check slots. LSA hardcodes no tool. Full contract: [`knowledge/quality-gate-contract.md`](./knowledge/quality-gate-contract.md).
- `autonomy` — `manual | semi | auto` (default `manual`); how much human-in-the-loop a parallel `manager:implement` run uses at the merge/deploy boundary. `manual` = the human merges; `semi` = auto-merge on green into the integration branch; `auto` = + deploy + healthcheck. The gate is identical at every level — autonomy removes only the prompt after green, never the gate. Consumed by `manager:implement`; semantics in `manager/knowledge/autonomy-policy.md`.
- `routing` — per-Agent-dispatch model tier map (default `{}`); surface-key → `inherit | sonnet | haiku`, read at dispatch time. Absent key or a model the plan lacks ⇒ `inherit` (never a hard error); floored surfaces (`lsa:reconcile` grader, `lsa:delegate` implementer, `manager:implement` fan-out) never route below `inherit`. Zero `model:` pins ship in frontmatter. Full contract + tier table: [`knowledge/model-routing.md`](./knowledge/model-routing.md).
- `paired_verify` — `off | checkpoint | async` (default `off`); whether `lsa:delegate` gates the build increment-by-increment. `off` = today's package → dispatch → await, no verifier injected; `checkpoint` = delegate injects a pause+signal protocol so the implementer, after each plan task F-K, writes a checkpoint-signal note and stops, and delegate dispatches [`observer:verify-checkpoint`](../observer/skills/verify-checkpoint/SKILL.md) to grade each increment (CLEAR auto-proceeds, BLOCK surfaces to the human); `async` = **not yet implemented** (the concurrent-interrupt model is reserved for a later pitch; delegate errors rather than degrading). Consumed by `lsa:delegate`; the checkpoint-signal contract (fields `target`/`since`/`spec`/`status`, plus the delegate-owned shared note path) is [`observer/skills/verify-checkpoint/SKILL.md:22-37`](../observer/skills/verify-checkpoint/SKILL.md).

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
