# Grounding — script-offload (verify, before-check, 2026-07-15)

Verdict: **GROUNDED**

## Reference map

| Spec reference | Status |
|---|---|
| `.lsa.yaml` `gate:` block (source of truth `gate.sh` reads) | exists @ `.lsa.yaml:15-18` (docs-invariants / citations / links) |
| Quality-gate contract (run each check, cite command+exit; NOT-RUNNABLE when no block) | exists @ `lsa/knowledge/quality-gate-contract.md:9-22,24-27` |
| `lsa:verify` Step 4 (run the gate block, cite command+exit) — F4 wiring point | exists @ `lsa/skills/verify/SKILL.md:33` |
| `lsa:reconcile` Step 1 (run the gate block, cite command+exit) — F4 wiring point | exists @ `lsa/skills/reconcile/SKILL.md:33` |
| `manager:next` Step 0 fast-path (model reads roadmap, finds first backlog row) — F5 wiring point | exists @ `manager/skills/next/SKILL.md:24` |
| First backlog row (extractor's expected output) | exists @ `.lsa/roadmap.md:13` (`Library-spec cache … Could … backlog`) |
| Repo-internal / shipped script precedent | `scripts/lint.sh` (repo-internal); `lsa/scripts/project-map-*.sh` (shipped with lsa) |
| Existing gate scripts the block names | exist @ `scripts/lint.sh`, `scripts/check-citations.sh`, `scripts/check-links.sh` |
| `scripts/gate.sh` (F1/F3 aggregate runner) | **new** — repo-internal, no plugin bump |
| `scripts/roadmap-row.sh` (F2 extractor) | **new** — repo-internal, no plugin bump |
| verify + reconcile gate-run wiring (aggregate runner + fallback) | **new** — `lsa` behavior (bumps lsa) |
| manager:next Step 0 extractor wiring (+ fallback) | **new** — `manager` behavior (bumps manager) |

## Feasibility

- Flow 1 (gate pre-pass): buildable — `gate.sh` parses the fixed 2-space-indent `gate:` block from
  `.lsa.yaml` with awk and runs each command; the block already points at repo-owned scripts. NOT-RUNNABLE
  branch is a simple "no gate: block" guard. verify/reconcile wiring is an additive clause + fallback.
- Flow 2 (roadmap-row extractor): buildable — `roadmap-row.sh` locates `## Feature Backlog`, walks the
  markdown table, and prints the first row whose Status cell is `backlog`/`not started` + its line number
  (`grep -n`). specs_root read from `.lsa.yaml` (default `.lsa/`). Fall-through = non-zero exit.

## Divergence from pitch

None. The pitch names exactly these two offloads ("verify pre-pass and roadmap-row extractor move from
model passes to `scripts/`"); both are delivered as repo-internal scripts + backward-compatible,
convention-gated shipped-skill wiring (D2).

## Gate results (quality-gate-contract; command + exit code) — pre-implementation baseline

- `bash scripts/lint.sh` → exit 0 (C1–C12 PASS)
- `bash scripts/check-citations.sh` → exit 0
- `bash scripts/check-links.sh` → exit 0

## Blockers

None.
