# Conformance — project-map.yaml out of the box

Feature: pro-tier-token-affordability/project-index
Verdict: **RE-OPENED** — prior PASS (`a790a44`) **vacated**; re-graded **PASS** after remediation
(`a75f2b4`, `de7487e`) · Date: 2026-07-15

## Why the prior verdict was vacated

The `a790a44` PASS graded conformance against requirements that had been **amended to delete the
parent pitch's success criterion**. The pitch mandates the index be *"≤ 1k tokens"*
(`../../../pitches/pro-tier-token-affordability.md` §"Definition of success") with the cap
*"lint-enforced in `scripts/lint.sh`"* (§"Rabbit holes" #2). The 2026-07-15 amendment rewrote D4 to
*"depth ≤ 3, **not** a chars/4 token budget"* and F3 to *"depth (not a token cap) is the size
control"* — moving the goalpost off the pitch — and the reconcile note then graded against the moved
goalpost (*"records the amended does·only·all against the updated requirements"*). Consequences the
PASS should have caught:

- The shipped map was **~1,570 tokens** — 57% over the pitch's 1k cap.
- The promised `scripts/lint.sh` budget guard **did not exist** (no `project-map` reference in the file).
- A file-level depth-3 map could not scope past directories anyway (targets live at depth 4).

An independent grader validating requirements the implementer amended — rather than the approved pitch —
is the exact failure the reconcile floor exists to prevent. Re-opened per that principle.

## Remediation (this branch)

- `a75f2b4` — map is **directories-only** (~599 tokens); **lint C13** restores the 1k-token budget the
  amendment deleted; routing trimmed to the one wired surface (sibling WS4 fix).
- `de7487e` — `.lsa/archive` excluded (~534 tokens, denser signal); the **orchestrator** discover step
  now names the map, so the agent that runs discovery actually reaches it.
- Requirements re-aligned with the pitch: F1/F3/F4 → directories-only; **F9 (1k-token budget)** added;
  D4 restored as the binding control (see `requirements.md`).

## Requirement ↔ evidence (re-graded)

| Requirement | Evidence | Scenario | Verdict |
|---|---|---|---|
| F1 (shipped deterministic builder, dirs-only) | `lsa/scripts/project-map-build.sh`; two builds byte-identical | flow-1 | ✅ |
| F2 (GENERATED banner; no self-list) | `project-map.yaml` header; test "map does not list itself" | flow-1 AC5 | ✅ |
| F3 (directory depth ≤ 3) | builder truncates; test "depth-4 directory d truncated" | flow-1 | ✅ |
| F4 (directories only; no files/descriptions) | test "no filenames listed (dirs-only)" | flow-1 | ✅ |
| F5 (check = rebuild + porcelain) | `project-map-check.sh`; tests PASS/FAIL | flow-3 | ✅ |
| F6 (discover + conventions + orchestrator name map) | discover Step 1; conventions Read protocol; orchestrator §"Discover, inline" | flow-2 | ✅ |
| F7 (absent ⇒ tree-walk; no git ⇒ exit 1) | conventions fall-back; test "build exits non-zero outside git" | flow-2 / tests | ✅ |
| F8 (init runs builder) | `lsa/skills/init/SKILL.md` Step 4 | AC4 | ✅ |
| **F9 (≤1k-token budget, lint-enforced)** | `scripts/lint.sh` C13 → "within 1k-token budget (~534 tokens)" | AC6 | ✅ |
| D1–D6 | requirements.md design decisions (D4 restored) | — | ✅ |

## Gates run (re-grade)

- `bash lsa/scripts/tests/test-project-map.sh` → **13 passed, 0 failed** (incl. dirs-only + archive-exclusion cases)
- `bash scripts/lint.sh` → All invariants hold (**C1–C13**; C13 = map budget, ~534 tokens)
- `bash scripts/gate.sh` → PASS (docs-invariants · citations · links · project-map freshness)

## Drift absorbed (this re-open)

- Budget: former D4 "no token budget" → **F9 ≤1k tokens, lint C13** (re-aligned to pitch)
- Content: file catalog (`file`/`dir` entries) → **directories only**
- Signal: historical `.lsa/archive` now excluded via `EXCLUDE_GLOBS`
- Reach: map named in the **orchestrator** discover step, not only the `discover` skill
