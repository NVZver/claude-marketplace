# Design: EARS + Journey-shape AC Discipline

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `vision/VISION.md` (constitution) | modify — add §2 standing principle on AC shape; mark §6 Adjust #1 RESOLVED |
| `lsa/skills/lsa-specify/SKILL.md` | modify — Gate 1 `requirements.md` template (AC block in EARS form); Gate 2 diagonal coverage table (+2 rows: EARS-pattern, journey-shape); failing-row decision-block prose updates |
| `lsa/skills/lsa-verify/SKILL.md` | modify — add AC-ID trace check (orphan-diff predicate + orphan-AC predicate) |
| `lsa/skills/lsa-plan/SKILL.md` | modify — epic template gains a `**Covers:** AC<n>` line under `### Scope`, parallel to `test-suites.md` Journey `**Covers:**` (per F8) |
| `vision/specs/modules/lsa/spec.md` | modify — add invariant entry for EARS + journey-shape Gate 2 rows (parallel to the diagonal-coverage invariant added 2026-05-21 at `vision/specs/modules/lsa/spec.md:34`) |
| `vision/specs/roadmap.md` | modify — mark Tech Picture #1 (EARS) shipped; reconcile stale v0.5.0 row (`roadmap.md:11`); add v0.6.0 to Recently merged |
| `lsa/CHANGELOG.md` | modify — new entry `[0.6.0] - 2026-05-21` (Keep a Changelog format per `vision/specs/main.spec.md` NFR3) |
| `lsa/.claude-plugin/plugin.json` | modify — `version: "0.5.0"` → `"0.6.0"` |
| `lsa/README.md` | read-only (unless a user-visible install/usage delta surfaces; expected none) |
| `lsa/ARCHITECTURE.md` | read-only (no schema or branch-management change) |

## Technical Approach

**1. Reuse the existing diagonal-coverage Gate 2 framework.** Two new rows are inserted into the table at `lsa/skills/lsa-specify/SKILL.md:158-161` between the existing row 1 (AC→Journey) and row 2 (Journey→Design):

| New row | Compares | When |
|---|---|---|
| 1a (EARS-pattern) | Each AC in `requirements.md` § Acceptance Criteria matches an EARS pattern per `vision/VISION.md:201`. | Always evaluated. |
| 1b (Journey-shape) | Each AC describes a user-observable behavior at the user/system boundary — not a unit-test of an internal helper. Agent-judged; human owns the call via Rule 6. | Always evaluated. |

Failing rows reuse the existing `✗` Rule 6 decision-block render at `lsa/skills/lsa-specify/SKILL.md:162-176`. All `✗` rows batch into a single `AskUserQuestion` call (existing pattern at `lsa/skills/lsa-specify/SKILL.md:174`).

**2. Gate 1 `requirements.md` template update.** The template block at `lsa/skills/lsa-specify/SKILL.md:48-77` changes its `## Acceptance Criteria` section from free-form `- [ ] AC1: [binary pass/fail condition]` to:

```
## Acceptance Criteria
- [ ] AC1: <EARS sentence, journey-shaped — "While X… when Y… the system shall Z" or one of the other four patterns per vision/VISION.md:201>
- [ ] AC2: ...
```

A one-line cite to `vision/VISION.md:201` lands inline in the template so the agent reads the pattern list before authoring.

**3. `lsa-plan` epic template update.** Per F8, the epic template at `lsa/skills/lsa-plan/SKILL.md:38-67` gains a single `**Covers:**` line under each epic's `### Scope` section. Self-verification's existing Test-coverage row (`lsa/skills/lsa-plan/SKILL.md:78`) gets a sibling row checking that every `requirements.md` AC appears in at least one epic's `**Covers:**` (the AC-coverage check stays narrow per AC4; broad orphan-diff coverage is per F4 + AC3). Epic-level `### Acceptance Criteria` blocks (locally numbered) stay as-is.

**Rationale (broadening from AC-only to any requirement ID).** F4 + F8 originally specified AC IDs only. Constitution / CHANGELOG / version / module-spec edits trace to F/NF requirements (e.g., F6, NF3), not behavioral ACs — by sub-principle 2a (see §5), they can't be ACs. Broadening aligns with `vision/specs/main.spec.md` NFR2 *"every artifact change traces to a spec requirement"* (universal). The dual predicate split (broad orphan-diff per AC3, narrow orphan-AC per AC4) keeps behavior coverage strict while letting non-behavioral edits trace cleanly.

**4. `lsa-verify` trace predicates.** Two new predicates in `lsa/skills/lsa-verify/SKILL.md`, both sourced from F8's `**Covers:**` line:

- **Orphan-diff predicate** (broad, per F4 + AC3). Every non-trivial diff hunk must be covered by ≥1 epic whose `### Scope` covers the hunk and whose `**Covers:**` cites ≥1 requirement ID. Miss → FAIL `<artifact-file>:<line> has no requirement trace`.
- **Orphan-AC predicate** (narrow, per AC4). Every AC ID in `requirements.md` § Acceptance Criteria must be cited by ≥1 epic's `**Covers:**`. Miss → FAIL `requirements.md:<AC-line> has no covering implementation`.

The non-trivial-diff filter reuses the existing doc-mode filter in `lsa-verify` (skips whitespace / formatting hunks).

**5. Vision principle landing — sub-principle 2a (OQ1 resolved).** A new sub-principle in `vision/VISION.md` §2 under principle 2 (*"Two groundings, always"*), modeled after the 1a *Ownership over automation* sub-principle at `vision/VISION.md:55`:

> *"**2a. Acceptance criteria are journey-shaped.** Each AC in `requirements.md` describes a user-observable behavior at the user/system boundary — how a user achieves a goal or how the system handles a corner case. Unit-test-scope checks (correctness of an internal function, helper, or non-user-observable computation) live in `test-suites.md` paths or downstream tests, not in the AC sub-block. Spec-grounding at the AC level is only meaningful when traced behavior is user-observable. (See `lsa/skills/lsa-specify/SKILL.md` Gate 2 rows 1a + 1b.)"*

Rationale: the rule operationalizes principle 2's *"code traces to specs"* clause at the AC level — if ACs are unit-shaped, spec-grounding becomes vacuous. Placed as sub-principle 2a rather than 1b or standalone principle 10 because it sharpens spec-grounding (principle 2), not trust-as-output (principle 1) or a new dimension (principle 9-style).

**Routing (Gate 3, 2026-05-21):** Both §5 (2a sub-principle) and §6 (§6 Adjust #1 RESOLVED marker) are authored via `lsa-revise-constitution`, not as direct edits to `vision/VISION.md`. The skill is the conventional path for constitution edits per its description (*"when feature decisions should become permanent standards"*). `lsa-plan` should decompose these as one epic invoking `lsa-revise-constitution`.

**6. Vision §6 Adjust #1 RESOLVED marker.** A `RESOLVED` line is appended to the existing §6 Adjust #1 block (`vision/VISION.md:184-201`) without rewriting history. Same shape as the §6 Adjust #4 RESOLVED marker at `vision/VISION.md:237`:

> *"**Decision: RESOLVED → adopted. See §2 sub-principle 2a (Acceptance criteria are journey-shaped) and `lsa/skills/lsa-specify/SKILL.md` Gate 2 rows 1a + 1b; `lsa/skills/lsa-verify/SKILL.md` AC-ID trace; `lsa/skills/lsa-plan/SKILL.md` epic `**Covers:**` line. Feature: `vision/specs/archive/2026-05-21-ears-journey-shape-ac/`.**"*

**7. `lsa` module spec invariant.** A new bullet in `vision/specs/modules/lsa/spec.md` § Invariants, parallel to the existing diagonal-coverage invariant at line 34:

> *"**`lsa-specify` Gate 2 — EARS + journey-shape AC.** Gate 2 evaluates two additional diagonal rows: EARS-pattern conformance and journey-shape. `✗` rows surface as Rule 6 decision blocks per the existing render. `lsa-plan` epics carry a `**Covers:** AC<n>` line; `lsa-verify` FAILs on orphan diffs or orphan ACs. Per `lsa/skills/lsa-specify/SKILL.md:<line>`, `lsa/skills/lsa-plan/SKILL.md:<line>`, `lsa/skills/lsa-verify/SKILL.md:<line>` and `vision/specs/archive/2026-05-21-ears-journey-shape-ac/`."*

**8. Roadmap reconciliation.** Three edits to `vision/specs/roadmap.md`:
- Status of row "EARS notation in AC block" (`roadmap.md:9`) → `shipped — lsa v0.6.0`.
- Status of row "Diagonal cross-artifact analysis at `lsa-specify` Gate 2" (`roadmap.md:11`) → `shipped — lsa v0.5.0` (reconciles stale entry from prior merge).
- "Recently merged" table gains: `| lsa v0.6.0 | 2026-05-21 | EARS + journey-shape AC discipline at Gate 2; lsa-plan **Covers:** line; lsa-verify AC-ID trace |` and `| lsa v0.5.0 | 2026-05-21 | Diagonal cross-artifact coverage at lsa-specify Gate 2 |`.

## Data Model Changes

none

## API / Interface Changes

none (`contract.yaml` skipped per Gate 1 contract-trigger = NO)

## Cross-Module Contracts

none new. The task→AC-ID mapping in `tasks.md` is an existing internal LSA convention shared by `lsa-specify`, `lsa-plan`, and `lsa-verify`; this feature tightens enforcement of an existing convention rather than introducing a new contract.

## Decisions

- **OQ1 — Vision principle placement → sub-principle 2a** (2026-05-21). Under principle 2 (*"Two groundings, always"*). Operationalizes the *"code traces to specs"* clause at the AC level. Lands as Technical Approach §5.
- **OQ2 — Task→requirement-ID trace → scope expanded** (2026-05-21). `lsa-plan` does not emit this mapping today (`lsa/skills/lsa-plan/SKILL.md:38-67`). F8 added; `lsa/skills/lsa-plan/SKILL.md` added to Modules Affected; Technical Approach §3 covers the template change.
- **`**Covers:**` field breadth → any requirement ID** (2026-05-21). Broadened from AC-only to align with `main.spec.md` NFR2. Orphan-diff predicate is broad (AC3); orphan-AC predicate stays narrow (AC4). Rationale in Technical Approach §3.

## Open Questions

- **OQ3 — Single AC-shape row vs. two rows in the diagonal table.** Current design: two rows (1a EARS-pattern + 1b journey-shape). Merging shortens the table but loses per-failure-mode citation specificity. Lean: keep two; revisit if Gate 2 review feels cluttered.
