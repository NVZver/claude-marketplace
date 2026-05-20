# Simplification Refactor Plan — 2026-05-20

**Status:** approved, awaiting execution
**Driver:** prompt-quality review across `core` + `lsa` plugins (rounds 1 + 2)
**Scope:** pure DRY / SRP / KISS refactor — no functionality change
**Constitution:** [`vision/VISION.md`](../VISION.md)

---

## 0. Core idea — what every PR MUST preserve

Per [`vision/VISION.md:11`](../VISION.md):
> *"trustworthy output — every fact traces to a source, every line of code traces to a spec — and whose ceremony scales to the weight of the task."*

Nine invariants the plan is bound by:

| # | Invariant | Source |
|---|---|---|
| I1 | Fact-grounding (no claim without Source + quote) | `vision/VISION.md:35` |
| I2 | Spec-grounding (no artifact without a spec) | `vision/VISION.md:36` |
| I3 | Knowledge vs Actor separation | `vision/VISION.md:40, 57` |
| I4 | SoC / DRY / KISS | `vision/VISION.md:41` |
| I5 | Read before write | `vision/VISION.md:59` |
| I6 | Ceremony scales (T1/T2/T3) | `vision/VISION.md:114-122` |
| I7 | Reconcile (Level 2.5) | `vision/VISION.md:135-145` |
| I8 | Per-plugin SemVer + CHANGELOG | `vision/VISION.md:44, 161` |
| I9 | Dogfood — system builds itself | `vision/VISION.md:46` |

Verification (§4) walks each invariant to confirm zero are weakened; I3 and I4 are strengthened.

---

## 1. Locked decisions

| # | Decision | Outcome |
|---|---|---|
| D1 | What to do with `vision/specs/standards/agents.md` | **Delete outright.** File self-declares as a digest at 5 lines; everything is restated from VISION/ARCHITECTURE/ground-rules/tier-selector. Sweep references and redirect each to canonical source during PR 1. |
| D2 | Trace tag format | **Unify to one shape:** `<!-- <action>: <source> YYYY-MM-DD -->` where `action ∈ {added, reconciled, revised}` and `source` is feature-name or `drift`. Defined once in `lsa/knowledge/conventions.md`. Side effect: fixes the `reconciled` tag's missing source field. |
| D3 | Spec-template extraction (`requirements.md` / `test-suites.md` / `design.md` templates inlined in `lsa-specify`) | **Defer to a future PR.** Keeps PR 2 scope tight. |

---

## 2. The three PRs

### PR 1 — Stratum-3 prune (meta-doc deduplication)

**Status:** [done] — completed 2026-05-20. Net: −680 lines across 5 files. `lsa` bumped 0.2.0 → 0.2.1. See `lsa/CHANGELOG.md` 0.2.1 entry.

**Goal:** delete restated content across meta-docs. No skill behavior changes. Lowest-risk PR.

**Files outside `artifact_paths`** — `lsa-verify` is not triggered (a known coverage gap, separate from this refactor).

| File | Action |
|---|---|
| `lsa/ARCHITECTURE.md` | Shrink ~540 → ~80 lines. **Keep:** §1 Purpose, §3 Directory, §4.10 `.lsa.yaml` schema, §9 Branch management, §11 Resolved decisions. **Delete:** §2 (dup VISION §2), §4.1–§4.9 (dup SKILL.md), §5 Workflow phases (dup SKILL.md), §6 Testing (dup `standards/testing.md`), §7 Fact-check (dup `ground-rules`), §8 Constitution revision (dup `lsa-revise-constitution`), §10 Skills index (dup README). |
| `vision/specs/standards/agents.md` | **Delete.** Sweep `grep -r "standards/agents.md"` references; redirect each to the canonical source named in the deleted section. |
| `vision/specs/modules/lsa/spec.md` | Shrink ~144 → ~40 lines. Keep "Role", "State files", "Invariants", `.lsa.yaml` 1-line pointer. Delete per-skill catalog (`:35-99`); replace with 1-line skill list pointing to `lsa/README.md`. |
| `vision/specs/modules/core/spec.md` | Shrink ~67 → ~25 lines. Delete per-skill behavioral-contract tables (`:17-42`). |
| `CLAUDE.md` (repo) | Shrink ~124 → ~30 lines. Keep: intro paragraph, install block, pointer to VISION + `.lsa.yaml`. Delete: ground-rules text (dup `core/CLAUDE.md`), tier outcomes (dup `core/CLAUDE.md`), directory tree (now in ARCHITECTURE §3), Discipline bullets (in VISION + `standards/code.md`). |
| `core/CLAUDE.md` | Add header comment marking it as canonical source of the always-on rules block. No content change. |
| `vision/specs/standards/code.md` | Audit for VISION duplication. Trim if found. |
| `vision/specs/standards/testing.md` | Audit for skill-body duplication. Trim if found. |
| `lsa/CHANGELOG.md` | Add 0.2.1 entry: *"docs: prune duplicated content across ARCHITECTURE / module spec / standards"*. |
| `lsa/.claude-plugin/plugin.json` | Bump 0.2.0 → 0.2.1. |
| `core/CHANGELOG.md` | Add 0.2.1 entry only if `core/CLAUDE.md` changed materially. |
| `core/.claude-plugin/plugin.json` | Bump only if above. |

**Estimated impact:** ~500–600 lines deleted.

---

### PR 2 — Stratum-1+2 cleanup (skill body deduplication)

**Status:** [done] — completed 2026-05-20. Net: −100 lines across 11 skill bodies, +73 lines in new `lsa/knowledge/conventions.md`, +~50 lines across two CHANGELOG entries. `core` bumped 0.2.1 → 0.3.0; `lsa` bumped 0.2.1 → 0.3.0. See `core/CHANGELOG.md` 0.3.0 and `lsa/CHANGELOG.md` 0.3.0 entries.

**Goal:** extract cross-skill conventions into Knowledge; trim skill bodies to actor-template essence.

**Touches `artifact_paths`** — must run through full LSA flow on this repo (`lsa-discover → lsa-specify → lsa-plan → implement → lsa-verify → lsa-sync`) per I9.

**New file:**

| File | Content |
|---|---|
| `lsa/knowledge/conventions.md` *(new)* | (1) `.lsa.yaml` defaults block — once. (2) Read protocol — once. (3) Hard / Soft Confirm definitions — once. (4) Unified tag format `<!-- <action>: <source> YYYY-MM-DD -->` — once. |

**Skill edits:**

| File | Edit |
|---|---|
| `lsa/skills/lsa-init/SKILL.md` | Step 1: cite conventions; delete inline defaults. |
| `lsa/skills/lsa-discover/SKILL.md` | Step 1: cite conventions. |
| `lsa/skills/lsa-specify/SKILL.md` | Step 1: cite conventions; delete "Confirm gate definitions" section (`:25-28`). Spec templates remain inline (D3 — deferred). |
| `lsa/skills/lsa-plan/SKILL.md` | Step 1: cite conventions. |
| `lsa/skills/lsa-verify/SKILL.md` | Step 1: cite conventions. **Keep verification checklist inline** (procedural, not reference). |
| `lsa/skills/lsa-sync/SKILL.md` | Step 1: cite conventions; tag format → cite conventions (using unified D2 shape). |
| `lsa/skills/lsa-reconcile/SKILL.md` | Tag format → cite conventions (D2). |
| `lsa/skills/lsa-revise-constitution/SKILL.md` | Step 1: cite conventions; tag format → cite conventions (D2). |
| 6 LSA skills with `[assumption: <why>]` Constraints line | **Delete the line** — `core/skills/ground-rules/SKILL.md:13-19` is canonical. Files: `lsa-init:110`, `lsa-specify:200`, `lsa-plan:125`, `lsa-verify:152`, `lsa-sync:150`, `lsa-revise-constitution:96`. |
| `core/skills/tier-selector/SKILL.md` | Steps 1+2: cite `vision/VISION.md:124, 126` instead of restating boundary signals + classification table (`:21-37`). Resolves debt at `lsa/ARCHITECTURE.md:459`. |
| `core/skills/actor-template/SKILL.md` | Pick ONE statement form. Delete duplicate "Rules" section (`:20-25`) and "What this skill never does" trailer (`:70-74`). Keep preamble + 5-section spec + worked example + copy-paste template. |
| `core/skills/ground-rules/SKILL.md` | Delete redundant "What this skill never does" trailer (`:69-75`). Keep four numbered rules + examples. |
| All 11 skills | `description:` frontmatter trim to ≤2 sentences (what + trigger phrases). Move implementation detail to body. |

**Versioning:**
- `core/CHANGELOG.md`: 0.2.x → 0.3.0 (minor — tier-selector body changed, knowledge boundary tightened).
- `core/.claude-plugin/plugin.json`: bump.
- `lsa/CHANGELOG.md`: 0.2.1 → 0.3.0 (minor — knowledge file added, skill bodies changed materially).
- `lsa/.claude-plugin/plugin.json`: bump.

**Estimated impact:** ~250–350 lines deleted from skills; ~150 added in `conventions.md`. Net ~100–200 line reduction.

---

### PR 3 — KISS quick wins (small surgical edits)

**Status:** [done] — completed 2026-05-20. Net: ~+10 lines (justifications + new Step 5 in `lsa-specify` slightly outweigh mechanical-detection trim). `lsa` bumped 0.3.0 → 0.3.1. See `lsa/CHANGELOG.md` 0.3.1 entry. Pre-Feature Checklist orphan was already deleted by PR 1 (`ARCHITECTURE.md` §5 prune); recorded here for traceability. `mode: mixed` deliberately retained.

**Goal:** remove orphans, magic numbers, redundant prompts.

**Touches `artifact_paths`** — full LSA flow required.

| File | Action |
|---|---|
| `lsa/ARCHITECTURE.md` (post-PR1) | Delete orphan Pre-Feature Checklist (originally `:244-249`). No owner; not enforced anywhere. |
| `lsa/skills/lsa-init/SKILL.md` Step 2 | Replace human question *"Greenfield or brownfield?"* with mechanical detection: *"If `${specs_root}/modules/` is empty AND `modules.*.artifact_paths` are empty → greenfield; else brownfield. Print determination; confirm."* Keeps the gate; removes redundant interrogation. |
| `lsa/skills/lsa-plan/SKILL.md` Step 2 | Add justification for ≤5 epics: *"chosen to keep epic-level human review tractable; if you cannot decompose in five, the feature is too large — escalate to spec reduction."* Closes magic-number gap. |
| `lsa/skills/lsa-specify/SKILL.md` Step 4 | Split contract trigger into its own Step 4.5 *"Determine contract requirement"* so each step has one Goal/Output (`:109-115`). |
| `lsa/CHANGELOG.md` | 0.3.0 → 0.3.1 entry. |
| `lsa/.claude-plugin/plugin.json` | Bump. |

**NOT in PR 3** (round-2 flagged but kept): `mode: mixed` — marginal complexity, removing would break an existing config surface (`lsa/ARCHITECTURE.md:230`).

**Estimated impact:** ~30 lines net.

---

## 3. What the plan deliberately does NOT do

Design decisions to keep (carried from rounds 1 + 2):

- No skill merging.
- No deletion of confirm gates.
- No removal of "observable result" annotations.
- No collapse of the four ground rules.
- No removal of `actor-template`'s 5-section shape.
- No extraction of `lsa-verify`'s verification checklist (procedural, not reference).
- No removal of `mode: mixed`.
- No flip of the module spec ↔ SKILL.md source-of-truth direction (real architectural tension flagged round 2; out of scope for a simplification refactor).

---

## 4. Invariant verification

| # | Invariant | Verdict | How preserved |
|---|---|---|---|
| I1 | Fact-grounding | ✓ | Plan deletes only second-copies. Every deletion has its canonical citation surviving. No sourced claim lost — only restated copies disappear. |
| I2 | Spec-grounding | ✓ | No spec → artifact link is broken. Module specs shrink but retain invariants and module-level contracts. Each skill still describes its behavior in its `SKILL.md`. |
| I3 | Knowledge vs Actor | ✓ **strengthened** | Current state has 11 boundary violations (round-2 findings). PR 2 extracts Knowledge from Actor bodies into `lsa/knowledge/conventions.md`; PR 1 strips Knowledge restatements from meta-docs. Directly serves `vision/VISION.md:57` *"Boundary violations are the highest-severity defect"*. |
| I4 | SoC / DRY / KISS | ✓ **strengthened** | Plan's primary purpose. ~900–1,100 net lines removed across the repo; one source-of-truth per concept. |
| I5 | Read before write | ✓ | Read protocol still lives in `core/skills/ground-rules/SKILL.md` (Rule 3) and `lsa/knowledge/conventions.md` (procedural form). All 6 LSA skills still invoke it (now by citation). |
| I6 | Ceremony T1/T2/T3 | ✓ | Tier-selector still classifies. Downstream skills still gate. No tier flow changes. Tier table lives in one place (`vision/VISION.md` §4); everywhere else cites. |
| I7 | Reconcile (Level 2.5) | ✓ | `lsa-reconcile`'s class (a)/(b) logic, per-module hard confirm, reverse-sync, and state-file mechanics all preserved. PR 2 only swaps inline `[assumption]` line for a citation. |
| I8 | Per-plugin SemVer + CHANGELOG | ✓ | Every PR includes version bump + CHANGELOG entry per `vision/VISION.md:44`. PR 1 → 0.2.1; PR 2 → 0.3.0; PR 3 → 0.3.1. |
| I9 | Dogfood | ✓ | PRs 2+3 modify `artifact_paths` and must run through the LSA flow (verified clean before merge). PR 1 modifies docs outside `artifact_paths` — a known coverage gap, not a regression. |

**Net assessment:** plan does not weaken any invariant. Strengthens I3 (Knowledge vs Actor) and I4 (DRY) by direct intent.

---

## 5. Total impact estimate

- ~900–1,100 lines deleted across the repo.
- ~150–200 lines added in `lsa/knowledge/conventions.md`.
- Net ~700–900 line reduction.
- Zero invariants weakened; two strengthened (I3, I4).

---

## 6. PR 4 — Contributor documentation (added post-hoc)

**Status:** [done] — completed 2026-05-20. Added after PR 1–3 to capture the discipline established during this session as actionable contributor instructions.

**Goal:** new `CONTRIBUTING.md` at repo root reflecting the rules surfaced by this refactor — DRY, SRP, KISS, factual, concrete, actionable.

**Files changed:**

| File | Action |
|---|---|
| `CONTRIBUTING.md` (new, repo root) | Single-purpose contributor workflow: setup, tier classification, adding skills, adding Knowledge surfaces, versioning, verifying, multi-step refactor pattern, discipline (sourced citations), anti-patterns. ~110 lines. No restatement of VISION/ARCHITECTURE/standards content — only citation. |
| `CLAUDE.md` (repo) | Added one line to "Further reading" linking to `CONTRIBUTING.md`. |

**No version bumps.** Both `CONTRIBUTING.md` and repo `CLAUDE.md` live outside per-plugin `artifact_paths` (verified against `.lsa.yaml`). No plugin behavior change.

**Invariant check:** I1–I9 all preserved. The new file itself is built per I3 (Knowledge surface, not Actor) and I4 (every fact cited rather than restated), so it acts as a live example of the discipline.
