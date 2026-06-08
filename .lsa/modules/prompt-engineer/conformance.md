# Conformance — `prompt-engineer` v0.4.0

Reconcile of the v0.4.0 change (testability + LSA module registration) against [`spec.md`](./spec.md). Module-level reconcile: no `<flow>.feature` files exist (the change was authored standalone, not via `lsa:specify`), so **does** is anchored on the calibrated probes + change correctness rather than Gherkin runs.

**Verdict: PASS** — does · only · all hold; the new spec is the baseline (no prior baseline to drift from).

## Change set

| File | Change | Traces to |
|---|---|---|
| `prompt-engineer/.claude-plugin/plugin.json` | `version` 0.3.0 → 0.4.0 | Versioning |
| `prompt-engineer/CHANGELOG.md` | `[0.4.0]` entry | Versioning |
| `prompt-engineer/tests/repo-anchored.md` | new — 10 repo-pinned probes | Testability |
| `prompt-engineer/VERIFICATION.md` | new — portable probes + threshold | Testability |
| `.lsa.yaml` | `prompt-engineer` module + artifact_paths | Registration (user-approved) |
| `.lsa/modules/prompt-engineer/spec.md` | new — this module spec | Registration |

(`.lsa/modules/core/spec.md` is also modified in the tree — a pre-existing unrelated edit, out of scope for this reconcile.)

## all — every invariant maps to a change or covering artifact

| Invariant (spec) | Satisfied by | Status |
|---|---|---|
| Versioning | plugin.json v0.4.0 + CHANGELOG [0.4.0] | ✓ this change |
| Markdown-only | new files are `.md`; no `/src/` added | ✓ holds |
| Spec source-of-truth | new spec.md carries invariants only (no per-rule catalog) | ✓ holds |
| Separation of Concerns — self-applied | pre-existing (agent 58 lines); probes A1/A2/A3 — **A2 ran green** | ✓ covered |
| Rule categories canonical in knowledge | pre-existing `knowledge/*.md`; probes A1, B1 | ✓ covered |
| Show-changes author-time check | pre-existing v0.3.0 (`prompt-review.md:39`); probes B2/B4 — **B4 calibrated** | ✓ covered |
| Testability | `tests/repo-anchored.md` + `VERIFICATION.md` (new) | ✓ this change |

No under-delivery.

## only — every changed hunk traces to a requirement

Each row in the change set traces to an invariant or the user-approved registration. No untraced hunks → no scope creep.

## does — works?

| Evidence | Result |
|---|---|
| A2 grep invariant (deterministic) | ✓ ran — exactly one hit |
| B3 behavioral (command sample) | ✓ calibrated — HIGH/MEDIUM/LOW, no WARNING |
| B4 behavioral (`**/SKILL.md` sample) | ✓ calibrated — one WARNING/3l, no HIGH/MEDIUM |
| Cross-ref links resolve | ✓ all 10 |
| Module registration valid | ✓ `.lsa.yaml` parses; artifact_paths match real dirs; spec.md present |
| A1, A3, B1, C1, C2, D1, D2 | ⏳ authored + citations verified; not yet executed (suite runbook) |

The **change** works (version, registration, files, trickiest probes). The remaining probes are specified-not-run — first full execution is the suite's own runbook, not this reconcile.

## drift

None. The module spec was authored in this change to match reality, so it already reflects the artifacts; this reconcile establishes the baseline rather than absorbing divergence.
