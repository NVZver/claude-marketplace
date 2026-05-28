# Discovery — 2026-05-21-ears-journey-shape-ac

- **Module(s):** `lsa` (primary — `lsa/skills/lsa-specify/SKILL.md` + `lsa/skills/lsa-verify/SKILL.md`); constitution edit to `.lsa/VISION.md` implied.
- **Change:** Adopt EARS in the `requirements.md` AC sub-block (forward-only) plus a journey-shape gate (ACs describe user-observable goal/corner-case behavior, not unit-testable internals); extend `lsa-verify` so each EARS AC line traces to ≥1 test in `test-suites.md`.
- **Acceptance:** After merge, (1) `lsa-specify` Gate 2 rejects any new `requirements.md` whose AC sub-block is not in EARS form or contains a non-journey-shaped line, and (2) `lsa-verify` rejects a feature whose implementation diff cannot be traced to a specific EARS AC line. Forward-only; existing specs not retrofitted.
