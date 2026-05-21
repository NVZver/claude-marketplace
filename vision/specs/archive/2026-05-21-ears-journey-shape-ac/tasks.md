# Tasks: EARS + Journey-shape AC Discipline

## Epic Overview

| Epic | Branch | Status | Dependency |
|------|--------|--------|------------|
| E1: Vision principle 2a + §6 Adjust #1 RESOLVED | `feature/2026-05-21-ears-journey-shape-ac-e1` | pending | none |
| E2: `lsa-specify` Gate 1 template + Gate 2 diagonal rows | `feature/2026-05-21-ears-journey-shape-ac-e2` | pending | none |
| E3: `lsa-plan` epic template `**Covers:**` line | `feature/2026-05-21-ears-journey-shape-ac-e3` | pending | none |
| E4: `lsa-verify` AC-ID trace predicates | `feature/2026-05-21-ears-journey-shape-ac-e4` | pending | none |
| E5: Module spec + roadmap + CHANGELOG + version bump | `feature/2026-05-21-ears-journey-shape-ac-e5` | pending | E1, E2, E3, E4 (CHANGELOG describes their changes) |

E1-E4 are parallel-safe (no runtime dependency; each touches a distinct file). E5 has a content-reference dependency on E1-E4 because its `lsa/CHANGELOG.md` entry describes their changes; safe to plan in parallel but final CHANGELOG text lands last.

## Epics

### Epic 1: Vision principle 2a + §6 Adjust #1 RESOLVED

**Description.** Author the new sub-principle 2a under `vision/VISION.md` §2 principle 2 (*"Two groundings, always"*) and append the RESOLVED marker to §6 Adjust #1. Per Gate 3 routing decision, route via `lsa-revise-constitution`, not direct edit.

**Scope.**
- Files/modules touched: `vision/VISION.md`
- Creates / modifies / deletes: modifies §2 (add 2a) + §6 Adjust #1 (append RESOLVED line)
- Does NOT touch: any `lsa/` SKILL, any module spec, any roadmap/CHANGELOG

**Covers:** F6, AC1 (enables — Gate 2 cites 2a; without 2a the citation is forward-broken)

**Technical Details.** Invoke `lsa-revise-constitution` with the principle 2a text and §6 RESOLVED marker text from `design.md` §5-§6. Skill is the conventional path for constitution edits (`vision/VISION.md` §2 principle 7: *"The human owns intent; the system absorbs reality"* — constitution edits are intent-owned, route through the dedicated skill).

**Acceptance Criteria.**
- [ ] AC1: `vision/VISION.md` §2 contains sub-principle 2a *"Acceptance criteria are journey-shaped"* with the body text from `design.md` §5.
- [ ] AC2: `vision/VISION.md` §6 Adjust #1 has the RESOLVED line from `design.md` §6.
- [ ] AC3: The Vision edit was authored via `lsa-revise-constitution` (commit message references the skill).

**Testing Plan.**
| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | N/A — markdown only | — |
| Integration | `lsa-verify` parses the new principle and §6 marker without error | Must |
| E2E | V2 probe: in a fresh session, ask "what does Vision §2 principle 2a say?" → agent quotes the new text | Must |

**Definition of Done.**
- [ ] All ACs pass
- [ ] `lsa-verify` clean for E1's diff
- [ ] No code smells per `vision/specs/standards/code.md`

---

### Epic 2: `lsa-specify` Gate 1 template + Gate 2 diagonal rows

**Description.** Update `lsa/skills/lsa-specify/SKILL.md` in two places: Gate 1 template (AC sub-block becomes EARS-form with `vision/VISION.md:201` citation) and Gate 2 diagonal coverage table (insert rows 1a EARS-pattern + 1b journey-shape between existing rows 1 and 2; failing-row Rule 6 prose updated to include the new resolutions).

**Scope.**
- Files/modules touched: `lsa/skills/lsa-specify/SKILL.md`
- Creates / modifies / deletes: modifies Gate 1 template at `SKILL.md:48-77` and Gate 2 body at `SKILL.md:154-176`
- Does NOT touch: any other SKILL, Vision, module spec, CHANGELOG

**Covers:** F1, F2, F3, AC1, AC2

**Technical Details.** Per `design.md` §1-§2. Reuses the existing `✗` Rule 6 decision-block render at `SKILL.md:162-176` for the two new rows. EARS pattern list + journey-shape definition are cited from `vision/VISION.md:201` and `vision/VISION.md` 2a (added in E1) — not restated in the SKILL body per NFR4 (Knowledge vs Actor).

**Acceptance Criteria.**
- [ ] AC1: Gate 1 template at `lsa/skills/lsa-specify/SKILL.md:48-77` shows the `## Acceptance Criteria` sub-block in EARS form with a `vision/VISION.md:201` citation inline.
- [ ] AC2: Gate 2 diagonal table at `lsa/skills/lsa-specify/SKILL.md:158-161` has rows 1a (EARS-pattern) and 1b (journey-shape) between row 1 (AC→Journey) and row 2 (Journey→Design).
- [ ] AC3: Failing-row Rule 6 decision-block prose at `lsa/skills/lsa-specify/SKILL.md:162-176` references EARS / journey-shape resolutions in the `[a]` / `[b]` slots.

**Testing Plan.**
| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | N/A — SKILL body is markdown | — |
| Integration | Render diagonal table from a fresh `lsa-specify` invocation; verify 6 rows (5 with contract skipped) | Must |
| E2E | V2 probe: feed `lsa-specify` a `requirements.md` draft with a non-EARS AC line; verify Gate 2 surfaces the line with a Rule 6 decision block. Mirrors Journey 1 Path 2 in `test-suites.md:9`. | Must |

**Definition of Done.**
- [ ] All ACs pass
- [ ] `lsa-verify` clean for E2's diff
- [ ] V2 E2E probe passes in fresh session

---

### Epic 3: `lsa-plan` epic template `**Covers:**` line

**Description.** Add a `**Covers:** AC<n>, AC<n>` line under each epic's `### Scope` section in `lsa/skills/lsa-plan/SKILL.md`'s template. Add a sibling self-verification row that checks every `requirements.md` AC appears in at least one epic's `**Covers:**`.

**Scope.**
- Files/modules touched: `lsa/skills/lsa-plan/SKILL.md`
- Creates / modifies / deletes: modifies epic template at `SKILL.md:38-67` and self-verification table at `SKILL.md:73-79`
- Does NOT touch: any other SKILL, Vision, module spec, CHANGELOG

**Covers:** F8, AC3 (enables), AC4 (enables)

**Technical Details.** Per `design.md` §3. Single new line `**Covers:** AC1, AC2` under `### Scope`. Self-verification table gains one row (per design): *"AC coverage — Does every requirements.md AC appear in at least one epic's `**Covers:**` line?"*. Epic-level `### Acceptance Criteria` blocks (locally numbered) stay as-is — this is for epic Definition-of-Done, not requirement trace.

**Acceptance Criteria.**
- [ ] AC1: Epic template at `lsa/skills/lsa-plan/SKILL.md:38-67` has a `**Covers:** AC<n>, AC<n>` line under `### Scope`.
- [ ] AC2: Self-verification table at `lsa/skills/lsa-plan/SKILL.md:73-79` has a new "AC coverage" row checking every `requirements.md` AC is cited in ≥1 epic's `**Covers:**`.

**Testing Plan.**
| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | N/A — SKILL body is markdown | — |
| Integration | Run `lsa-plan` on a small feature spec; verify tasks.md output includes the `**Covers:**` line | Must |
| E2E | V2 probe: fresh-session `lsa-plan` invocation on a small fake feature; check tasks.md schema | Must |

**Definition of Done.**
- [ ] All ACs pass
- [ ] `lsa-verify` clean for E3's diff
- [ ] V2 E2E probe passes

---

### Epic 4: `lsa-verify` AC-ID trace predicates

**Description.** Add orphan-diff and orphan-AC predicates to `lsa/skills/lsa-verify/SKILL.md`. Both predicates source from `tasks.md`'s `**Covers:**` line (introduced by E3).

**Scope.**
- Files/modules touched: `lsa/skills/lsa-verify/SKILL.md`
- Creates / modifies / deletes: modifies verify logic body (exact section depends on current SKILL.md structure — to be located at implementation time)
- Does NOT touch: any other SKILL, Vision, module spec, CHANGELOG

**Covers:** F4, F5, AC3, AC4

**Technical Details.** Per `design.md` §4. Two predicates:
- **Orphan-diff.** For every non-trivial diff hunk: epic in `tasks.md` whose `### Scope` covers the hunk and whose `**Covers:**` cites ≥1 AC ID → if no such epic → FAIL with `<file>:<line> has no AC trace`.
- **Orphan-AC.** For every AC ID in `requirements.md` § Acceptance Criteria: ≥1 epic cites the ID in `**Covers:**` → if no such epic → FAIL with `requirements.md:<line> has no covering implementation`.

Non-trivial-diff filter reuses the existing doc-mode filter (skips whitespace/formatting hunks).

**Acceptance Criteria.**
- [ ] AC1: `lsa-verify` SKILL.md describes the orphan-diff predicate with FAIL output `<artifact-file>:<line> has no requirement trace`.
- [ ] AC2: `lsa-verify` SKILL.md describes the orphan-AC predicate with FAIL output `requirements.md:<AC-line> has no covering implementation`.
- [ ] AC3: Both predicates cite `tasks.md`'s `**Covers:**` line as source.

**Testing Plan.**
| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | N/A — SKILL body is markdown | — |
| Integration | Run `lsa-verify` on this very feature branch at end of implementation; verify clean PASS (dogfood) | Must |
| E2E | V2 probe: synthetic feature with deliberate orphan diff → verify FAIL with citation; orphan AC → verify FAIL with citation. Mirrors `test-suites.md` Journey 2 paths 2 + 3. | Must |

**Definition of Done.**
- [ ] All ACs pass
- [ ] `lsa-verify` clean for E4's diff
- [ ] V2 E2E probes (orphan-diff, orphan-AC) both pass

---

### Epic 5: Module spec + roadmap + CHANGELOG + version bump

**Description.** Add the `lsa` module spec invariant entry; reconcile `vision/specs/roadmap.md` (mark EARS shipped, mark stale diagonal entry shipped, add v0.6.0 and v0.5.0 to Recently merged); author `lsa/CHANGELOG.md` `[0.6.0] - 2026-05-21` entry; bump `lsa/.claude-plugin/plugin.json` version `0.5.0 → 0.6.0`; review `lsa/README.md` for user-visible delta.

**Scope.**
- Files/modules touched: `vision/specs/modules/lsa/spec.md`, `vision/specs/roadmap.md`, `lsa/CHANGELOG.md`, `lsa/.claude-plugin/plugin.json`, `lsa/README.md` (read-only confirm)
- Creates / modifies / deletes: modifies all 4 first files; reads README to confirm no delta needed
- Does NOT touch: any SKILL body, Vision

**Covers:** F6, NF3

**Technical Details.** Per `design.md` §7-§8. Module spec invariant text from §7. Roadmap edits from §8. CHANGELOG entry follows Keep a Changelog format per `vision/specs/main.spec.md` NFR3. SemVer bump in the same commit as the CHANGELOG entry per NFR3.

**Acceptance Criteria.**
- [ ] AC1: `vision/specs/modules/lsa/spec.md` has a new invariant bullet per `design.md` §7.
- [ ] AC2: `vision/specs/roadmap.md` row 9 (EARS) status → `shipped — lsa v0.6.0`; row 11 (Diagonal) status → `shipped — lsa v0.5.0`; Recently merged gains two new entries.
- [ ] AC3: `lsa/CHANGELOG.md` has a new `[0.6.0] - 2026-05-21` entry per Keep a Changelog.
- [ ] AC4: `lsa/.claude-plugin/plugin.json` `version` field is `"0.6.0"`.
- [ ] AC5: `lsa/README.md` reviewed; user-visible delta either landed or explicitly confirmed unnecessary.

**Testing Plan.**
| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Unit | N/A — markdown / JSON | — |
| Integration | `/plugin install lsa@NVZver` after merge; `/help` lists the same skill table; V1 install passes | Must |
| E2E | Confirm `lsa/.claude-plugin/plugin.json` parses; CHANGELOG renders as Keep a Changelog | Must |

**Definition of Done.**
- [ ] All ACs pass
- [ ] `lsa-verify` clean for E5's diff (note: lsa-verify must accept the Covers field citing non-AC requirements F6 + NF3 — see self-verification finding below)
- [ ] V1 install probe passes

---

## Integration Checklist

- [ ] All epics merged into feature branch `feature/2026-05-21-ears-journey-shape-ac`
- [ ] E2E tests pass on feature branch (Journey 1 paths 1+2+3; Journey 2 paths 1+2+3 per `test-suites.md`)
- [ ] Integration tests pass (each epic's Testing Plan integration row)
- [ ] `lsa-verify` passes on feature branch
- [ ] `lsa-sync` completed (feature → module specs absorbed; feature archived under `vision/specs/archive/`)
- [ ] PR to `main` created

---

## Self-verification

| Check | Question | Result |
|-------|----------|--------|
| Traceability | Does every epic map to at least one requirement in `requirements.md`? | **PASS** — E1→F6+AC1(enables); E2→F1+F2+F3+AC1+AC2; E3→F8+AC3(enables)+AC4(enables); E4→F4+F5+AC3+AC4; E5→F6+NF3 |
| Accuracy | Does the technical approach match `design.md`? | **PASS** — E1↔design.md §5+§6; E2↔§1+§2; E3↔§3; E4↔§4; E5↔§7+§8 |
| Consistency | Do any epics overlap in scope or contradict each other? | **PASS** — no file overlap between epics; every `**Covers:**` cites a valid requirement ID per F8. |
| Test coverage | Is every AC covered by at least one test in the testing plan? | **PASS** — AC1 → E2 E2E (Journey 1 Path 2); AC2 → E2 E2E (Journey 1 Path 3); AC3 → E4 E2E (Journey 2 Path 2 orphan-diff); AC4 → E4 E2E (Journey 2 Path 3 orphan-AC) |
| Completeness | Are there requirements with no corresponding epic? | **PASS** — F1-F8 all in E1/E2/E3/E4/E5; NF1 is forward-only (no impl needed); NF2 is a citation-format constraint on E2's render; NF3 in E5; NF4 is a constraint on E2 + E4 content |
