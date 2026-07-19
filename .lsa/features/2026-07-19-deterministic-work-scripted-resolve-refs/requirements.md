# Resolve-refs script — verify reference resolution

## Summary

Give `lsa:verify` a deterministic per-symbol resolver instead of multi-round model
`Grep`. `scripts/resolve-refs.sh` takes the named symbols the model identified in the
spec and emits `exists @ file:line` | `new` | `MISSING`/`OUT-OF-RANGE` for each — the
deterministic lookup half of Step 1. Identifying *which* symbols the spec names stays
the model's judgment; resolving each is scripted (principle 10).

- Source: discover handoff 2026-07-17 (deterministic-work sweep, epic 3 of 4).
- Applies: `.lsa/VISION.md` §2 principle 10.
- Target surface: `lsa/skills/verify/SKILL.md:30` (Step 1 reference resolution).
- Style precedent: `scripts/check-citations.sh` (path+line resolution), `scripts/coverage-skeleton.sh`.

## User Flows

1. **Grounding a spec (`verify`).** The model reads the spec and identifies the named
   modules / functions / types (judgment), passes them to `resolve-refs.sh`, and cites
   its per-symbol resolution as the reference map — instead of running Grep round by round.
   The GROUNDED / NOT-GROUNDED verdict stays the model's.
2. **Author runs it directly.** `bash scripts/resolve-refs.sh <symbol>…` (or piped, one per
   line) prints one resolution line per symbol; exit 0 = resolved, non-zero = usage error.

## Functional requirements (EARS)

- R1. `scripts/resolve-refs.sh` SHALL accept symbols as arguments; when **no arguments** are
  given it SHALL read symbols from stdin (one per line). Arguments take precedence — with
  args present the script SHALL NOT read stdin. This is the conventional Unix precedence
  (`grep`/`cat`) and it is load-bearing here: the primary consumer is `lsa:verify` running
  inside an agent harness, where stdin may be an open pipe that never sends EOF, so a
  `-t 0`-guarded read blocks forever (observed: arg-only invocation hung >4s). Empty input
  (no args and no stdin symbols) SHALL exit non-zero with a usage diagnostic.
- R2. For a symbol that is a filesystem path (contains `/`), it SHALL emit
  `<symbol> → exists @ <path>` when the path exists, else `<symbol> → new`.
- R3. For a symbol of form `<path>:<line>`, it SHALL emit `exists @ <path>:<line>` when the
  path exists and `<line>` ≤ the file's line count, `<symbol> → MISSING` when the path is
  absent, or `<symbol> → OUT-OF-RANGE` when `<line>` exceeds the file length.
- R4. For a bare identifier (no `/`), it SHALL resolve via `git grep -n` (fallback
  `grep -rn`) over tracked files and emit `<symbol> → exists @ <file>:<line>` (first hit) or
  `<symbol> → new` (no hit).
- R5. It SHALL be resolution only — it SHALL NOT parse a spec to guess which tokens are
  named symbols (that stays the model's judgment; no fragile matching, per the doc-lint
  gate's R2). It resolves the list it is given.
- R6. It SHALL match `scripts/` style — `set -uo pipefail`, bash 3.2-safe, git+grep only.
  Exit 0 when every input was resolved (a `new` / `MISSING` / `OUT-OF-RANGE` result is
  informational, not a failure); non-zero only on usage error (R1).
- R7. `lsa/skills/verify/SKILL.md` Step 1 SHALL cite `scripts/resolve-refs.sh` — pass the
  model-identified symbols and cite its resolution as the reference map instead of
  multi-round `Grep`; the GROUNDED / NOT-GROUNDED judgment stays the model's. No existing
  verify check SHALL be weakened (the `gate:` step, feasibility, `[ASSUMPTION]` visibility).
- R8. `scripts/tests/resolve-refs-test.sh` SHALL cover: path-exists, path-new, `path:line`
  in-range, `path:line` out-of-range, `path:line` missing-path, identifier-hit,
  identifier-new, and empty-input non-zero exit.
- R9. `lsa` SHALL bump SemVer (0.27.0 → 0.28.0, MINOR — new verify behavior) + CHANGELOG +
  README (the `verify` row names the script). Script + test are repo-level (outside every
  `artifact_paths`); only the `verify/SKILL.md` edit drives the `lsa` bump.
- R10. `bash scripts/gate.sh` SHALL exit 0 after the change.

## Acceptance scenarios (Gherkin)

```gherkin
Feature: Per-symbol reference resolution for verify

  Scenario: Resolve a mix of path, missing path, and identifier
    Given the symbols "scripts/gate.sh", "scripts/nope.sh", and "pass_line"
    When "bash scripts/resolve-refs.sh scripts/gate.sh scripts/nope.sh pass_line" runs
    Then "scripts/gate.sh" resolves to "exists @ scripts/gate.sh"
    And "scripts/nope.sh" resolves to "new"
    And "pass_line" resolves to "exists @ <file>:<line>"
    And it exits 0

  Scenario: path:line range checking
    Given the symbols "lsa/README.md:1" and "lsa/README.md:999999"
    When the script runs
    Then "lsa/README.md:1" resolves to "exists @ lsa/README.md:1"
    And "lsa/README.md:999999" resolves to "OUT-OF-RANGE"

  Scenario: Empty input is a usage error
    Given no arguments and empty stdin
    When the script runs
    Then it prints a usage diagnostic
    And it exits non-zero
```

## Out of Scope

- Parsing a spec to auto-identify named symbols (R5 — the model's judgment).
- Verbatim quote-matching of citations (that's `check-citations.sh`'s job; resolve-refs is
  symbol→location, not quote verification).
- Any change to verify's feasibility / gate / `[ASSUMPTION]` steps — only Step 1's lookup.
