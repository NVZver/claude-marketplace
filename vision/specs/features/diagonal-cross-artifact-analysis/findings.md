# Dogfood Findings — diagonal-cross-artifact-analysis

The first end-to-end loop of LSA driving its own development (2026-05-21, single session). Findings logged as they surfaced; some closed in-feature, some deferred.

## Closed in this feature

### Finding #3 — `vision/specs/main.spec.md` module index stale

- **Symptom:** Module index row `| \`lsa\` | … | active — v0.2.0 |` while actual `lsa/.claude-plugin/plugin.json` was already v0.4.0 (bumped to v0.5.0 in E3).
- **Surfaced:** During the Read Protocol of `lsa-specify` (Step 1) — read summary compared main.spec.md to module spec.
- **Closed by:** E3, commit `00807a9` — main.spec.md `lsa` row updated to v0.5.0.

### Finding #4 — `vision/specs/modules/lsa/spec.md` stale on three lines

- **Symptom:** Line 5 `(v0.2.1)`, line 29 `Currently v0.2.1`, line 31 `Depends on core v0.2.0` — all stale by 2 minors.
- **Surfaced:** During E3 planning — when re-deriving the SemVer bump, the actual plugin.json version (v0.4.0) was discovered to mismatch the module spec.
- **Closed by:** E2, commit `8b67a23` — three lines refreshed (v0.5.0 + core v0.4.0 floor).

### Finding #7 — README skill table stale wording

- **Symptom:** `lsa/README.md:17` described `lsa-specify` as having "hard/soft confirm gates per file" — stale since the audit-C gate collapse in v0.4.0 made all three gates Hard.
- **Surfaced:** During E3 planning — when checking what to update in README to reflect the diagonal addition.
- **Closed by:** E3, commit `00807a9` — bundled the staleness fix with the diagonal mention.

## Open after this feature (logged, not blocking)

### Finding #1 — `lsa-discover` Constraint contradicts `lsa-specify` Input

- **Symptom:** `lsa/skills/lsa-discover/SKILL.md` *Constraints* says *"Do not write to the configured `specs_root`"* but `lsa/skills/lsa-specify/SKILL.md:25` reads `discovery.md` from `${specs_root}/features/<feature-name>/`. No documented scratch path bridges the two.
- **Surfaced:** Step 4 of `lsa-discover` execution.
- **Pragmatic resolution this session:** wrote `discovery.md` inside `specs_root/features/<feature-name>/` (per user decision 2026-05-21). The strict reading of the `lsa-discover` Constraint is overly tight.
- **Recommended fix:** Either (a) relax the `lsa-discover` Constraint wording to *"do not write the formal spec files"* (the spirit), or (b) define a scratch path like `.lsa/scratch/<feature>/` and update both skills + `lsa/ARCHITECTURE.md`.
- **Suggested follow-up:** open a T2 feature for `lsa-revise-constitution` or directly edit both SKILL.md files in a separate PR.

### Finding #2 — `lsa/knowledge/conventions.md` Confirm-gate types stale

- **Symptom:** `conventions.md:38-47` § "Confirm gate types" lists `lsa-specify` under both Hard (`requirements.md`, `test-suites.md`) and Soft (`contract.yaml`, `design.md`). But `lsa-specify` SKILL.md body explicitly says *"All three gates in this skill are **Hard Confirm**"* and footnotes the staleness: *"(`conventions.md` §"Confirm gate types" still defines both Hard and Soft for other skills' use; lsa-specify no longer uses Soft after the audit-C gate collapse.)"*
- **Surfaced:** During Read Protocol read of `lsa-specify` SKILL body.
- **Status:** SKILL body acknowledges the staleness in a footnote — informal documentation. `conventions.md` itself is unchanged.
- **Recommended fix:** Update `conventions.md:47` to remove `lsa-specify` from the Soft list. The footnote in SKILL body becomes redundant.
- **Suggested follow-up:** T2 feature or `lsa-reconcile` run.

### Finding #5 — Ambiguous wording in new Step 5 sub-section

- **Symptom:** The new diagonal coverage table row 2 says *"Every Journey in `test-suites.md` is grounded in a section of `design.md`"* — *"grounded"* is not defined. Similarly row 4 says *"Every endpoint/schema in `contract.yaml` is exercised by at least one Journey path"* — *"exercised"* is not defined.
- **Surfaced:** During E1 read-back self-test.
- **Status:** Acceptable as v1 prose; a future agent running Gate 2 will make a judgment call. Worked examples in a follow-up would lock the interpretation.
- **Recommended fix:** Add a worked example for each ambiguous row, either in `lsa/knowledge/conventions.md` or as a sample in `vision/specs/features/diagonal-cross-artifact-analysis/` itself.
- **Suggested follow-up:** T2 feature; add 1-2 worked examples per row in a `conventions.md` § "Gate 2 diagonal coverage — worked examples" sub-section.

### Finding #6 — AC5 vs module spec separation-of-concerns

- **Symptom:** Feature AC5 says to add the diagonal coverage documentation to `vision/specs/modules/lsa/spec.md` § Invariants. But the module spec preamble says *"Per-skill behavior (source of truth per skill): lsa/skills/*/SKILL.md"* — skill behavior is intentionally NOT in the module spec.
- **Surfaced:** During E2 planning — when wording the new Invariant.
- **Pragmatic resolution this session:** wrote the new Invariant at a module-level scope (cited the SKILL as the implementation), satisfying AC5 literally while respecting the module-spec separation. The bullet wording: *"`lsa-specify` Gate 2 — diagonal cross-artifact coverage"* + cite to SKILL.md:154.
- **Recommended fix:** Either (a) drop AC5 from this kind of feature in the future (skill-internal changes don't need module spec entries), or (b) rewrite the module spec preamble to permit skill-behavior summaries when they encode a module-level discipline.
- **Suggested follow-up:** A `lsa-revise-constitution` session that clarifies what belongs in module spec vs SKILL.md.

### Finding #8 — `vision/specs/main.spec.md` core row also stale

- **Symptom:** Module index row `| \`core\` | … | active — v0.2.0 |` while actual `core/.claude-plugin/plugin.json` is v0.4.1.
- **Surfaced:** During E3 planning — the lsa row staleness prompted a check of the core row.
- **Status:** Not in this feature's scope; the user's earlier decision was *"fold lsa version references into E2 + E3"* (lsa only).
- **Recommended fix:** Update the core row in a separate PR or in the same `lsa-reconcile` run that addresses Findings #1 and #2.
- **Suggested follow-up:** Bundle with Finding #2 fix.

## Meta-observations on LSA itself

- **The loop works end-to-end.** All six skills (`tier-selector`, `lsa-discover`, `lsa-specify`, `lsa-plan`, plus the implementation, plus `lsa-verify` + `lsa-sync` to follow) fired in sequence on a real feature without requiring agent improvisation.
- **Human-in-the-loop gates are the right shape.** Every gate landed an `AskUserQuestion` with concrete options + outcomes per Rule 0 (ownership over automation). Zero gates auto-approved.
- **Per-plugin SemVer discipline held.** SemVer bump + CHANGELOG entry landed in the same commit (E3) per `vision/specs/main.spec.md:30` NFR3.
- **Read Protocol surfaced two staleness findings on its own** (#3, #4). The protocol's value is concrete: reading the specs forced the agent to notice the drift.
- **Feature-as-its-own-dogfood worked.** The feature implementing the diagonal check ran its own diagonal check (manually) at Gate 2; all 4 rows ✓ or N/A on its own spec — evidence the spec is internally consistent under its own check.
- **Sequential epic execution is cheap on a small feature.** Three epics took ~3 commits each in ~1 chat session. Parallel epic branches would not have saved meaningful wall time at this size.
- **Findings logging worked as a continuous habit.** Surface-as-you-go beats a retro at the end; the file accumulated naturally.
