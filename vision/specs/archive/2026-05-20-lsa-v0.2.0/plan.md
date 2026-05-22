<!-- ARCHIVED 2026-05-22: moved from vision/plans/2026-05-20-lsa-v0.2.0-plan.md → vision/specs/archive/2026-05-20-lsa-v0.2.0/plan.md as part of feature/2026-05-21-maintenance-cleanup. Internal historical path references below are preserved as written at time of authorship; only the active "Source spec" link (line 13) was rewritten to resolve from the new location. -->

# LSA v0.2.0 + Core v0.2.0 Implementation Plan

> **For agentic workers:** Use `dev-plugin:implement` or `lsa:lsa-plan`'s sub-agent pattern to execute this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Each task has explicit Inputs / Outputs / Files / Verification / Spec trace.

**Goal:** Ship `core` v0.2.0 (adds `tier-selector` skill + always-on tier fragment) and `lsa` v0.2.0 (closes seven Vision-alignment gaps), then bootstrap this repo's `vision/specs/` tree so LSA actually runs against itself end-to-end.

**Architecture:** Two plugins evolve independently with their own SemVer + CHANGELOG. Core ships first (its v0.2.0 is consumed by lsa v0.2.0). Then lsa v0.2.0. Then the this-repo bootstrap as the dogfood probe. Per-plugin SemVer + CHANGELOG per `vision/VISION.md` §1 *"Distribution + versioning"*.

**Tech Stack:** Markdown (`SKILL.md`, `ARCHITECTURE.md`, specs), JSON (`plugin.json`, `marketplace.json`, `.lsa-sync-state.json`), YAML (`.lsa.yaml`), bash (hook scripts), Claude Code (`/plugin`, `/help`, `/reload-plugins`, slash-skill invocation).

**Source spec:** [`./design.md`](./design.md) — every task below traces to a spec section.

---

## File map (what's created or modified)

| Path | Status | Phase | Responsibility |
| --- | --- | --- | --- |
| `core/skills/tier-selector/SKILL.md` | Create | A | New Actor skill — boundary signals + classification |
| `core/CLAUDE.md` | Create | A | Always-on tier-rule fragment shipped in core |
| `core/.claude-plugin/plugin.json` | Modify | A | Bump version 0.1.0 → 0.2.0; update description |
| `core/README.md` | Modify | A | Add tier-selector + CLAUDE.md fragment install instructions |
| `core/VERIFICATION.md` | Modify | A | Add V2 probe for tier-selector |
| `core/CHANGELOG.md` | Modify | A | v0.2.0 release entry |
| `lsa/skills/lsa-discover/SKILL.md` | Create | B | New light-discovery skill |
| `lsa/skills/lsa-reconcile/SKILL.md` | Create | B | New drift-absorption skill |
| `lsa/skills/lsa-init/SKILL.md` | Modify | B | Mechanical relabel; reads `.lsa.yaml`; brownfield uses artifact_paths |
| `lsa/skills/lsa-specify/SKILL.md` | Modify | B | Mechanical relabel; accepts discovery.md from lsa-discover |
| `lsa/skills/lsa-plan/SKILL.md` | Modify | B | Mechanical relabel |
| `lsa/skills/lsa-verify/SKILL.md` | Modify | B | **Substantive rewrite** (per design §5) — 5-section actor + `.lsa.yaml` path swap + doc-mode branch + metrics.md writer |
| `lsa/skills/lsa-sync/SKILL.md` | Modify | B | **Substantive rewrite** (per design §5) — 5-section actor + `.lsa.yaml` path swap + `.lsa-sync-state.json` writer + metrics aggregator |
| `lsa/skills/lsa-revise-constitution/SKILL.md` | Modify | B | Mechanical relabel; uses configured constitution path |
| `lsa/hooks/hooks.json` | Create | B | Plugin hook manifest (single file declaring SessionStart per `code.claude.com/docs/en/hooks`) |
| `lsa/hooks/session-start-drift-check.sh` | Create | B | Drift detection script invoked by the SessionStart hook |
| `lsa/ARCHITECTURE.md` | Modify | B | Major update — new skills, tiers, reconcile, doc-mode, `.lsa.yaml`, K-vs-A note |
| `lsa/README.md` | Modify | B | Mention new skills + `.lsa.yaml` |
| `lsa/.claude-plugin/plugin.json` | Modify | B | Bump version 0.1.1 → 0.2.0; update description |
| `lsa/CHANGELOG.md` | Modify | B | v0.2.0 entry (moves [Unreleased] in) |
| `/.lsa.yaml` | Create | C | This repo's config — points at vision/VISION.md and vision/specs/ |
| `vision/specs/main.spec.md` | Create | C | Module index, cross-plugin contracts, NFRs |
| `vision/specs/standards/code.md` | Create | C | Markdown-only, SemVer + CHANGELOG, plugin layout |
| `vision/specs/standards/testing.md` | Create | C | Manual VERIFICATION.md probes per plugin |
| `vision/specs/standards/agents.md` | Create | C | Gate types, escalation rules |
| `vision/specs/roadmap.md` | Create | C | From VISION §6 / §7 / post-0.2.0 follow-ups |
| `vision/specs/research-backlog.md` | Create | C | Empty table |
| `vision/specs/modules/core/spec.md` | Create | C | Three skills with behavioral contracts |
| `vision/specs/modules/lsa/spec.md` | Create | C | Eight skills, eight numbered phases (Phase 0 + Phases 1–7) plus ad-hoc Reconcile, gates |
| `vision/specs/archive/2026-05-20-core-v1/design.md` | Relocate | C | Moved from `vision/specs/archive/2026-05-20-core-v1/design.md` |
| `vision/specs/archive/2026-05-20-core-v1/tasks.md` | Relocate | C | Moved from `vision/specs/archive/2026-05-20-core-v1/tasks.md` |
| `/CLAUDE.md` | Modify | C | Slim to thin entry point + tier fragment |

The "tests" are V1/V2/V3 manual probes per design §13 — no automated harness in v0.2.0.

---

## Task order rationale

Three phases, run top-to-bottom. Within each phase, **V1 probe runs before any body content** (per design §13 *"Run V1 first, not last"*).

**Phase A — Core v0.2.0** (Tasks 1–8). Adds `tier-selector` and the CLAUDE.md fragment. Ships first because `lsa-discover` in Phase B depends on it. End of Phase A: core v0.2.0 tagged and pushable.

**Phase B — LSA v0.2.0** (Tasks 9–25). Two new skills, six reshaped, doc-mode, sync state, metrics, hook, marker sweep, docs. End of Phase B: lsa v0.2.0 tagged and pushable.

**Phase C — This-repo bootstrap** (Tasks 26–34). Creates `/.lsa.yaml`, the `vision/specs/` tree, slims `/CLAUDE.md`, relocates archive content. End of Phase C: `/lsa:verify` succeeds on a fresh feature branch in this repo.

---

# Phase A — Core v0.2.0

### Task 1 — Add `tier-selector` skill stub

**Inputs:** `core/skills/` contains `ground-rules/` and `actor-template/`. `tier-selector/` does not exist.
**Outputs:** `core/skills/tier-selector/SKILL.md` exists with frontmatter only.
**Files:** Create `core/skills/tier-selector/SKILL.md`.
**Verification:** `head -2 core/skills/tier-selector/SKILL.md` shows `---` then `name: tier-selector`.
**Spec trace:** §4.1.

- [ ] **1. Create the directory.** `mkdir -p core/skills/tier-selector`. Expected: silent.

- [ ] **2. Write the stub.** Create `core/skills/tier-selector/SKILL.md` with exactly:

```markdown
---
name: tier-selector
description: Apply before any non-trivial task — when the work touches behavior, adds a new module, changes an API or data model, exceeds ~5 files, or lacks an existing spec. Outputs a tier (T1 / T2 / T3) with visible chain-of-thought reasoning over boundary signals, then waits for human confirmation. Per Vision §4: ceremony scales to the weight of the task.
---

STUB — full body lands in Task 3.
```

- [ ] **3. Verify.** Run: `head -2 core/skills/tier-selector/SKILL.md`. Expected output:

```
---
name: tier-selector
```

- [ ] **4. Commit.**

```bash
git add core/skills/tier-selector/SKILL.md
git commit -m "feat(core): add tier-selector skill stub (frontmatter only)"
```

---

### Task 2 — V1 probe (core v0.2.0 install on Claude Code) — MANUAL

**Inputs:** Task 1 complete.
**Outputs:** Documented PASS/FAIL.
**Files:** none.
**Verification:** `/help` lists `/core:tier-selector` alongside the existing two.
**Spec trace:** §13 V1; design.md note "Run V1 first, not last".

This task **must be run by the human in a real Claude Code session.**

- [ ] **1. Reload plugins.** In Claude Code: `/reload-plugins`. Expected: silent reload.

- [ ] **2. Check `/help`.** Expected: three core skills listed under `/core:`: `ground-rules`, `actor-template`, `tier-selector`.

- [ ] **3. Record outcome.** Write `V1 (Code, core v0.2.0): PASS` or note the failure (most common: skill folder missing or stub frontmatter malformed). If FAIL, debug before proceeding.

---

### Task 3 — Write `tier-selector` body

**Inputs:** Task 2 returned PASS.
**Outputs:** `core/skills/tier-selector/SKILL.md` contains the full Actor body per design §4.1 (Goal / Input / Steps / Output / Constraints with boundary signals and classification table embedded in Steps).
**Files:** Modify `core/skills/tier-selector/SKILL.md`.
**Verification:** `grep -c '^## ' core/skills/tier-selector/SKILL.md` prints `>= 5` (Goal, Input, Steps, Output, Constraints minimum).
**Spec trace:** §4.1.

- [ ] **1. Read the source.** Open `vision/VISION.md` §4 to extract the boundary signals (lines 122–134) and worked examples (the four-row table).

- [ ] **2. Land the full body.** Overwrite `core/skills/tier-selector/SKILL.md`. The body must contain (per design §4.1):
  - Five labeled sections (Goal / Input / Steps / Output / Constraints).
  - In Steps: the five boundary signals as a checklist, the four-row classification table, the "stop and confirm" hard gate, the tier-specific handoff (T1 → return; T2 → invoke `lsa-discover`; T3 → invoke `lsa-discover` then `lsa-specify`).
  - Constraints: don't start LSA ceremony pre-confirmation; don't invent signals; don't silently override the human's tier choice.
  - Footer line: *"On confirm, downstream LSA skills absorb the tier into their own gates. Every output still obeys `ground-rules`."*

- [ ] **3. Verify section count.** Run: `grep -c '^## ' core/skills/tier-selector/SKILL.md`. Expected: `>= 5`.

- [ ] **4. Commit.**

```bash
git add core/skills/tier-selector/SKILL.md
git commit -m "feat(core): land tier-selector body with boundary signals and four worked examples"
```

---

### Task 4 — V2 probe for `tier-selector` — MANUAL

**Inputs:** Task 3 complete.
**Outputs:** Documented PASS/FAIL.
**Spec trace:** §13 V2.

- [ ] **1. Reload plugins.** `/reload-plugins`.

- [ ] **2. Probe T3 trigger.** In a fresh session: *"I want to add password-reset via email."* Expected: response classifies as T3 with chain-of-thought reasoning, names boundary signals (new behavior, new endpoint, auth+mailer modules, no spec yet), waits for confirmation.

- [ ] **3. Probe T1 trigger.** New session: *"Fix the typo in the login button label — should be 'Sign in'."* Expected: response classifies as T1 with reasoning (one string, no behavior change), waits for confirm.

- [ ] **4. Probe T2 trigger.** New session: *"The date formatter returns wrong month off-by-one."* Expected: T2 with reasoning (one bug, existing spec'd module, no new contract).

- [ ] **5. Record outcomes.** Write `V2 (Code, tier-selector): PASS` if all three probes classify correctly or invoke `tier-selector` explicitly. Note failures in the falsifiable-threshold log (§13).

---

### Task 5 — Create `core/CLAUDE.md` fragment

**Inputs:** Task 4 returned PASS.
**Outputs:** `core/CLAUDE.md` exists with the always-on tier fragment per design §4.2.
**Files:** Create `core/CLAUDE.md`.
**Verification:** `grep -c "tier-selector" core/CLAUDE.md` prints `>= 2`.
**Spec trace:** §4.2.

- [ ] **1. Write the file.** Create `core/CLAUDE.md` with exactly:

```markdown
# Core — CLAUDE.md fragment

This is an **opt-in fragment** to merge into your project's `CLAUDE.md` when you install the `core` plugin. It declares two always-on rules: ground-rules application and tier-selector invocation. Copy the content below into your project's `CLAUDE.md`.

---

## Ground rules (always-on)

Apply `core/ground-rules` to every substantive task. Every factual claim carries a source + searchable quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked.

## Tier selection (always-on)

Before any non-trivial task, invoke `core/tier-selector` to classify the work as T1, T2, or T3 — and present the reasoning to the human for confirmation. Skip only for tasks that obviously stay inside T1 boundaries (single-string edits, single-question answers).

**The boundary signals** (Vision §4 `vision/VISION.md:124`): new module · API/contract change · data-model change · ~5 files · no existing spec.

**Tier outcomes:**
- **T1** — single pass, no LSA ceremony. `ground-rules` still applies.
- **T2** — `lsa-discover` (light) → agent TDD → `lsa-verify`.
- **T3** — `lsa-discover` → `lsa-specify` → `lsa-plan` → implement → `lsa-verify` → `lsa-sync`.
```

- [ ] **2. Verify.** Run: `grep -c "tier-selector" core/CLAUDE.md`. Expected: `>= 2`.

- [ ] **3. Commit.**

```bash
git add core/CLAUDE.md
git commit -m "feat(core): add CLAUDE.md fragment for always-on ground-rules + tier-selector"
```

---

### Task 6 — Update `core/README.md`, `core/VERIFICATION.md`

**Inputs:** Task 5 complete.
**Outputs:** README mentions `tier-selector` + the CLAUDE.md merge step; VERIFICATION includes a V2 probe for `tier-selector`.
**Files:** Modify `core/README.md`, `core/VERIFICATION.md`.
**Verification:** `grep -c "tier-selector" core/README.md` prints `>= 1`; `grep -c "tier-selector" core/VERIFICATION.md` prints `>= 1`.
**Spec trace:** §12.3 (CHANGELOG), §13 (VERIFICATION).

- [ ] **1. Edit `core/README.md`.** In the "What's here" section, add a third bullet for `tier-selector` mirroring the existing two bullets' shape. After the "Install on Claude Code" section, add a new sub-section "Merge the CLAUDE.md fragment" that instructs: *"Copy the content of `core/CLAUDE.md` into your project's `/CLAUDE.md` (or whichever path your `.lsa.yaml` configures as the constitution)."*

- [ ] **2. Edit `core/VERIFICATION.md`.** Under "V2 — Description-match triggers reliably", add Probe C: *"In a fresh session: 'I want to add password-reset via email.' Expected: response classifies as T3, names boundary signals, waits for confirm."*

- [ ] **3. Verify.** Run: `grep -c "tier-selector" core/README.md core/VERIFICATION.md`. Expected: `>= 2`.

- [ ] **4. Commit.**

```bash
git add core/README.md core/VERIFICATION.md
git commit -m "docs(core): document tier-selector install + V2 probe"
```

---

### Task 7 — Bump `core/.claude-plugin/plugin.json` to 0.2.0

**Inputs:** Task 6 complete.
**Outputs:** `version` field is `0.2.0`; description mentions tier-selector.
**Files:** Modify `core/.claude-plugin/plugin.json`.
**Verification:** `jq -r .version core/.claude-plugin/plugin.json` prints `0.2.0`.
**Spec trace:** §12.1.

- [ ] **1. Overwrite the manifest.** Replace contents with exactly:

```json
{
  "name": "core",
  "description": "Domain-neutral discipline for trustworthy output and ceremony-scales-to-weight task orchestration: fact-grounding (sources + quotes), no fake-confidence hedging, read-before-write, only-required-output, the Goal/Input/Steps/Output/Constraints shape for any actor, and tier-selector (T1/T2/T3) chain-of-thought.",
  "version": "0.2.0",
  "author": { "name": "Nikita Zverev" }
}
```

- [ ] **2. Verify.** Run: `jq -r .version core/.claude-plugin/plugin.json`. Expected: `0.2.0`.

- [ ] **3. Commit.**

```bash
git add core/.claude-plugin/plugin.json
git commit -m "feat(core): bump to v0.2.0 (adds tier-selector)"
```

---

### Task 8 — `core/CHANGELOG.md` v0.2.0 entry

**Inputs:** Task 7 complete.
**Outputs:** CHANGELOG has a `## [0.2.0] — 2026-05-20` entry under Added / Notes.
**Files:** Modify `core/CHANGELOG.md`.
**Verification:** `grep -c "^## \[0.2.0\]" core/CHANGELOG.md` prints `1`.
**Spec trace:** §12.3.

- [ ] **1. Read the existing changelog.** `head -30 core/CHANGELOG.md` to see the v0.1.0 entry shape; mirror that format.

- [ ] **2. Insert the v0.2.0 section.** Above the v0.1.0 heading, add:

```markdown
## [0.2.0] — 2026-05-20

### Added
- `core/skills/tier-selector/SKILL.md` — Actor skill that classifies a task into T1/T2/T3 by applying Vision §4 boundary signals, then waits for human confirmation. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §4.1.
- `core/CLAUDE.md` — opt-in always-on fragment declaring both `ground-rules` and `tier-selector` as required pre-task invocations. Mirrors the always-on/on-demand split from `vision/VISION.md:106`.

### Changed
- `core/README.md` — adds tier-selector to "What's here" and adds a "Merge the CLAUDE.md fragment" install step.
- `core/VERIFICATION.md` — adds Probe C for `tier-selector` under V2.
- Plugin description in `core/.claude-plugin/plugin.json` extended to mention tier-selector.

### Notes
- `core/registry` (the lazy-load map-not-territory skill) remains deferred to v0.3.0. `vision/VISION.md:177` notes Claude Code's per-component plugin discovery partially subsumes its role.
```

- [ ] **3. Verify.** Run: `grep -c "^## \[0.2.0\]" core/CHANGELOG.md`. Expected: `1`.

- [ ] **4. Commit.**

```bash
git add core/CHANGELOG.md
git commit -m "docs(core): v0.2.0 changelog entry"
```

---

**End of Phase A.** `core` v0.2.0 is tagged-ready. Pause and push if desired (`git push origin main`). Phase B can begin.

---

# Phase B — LSA v0.2.0

### Task 9 — Add `lsa-discover` skill stub

**Inputs:** Phase A complete.
**Outputs:** `lsa/skills/lsa-discover/SKILL.md` exists with frontmatter only.
**Files:** Create `lsa/skills/lsa-discover/SKILL.md`.
**Verification:** `head -2 lsa/skills/lsa-discover/SKILL.md` shows `---` then `name: lsa-discover`.
**Spec trace:** §4.3.

- [ ] **1. Create directory.** `mkdir -p lsa/skills/lsa-discover`.

- [ ] **2. Write the stub.**

```markdown
---
name: lsa-discover
description: Light discovery phase used at the start of every T2 and T3 task. Asks the minimal clarifying questions needed to identify the affected module spec, the change's intent, and the acceptance criterion. Writes nothing to disk for T2 (oral output only); hands the captured context to lsa-specify for T3. Use this before any code or spec change when the tier is T2 or T3.
---

STUB — full body lands in Task 12.
```

- [ ] **3. Verify.** `head -2 lsa/skills/lsa-discover/SKILL.md`. Expected: `---` / `name: lsa-discover`.

- [ ] **4. Commit.**

```bash
git add lsa/skills/lsa-discover/SKILL.md
git commit -m "feat(lsa): add lsa-discover skill stub"
```

---

### Task 10 — Add `lsa-reconcile` skill stub

**Inputs:** Task 9 complete.
**Outputs:** `lsa/skills/lsa-reconcile/SKILL.md` exists with frontmatter only.
**Files:** Create `lsa/skills/lsa-reconcile/SKILL.md`.
**Verification:** `head -2 lsa/skills/lsa-reconcile/SKILL.md` shows `---` then `name: lsa-reconcile`.
**Spec trace:** §4.4.

- [ ] **1. Create directory.** `mkdir -p lsa/skills/lsa-reconcile`.

- [ ] **2. Write the stub.**

```markdown
---
name: lsa-reconcile
description: Absorbs direct artifact edits (the human edited a SKILL.md, a config, a plugin file by hand) into the matching module spec, rather than blocking the edit. Compares current artifact_paths against the last-sync commit recorded in .lsa-sync-state.json, summarizes the drift per module, and proposes a one-line spec update for each. Human confirms each absorption individually. Use after direct edits, or when SessionStart warns of drift.
---

STUB — full body lands in Task 14.
```

- [ ] **3. Verify.** `head -2 lsa/skills/lsa-reconcile/SKILL.md`. Expected: `---` / `name: lsa-reconcile`.

- [ ] **4. Commit.**

```bash
git add lsa/skills/lsa-reconcile/SKILL.md
git commit -m "feat(lsa): add lsa-reconcile skill stub"
```

---

### Task 11 — V1 probe (lsa v0.2.0 install) — MANUAL

**Inputs:** Tasks 9, 10 complete.
**Outputs:** Documented PASS/FAIL.
**Spec trace:** §13 V1.

- [ ] **1. Reload plugins.** `/reload-plugins`.

- [ ] **2. Check `/help`.** Expected: all 8 LSA skills listed under `/lsa:`: `init`, `discover`, `specify`, `plan`, `verify`, `sync`, `reconcile`, `revise-constitution`.

- [ ] **3. Record outcome.** `V1 (Code, lsa v0.2.0 stubs): PASS` or note failure.

---

### Task 12 — Write `lsa-discover` body

**Inputs:** Task 11 returned PASS.
**Outputs:** Full Actor body per design §4.3.
**Files:** Modify `lsa/skills/lsa-discover/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-discover/SKILL.md` prints `>= 5`. `grep -c "three-question" lsa/skills/lsa-discover/SKILL.md` prints `>= 1`.
**Spec trace:** §4.3.

- [ ] **1. Land the body.** Five labeled sections (Goal / Input / Steps / Output / Constraints). Steps must contain:
  1. Read `.lsa.yaml`, list candidate module names.
  2. Three-question probe: which module, one-sentence change, one-sentence AC.
  3. For T2: single-paragraph context summary, stop.
  4. For T3: write `discovery.md` scratch file, hand off to `lsa-specify`.

  Constraints: three questions max; don't write to `specs_root`; don't invent module names.

- [ ] **2. Verify.** `grep -c '^## ' lsa/skills/lsa-discover/SKILL.md`. Expected: `>= 5`.

- [ ] **3. Commit.**

```bash
git add lsa/skills/lsa-discover/SKILL.md
git commit -m "feat(lsa): land lsa-discover body with three-question probe and T2/T3 branching"
```

---

### Task 13 — V2 probe for `lsa-discover` — MANUAL

**Inputs:** Task 12 complete.
**Outputs:** Documented PASS/FAIL.
**Spec trace:** §13 V2.

- [ ] **1. Reload plugins.** `/reload-plugins`.

- [ ] **2. Probe.** First trigger T2 via `tier-selector` (e.g., *"The date formatter is off by one month"*); confirm T2. Then expect `lsa-discover` to fire with three short questions: which module, change in one sentence, AC in one sentence.

- [ ] **3. Record outcome.** `V2 (Code, lsa-discover): PASS` or failure note.

---

### Task 14 — Write `lsa-reconcile` body

**Inputs:** Task 13 returned PASS.
**Outputs:** Full Actor body per design §4.4.
**Files:** Modify `lsa/skills/lsa-reconcile/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-reconcile/SKILL.md` prints `>= 5`. `grep -c "lsa-sync-state" lsa/skills/lsa-reconcile/SKILL.md` prints `>= 1`.
**Spec trace:** §4.4, §7.

- [ ] **1. Land the body.** Five-section actor shape. Steps must contain the six-step procedure from design §4.4:
  1. Per-module `git diff <recorded-sha> -- <artifact_paths>` (working-tree vs recorded SHA, no `..HEAD` — see design §4.4 / §7 for why).
  2. Exit-if-clean.
  3. **Classify each delta as class (a) — change to existing behavior — or class (b) — new behavior.** Note classification in the draft delta block.
  4. Per-module hard-confirm.
  5. On confirm — **reverse-sync per Vision §4 (`vision/VISION.md:143`):**
     - Class (a): *update in place* — edit the contradicted requirement line(s) so the spec now states the new behavior. Replace, don't append next to. Tag the line with `<!-- reconciled: YYYY-MM-DD -->`.
     - Class (b): *append new requirement* — add a new requirement line in the appropriate section. Tag with `<!-- reconciled: YYYY-MM-DD -->`.
     - Update `.lsa-sync-state.json` with new HEAD SHA.
  6. On reject — leave the spec untouched; optionally write the rejected delta to `${specs_root}/research-backlog.md`.

  Constraints:
  - Never block/revert/reformat the artifact edits themselves (Vision §4 `vision/VISION.md:144`).
  - **Never leave the spec self-contradictory** — class (a) replaces, doesn't append next to.
  - One module at a time.
  - Missing `.lsa-sync-state.json` → treat as first commit on `main` (initialize, don't error).

- [ ] **2. Verify.** `grep -c '^## ' lsa/skills/lsa-reconcile/SKILL.md` → `>= 5`. `grep -c "lsa-sync-state" lsa/skills/lsa-reconcile/SKILL.md` → `>= 1`. `grep -c "reverse-sync\\|reconciled:\\|class (a)\\|class (b)" lsa/skills/lsa-reconcile/SKILL.md` → `>= 4`.

- [ ] **3. Commit.**

```bash
git add lsa/skills/lsa-reconcile/SKILL.md
git commit -m "feat(lsa): land lsa-reconcile body with per-module drift absorption gate"
```

---

### Task 15 — V2 probe for `lsa-reconcile` — MANUAL

**Inputs:** Task 14 complete. `.lsa-sync-state.json` may not yet exist (skill must handle that).
**Outputs:** Documented PASS/FAIL.
**Spec trace:** §13 V2.

- [ ] **1. Make a fake drift.** Edit `core/skills/ground-rules/SKILL.md` — change one word in a paragraph. Save.

- [ ] **2. Reload plugins.** `/reload-plugins`.

- [ ] **3. Probe.** Run `/lsa:reconcile`. Expected: skill reads `.lsa.yaml`, computes diff (state file absent → uses first commit fallback), summarizes drift on `core` module, asks for per-module confirm.

- [ ] **4. Reject the proposal** (to avoid polluting the spec tree before Phase C lands `vision/specs/modules/core/spec.md`). Expected: skill exits without modifying the spec.

- [ ] **5. Restore the edit.** Revert the word change in `core/skills/ground-rules/SKILL.md`.

- [ ] **6. Record outcome.** `V2 (Code, lsa-reconcile): PASS` or failure note.

---

### Task 16 — Reshape `lsa-init` (mechanical relabel + `.lsa.yaml` read)

**Inputs:** Task 15 complete.
**Outputs:** `lsa/skills/lsa-init/SKILL.md` has Goal / Input / Steps / Output / Constraints headers and reads `.lsa.yaml`.
**Files:** Modify `lsa/skills/lsa-init/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-init/SKILL.md` prints `>= 5`. `grep -c ".lsa.yaml" lsa/skills/lsa-init/SKILL.md` prints `>= 1`.
**Spec trace:** §5 row 1.

- [ ] **1. Read the current file.** `cat lsa/skills/lsa-init/SKILL.md` to confirm the existing four-step shape (Read Sources / Determine Mode / Write Spec Files / Report to Human).

- [ ] **2. Reshape to actor-template's five-section shape.** Per the core v1 design's actor-template definition (`vision/specs/archive/2026-05-20-core-v1/design.md:104-108` at Phase B execution time; relocated to `vision/specs/archive/2026-05-20-core-v1/design.md` after Phase C Task 31 runs): *"Every Actor file must contain exactly these five sections, in this order, no renames, no merges: Goal · Input · Steps · Output · Constraints"*. Existing `## Step 1 — Read Sources`, `## Step 2 — Determine Mode`, `## Step 3 — Write Spec Files`, `## Step 4 — Report to Human` headers **collapse under a single `## Steps` section as numbered sub-items**:

```markdown
## Steps

1. **Read sources.** ...  (was Step 1)
2. **Determine mode.** ...  (was Step 2)
3. **Write spec files.** ...  (was Step 3)
4. **Report to human.** ...  (was Step 4)
```

Add `## Goal` (one sentence: "Initialize the LSA spec structure on a project"), `## Input` (project root with constitution; optional `.lsa.yaml`), `## Output` (scaffolded spec tree), `## Constraints` (never overwrite existing specs; abort if `${specs_root}` already exists with non-empty content) sections around the relabelled Steps.

- [ ] **3. Replace hardcoded paths with `.lsa.yaml` reads.** The current Step 1 reads `/CLAUDE.md` (hardcoded). Update Step 1 to: *"Read `.lsa.yaml` from repo root (or apply defaults: `constitution: /CLAUDE.md`, `specs_root: /specs/`, `mode: code`). Then read `${constitution}` (the file at the configured path)."* Brownfield mode (Step 2 in old shape) scans `modules.*.artifact_paths` from `.lsa.yaml` instead of hardcoded `/src/`.

- [ ] **4. Marker sweep.** Replace `[INFERRED — verify]` with `[assumption: inferred from <source>; verify]` per design §10.

- [ ] **5. Verify.** `grep -c '^## ' lsa/skills/lsa-init/SKILL.md`. Expected: `>= 5`. `grep -c "^## Steps" lsa/skills/lsa-init/SKILL.md` → `1` (single Steps section, not multiple `## Step N`).

- [ ] **6. Commit.**

```bash
git add lsa/skills/lsa-init/SKILL.md
git commit -m "feat(lsa): reshape lsa-init to Goal/Input/Steps/Output/Constraints + .lsa.yaml support"
```

---

### Task 17 — Reshape `lsa-specify` (mechanical relabel)

**Inputs:** Task 16 complete.
**Outputs:** `lsa/skills/lsa-specify/SKILL.md` has Goal / Input / Steps / Output / Constraints headers; accepts `discovery.md` as Input.
**Files:** Modify `lsa/skills/lsa-specify/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-specify/SKILL.md` prints `>= 5`. `grep -c "discovery.md" lsa/skills/lsa-specify/SKILL.md` prints `>= 1`.
**Spec trace:** §5 row 2.

- [ ] **1. Read and reshape.** Existing `## Step 1` through `## Step 8` headers collapse under a single `## Steps` section as numbered sub-items (preserve the gate sequence verbatim). Add `## Goal` (write the formal feature spec files: requirements.md, test-suites.md, contract.yaml, design.md), `## Input` (feature description + optional `discovery.md` from `lsa-discover`), `## Output` (the four files written under `${specs_root}/features/<name>/`), `## Constraints` (hard-confirm on each artifact, never skip gates, only proceed on explicit human approval).

- [ ] **2. Replace hardcoded paths.** Current Step 1 hardcodes `/CLAUDE.md`, `/specs/main.spec.md`, `/specs/modules/<name>/spec.md` (verified at `lsa/skills/lsa-specify/SKILL.md:21-23`). Update to: *"Read `.lsa.yaml` (or defaults). Then read `${constitution}`, `${specs_root}/main.spec.md`, `${specs_root}/modules/<name>/spec.md` for each module this feature touches."* Step 3's spec-directory creation: `${specs_root}/features/<feature-name>/`.

- [ ] **3. Marker sweep.** Replace `[ASSUMPTION: ...]` with `[assumption: <why>]` per design §10.

- [ ] **4. Verify.** `grep -c '^## ' lsa/skills/lsa-specify/SKILL.md`. Expected: `>= 5`. `grep -c "^## Steps" lsa/skills/lsa-specify/SKILL.md` → `1`. `grep -c "/specs/" lsa/skills/lsa-specify/SKILL.md` → `0` (no hardcoded paths remain).

- [ ] **5. Commit.**

```bash
git add lsa/skills/lsa-specify/SKILL.md
git commit -m "feat(lsa): reshape lsa-specify (5-section actor + .lsa.yaml path reads + discovery.md input)"
```

---

### Task 18 — Reshape `lsa-plan` (mechanical relabel)

**Inputs:** Task 17 complete.
**Outputs:** `lsa/skills/lsa-plan/SKILL.md` has Goal / Input / Steps / Output / Constraints headers.
**Files:** Modify `lsa/skills/lsa-plan/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-plan/SKILL.md` prints `>= 5`.
**Spec trace:** §5 row 3.

- [ ] **1. Reshape.** Existing `## Step 1` through `## Step 5` headers collapse under a single `## Steps` section. Preserve the ≤5-epic decomposition logic + self-verification table.

- [ ] **2. Replace hardcoded paths.** Current Step 1 hardcodes `/CLAUDE.md`, `/specs/features/<feature-name>/...`, `/specs/modules/<name>/spec.md`, `/specs/standards/testing.md` (verified at `lsa/skills/lsa-plan/SKILL.md:15-21`). Update to use `${constitution}` and `${specs_root}/...` per design §5.

- [ ] **3. Add `## Goal` / `## Input` / `## Output` / `## Constraints` sections.** Goal: decompose an approved feature spec into ≤5 parallel-safe epics with self-verification. Input: approved `requirements.md`, `test-suites.md`, `design.md`. Output: `tasks.md` under `${specs_root}/features/<name>/`. Constraints: max 5 epics; each epic independent (or dependency explicit).

- [ ] **4. Marker sweep.** Replace any `[ASSUMPTION: ...]` with `[assumption: <why>]`.

- [ ] **5. Verify.** `grep -c '^## ' lsa/skills/lsa-plan/SKILL.md` → `>= 5`. `grep -c "/specs/" lsa/skills/lsa-plan/SKILL.md` → `0`.

- [ ] **6. Commit.**

```bash
git add lsa/skills/lsa-plan/SKILL.md
git commit -m "feat(lsa): reshape lsa-plan (5-section actor + .lsa.yaml path reads)"
```

---

### Task 19 — Reshape `lsa-verify` (substantive rewrite: relabel + path swap + doc-mode + metrics writer)

**Inputs:** Task 18 complete.
**Outputs:** `lsa/skills/lsa-verify/SKILL.md` has the five-section actor shape, reads `.lsa.yaml`, branches on `mode`, writes `metrics.md` on PASS.
**Files:** Modify `lsa/skills/lsa-verify/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-verify/SKILL.md` → `>= 5`. `grep -c "doc-mode" lsa/skills/lsa-verify/SKILL.md` → `>= 1`. `grep -c "metrics.md" lsa/skills/lsa-verify/SKILL.md` → `>= 1`. `grep -c "/specs/" lsa/skills/lsa-verify/SKILL.md` → `0`. `grep -c " src/" lsa/skills/lsa-verify/SKILL.md` → `0` (the unconditional `src/` diff is gone).
**Spec trace:** §5 row 4 (substantive), §8, §9.

**Note (per design §5):** This task is a *substantive rewrite*, not a mechanical relabel — doc-mode is a new branch of logic and the metrics writer is new file I/O. Budget accordingly.

- [ ] **1. Read the current file in full.** `cat lsa/skills/lsa-verify/SKILL.md`. Note the existing 5 steps (Read Sources / Get Diffs / Verification Checklist / Verification Report / Gate) and the two hardcoded shell commands at `lsa/skills/lsa-verify/SKILL.md:29-31`.

- [ ] **2. Reshape to 5-section actor.** Existing `## Step 1` through `## Step 5` collapse under one `## Steps`. Add `## Goal` (verify implementation matches feature spec; every change traces), `## Input` (feature branch + feature spec at `${specs_root}/features/<name>/` + `.lsa.yaml`), `## Output` (verification report + `metrics.md` on PASS), `## Constraints` (FAIL on any untraced change; PASS WITH WARNINGS allowed only with explicit warning categories).

- [ ] **3. Replace hardcoded paths.** Step 1 reads update to `${constitution}`, `${specs_root}/features/<feature-name>/...`, `${specs_root}/modules/<name>/spec.md` per design §5.

- [ ] **4. Restructure the diff step by mode.** Replace the unconditional `git diff main -- src/` with a mode-branched block:
  - When `.lsa.yaml: mode` is `code` (or absent — default): run `git diff main -- src/` as before.
  - When `mode` is `docs`: for each module in `.lsa.yaml`, run `git diff main -- <artifact_paths>`. Aggregate diffs across modules.
  - When `mode` is `mixed`: run both. Either failing fails the whole verify.

- [ ] **5. Add doc-mode trace check (design §8).** A changed artifact (doc-mode) is traced if either (a) the feature spec's `requirements.md` names the file or its containing directory in an AC, or (b) the artifact's diff is wholly mechanical (rename, whitespace, formatting) — judged by the agent and reported as such. Untraced doc-mode changes → FAIL.

- [ ] **6. Document "no active feature" handling (for use by reconcile-adjacent flows).** When verify is invoked without an active feature spec (no `${specs_root}/features/<name>/` directory in the diff), the skill **errors out cleanly with "no active feature — use `/lsa:reconcile` for direct-edit absorption"**, rather than attempting to verify against module specs alone. Documents the boundary between verify (feature-scoped) and reconcile (drift-scoped).

- [ ] **7. Add metrics writer.** After PASS conditions, write `${specs_root}/archive/<feature>/metrics.md` with the three Vision §5 metric scores per design §9 template (exact format). On FAIL or PASS-WITH-WARNINGS, do NOT write metrics — only on clean PASS.

- [ ] **8. Marker sweep.** Replace any `[ASSUMPTION: ...]` with `[assumption: <why>]`.

- [ ] **9. Verify.** The five `grep -c` checks above.

- [ ] **10. Commit.**

```bash
git add lsa/skills/lsa-verify/SKILL.md
git commit -m "feat(lsa): rewrite lsa-verify (5-section actor + .lsa.yaml + doc-mode + metrics writer)"
```

---

### Task 20 — Reshape `lsa-sync` (substantive rewrite: relabel + path swap + sync-state writer + metrics aggregator)

**Inputs:** Task 19 complete.
**Outputs:** `lsa/skills/lsa-sync/SKILL.md` has the five-section actor shape, reads `.lsa.yaml`, archives to `${specs_root}/archive/...` (not hardcoded `/specs/archive/...`), writes `.lsa-sync-state.json`, appends to `${specs_root}/metrics.md` aggregate when per-feature metrics exist.
**Files:** Modify `lsa/skills/lsa-sync/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-sync/SKILL.md` → `>= 5`. `grep -c "lsa-sync-state" lsa/skills/lsa-sync/SKILL.md` → `>= 1`. `grep -c "/specs/" lsa/skills/lsa-sync/SKILL.md` → `0`. `grep -c "specs_root" lsa/skills/lsa-sync/SKILL.md` → `>= 3`.
**Spec trace:** §5 row 5 (substantive), §7.

**Note (per design §5):** Substantive rewrite, not a relabel — the sync-state writer is new file I/O.

- [ ] **1. Read the current file in full.** Note the hardcoded paths at `lsa/skills/lsa-sync/SKILL.md:14-20` (Step 1 reads) and `lsa/skills/lsa-sync/SKILL.md:74` (the `mv /specs/features/... /specs/archive/...` shell command).

- [ ] **2. Reshape to 5-section actor.** Existing `## Step 1` through `## Step 6` collapse under one `## Steps`. Add `## Goal` (extract feature delta into module specs; archive feature; record sync SHA), `## Input` (verified feature branch + `.lsa.yaml`), `## Output` (updated module specs, updated main.spec.md, archived feature dir, `.lsa-sync-state.json`, optional `${specs_root}/metrics.md` aggregate row), `## Constraints` (human reviews delta before any spec write; never delete content; tag every addition).

- [ ] **3. Replace hardcoded paths.** Step 1 reads → `${constitution}`, `${specs_root}/features/<feature-name>/...`, `${specs_root}/modules/<name>/spec.md`, `${specs_root}/main.spec.md`. Step 5 archive command → `mv ${specs_root}/features/<feature-name>/ ${specs_root}/archive/$(date +%Y-%m-%d)-<feature-name>/`.

- [ ] **4. Add sync-state write.** After Step 5 (archive), write/update `.lsa-sync-state.json` at repo root with the current HEAD SHA per module (JSON shape per design §7: `{"modules": {"<name>": {"last_sync_sha": "...", "last_sync_iso": "..."}}}`). If the file exists, update only the modules touched by this feature; preserve other modules' entries.

- [ ] **5. Add aggregate metrics row.** If `${specs_root}/archive/<feature>/metrics.md` exists (i.e., `lsa-verify` wrote it on PASS), append a one-line row to `${specs_root}/metrics.md` (create the file with a header if absent). One row per archived feature.

- [ ] **6. Marker sweep.** Replace any `[ASSUMPTION: ...]` with `[assumption: <why>]`.

- [ ] **7. Verify.** The four `grep -c` checks above.

- [ ] **8. Commit.**

```bash
git add lsa/skills/lsa-sync/SKILL.md
git commit -m "feat(lsa): rewrite lsa-sync (5-section actor + .lsa.yaml + sync-state + metrics aggregator)"
```

---

### Task 21 — Reshape `lsa-revise-constitution` (relabel + configured constitution path)

**Inputs:** Task 20 complete.
**Outputs:** `lsa/skills/lsa-revise-constitution/SKILL.md` has the five headers and uses the configured `constitution` path (not hardcoded `/CLAUDE.md`).
**Files:** Modify `lsa/skills/lsa-revise-constitution/SKILL.md`.
**Verification:** `grep -c '^## ' lsa/skills/lsa-revise-constitution/SKILL.md` prints `>= 5`. `grep -E "constitution:|\\.lsa\\.yaml" lsa/skills/lsa-revise-constitution/SKILL.md` matches `>= 1` line.
**Spec trace:** §5 row 6.

- [ ] **1. Reshape.** Collapse any existing `## Step N` headers under one `## Steps` section. Preserve diff-based change presentation. Add `## Goal` (propose and apply constitution changes after explicit per-change human approval), `## Input` (completed feature spec + human's proposed change), `## Output` (updated constitution file + tagged changes), `## Constraints` (per-change hard confirm; never touch specs/src/skills — only constitution path + `${specs_root}/standards/`).

- [ ] **2. Configured-path generalization.** Replace any hardcoded `/CLAUDE.md` references in the skill body with reads/writes of the path at `.lsa.yaml: constitution` (default `/CLAUDE.md`). Same for `/specs/standards/` → `${specs_root}/standards/`.

- [ ] **3. Marker sweep.** Replace any `[ASSUMPTION: ...]` with `[assumption: <why>]`.

- [ ] **4. Verify.** `grep -c '^## ' lsa/skills/lsa-revise-constitution/SKILL.md` → `>= 5`. `grep -E "constitution:|\\.lsa\\.yaml" lsa/skills/lsa-revise-constitution/SKILL.md` matches `>= 1` line. `grep -c " /CLAUDE.md" lsa/skills/lsa-revise-constitution/SKILL.md` → `0` (the hardcoded path is gone, except possibly in the default-fallback documentation).

- [ ] **5. Commit.**

```bash
git add lsa/skills/lsa-revise-constitution/SKILL.md
git commit -m "feat(lsa): reshape lsa-revise-constitution + read constitution path from .lsa.yaml"
```

---

### Task 22 — Add SessionStart hook (drift warning)

**Inputs:** Task 21 complete.
**Outputs:** `lsa/hooks/hooks.json` exists with the SessionStart hook declaration per `code.claude.com/docs/en/hooks`; companion script `lsa/hooks/session-start-drift-check.sh` exists and is executable.
**Files:** Create `lsa/hooks/hooks.json`, `lsa/hooks/session-start-drift-check.sh`.
**Verification:** `jq -r '.hooks.SessionStart[0].matcher' lsa/hooks/hooks.json` prints `startup`. `jq -r '.hooks.SessionStart[0].hooks[0].type' lsa/hooks/hooks.json` prints `command`. `test -x lsa/hooks/session-start-drift-check.sh` returns 0.
**Spec trace:** §7 (design); hook schema verified against `code.claude.com/docs/en/hooks` fetched 2026-05-20.

- [ ] **1. Create the hook manifest.** Write `lsa/hooks/hooks.json` with exactly:

```json
{
  "description": "LSA — surface artifact drift at session start",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start-drift-check.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Note: single-file `hooks.json` (not per-event JSON) is the Claude Code plugin convention. `matcher: "startup"` ensures the hook fires once per session start, not on resume/clear/compact (drift state doesn't change on those events). `timeout: 10` is a conservative upper bound — the script is fast (one git diff per module).

- [ ] **2. Create the drift-check script.** Write `lsa/hooks/session-start-drift-check.sh` — bash script that:
  - Sets `set -euo pipefail` and `trap` to ensure exit 0 even on subshell errors (informational hook, must not block session).
  - Resolves the repo root via `git rev-parse --show-toplevel` (fall back to `${CLAUDE_PROJECT_DIR}` if not in a git repo — silent return).
  - Returns early if `${repo_root}/.lsa.yaml` is absent (no opt-in, no drift checks).
  - Parses `.lsa.yaml` for module names + `artifact_paths`. Uses `yq` if available; otherwise a documented grep/sed fallback (constrained to the simple `modules.<name>.{spec,artifact_paths}` structure design §6 defines).
  - Returns early if `${repo_root}/.lsa-sync-state.json` is absent (no baseline → no drift to report).
  - For each module: runs `git diff --quiet <last_sync_sha> -- <artifact_paths>` and collects module names with non-zero exit (drift detected). **Note: no `..HEAD` suffix** — that form misses uncommitted edits, which is the case the reconcile loop is designed for (Vision §4 example). Working-tree vs recorded SHA is the right comparison.
  - If any drift: prints exactly one line to stdout — `LSA: drift detected in modules [<comma-separated names>] — run /lsa:reconcile to absorb.` Otherwise prints nothing.
  - Exits 0 always.

- [ ] **3. Make executable.** Run: `chmod +x lsa/hooks/session-start-drift-check.sh`.

- [ ] **4. Verify the manifest.**
  - `jq -r '.hooks.SessionStart[0].matcher' lsa/hooks/hooks.json` → `startup`.
  - `jq -r '.hooks.SessionStart[0].hooks[0].type' lsa/hooks/hooks.json` → `command`.
  - `jq -r '.hooks.SessionStart[0].hooks[0].command' lsa/hooks/hooks.json` → contains `session-start-drift-check.sh`.
  - `test -x lsa/hooks/session-start-drift-check.sh` → exit 0.

- [ ] **5. Smoke-test the script in isolation.** Run: `bash lsa/hooks/session-start-drift-check.sh`. Expected: silent (no `.lsa.yaml` yet, so the script returns early). Confirms the script doesn't error on the no-config path.

- [ ] **6. Commit.**

```bash
git add lsa/hooks/
git commit -m "feat(lsa): add SessionStart hook (hooks.json) for drift detection warning"
```

---

### Task 23 — Update `lsa/ARCHITECTURE.md`

**Inputs:** Task 22 complete.
**Outputs:** ARCHITECTURE.md reflects the new skills, tier model, reconcile loop, doc-mode, `.lsa.yaml`, K-vs-A note, marker convention.
**Files:** Modify `lsa/ARCHITECTURE.md`.
**Verification:** Section count `>= original + 2`. `grep -c "lsa-discover\\|lsa-reconcile\\|\\.lsa\\.yaml\\|doc-mode" lsa/ARCHITECTURE.md` prints `>= 8`.
**Spec trace:** §5, §6, §7, §8, §10.

- [ ] **1. Update §3 Directory Structure.** Add `lsa-discover/` and `lsa-reconcile/` under skills; add `hooks/`; document the optional `.lsa.yaml` at repo root.

- [ ] **2. Update §4 Components.** Add §4.8 "lsa-discover" and §4.9 "lsa-reconcile" mirroring the existing component tables. Add §4.10 ".lsa.yaml configuration" describing the schema per design §6.

- [ ] **3. Update §5 Workflow Phases.** Insert "Phase 0 — Discover" between Pre-Feature Checklist and Phase 1; insert "Phase Reconcile (ad-hoc)" between Phase 6 (Sync) and Phase 7 (Replan). Tier-aware notes: each phase mentions which tier(s) it applies to.

- [ ] **4. Update §7 Fact-Check Policy.** Note that LSA uses `[assumption: <why>]` and `[cannot verify]` lowercase per `core/skills/ground-rules/SKILL.md`; the historical `[ASSUMPTION: ]` is removed.

- [ ] **5. Update §10 Skills Index.** Add `lsa-discover`, `lsa-reconcile`. Total 8 skills now.

- [ ] **6. Update §11 Resolved Decisions.** Add new rows: OQ5 (path config = `.lsa.yaml`), OQ6 (T2 path = `lsa-discover` + `lsa-verify`), OQ7 (reconcile = new skill), OQ8 (drift detection = `.lsa-sync-state.json`).

- [ ] **7. Update status line at top** from "0.1.0 — Installable; pending stress test" to "0.2.0 — Vision-aligned; dogfooded on claude-marketplace itself; see vision/specs/2026-05-20-lsa-v0.2.0-design.md".

- [ ] **8. Verify.** `grep -c "lsa-discover\\|lsa-reconcile\\|\\.lsa\\.yaml\\|doc-mode" lsa/ARCHITECTURE.md`. Expected: `>= 8`.

- [ ] **9. Commit.**

```bash
git add lsa/ARCHITECTURE.md
git commit -m "docs(lsa): update ARCHITECTURE.md for v0.2.0 (new skills, tiers, reconcile, doc-mode, .lsa.yaml)"
```

---

### Task 24 — Update `lsa/README.md`

**Inputs:** Task 23 complete.
**Outputs:** README mentions the 8 skills + `.lsa.yaml` configurability.
**Files:** Modify `lsa/README.md`.
**Verification:** `grep -c "lsa-discover\\|lsa-reconcile\\|\\.lsa\\.yaml" lsa/README.md` prints `>= 4`.
**Spec trace:** §12.

- [ ] **1. Edit README.** In the skills table, add rows for `lsa-discover` and `lsa-reconcile`. Add a section "Configuration" pointing at `.lsa.yaml` with the minimal default-overriding example from design §6.

- [ ] **2. Verify and commit.**

```bash
git add lsa/README.md
git commit -m "docs(lsa): update README for v0.2.0 (8 skills + .lsa.yaml)"
```

---

### Task 25 — Bump manifest + CHANGELOG

**Inputs:** Tasks 9–24 complete.
**Outputs:** `lsa/.claude-plugin/plugin.json` at `0.2.0`; `lsa/CHANGELOG.md` has `## [0.2.0] — 2026-05-20` with the four `[Unreleased]` items moved in plus the additions.
**Files:** Modify `lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md`.
**Verification:** `jq -r .version lsa/.claude-plugin/plugin.json` prints `0.2.0`. `grep -c "^## \[0.2.0\]" lsa/CHANGELOG.md` prints `1`.
**Spec trace:** §12.2, §12.4.

- [ ] **1. Overwrite plugin.json:**

```json
{
  "name": "lsa",
  "description": "Living Spec Architecture — spec-first development methodology where specs are the permanent source of truth and every code/artifact change traces to a spec requirement. Eight skills enforce phases with human gates: init, discover, specify, plan, verify, sync, reconcile, revise-constitution. Tier-aware (T1/T2/T3) via core/tier-selector. Path-configurable via .lsa.yaml. Depends on `core` (cites `core/ground-rules` for fact-grounding and `core/tier-selector` for tier selection).",
  "version": "0.2.0",
  "author": { "name": "Nikita Zverev" }
}
```

- [ ] **2. Update CHANGELOG.** Move every `[Unreleased]` entry into a new `## [0.2.0] — 2026-05-20` section. Add additions:
  - `Added`: `lsa-discover`, `lsa-reconcile`, `.lsa.yaml` loader, doc-mode in verify, `.lsa-sync-state.json` writer, per-feature `metrics.md` writer, SessionStart hook, dependency note on `core` v0.2.0 for `tier-selector`.
  - `Changed`: 6 existing skills reshaped to Goal/Input/Steps/Output/Constraints; marker convention swept to lowercase `[assumption: <why>]` / `[cannot verify]`; ARCHITECTURE.md major update; README expanded.
  - `Notes`: schema version note (§6); marketplace dependency field still absent (`lsa/CHANGELOG.md:21` carries forward).

- [ ] **3. Verify.** `jq -r .version lsa/.claude-plugin/plugin.json` → `0.2.0`. `grep -c "^## \[0.2.0\]" lsa/CHANGELOG.md` → `1`.

- [ ] **4. Commit.**

```bash
git add lsa/.claude-plugin/plugin.json lsa/CHANGELOG.md
git commit -m "feat(lsa): bump to v0.2.0 with full Vision alignment"
```

---

**End of Phase B.** `lsa` v0.2.0 is tagged-ready. Push to GitHub at this checkpoint if desired so a fresh `/plugin install lsa@nz-vision` from a clean machine resolves.

---

# Phase C — This-repo bootstrap (dogfood)

### Task 26 — Create `/.lsa.yaml`

**Inputs:** Phases A + B complete.
**Outputs:** `/.lsa.yaml` exists at repo root with `mode: docs` and modules `core` + `lsa`.
**Files:** Create `/.lsa.yaml`.
**Verification:** `yq -r .mode .lsa.yaml` prints `docs` (or `grep -c "^mode: docs" .lsa.yaml` prints `1`).
**Spec trace:** §6, §11.

- [ ] **1. Write the file.** Create `/.lsa.yaml` with exactly the contents from design §6 ("This repo's `/.lsa.yaml`" block).

- [ ] **2. Verify.** `grep -c "^mode: docs" .lsa.yaml`. Expected: `1`.

- [ ] **3. Commit.**

```bash
git add .lsa.yaml
git commit -m "feat(repo): add .lsa.yaml — constitution=VISION.md, specs_root=vision/specs/, mode=docs"
```

---

### Task 27 — Create `vision/specs/main.spec.md`

**Inputs:** Task 26 complete.
**Outputs:** `vision/specs/main.spec.md` exists with Module Index, Cross-Plugin Contracts, NFRs.
**Files:** Create `vision/specs/main.spec.md`.
**Verification:** `grep -c "^## " vision/specs/main.spec.md` prints `>= 3`.
**Spec trace:** §11.

- [ ] **1. Write the file.** Three sections per `lsa/ARCHITECTURE.md` §4.3 template:
  - **Purpose** — extracted from VISION.md §0 one-sentence.
  - **Module Index** — table with rows for `core` and `lsa`, both pointing at their module specs (to be written in Tasks 29, 30).
  - **Cross-Module Contracts** — `lsa` depends on `core/ground-rules` (per `lsa/README.md`) and `core/tier-selector` (per design §4.1). `core/skills/tier-selector` is consumed by `lsa-discover` upstream of T2/T3.
  - **Non-Functional Requirements** — fact-grounding (every claim sourced), spec-grounding (every artifact change traces), Level 2.5 reconcile (drift absorbed, not blocked).
  - **Repo-level config files** — note `.claude-plugin/marketplace.json` is tracked but not LSA-verified (catalog file, not behavior-bearing).

- [ ] **2. Verify.** `grep -c "^## " vision/specs/main.spec.md`. Expected: `>= 3`.

- [ ] **3. Commit.**

```bash
git add vision/specs/main.spec.md
git commit -m "feat(specs): add main.spec.md — module index, cross-plugin contracts, NFRs"
```

---

### Task 28 — Create `vision/specs/standards/{code,testing,agents}.md`

**Inputs:** Task 27 complete.
**Outputs:** Three standards files exist.
**Files:** Create `vision/specs/standards/code.md`, `vision/specs/standards/testing.md`, `vision/specs/standards/agents.md`.
**Verification:** `ls vision/specs/standards/ | wc -l` prints `>= 3`.
**Spec trace:** §11.

- [ ] **1. Create directory.** `mkdir -p vision/specs/standards`.

- [ ] **2. Write `code.md`.** Content: markdown-only deliverables (no `src/`); per-plugin SemVer + CHANGELOG (Keep a Changelog); plugin layout from `vision/specs/archive/2026-05-20-core-v1/design.md:33`; `${CLAUDE_PLUGIN_ROOT}` convention; bump-version-with-changelog rule from `/CLAUDE.md`.

- [ ] **3. Write `testing.md`.** Content: V1/V2/V3 manual probes per plugin per `core/VERIFICATION.md` template; ~90% falsifiable threshold per design §13; statistical eval deferred per VISION §6.

- [ ] **4. Write `agents.md`.** Content: gate types (hard confirm = stop completely; soft confirm = present + correct + delegate) from `lsa/ARCHITECTURE.md:187`; escalation rules from VISION §4 (orchestrator proposes tier, human confirms or overrides); the eight first principles from VISION §2; the reconcile loop is absorptive not blocking per `vision/VISION.md:144`.

- [ ] **5. Verify and commit.**

```bash
git add vision/specs/standards/
git commit -m "feat(specs): add standards/{code,testing,agents}.md"
```

---

### Task 29 — Create `vision/specs/roadmap.md` and `research-backlog.md`

**Inputs:** Task 28 complete.
**Outputs:** Both files exist.
**Files:** Create `vision/specs/roadmap.md`, `vision/specs/research-backlog.md`.
**Verification:** `test -f vision/specs/roadmap.md && test -f vision/specs/research-backlog.md` exits 0.
**Spec trace:** §11.

- [ ] **1. Write `roadmap.md`.** Table populated from VISION §6 Adjust items (EARS in AC block, library-spec cache for top 3-5 libs), §7 Open decisions (tier threshold finalization, naming), and post-0.2.0 follow-ups from design §15 (`core/registry` resurrection, two-week dogfood log, doc-mode strict tracing, marketplace dep field adoption).

- [ ] **2. Write `research-backlog.md`.** Empty table with the columns from `lsa/ARCHITECTURE.md` §4.7: Date / Topic / Summary / Recommendation / Status.

- [ ] **3. Commit.**

```bash
git add vision/specs/roadmap.md vision/specs/research-backlog.md
git commit -m "feat(specs): add roadmap.md and research-backlog.md"
```

---

### Task 30 — Create module specs

**Inputs:** Task 29 complete.
**Outputs:** `vision/specs/modules/core/spec.md` and `vision/specs/modules/lsa/spec.md` exist.
**Files:** Create both.
**Verification:** `grep -c '^## ' vision/specs/modules/core/spec.md` and same for lsa each print `>= 3`.
**Spec trace:** §11.

- [ ] **1. Create directories.** `mkdir -p vision/specs/modules/core vision/specs/modules/lsa`.

- [ ] **2. Write `modules/core/spec.md`.** Three skills (`ground-rules`, `actor-template`, `tier-selector`), each with: name, role, behavioral contract (the SKILL.md's description distilled to one paragraph), invariants. Include cross-references to `lsa` consumers.

- [ ] **3. Write `modules/lsa/spec.md`.** Eight skills (init, discover, specify, plan, verify, sync, reconcile, revise-constitution). **Phase count:** v0.1.1 had a Pre-Feature Checklist + Phases 1–7 (Specify / Plan / Implement / Sub-Agent Review / Verify / Sync / Replan). v0.2.0 inserts **Phase 0 — Discover** (before Phase 1) and an **ad-hoc Reconcile phase** (not numbered — fires whenever drift is detected, not in feature-flow sequence). Net: 8 numbered phases (0–7) plus 1 ad-hoc phase. Document this explicitly to avoid the math error noted in design §16. Gate types per skill (hard/soft confirm — preserve current ARCHITECTURE.md §5). Include cross-references to `core` dependencies (`tier-selector` upstream of T2/T3; `ground-rules` always-on).

- [ ] **4. Verify and commit.**

```bash
git add vision/specs/modules/
git commit -m "feat(specs): add module specs for core and lsa plugins"
```

---

### Task 31 — Relocate core v1 design + plan into archive (with cross-reference fix-up)

**Inputs:** Task 30 complete.
**Outputs:** `vision/specs/archive/2026-05-20-core-v1/{design.md,tasks.md}` exist; the originals at `vision/specs/archive/2026-05-20-core-v1/design.md` and `vision/specs/archive/2026-05-20-core-v1/tasks.md` no longer exist. All citations to the old paths in `vision/specs/2026-05-20-lsa-v0.2.0-design.md` and `vision/plans/2026-05-20-lsa-v0.2.0-plan.md` are updated to the new archive paths.
**Files:** Move two files via `git mv`; modify the two lsa v0.2.0 docs.
**Verification:** Both relocated files exist. `grep -rn "vision/specs/archive/2026-05-20-core-v1/design.md\\|vision/specs/archive/2026-05-20-core-v1/tasks.md" vision/` returns no matches (all references updated). The relocated plan's `Source spec:` line points at the new design path.
**Spec trace:** §11.

- [ ] **1. Create archive directory.** `mkdir -p vision/specs/archive/2026-05-20-core-v1`.

- [ ] **2. Move design file.** `git mv vision/specs/archive/2026-05-20-core-v1/design.md vision/specs/archive/2026-05-20-core-v1/design.md`.

- [ ] **3. Move plan file.** `git mv vision/specs/archive/2026-05-20-core-v1/tasks.md vision/specs/archive/2026-05-20-core-v1/tasks.md`.

- [ ] **4. Fix cross-references in the new lsa v0.2.0 docs.** The lsa v0.2.0 design + plan cite the old paths in multiple places (line numbers became stale on relocation but path identity is what breaks). Run a global replace:

```bash
# Update path references inside the two lsa v0.2.0 docs:
sed -i.bak \
  -e 's|vision/specs/archive/2026-05-20-core-v1/design.md|vision/specs/archive/2026-05-20-core-v1/design.md|g' \
  -e 's|vision/specs/archive/2026-05-20-core-v1/tasks.md|vision/specs/archive/2026-05-20-core-v1/tasks.md|g' \
  vision/specs/2026-05-20-lsa-v0.2.0-design.md \
  vision/plans/2026-05-20-lsa-v0.2.0-plan.md
rm vision/specs/2026-05-20-lsa-v0.2.0-design.md.bak vision/plans/2026-05-20-lsa-v0.2.0-plan.md.bak
```

Note: this updates path references but **not** the `:NNN` line numbers — those become approximate. The plan accepts that loss; precise line numbers are restored only if the archived file is itself edited (which it shouldn't be, per `lsa/ARCHITECTURE.md` §4.6 *"After merge ... archived, not deleted"*).

- [ ] **5. Fix the archived plan's `Source spec:` link.** Inside `vision/specs/archive/2026-05-20-core-v1/tasks.md`, the first prose line points at `../specs/2026-05-20-core-v1-design.md` (relative from the old `vision/plans/` location). After relocation it should be `./design.md` (sibling in the same archive directory).

```bash
sed -i.bak \
  's|../specs/2026-05-20-core-v1-design.md|./design.md|g' \
  vision/specs/archive/2026-05-20-core-v1/tasks.md
rm vision/specs/archive/2026-05-20-core-v1/tasks.md.bak
```

- [ ] **6. Verify.**
  - `test -f vision/specs/archive/2026-05-20-core-v1/design.md && test -f vision/specs/archive/2026-05-20-core-v1/tasks.md && echo OK` → `OK`.
  - `grep -r "vision/specs/archive/2026-05-20-core-v1/design.md\\|vision/specs/archive/2026-05-20-core-v1/tasks.md" vision/ CLAUDE.md core/ lsa/ 2>/dev/null` → no matches (all references updated).
  - `grep -c "./design.md" vision/specs/archive/2026-05-20-core-v1/tasks.md` → `>= 1`.

- [ ] **7. Commit.**

```bash
git add vision/specs/ vision/plans/
git commit -m "refactor(specs): relocate core v1 design+plan into archive; fix cross-references"
```

Note: `vision/plans/` may now be empty. Leave the directory in place for future feature work — its purpose persists.

---

### Task 32 — Slim `/CLAUDE.md`

**Inputs:** Task 31 complete.
**Outputs:** `/CLAUDE.md` is the thin entry point per design §11.
**Files:** Modify `/CLAUDE.md`.
**Verification:** `grep -c "Known gaps" /CLAUDE.md` prints `0` (the gaps closed). `grep -c "VISION.md" /CLAUDE.md` prints `>= 1`. `grep -c "tier-selector" /CLAUDE.md` prints `>= 1` (the fragment is embedded).
**Spec trace:** §11.

- [ ] **1. Read the current CLAUDE.md.** Note which sections to preserve (default plugins, where things live, discipline pointers) and which to remove (Known gaps — those closed by this release).

- [ ] **2. Rewrite as the thin entry.** Sections:
  - **Default plugins** — `core` and `lsa` install commands (unchanged from current).
  - **Ground rules + tier selection** — verbatim from `core/CLAUDE.md` (the fragment from Task 5).
  - **Constitution pointer** — *"Operating rules live in [`vision/VISION.md`](./vision/VISION.md). LSA configuration is at [`/.lsa.yaml`](./.lsa.yaml)."*
  - **Where things live** — preserve current table (already accurate).
  - **Discipline** — preserve current pointer to per-plugin SemVer/CHANGELOG + GitHub account note.
  - **Known gaps** — **delete** (closed by this release).

- [ ] **3. Verify.** Three `grep -c` checks above.

- [ ] **4. Commit.**

```bash
git add CLAUDE.md
git commit -m "docs(repo): slim /CLAUDE.md to thin entry — VISION.md is the constitution"
```

---

### Task 33 — Dogfood probes (V3a + V3b) — MANUAL

**Inputs:** Tasks 26–32 complete.
**Outputs:** Documented PASS/FAIL of two separate probes — V3a (T2 feature flow) and V3b (reconcile + session-start drift). Both probes per design §13 V3.
**Spec trace:** §13 V3a and V3b.

This task **must be run by the human in a real Claude Code session** with both plugins reloaded. **Two separate sub-probes** — they exercise different code paths and verify-vs-reconcile have distinct input contracts (verify expects an active feature spec; reconcile expects drift without one). Conflating them — as the pre-revision Task 33 did — would make `/lsa:verify` error on "no active feature" per the reshaped Task 19 step 6.

#### V3a — T2 feature flow (tier-selector + lsa-discover + doc-mode verify)

Per design §13 V3a: **edit an artifact, not a spec file.** Standards files (`vision/specs/standards/*`) live under `${specs_root}` — they're spec content, not artifacts. Doc-mode verify diffs `artifact_paths` against the matching module spec; editing a spec file isn't an artifact change.

- [ ] **1. Reload plugins.** `/reload-plugins`.

- [ ] **2. Open a branch.** `git checkout -b dogfood/v0.2.0-t2-probe`.

- [ ] **3. Invoke tier-selector with a small T2 ask targeting an artifact.** Type in a fresh chat: *"In `core/skills/ground-rules/SKILL.md`, rephrase one sentence in the 'No fake confidence' section to remove an ambiguity."* This is class (a) drift (existing requirement; wording change). Expected: `core/tier-selector` proposes T2 with reasoning (one file, no contract change, existing spec). Confirm T2.

- [ ] **4. Expect `lsa-discover` to fire.** Three short questions: which module (answer: `core`), change in one sentence (answer: clarify wording in the no-fake-confidence example), AC in one sentence (answer: meaning preserved; no behavior change).

- [ ] **5. Agent makes the edit.** One sentence rephrased in `core/skills/ground-rules/SKILL.md`.

- [ ] **6. Invoke `/lsa:verify`.** Expected: doc-mode runs (`.lsa.yaml: mode: docs`); diffs `core.artifact_paths` against `main`; finds the wording change; trace clause (b) from design §8 — "wholly mechanical (rename, whitespace, formatting)" — applies if the change is purely cosmetic, else trace clause (a) requires the feature spec name the file. For T2 without a feature spec, the verify report should output PASS WITH WARNINGS with the warning *"no active feature spec — change accepted under module-spec coverage only."*

- [ ] **7. Confirm no metrics file was written.** Per design §9 (revised), T2 does not emit metrics. `find vision/specs/archive -name metrics.md -newer .lsa.yaml` returns no new file.

- [ ] **8. Record V3a outcome.** `V3a: PASS WITH WARNINGS (no-feature)` or list specific failures.

- [ ] **9. Discard the V3a branch.**

```bash
git checkout . && git checkout main && git branch -D dogfood/v0.2.0-t2-probe
```

#### V3b — Reconcile + SessionStart drift

- [ ] **10. Open a separate branch.** `git checkout -b dogfood/v0.2.0-reconcile-probe`.

- [ ] **11. Make a direct artifact edit (drift).** Edit a **body paragraph** (not the YAML frontmatter — a malformed frontmatter would break skill load before the SessionStart hook can run) of `core/skills/ground-rules/SKILL.md` — change one word inside the "No fake confidence" example. Save. Do NOT commit.

- [ ] **12. Close and reopen Claude Code.** On reopen, the SessionStart hook should print: `LSA: drift detected in modules [core] — run /lsa:reconcile to absorb.` (working-tree-vs-recorded-SHA diff catches the uncommitted edit per design §7). Record whether the hook fired.

- [ ] **13. Invoke `/lsa:reconcile`.** Expected: per-module diff summary, classification of the edit as class (a) — wording change to existing requirement — hard-confirm gate.

- [ ] **14. Confirm absorption.** Expected:
  - The contradicted line (or wording) in `vision/specs/modules/core/spec.md`'s coverage of `ground-rules` is **edited in-place** with the new value, tagged `<!-- reconciled: 2026-05-20 -->`.
  - `.lsa-sync-state.json` updated with HEAD SHA for `core`.
  - **No `## Drift absorbed YYYY-MM-DD` heading** is created (that approach was explicitly rejected in design §4.4 to avoid self-contradictory specs).

- [ ] **15. Inspect state files.**
  - `cat .lsa-sync-state.json` → contains a recent SHA + ISO timestamp for `core`.
  - `git diff vision/specs/modules/core/spec.md` → shows in-place edit (no new heading) with the `reconciled:` tag.

- [ ] **16. Record V3b outcome.** `V3b: PASS` or list specific failures (most likely failure: the hook didn't fire — check `hooks.json` schema, `chmod +x` on the script, and `${CLAUDE_PLUGIN_ROOT}` resolution).

- [ ] **17. Discard the V3b branch.**

```bash
git checkout .  # discard uncommitted reconcile-applied changes + the original drift edit
git checkout main
git branch -D dogfood/v0.2.0-reconcile-probe
```

Confirm clean state: `git status` shows no changes.

---

### Task 34 — Push to GitHub

**Inputs:** Task 33 returned PASS (or documented partial PASS).
**Outputs:** All commits pushed to `github.com/NVZver/claude-marketplace`.
**Verification:** `git status` shows the local `main` branch is up-to-date with `origin/main`.

- [ ] **1. Confirm GitHub account.** Run `gh auth status`. Expected: `NVZver` is the active account (per `/CLAUDE.md` "GitHub account" note). If not, run `gh auth switch` first.

- [ ] **2. Push.** `git push origin main`. Expected: push succeeds. If rejected, do NOT force-push to main — investigate the rejection.

- [ ] **3. Verify public install.** From a fresh Claude Code session (or after `/plugin marketplace remove nz-vision`): `/plugin marketplace add NVZver/claude-marketplace` then `/plugin install core@nz-vision lsa@nz-vision`. Expected: both install at v0.2.0; `/help` lists all 11 skills.

---

## Self-review (executed before publishing this plan)

**Design coverage.** Every design section maps to at least one task:

| Design § | Tasks |
| --- | --- |
| §1 Goal | (covered by V3 probe — Task 33) |
| §2 Decisions locked | (no direct task; reference document only) |
| §3 Architecture and file tree | 1, 9, 10, 22, 26, 27, 28, 29, 30, 31 |
| §4.1 tier-selector | 1, 3, 4 |
| §4.2 core/CLAUDE.md | 5 |
| §4.3 lsa-discover | 9, 12, 13 |
| §4.4 lsa-reconcile | 10, 14, 15 |
| §5 Existing skills refactor | 16, 17, 18, 19, 20, 21 |
| §6 `.lsa.yaml` schema | 26 (file written); 16 (init reads it); other skills read defaults |
| §7 Reconcile loop | 14, 20, 22 |
| §8 Doc-mode verify | 19 |
| §9 Metrics | 19, 20 |
| §10 Marker convention | 16, 17, 18, 19, 20, 21 (sweep step in each); 23 (ARCHITECTURE update) |
| §11 This-repo bootstrap | 26, 27, 28, 29, 30, 31, 32 |
| §12 Manifests | 7, 8, 25 |
| §13 Verification | 2, 4, 11, 13, 15, 33 |
| §14 Out of scope | (covered by absence — `registry` and statistical eval correctly not tasked) |
| §15 Open follow-ups | (covered by absence — post-0.2.0) |

**V1-first discipline.** Stubs land before bodies in both phases:
- Phase A: Task 1 (stub) → Task 2 (V1) → Task 3 (body).
- Phase B: Tasks 9, 10 (stubs) → Task 11 (V1) → Tasks 12, 14 (bodies).

**Mechanical vs substantive refactor scope.** Per design §5: Tasks 16, 17, 18, 21 are mechanical relabels + path swap. Tasks 19 (`lsa-verify`) and 20 (`lsa-sync`) are flagged as **substantive rewrites** — they add new logic branches (doc-mode, metrics writer, sync-state writer). Budget accordingly.

**Placeholder scan.** No "TBD", "TODO", "handle errors appropriately" in this plan. Where flexibility is allowed (e.g., the bash hook script's `yq` vs grep fallback), the task lists explicit acceptance criteria.

**Identifier consistency.** Skill names (`tier-selector`, `lsa-discover`, `lsa-reconcile`, the six reshaped), plugin names (`core`, `lsa`), namespace prefixes (`/core:`, `/lsa:`), config file (`.lsa.yaml`), state file (`.lsa-sync-state.json`), hook manifest (`hooks/hooks.json` — single file per `code.claude.com/docs/en/hooks`), GitHub repo (`NVZver/claude-marketplace`) used identically across every task.

**Reversibility.** Phase A and Phase B are reversible by `git revert`. Phase C Task 31's `git mv` is reversible — git tracks the rename. Phase C Task 32's `/CLAUDE.md` slim removes content recoverable from git history. No phase requires destructive `git push --force` to `main`.

**Risk surfaces.**
- **Task 19 / Task 20 (substantive rewrites)** — these are mid-sized changes, not relabels. Expect more iteration than the other reshape tasks; consider running V2 probes mid-task (after the actor reshape, before the new logic lands) to isolate regressions.
- **Task 22 (hook script)** — bash dependency on `yq` is soft (falls back to grep). If the host lacks `yq` and the fallback misses an edge case, the hook prints nothing — drift goes silent until manual `/lsa:reconcile`. Acceptable for v0.2.0. Hook manifest schema is verified against `code.claude.com/docs/en/hooks` fetched 2026-05-20.
- **Task 31 (file relocation + cross-reference fix-up)** — relocates two files and rewrites references inside the two lsa v0.2.0 docs. The `:NNN` line-number citations become approximate (path identity restored, but line numbers in the archived files weren't tracked). Mitigation: archived files are read-only per `lsa/ARCHITECTURE.md` §4.6, so line numbers stay stable from this point forward.
- **Task 33 V3a — standards/ artifact_paths edge case.** Standards files in `${specs_root}/standards/` aren't currently in any module's `artifact_paths`. The probe explicitly surfaces this and asks the implementer to decide. Likely resolution: add `vision/specs/standards/**` to `lsa.artifact_paths` (since lsa owns the standards convention via ARCHITECTURE.md §4.2).
- **Task 33 V3b — uncommitted-drift handling.** The probe edits `core/skills/ground-rules/SKILL.md` without committing. The drift-check script and `lsa-reconcile` skill body use `git diff <sha> -- <files>` (working-tree vs SHA, no `..HEAD`) per design §4.4 and §7, so uncommitted drift IS detected. Verified consistency across design §7, design §4.4, plan Task 14, plan Task 22.
