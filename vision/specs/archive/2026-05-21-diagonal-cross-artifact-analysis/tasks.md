# Tasks: Diagonal Cross-Artifact Analysis

## Epic Overview

| Epic | Branch | Status | Dependency |
|------|--------|--------|------------|
| E1: Implement diagonal check in `lsa-specify` Gate 2 | `feature/diagonal-cross-artifact-analysis-e1` | pending | none |
| E2: Document new gate shape in `lsa` module spec | `feature/diagonal-cross-artifact-analysis-e2` | pending | none |
| E3: Per-plugin discipline — SemVer bump + CHANGELOG + README + main.spec.md version sync | `feature/diagonal-cross-artifact-analysis-e3` | pending | none |

All three epics touch disjoint file sets and can be implemented in parallel on independent branches. They merge into the feature branch in any order.

## Epics

### Epic 1: Implement diagonal check in `lsa-specify` Gate 2

#### Description

Edit Step 5 of `lsa/skills/lsa-specify/SKILL.md` (the Gate 2 step) to render a 4-row diagonal coverage table after the existing AC-coverage check. The table covers AC→Journey, Journey→Design, Design→Contract, Contract→test-suites; rows 3–4 render `N/A — contract skipped` when Gate 1 contract-trigger = NO. Failing rows surface as Rule 6 decision blocks rendered together (batched) in a single multi-question `AskUserQuestion` call. Blocks approval until every `✗` row resolved.

#### Scope

- **Files touched:** `lsa/skills/lsa-specify/SKILL.md` only.
- **Creates / modifies / deletes:** modifies one Step 5 block (~30–50 added lines of prose).
- **Does NOT touch:** Gate 1, Gate 3, artifact-file templates, any file outside this skill, any other skill.

#### Technical Details

Per `vision/specs/features/diagonal-cross-artifact-analysis/design.md` §"Technical Approach". The check logic is described in prose inside the SKILL body (per `lsa` invariant: *"Markdown + small JSON / YAML / bash surface. No /src/"* — `vision/specs/modules/lsa/spec.md:30`). Insertion point: after `lsa/skills/lsa-specify/SKILL.md:154` (the existing AC-coverage line), before the rendered presentation of `test-suites.md`.

Citation format per `design.md`: `<file>:<line> ↔ <file>:<line>`. Failure render per `design.md` §"Rule 6 decision block on failure".

#### Acceptance Criteria

- [ ] **AC1.1:** `lsa/skills/lsa-specify/SKILL.md` Step 5 body documents the 4-row coverage table rendered at every Gate 2 fire (mapping to feature AC1).
- [ ] **AC1.2:** Step 5 prose specifies the `file:line` citation format (mapping to feature AC2).
- [ ] **AC1.3:** Step 5 prose specifies the Rule 6 decision block render for `✗` rows, with batched multi-question presentation (mapping to feature AC3 + NF2).
- [ ] **AC1.4:** Step 5 prose specifies `N/A — contract skipped` for rows 3–4 when Gate 1 trigger = NO (mapping to feature AC4).
- [ ] **AC1.5:** Existing AC→Journey check is preserved as row 1, not replaced (mapping to feature F5).

#### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | N/A — no executable code (per `lsa` invariant) | — |
| Integration | N/A — markdown-only skill body | — |
| E2E (V3 manual probe) | Re-run Journey 1, Journey 2, Journey 3 against a synthetic feature spec (a fake `vision/specs/features/probe-feature/` with deliberate contradictions in Path 1 of Journey 3) and inspect the rendered Gate 2 output. Verify: (a) 4-row table appears, (b) all rows cite `file:line`, (c) failing rows render Rule 6 decision blocks, (d) approval blocks until resolved. | Must |
| Read-back | A second pass over Step 5 to confirm the prose is unambiguous to a future agent — no hidden assumptions, no missing edge case. | Must |

#### Definition of Done

- [ ] All E1 ACs pass.
- [ ] V3 manual probe executed on a synthetic feature; output captured in the dogfood findings log.
- [ ] No code smells per `vision/specs/standards/code.md` (which for `lsa` reduces to: prose follows `core/actor-template` shape).
- [ ] `lsa-verify` passed on this epic's diff.

---

### Epic 2: Document new gate shape in `lsa` module spec

#### Description

Add one Invariant line to `vision/specs/modules/lsa/spec.md` § Invariants documenting the 4-row diagonal coverage at `lsa-specify` Gate 2 (mapping to feature AC5).

#### Scope

- **Files touched:** `vision/specs/modules/lsa/spec.md` only.
- **Creates / modifies / deletes:** adds one bullet under § Invariants.
- **Does NOT touch:** any skill file, any plugin manifest, any README.

#### Technical Details

Per feature AC5 + `design.md` OQ5. The Invariant line cites both the SKILL.md Step where the new behavior lives and the feature spec where the contract is defined. Single-sentence form.

Draft (subject to wordsmithing during implementation):

> **Gate 2 diagonal coverage.** `lsa-specify` Gate 2 renders a 4-row cross-artifact coverage table (AC→Journey, Journey→Design, Design→Contract, Contract→test-suites). Each row cites two artifact lines; `✗` rows surface as Rule 6 decision blocks. Per `lsa/skills/lsa-specify/SKILL.md:154` (Step 5) and `vision/specs/archive/<sync-date>-diagonal-cross-artifact-analysis/requirements.md`.

#### Acceptance Criteria

- [ ] **AC2.1:** `vision/specs/modules/lsa/spec.md` § Invariants contains a one-bullet entry naming the 4-row diagonal coverage check (mapping to feature AC5).
- [ ] **AC2.2:** The entry cites both `lsa-specify` SKILL.md Step 5 and the archived feature spec path (filled in post-`lsa-sync`).

#### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Read-back | Read the module spec after edit; confirm the invariant is visible and unambiguous. | Must |
| Trace check | Confirm the cited paths exist and point to the right anchors (`lsa-specify` SKILL.md Step 5 anchor, archived feature spec path). | Must |

#### Definition of Done

- [ ] AC2.1, AC2.2 pass.
- [ ] `lsa-verify` passed on this epic's diff.

---

### Epic 3: Per-plugin discipline — SemVer + CHANGELOG + README + main.spec.md version sync

#### Description

Bump `lsa` plugin SemVer per `vision/specs/main.spec.md:30` NFR3 ("every plugin maintains its own CHANGELOG.md plus a SemVer in plugin.json; bump version in same commit as changelog entry"). Add CHANGELOG entry. Update `lsa/README.md` skill table only if user-visible delta (the lsa-specify row description widens but skill name unchanged — minor edit). Sync `vision/specs/main.spec.md` module index version from the stale `lsa v0.2.0` (logged as Finding #3) to the new `v0.2.x`.

This epic also discharges **dogfood Finding #3** by repairing the main.spec.md stale version reference.

#### Scope

- **Files touched:**
  - `lsa/.claude-plugin/plugin.json` (version field)
  - `lsa/CHANGELOG.md` (new Added entry)
  - `lsa/README.md` (lsa-specify row description, if user-visible delta)
  - `vision/specs/main.spec.md` (module index version cell)
- **Creates / modifies / deletes:** all modifies.
- **Does NOT touch:** `lsa/skills/`, `vision/specs/modules/`, any feature spec.

#### Technical Details

**Version bump decision.** New behavior added to an existing skill, no breaking change. Per [SemVer 2.0.0](https://semver.org/#summary): *"MINOR version when you add functionality in a backward compatible manner."* Bump `lsa` `v0.2.1` → `v0.2.2`.

[unverified — SemVer URL not refetched this session, citing from memory of the standard; please confirm during implementation]

**CHANGELOG entry shape** per Keep a Changelog:

```markdown
## [0.2.2] — YYYY-MM-DD

### Added
- `lsa-specify` Gate 2 now renders a 4-row diagonal cross-artifact coverage table (AC→Journey, Journey→Design, Design→Contract, Contract→test-suites). Failing rows surface as Rule 6 decision blocks that block approval until resolved. Source: `vision/specs/archive/<sync-date>-diagonal-cross-artifact-analysis/`.
```

**main.spec.md module index** — change row `| \`lsa\` | … | active — v0.2.0 |` to `| \`lsa\` | … | active — v0.2.2 |`. The v0.2.0 → v0.2.1 step is a gap (Finding #3); fixing the row to the new version closes the staleness without back-filling history.

#### Acceptance Criteria

- [ ] **AC3.1:** `lsa/.claude-plugin/plugin.json` version reads `0.2.2`.
- [ ] **AC3.2:** `lsa/CHANGELOG.md` has a new `[0.2.2]` section with the dated Added entry naming the diagonal coverage feature.
- [ ] **AC3.3:** `lsa/README.md` skill table reflects the expanded behavior of `lsa-specify` (or pure-refactor exemption invoked per `CLAUDE.md` "READMEs are living documents" — exemption logged).
- [ ] **AC3.4:** `vision/specs/main.spec.md` module index shows `lsa` at `v0.2.2`, closing Finding #3.

#### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Lint | `jq` parses `lsa/.claude-plugin/plugin.json`; version field is a valid SemVer string. | Must |
| Read-back | CHANGELOG renders correctly; the new section is at top; date is today (`2026-05-21`). | Must |
| Trace check | The CHANGELOG citation to the archived feature spec path is correct after `lsa-sync` renames the feature dir to `archive/YYYY-MM-DD-diagonal-cross-artifact-analysis/`. | Must |

#### Definition of Done

- [ ] AC3.1–AC3.4 pass.
- [ ] CHANGELOG entry + plugin.json version bump are in the same commit per `CLAUDE.md` discipline.
- [ ] `lsa-verify` passed on this epic's diff.

---

## Integration Checklist

- [ ] All 3 epics merged into `feature/diagonal-cross-artifact-analysis`.
- [ ] V3 manual probe re-run on the merged feature branch (full Journey 1 + Journey 2 + Journey 3 against a synthetic spec).
- [ ] Cross-epic consistency check: the version cited in E3 CHANGELOG matches the version in E3 plugin.json matches the version in E3 main.spec.md.
- [ ] `lsa-verify` passed on the feature branch.
- [ ] `lsa-sync` completed — `vision/specs/features/diagonal-cross-artifact-analysis/` archived to `vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/`; module spec absorbed E2's Invariant edit; `.lsa-sync-state.json` updated.
- [ ] Dogfood findings log committed to feature branch with all findings #1, #2, #3, plus any surfaced during implementation/verify/sync.
- [ ] PR to `main` created.

---

## Self-Verification

| Check | Result | Reason |
|-------|--------|--------|
| Traceability | PASS | E1 maps to feature F1/F2/F3/F4/F5 + NF1/NF2 + AC1–AC4. E2 maps to feature AC5. E3 maps to `vision/specs/main.spec.md:30` NFR3 + closes Finding #3. |
| Accuracy | PASS | E1 implements `design.md` §"Technical Approach" + §"Coverage table rows" + §"Citation format" + §"Rule 6 decision block on failure". E2 implements `design.md` §"Modules Affected" (lsa) and OQ5. E3 implements per-plugin discipline per `vision/specs/main.spec.md:30`. |
| Consistency | PASS | E1 touches `lsa/skills/lsa-specify/SKILL.md` only. E2 touches `vision/specs/modules/lsa/spec.md` only. E3 touches plugin.json + CHANGELOG + README + main.spec.md. Zero overlap. No contradictions. |
| Test coverage | PASS | Feature ACs 1–4 covered by E1 V3 probe + read-back. Feature AC5 covered by E2 read-back + E1 read-back. NFR3 covered by E3 lint + read-back. |
| Completeness | PASS | All 5 feature ACs + 5 functional requirements + 2 non-functional requirements + 1 main.spec.md NFR (NFR3) have at least one epic. No orphan requirements. |
