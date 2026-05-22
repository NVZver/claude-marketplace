# Tasks: /maintenance:cleanup

## Epic Overview

| Epic | Branch | Status | Dependency |
|------|--------|--------|------------|
| E0: manual-before-automate cleanup waves (validation input) | `feature/2026-05-21-maintenance-cleanup` (pre-spec commits) | done | none |
| E1: maintenance plugin scaffold + registration | `feature/2026-05-21-maintenance-cleanup-e1` | done | E0 (empirical input) |
| E2: cleanup skill body (6-phase actor) | `feature/2026-05-21-maintenance-cleanup-e2` | done | E0 (procedure capture) |

E0 captures the pre-spec manual validation that informed the SKILL.md (per NF6 *manual-before-automate*). E1 and E2 are file-disjoint (E1 touches infra files, E2 touches the skill body) and were developed on independent branches. Integration happened by merging both into the parent feature branch (`feature/2026-05-21-maintenance-cleanup`) before the final lsa-verify + lsa-sync.

---

## Epics

### Epic 0: manual-before-automate cleanup waves (validation input)

#### Description

Three pre-spec commits on this feature branch executed the cleanup procedure manually end-to-end on real repo content before any SKILL.md was authored. The pass achieved -52.1% shipped-non-archive token reduction (65,659 → 31,450) and surfaced the 12-step procedure that E2 encodes. Documented retroactively to close the orphan-diff predicate against the feature spec; covers NF6.

#### Scope

- **Commits (pre-spec, on this branch):** `35b1068` (wave 1 — archive lsa-v0.2.0 design+plan), `9c1a9f2` (wave 2 — archive credo-rollout + simplification plans + plan-file-as-spec deprecation in CONTRIBUTING.md), `cb2bad1` (wrap-up — `core` v0.5.3 + `lsa` v0.6.3 version bumps + CHANGELOG entries).
- **Creates (pre-spec discovery artifacts inside feature spec dir):**
  - `vision/specs/features/2026-05-21-maintenance-cleanup/discovery.md`
  - `vision/specs/features/2026-05-21-maintenance-cleanup/clarification.md`
  - `vision/specs/features/2026-05-21-maintenance-cleanup/manual-pass-notes.md`
- **Modifies (infra cleanup, outside feature SKILL scope but inside feature branch):**
  - `CONTRIBUTING.md` (plan-file-as-spec fallback deprecation)
  - `core/.claude-plugin/plugin.json` (v0.5.2 → v0.5.3)
  - `core/CHANGELOG.md` (citation-path updates + v0.5.3 entry)
  - `lsa/.claude-plugin/plugin.json` (v0.6.2 → v0.6.3)
  - `lsa/ARCHITECTURE.md` (citation-path updates to archived locations)
  - `lsa/CHANGELOG.md` (citation-path updates + v0.6.3 entry)
  - `vision/specs/main.spec.md` (core + lsa version rows updated)
  - `vision/specs/modules/core/spec.md` (citation-path updates)
  - `vision/specs/modules/lsa/spec.md` (citation-path updates)
  - `vision/specs/roadmap.md` (citation-path updates)
  - `vision/specs/standards/testing.md` (citation-path updates)
  - `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/discovery.md` (link-target fix per F8)
- **Renames (archive relocations per F6.1):**
  - `vision/specs/2026-05-20-lsa-v0.2.0-design.md` → `vision/specs/archive/2026-05-20-lsa-v0.2.0/design.md`
  - `vision/plans/2026-05-20-lsa-v0.2.0-plan.md` → `vision/specs/archive/2026-05-20-lsa-v0.2.0/plan.md`
  - `vision/plans/2026-05-20-credo-rollout-plan.md` → `vision/specs/archive/2026-05-20-credo-rollout/plan.md`
  - `vision/plans/2026-05-20-simplification-refactor-plan.md` → `vision/specs/archive/2026-05-20-simplification-refactor/plan.md`
- **Does NOT touch:** the `maintenance/` plugin directory (that's E1+E2's scope).

**Covers:** NF6 <!-- the entire epic is the empirical validation captured by NF6 -->

#### Technical Details

Procedure was executed by-hand: human ran inventory (heuristic token count via `wc -w * 1.3`), classified candidates into the 5 edit classes that E2 later encoded, applied each patch, checked the 6 universal invariants by-hand, ran the 12-check verification protocol by-hand. Lessons captured in `manual-pass-notes.md`. The empirical observation that signal (d) — relocation-candidate detection — produces the highest-leverage class drove `requirements.md` F2's *"Signal (d) is the highest-leverage class (proven by wave 1+2 → -52.1%)"* claim.

#### Acceptance Criteria

- [x] AC-E0-1: 3 wave commits exist on this feature branch (`git log main..HEAD | grep -E '35b1068|9c1a9f2|cb2bad1'`).
- [x] AC-E0-2: Shipped-non-archive token total reduced by ≥50% across waves 1+2 (`-52.1%` per `9c1a9f2` commit message).
- [x] AC-E0-3: 12-step procedure captured in `manual-pass-notes.md` and encoded verbatim into `maintenance/skills/cleanup/SKILL.md` Steps 1–6.

#### Definition of Done

- [x] All 3 wave commits ship on the parent feature branch (`feature/2026-05-21-maintenance-cleanup`)
- [x] `manual-pass-notes.md` exists in the feature spec dir
- [x] `core` v0.5.3 + `lsa` v0.6.3 documented in their CHANGELOGs
- [x] NF6 cites this epic as the empirical validation

---

### Epic 1: maintenance plugin scaffold + registration

#### Description

Create the new `maintenance` plugin shell, register it with the marketplace + LSA tracking, and write the module spec. Provides the shipping surface the cleanup skill will live on. No skill body in this epic — that's E2.

#### Scope

- **Creates:**
  - `maintenance/.claude-plugin/plugin.json` (name, description, version `0.1.0`, author)
  - `maintenance/README.md` (install instructions, single-skill overview, NF1 budgets documented, NF3 Ollama/Mistral target stated, F4 output paths documented — `vision/reports/cleanup-<date>.md`)
  - `maintenance/CHANGELOG.md` (Keep-a-Changelog format; `[0.1.0]` entry describing the cleanup skill)
  - `vision/specs/modules/maintenance/spec.md` (module-level invariants; lists `cleanup` skill with forward reference; depends-on `core` v0.5.3+)
- **Modifies:**
  - `.claude-plugin/marketplace.json` (append `maintenance` plugin entry with name + source `./maintenance` + description)
  - `.lsa.yaml` (add `modules.maintenance.spec` + `artifact_paths` covering `maintenance/skills/**/SKILL.md`, `maintenance/.claude-plugin/plugin.json`, `maintenance/README.md`)
  - `vision/specs/main.spec.md` (append `maintenance` row to Module Index)
- **Does NOT touch:** `maintenance/skills/` (E2's territory)

**Covers:** F4, NF1, NF3, AC1 <!-- F4=output paths documented; NF1=budgets stated; NF3=Ollama/Mistral target framed; AC1=skill exists to be invoked -->

#### Technical Details

Follows `vision/specs/standards/code.md` *"Markdown-only"* (no `/src/`). Plugin manifest is the minimal JSON (5 fields). README sized within the per-plugin README budget (≤ 1,500 tokens per NF1). Module spec follows the `core`/`lsa` precedent — module-level invariants only, not a per-skill catalog (that lives in the plugin README). `.lsa.yaml` schema follows the existing `core` + `lsa` entries (spec path + artifact_paths globs).

#### Acceptance Criteria

- [ ] AC-E1-1: `/plugin install maintenance@NVZver` succeeds; `/help` lists `/maintenance:cleanup` (V1 probe per `vision/specs/standards/testing.md`).
- [ ] AC-E1-2: `vision/specs/main.spec.md` Module Index includes `maintenance` row with version `v0.1.0`.
- [ ] AC-E1-3: `.lsa.yaml` parses; `modules.maintenance.artifact_paths` resolves to ≥1 file once E2 lands.
- [ ] AC-E1-4: `maintenance/README.md` documents NF1 budgets + NF3 target + F4 output paths.

#### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit (structural) | plugin.json parses; marketplace.json parses + lists maintenance; .lsa.yaml parses + modules.maintenance present; module spec exists | Must |
| Integration (V1) | `/plugin install` → `/help` shows the new skill | Must |
| E2E | covered jointly with E2 in the parent feature branch — no independent E2E for E1 alone (the skill body isn't shipped yet) | N/A |

#### Definition of Done

- [ ] All E1 ACs pass
- [ ] V1 probe passes
- [ ] No code smells per the constitution (`core/actor-template` shape for any new Knowledge file; READMEs are living per `CLAUDE.md`)
- [ ] lsa-verify passes on the E1 branch (every file change traces to F4 / NF1 / NF3 / AC1)

---

### Epic 2: cleanup skill body (6-phase actor)

#### Description

Author the `/maintenance:cleanup` SKILL.md actor implementing the 6-phase technical approach from `design.md`. The body follows the Goal / Input / Steps / Output / Constraints shape per `core/actor-template`. Each step produces an observable result. Each user-facing prompt follows `core/output` Rule 5 (concrete subject-driven prompt voice; never render `[a]/[b]/[c]` text blocks when `AskUserQuestion` is available, per `core/CLAUDE.md` operational checkpoint #1).

#### Scope

- **Creates:**
  - `maintenance/skills/cleanup/SKILL.md` — the actor body (6 phases: Preconditions, Inventory, Classify, Stage, Verify, Report)
- **Modifies:** none (E1 has already created all the surfaces this needs)
- **Does NOT touch:** plugin manifest, marketplace.json, .lsa.yaml, main.spec.md, module spec (all E1)

**Covers:** F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, NF1, NF2, NF3, NF4, NF5, AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10

#### Technical Details

The SKILL.md body implements the 6 phases verbatim from `design.md` § Technical Approach:

1. **Preconditions** — checks branch ≠ `main` + `git status --porcelain` empty. Phase output: continue or abort.
2. **Inventory** — `git ls-files` + filter per F1; `wc -w * 1.3` per file; run the 4 signal detectors from F2. Phase output: classified candidate-patch list.
3. **Classify** — assigns each candidate to one of 5 edit classes (F6).
4. **Stage** — applies each patch, checks F3 invariants + class-specific rules, records skips per AC8 categorization. `relocate` class uses `git mv` + archival-comment + narrative-preserve + relative-link-recalc + line→section-citation upgrade (F7). Archive link-target fixes allowed per F8.
5. **Verify** — runs the 12-check protocol (F5). On any FAIL: `git restore` staged files + report failure with `file:line`.
6. **Report** — writes `vision/reports/cleanup-<YYYY-MM-DD>.md` (creates `vision/reports/` if absent per OQ2). Aborts if file exists (AC10).

The skill body itself respects the NF1 SKILL.md budget (≤ 2,000 tokens) — this is the dogfood test (NF3 — Ollama/Mistral friendliness for the skill that enforces friendliness).

#### Acceptance Criteria

- [ ] AC-E2-1 through AC-E2-10: Direct 1:1 with AC1–AC10 from `requirements.md`. Each verified by running the matching journey from `test-suites.md` manually.
- [ ] AC-E2-11: SKILL.md frontmatter has `name: cleanup` + a description that triggers reliably on phrases "cleanup the repo", "trim the repo", "run /maintenance:cleanup".
- [ ] AC-E2-12: SKILL.md body fits within the NF1 SKILL.md budget (≤ 2,000 tokens).

#### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit (structural) | SKILL.md frontmatter parses; body matches Goal/Input/Steps/Output/Constraints; token count ≤ 2,000 | Must |
| Integration (V2) | description-match triggers reliably across 3–5 fresh-session probes | Must |
| E2E | Execute all 4 journeys from `test-suites.md` manually on this very feature branch (the cleanup skill cleaning the repo it lives in — the deepest dogfood) | Must |

#### Definition of Done

- [ ] All E2 ACs pass
- [ ] V2 probe ≥ 90% trigger rate per `vision/specs/standards/testing.md`
- [ ] All 4 journeys executed end-to-end manually with their expected outcomes
- [ ] SKILL.md respects the NF1 budget
- [ ] No code smells (Goal/Input/Steps/Output/Constraints shape; every step produces observable result; concrete prompt voice on every picker)
- [ ] lsa-verify passes on the E2 branch (every hunk traces to ≥1 covered requirement)

---

## Self-Verification

| Check | Result | Reason |
|-------|--------|--------|
| Traceability | PASS | Every epic traces to ≥1 requirement (E0: NF6; E1: F4, NF1, NF3, AC1; E2: F1–F10, NF1–NF5, AC1–AC10) |
| Accuracy | PASS | E2 § Technical Details mirrors `design.md` § Technical Approach 6-phase flow verbatim |
| Consistency | PASS | E0, E1, E2 touch disjoint file sets (E0: pre-spec validation + repo-level infra; E1: maintenance/* plumbing; E2: skill body). No overlap, no contradiction |
| Test coverage | PASS | Every requirements.md AC covered by ≥1 journey in test-suites.md per User Verification 2 diagonal Row 1; each epic's testing plan exercises those journeys |
| AC coverage | PASS | AC1 covered by both E1 (the skill exists) and E2 (the skill produces the artifacts); AC2–AC10 all covered by E2; NF6 covered by E0 |
| Completeness | PASS | No requirement in requirements.md F1–F10 / NF1–NF6 / AC1–AC10 lacks an epic |

---

## Integration Checklist

- [ ] E1 merged into `feature/2026-05-21-maintenance-cleanup`
- [ ] E2 merged into `feature/2026-05-21-maintenance-cleanup`
- [ ] All 4 journeys in `test-suites.md` executed end-to-end on the feature branch (manual; no harness)
- [ ] V1 + V2 probes pass on a fresh session install
- [ ] lsa-verify passed on `feature/2026-05-21-maintenance-cleanup`
- [ ] lsa-sync completed (feature decisions absorbed into `vision/specs/modules/maintenance/spec.md`; feature archived)
- [ ] PR to main created
