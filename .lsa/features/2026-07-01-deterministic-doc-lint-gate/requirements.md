# Deterministic doc-lint gate

## Summary

Wire the mechanical doc-checks that `verify` / `reconcile` re-derive by hand every
session into a deterministic `.lsa.yaml` `gate:` block, so the two grounding checks
cite a script exit code as the Rule-7 gate artifact instead of regenerating grep
recipes. Adds two new repo-internal scripts (`scripts/check-citations.sh`,
`scripts/check-links.sh`) alongside the existing `scripts/lint.sh`, registers all
three as the repo's docs-mode gate, and teaches `verify` to run the gate.

- Source pitch: `deterministic-doc-lint-gate` (approved; fork "FAIL = BLOCK").
- Gate contract: `lsa/knowledge/quality-gate-contract.md` §"docs-mode repos".
- Existing invariant lint (reused, not duplicated): `scripts/lint.sh`.

## User Flows

1. **Grounding a spec (`verify`).** An author runs `verify` before delegating. In
   addition to resolving references and confirming feasibility, `verify` runs the
   `.lsa.yaml` `gate:` block and cites each command + exit code. A non-zero exit
   (a broken citation, a dangling link, or a violated invariant) yields
   `NOT-GROUNDED` and blocks delegation.
2. **Reconciling a diff (`reconcile`).** Already runs the `gate:` block
   (`lsa/skills/reconcile/SKILL.md` Step 1) — the new checks plug in with no logic
   change; the docs gate now has three keys to cite.
3. **Author runs the checks directly.** Any contributor runs
   `bash scripts/check-citations.sh` / `bash scripts/check-links.sh` locally; exit
   `0` = clean, exit `1` = violations printed one per line with a summary.

## Functional requirements (EARS)

### Scripts
- R1. `scripts/check-citations.sh` SHALL, for every `path:line` citation in a
  tracked `*.md` file, verify the path resolves to an existing file and every
  cited line number is within that file's line count. (mechanical existence +
  range only)
- R2. `scripts/check-citations.sh` SHALL NOT attempt verbatim quote-matching
  (explicitly out of scope — fragile against line drift).
- R3. `scripts/check-links.sh` SHALL, for every relative-file markdown link
  `[text](path)` in a tracked `*.md` file, verify the target file exists on disk
  (resolved relative to the linking file); anchors (`#heading`) and external URLs
  SHALL be out of scope.
- R4. Both scripts SHALL match the existing `scripts/lint.sh` style: `set -uo
  pipefail`, bash 3.2-safe, no heavy deps (bash + grep + git only), exit `0` when
  clean / `1` when violations are found, printing one line per violation plus a
  summary.
- R5. Both scripts SHALL reuse `scripts/lint.sh`'s false-positive-control
  discipline — exempting frozen/illustrative surfaces (`CHANGELOG.md`, the `.lsa/`
  spec+archive tree, `tests/` fixtures, fenced code blocks, `[illustrative]` /
  `[unverified]` lines, `${var}`-templated and external targets).
- R6. The scripts SHALL be repo-internal (Pro-safe: local bash, zero model calls)
  and SHALL live outside every plugin's `artifact_paths`, so they trigger no
  plugin version bump.

### Gate wiring
- R7. `.lsa.yaml` SHALL gain a `gate:` block with keys `docs-invariants: bash
  scripts/lint.sh`, `citations: bash scripts/check-citations.sh`, `links: bash
  scripts/check-links.sh`.
- R8. `lsa/skills/verify/SKILL.md` SHALL add a Step that runs the `.lsa.yaml`
  `gate:` block during grounding and cites each command + exit code as evidence
  (not re-derive the checks), with an Observable result.
- R9. When any configured `gate:` check exits non-zero, `verify` SHALL yield
  `NOT-GROUNDED` (FAIL = BLOCK). `reconcile` already consumes the block
  (`lsa/skills/reconcile/SKILL.md` Step 1) — no logic change there.

### Versioning + hygiene
- R10. `lsa` SHALL bump SemVer (0.20.2 → 0.22.0, MINOR — new skill behavior) with
  a CHANGELOG entry and a README update (the `verify` row + `.lsa.yaml` schema
  prose now name the gate).
- R11. Pre-existing citation/link drift surfaced by the gate's first full-repo run
  SHALL be corrected so the gate passes clean on `main`; each touched plugin
  (`core`, `manager`, `prompt-engineer`) SHALL bump SemVer (PATCH) + CHANGELOG.

## Acceptance scenarios (Gherkin)

```gherkin
Feature: Deterministic doc-lint gate

  Scenario: A broken citation blocks the grounded verdict
    Given a tracked markdown file cites "core/README.md:99999"
    And core/README.md has fewer than 99999 lines
    When "bash scripts/check-citations.sh" runs
    Then it prints a VIOLATION line naming the file and the out-of-range citation
    And it exits with status 1
    And "verify" reports NOT-GROUNDED citing that command and exit code

  Scenario: A dangling relative link is caught
    Given a tracked markdown file links to "(./does-not-exist.md)"
    When "bash scripts/check-links.sh" runs
    Then it prints a VIOLATION line naming the file and the dangling target
    And it exits with status 1

  Scenario: A clean repo passes the gate
    Given every citation resolves and every relative link target exists
    When each ".lsa.yaml gate:" command runs
    Then every command exits 0
    And "verify" may report GROUNDED citing each command + exit 0
```

## Out of Scope

- Verbatim quote-matching of citation text (fragile; stays a human/LLM judgement).
- Anchor (`#heading`) resolution and external-URL reachability in link checking.
- Retro-marking every illustrative example repo-wide — only the drift the gate's
  first run surfaces is corrected (R11).
- Any behavioral change to `reconcile` (it already runs the `gate:` block).
