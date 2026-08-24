Epic: marketplace-mcp-server/core-server
Verdict: GROUNDED
Date: 2026-08-24

## Reference map (`bash scripts/resolve-refs.sh`)

| Symbol | Resolution |
|---|---|
| `core/skills/ground-rules/SKILL.md:1` | exists @ core/skills/ground-rules/SKILL.md:1 |
| `lsa/knowledge/conventions.md:50` | exists @ lsa/knowledge/conventions.md:50 |
| `scripts/opencode-dist-generate.sh:129` | exists @ scripts/opencode-dist-generate.sh:129 |
| `.lsa.yaml:62` | exists @ .lsa.yaml:62 |
| `mcp-server/` | new — the open assumption in requirements.md; no such directory exists yet |
| `core/skills`, `lsa/skills`, `manager/skills` | exists |
| `core/knowledge`, `lsa/knowledge`, `manager/knowledge` | exists |

## Feasibility (per user flow)

- **Flow 1 (startup & registration):** buildable — all six source directories exist and are readable; no missing dependency.
- **Flow 2 (tool invocation):** buildable — returning a file's body unchanged requires no mechanism beyond a file read.
- **Flow 3 (resource read):** buildable — same as Flow 2, for `knowledge/*.md`.

No flow is infeasible on what exists.

## Assumptions

- `[ASSUMPTION]` Server source code location: proposed new top-level `mcp-server/` directory (requirements.md "Open assumption" section). Not yet confirmed against a second source; carried forward to `delegate` as the implementer's starting point, and to be added as a new `.lsa.yaml` `modules:` entry once code lands.

## Gate (`.lsa.yaml` `gate:` block, docs-mode repo — `lsa/knowledge/quality-gate-contract.md` §"docs-mode repos")

First run (2026-08-24, pre-merge) — `bash scripts/gate.sh`:

```
FAIL  docs-invariants  bash scripts/lint.sh → exit 1   (C20: this feature dir's requirements.md has no conformance.md yet)
PASS  citations / links / project-map / tests / lib-pins
```

Root cause: `C20` (`scripts/lint.sh`) requires every `requirements.md` to have a sibling `conformance.md`, which is only written by `lsa:reconcile` — structurally impossible for a spec still between `specify` and `delegate`. This exact gap was previously diagnosed on 2026-08-10 (found via `lsa:verify` on a different feature) and fixed on the unmerged branch `fix/lint-c20-untracked-requirements` (commit `53bdd6a`), which scopes C20 to `git ls-files`-tracked `requirements.md` files. Per user decision (gate this session), that branch was merged into `main` (merge commit, this session) rather than routing around the check.

Second run (2026-08-24, post-merge) — `bash scripts/gate.sh`:

```
PASS  docs-invariants  bash scripts/lint.sh → exit 0
PASS  citations        bash scripts/check-citations.sh → exit 0
PASS  links            bash scripts/check-links.sh → exit 0
PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
PASS  tests            bash scripts/run-tests.sh → exit 0
PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0
gate: PASS — every configured check exited 0
```

## Verdict

**GROUNDED.** Every cited reference resolves (or is explicitly `[ASSUMPTION]`), all three flows are buildable on the existing repo, and the gate block exits 0. Cleared for `lsa:delegate`.
