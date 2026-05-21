# Clarification — 2026-05-21-ears-journey-shape-ac

Assumed answers. Silence on a line = approval. Override per line, or batch via the decision below.

## Functional (5)

- **F1 — What does `lsa-specify` Gate 2 reject for a new `requirements.md` AC sub-block?**
  - Assumed: An AC sub-block whose lines do **not** all match one of the five EARS patterns (Ubiquitous / Event / State / Optional / Unwanted — per `vision/VISION.md:201`), **or** which contains any line that fails the journey-shape rule.

- **F2 — How does the journey-shape rule decide a line is unit-shaped vs. journey-shaped?**
  - Assumed: The agent checks each AC line against two signals: (a) the trigger names an internal function/method/helper, or describes correctness of a non-user-observable computation, → unit-shaped; (b) the AC has no plausible mapping to a step or branch of any Journey in `test-suites.md` → unit-shaped. Detection is agent-judged in the gate prompt; the **human owns the call** via the Rule 6 decision block (`[a] revise the AC / [b] move to unit-test scope / [c] custom`). No automated lint.

- **F3 — How does `lsa-verify` trace from an implementation diff back to a specific EARS AC line?**
  - Assumed: Each AC line in `requirements.md` already has a stable ID (`AC1`, `AC2`, …) — `lsa-specify` writes this today. `lsa-verify` cross-references `tasks.md` (which `lsa-plan` already maps tasks → AC IDs) against the implementation diff. Verify FAILs if any non-trivial diff hunk has no covering task→AC trace, **or** any AC ID has zero covering implementation/test.

- **F4 — Does the EARS + journey-shape rule apply to other LSA skills (`lsa-revise-constitution`, `lsa-reconcile`, `lsa-init`)?**
  - Assumed: **No.** Only `lsa-specify`'s `requirements.md` AC sub-block is in scope. `lsa-revise-constitution` edits the constitution (free prose); `lsa-reconcile` absorbs drift (no new AC authoring). Skills outside `lsa-specify` are untouched.

- **F5 — Does the journey-shape rule apply to NFRs in `requirements.md`?**
  - Assumed: **No.** NFRs already live in their own sub-block (`## Non-Functional Requirements`); they describe cross-cutting properties (performance, fact-grounding, etc.), not user journeys. Rule scope is the `## Acceptance Criteria` sub-block only.

## Non-functional (2)

- **NF1 — Does the new gate add latency / token cost?**
  - Assumed: Negligible. The diagonal coverage table at Gate 2 already exists (`lsa/skills/lsa-specify/SKILL.md:158`); adding shape-check + EARS-pattern-check rows reuses the same render-and-resolve loop. Human-confirm latency dominates; the agent-side check adds one paragraph.

- **NF2 — Backwards compatibility — what happens to existing feature specs under `vision/specs/archive/`?**
  - Assumed: **Untouched.** Forward-only per `discovery.md`. Archived `requirements.md` files keep GWT-style ACs; the rule applies only to new specs authored after merge. No retrofit script; no migration.

## Boundaries (2)

- **B1 — In-scope edits.**
  - Assumed:
    - `vision/VISION.md` — promote AC shape to a standing principle (§2 first principles, candidate sub-principle 2a or new principle 10), and mark §6 Adjust #1 RESOLVED with a verdict reference.
    - `lsa/skills/lsa-specify/SKILL.md` — extend the Gate 1 `requirements.md` template (AC block in EARS form) and Gate 2 diagonal table (add EARS-pattern + journey-shape rows alongside the existing AC→Journey row).
    - `lsa/skills/lsa-verify/SKILL.md` — extend the verifier trace logic to require AC-ID coverage on every implementation diff and every AC.
    - `vision/specs/modules/lsa/spec.md` — add module-level invariant entry for EARS + journey-shape gate (parallel to the diagonal-coverage entry added 2026-05-21).
    - `vision/specs/roadmap.md` — mark Tech Picture #1 (EARS) shipped; reconcile stale v0.5.0 entry; add a "Recently merged" row.
    - `lsa/CHANGELOG.md` + `lsa/.claude-plugin/plugin.json` — SemVer bump (`0.5.0 → 0.6.0`, minor — new gate behavior, no breaking surface).
    - `lsa/README.md` — only if a user-visible install/usage delta surfaces; expected none.

- **B2 — Out of scope.**
  - Assumed:
    - No retrofit of `vision/specs/archive/**/requirements.md`.
    - No new `core` skill for EARS — the rule lives inline in `lsa-specify`, not extracted to a shared core skill (per F4: only `lsa-specify` uses it).
    - No automated EARS-pattern linter — pattern conformance is agent-judged at Gate 2; human owns final call via Rule 6.
    - No `tasks.md` schema change — `lsa-plan`'s existing task→AC-ID mapping is reused.
    - No change to GWT in `## Functional Requirements` or elsewhere in `requirements.md` — only the AC sub-block is converted to EARS (per `vision/VISION.md:201` *"A tightening, not a replacement"*).

## Acceptance (3 + 3 static requirements)

**Acceptance criteria — journey-shaped (every AC observable at the human ↔ LSA-skill boundary):**

- **AC1.** *Journey:* human authors a new feature spec in `lsa-specify`. *Corner case:* AC sub-block contains a non-EARS line. *System behavior:* Gate 2 surfaces the offending line in a Rule 6 decision block (`[a] rewrite in EARS / [b] move to unit-test scope / [c] custom`); approval is blocked until the human resolves.

- **AC2.** *Journey:* human authors a new feature spec. *Corner case:* AC line is unit-shaped (names an internal function/method, or describes correctness of a non-user-observable computation). *System behavior:* Gate 2 surfaces the line in a Rule 6 decision block; approval is blocked until the human resolves.

- **AC3.** *Journey:* human runs `lsa-verify` on a completed feature branch. *Corner case:* an implementation diff hunk has no AC-ID trace, **or** an AC has no covering implementation/test. *System behavior:* `lsa-verify` reports **FAIL** with the unmapped diff line and the unmapped AC ID, both as `file:line` citations per `core/ground-rules` Rule 1.

**Static / structural requirements (not journey ACs — but in scope):**

- **SR1.** `vision/VISION.md` carries a standing principle: ACs in `requirements.md` are journey-shaped (observable at the user ↔ system boundary, not unit-test scope).
- **SR2.** `vision/VISION.md` §6 Adjust #1 is marked **RESOLVED** with a reference to the principle in SR1 and to the `lsa-specify` Gate 2 implementation.
- **SR3.** No `requirements.md` in `vision/specs/archive/**/` is modified.

---

## Decision

Format per `core/output`. Choose one:
- `[a]` approve all assumed answers → proceed to Gate 1
- `[b]` approve with overrides → list overrides per line; I re-draft and re-present
- `[c]` reject → stop; re-run `lsa-discover`
