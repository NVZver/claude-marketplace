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

### Finding #9 — `.lsa.yaml` `artifact_paths` missing `CHANGELOG.md` files

- **Symptom:** Neither `lsa/CHANGELOG.md` nor `core/CHANGELOG.md` is listed in any module's `artifact_paths` in `.lsa.yaml:9-26`. Per `vision/specs/main.spec.md:30` NFR3, the CHANGELOG must be bumped per feature — but docs-mode `lsa-verify` cannot see CHANGELOG edits because they fall outside `artifact_paths`.
- **Surfaced:** During `lsa-verify` (Step 3 trace check).
- **Status:** Real config gap. CHANGELOG edits could regress silently.
- **Recommended fix:** Add `lsa/CHANGELOG.md` and `core/CHANGELOG.md` to their respective module `artifact_paths` in `.lsa.yaml`.
- **Suggested follow-up:** Trivial T1 / T2 fix.

### Finding #10 — `lsa-verify` blind spot for non-artifact-path files

- **Symptom:** Files outside every module's `artifact_paths` AND outside the feature spec dir are invisible to docs-mode `lsa-verify`. User's direct commit `ea820a1` (root `README.md` polish) is in this session's feature-branch diff but `lsa-verify` cannot trace it.
- **Surfaced:** During `lsa-verify` (the verify report's file-tally step).
- **Status:** A real gap if you assume verify catches all branch changes. Mitigation: PR review catches what verify misses.
- **Recommended fix:** Either (a) make `.lsa.yaml` allow a top-level `artifact_paths` list for files outside any module, or (b) document explicitly that verify only inspects in-`artifact_paths` files and the rest is PR-review's job.
- **Suggested follow-up:** Design decision; not trivial.

### Finding #11 — Archive path convention inconsistency in `lsa-verify`

- **Symptom:** `lsa/skills/lsa-verify/SKILL.md` Step 6 says metrics.md goes to `${specs_root}/archive/<feature-name>/metrics.md` (no date prefix), but `lsa/ARCHITECTURE.md` §"directory layout" prescribes `archive/YYYY-MM-DD-<feature-name>/`. Two SKILL bodies disagree on the same path.
- **Surfaced:** During `lsa-verify` Step 6 execution — when deciding where to write metrics.md.
- **Pragmatic resolution this session:** wrote metrics.md to the **dated** form (`vision/specs/archive/2026-05-21-diagonal-cross-artifact-analysis/metrics.md`) per ARCHITECTURE convention.
- **Recommended fix:** Update `lsa-verify` SKILL.md Step 6 path to `archive/YYYY-MM-DD-<feature-name>/`.
- **Suggested follow-up:** Trivial T1 fix.

### Finding #12 — `lsa-verify` only-required-changes metric hides scope creep

- **Symptom:** The "Only-required-changes" metric in `lsa-verify` Step 6 counts only files in `artifact_paths`. Files outside `artifact_paths` (root `README.md`, root configs, etc.) can be modified without affecting the metric. In this feature, strict score = 3/3 = 1.00 but wider score (all 13 files in diff) = 12/13 = 0.923.
- **Surfaced:** During metrics.md write — the strict definition gave a perfect score despite a known out-of-scope file (`ea820a1`).
- **Status:** Metric is honest within its declared scope, but the scope itself is narrower than expected.
- **Recommended fix:** Either (a) widen the metric to count all branch-diff files vs files-covered-by-an-AC, or (b) add an explicit "off-metric scope-creep observation" sub-section to the metric template (this feature did the latter as a one-time precedent).
- **Suggested follow-up:** Bundle with Finding #10's design decision.

### Finding #13 — Implementation epics writing to module specs (LSA flow inconsistency)

- **Symptom:** `tasks.md` decomposed the diagonal-coverage feature into 3 implementation epics, of which E2 (module spec invariant) and E3 (main.spec.md version row) write directly to module specs during the **implementation** phase. LSA's standard flow places module-spec edits in `lsa-sync` Step 3 ("Merge into module specs"), not in implementation epics.
- **Surfaced:** During `lsa-sync` Step 3 execution — sync's job was reduced to adding trace tags to already-written content because E2/E3 had pre-emptively done the writes.
- **Status:** Result state is identical (the module spec has the new Invariant either way). Flow inconsistency: which phase owns the write?
- **Recommended fix:** Either (a) future `tasks.md` decompositions never include module-spec edits as implementation epics (let sync do them), or (b) document explicitly that "early sync via implementation epic" is an acceptable pattern and adjust `lsa-sync`'s expectations.
- **Suggested follow-up:** A `lsa-revise-constitution` session to clarify which phase owns module-spec writes.

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

## V3 manual probe — Journey 3 (contradiction-surfacing paths)

Closes `lsa-verify` W2 by exercising the new Step 5 diagonal check against two synthetic probe-features with deliberate contradictions. Both probes are `[illustrative]` per `core/ground-rules` Rule 1 — they describe fictional features for the sole purpose of exercising the new check, not features that exist in this repo.

### Probe A — single mismatch (Contract↔test-suites)

`[illustrative]` — fictional password-reset feature; the artifact snippets below do not point to real files.

```
# requirements.md (excerpt)
- AC1: Authenticated user can request a password reset via POST /reset; server emails a tokenized link.

# test-suites.md (excerpt)
## Journey 1: Reset request
**Covers:** AC1
**Paths:**
| 1 | Happy | user submits form → client sends PUT /reset → server emails link |

# design.md (excerpt)
## API / Interface Changes
- POST /reset — request a reset email (body: { email }).

# contract.yaml (excerpt)
paths:
  /reset:
    post:
      summary: Request a reset email
```

**Diagonal coverage check renders:**

| # | Pair | Status | Citation |
|---|------|--------|----------|
| 1 | AC→Journey | ✓ | `requirements.md:1 ↔ test-suites.md:3` |
| 2 | Journey→Design | ✓ | `test-suites.md:1 ↔ design.md:1` |
| 3 | Design→Contract | ✓ | `design.md:2 ↔ contract.yaml:3` |
| 4 | Contract→test-suites | ✗ | `contract.yaml:3 ↔ test-suites.md:5` |

**Failing-row render — one Rule 6 block (Path 1 single-failure case):**

```
✗ Row 4 (Contract→test-suites):  contract.yaml:3 ↔ test-suites.md:5
   contract: POST /reset
   test-suites: PUT /reset

   Resolution:
   [a] revise contract.yaml — change POST → PUT to match the journey path
   [b] revise test-suites.md — change PUT → POST to match the contract
   [c] custom — free-form text
```

Approval blocked at Gate 2 until human picks. Per F3 of the feature requirements (`requirements.md:32`).

**Result: Journey 3 Path 1 exercised. ✓**

### Probe B — two mismatches batched (Design↔Contract + Contract↔test-suites)

`[illustrative]` — fictional password-reset feature with both upstream and downstream artifact drift.

```
# requirements.md (excerpt)
- AC1: Authenticated user can request a password reset; server emails a tokenized link.

# test-suites.md (excerpt)
## Journey 1: Reset request
**Covers:** AC1
**Paths:**
| 1 | Happy | user submits form → client sends PUT /reset → server emails link |

# design.md (excerpt)
## API / Interface Changes
- POST /forgot — request a reset email (body: { email }).

# contract.yaml (excerpt)
paths:
  /reset:
    post:
      summary: Request a reset email
```

**Diagonal coverage check renders:**

| # | Pair | Status | Citation |
|---|------|--------|----------|
| 1 | AC→Journey | ✓ | `requirements.md:1 ↔ test-suites.md:3` |
| 2 | Journey→Design | ✓ | `test-suites.md:1 ↔ design.md:1` |
| 3 | Design→Contract | ✗ | `design.md:2 ↔ contract.yaml:3` |
| 4 | Contract→test-suites | ✗ | `contract.yaml:3 ↔ test-suites.md:5` |

**Failing-row render — TWO Rule 6 blocks, batched in a single multi-question `AskUserQuestion` call (Path 2 batched case, per NF2):**

```
✗ Row 3 (Design→Contract):  design.md:2 ↔ contract.yaml:3
   design: POST /forgot
   contract: POST /reset

   Resolution:
   [a] revise design.md — change /forgot → /reset
   [b] revise contract.yaml — change /reset → /forgot
   [c] custom

✗ Row 4 (Contract→test-suites):  contract.yaml:3 ↔ test-suites.md:5
   contract: POST /reset
   test-suites: PUT /reset

   Resolution:
   [a] revise contract.yaml — change POST → PUT
   [b] revise test-suites.md — change PUT → POST
   [c] custom
```

Both blocks surface together (per NF2: "All failing rows are surfaced together in a single Gate 2 presentation (batched), with the human picking per row via a multi-question `AskUserQuestion` call. No drip-feed of one failure at a time."). Approval blocked until both resolved.

**Result: Journey 3 Path 2 exercised. ✓**

### Probe C — `[c] custom` escape (Journey 3 Path 3)

Not separately constructed because the `[c] custom` option is identical in render across all probes — it appears in every Rule 6 block above. The escape hatch behavior (return to Gate 1 for deeper revision) is documented in the new Step 5 prose at `lsa/skills/lsa-specify/SKILL.md:178`: *"`[c]` returns to Gate 1 for deeper revision."* — verified by direct read-back of the SKILL.

**Result: Journey 3 Path 3 exercised by inspection of the SKILL body. ✓**

### Probe summary

All three Journey 3 paths exercised:
- Path 1 (single failure) — Probe A ✓
- Path 2 (batched failures) — Probe B ✓
- Path 3 (`[c]` custom escape) — read-back of SKILL.md:178 ✓

W2 closed. `lsa-verify` re-run should now return clean `PASS`.
