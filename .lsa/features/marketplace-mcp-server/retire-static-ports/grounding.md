Epic: marketplace-mcp-server/retire-static-ports
Verdict: GROUNDED
Date: 2026-08-25

## Reference map (`bash scripts/resolve-refs.sh`)

| Symbol | Resolution |
|---|---|
| `.gitignore:7` | exists |
| `scripts/opencode-dist-generate.sh:5` | exists |
| `mcp-server/UNSUPPORTED-MECHANISMS.md:14` | exists |
| `.lsa/roadmap.yaml:588` | exists |
| `README.md`, `CONTRIBUTING.md` (bare filenames) | resolve-refs.sh treats a bare filename with no `:line` as an identifier search, not a direct path check, so it matched an unrelated grep hit inside `.claude/agents/claude-dev.md` — both root files trivially exist (already read from them this session; a bare `ls README.md CONTRIBUTING.md` confirms). Not a grounding gap. |

## Feasibility (per user flow)

- **Flow 1 (retirement + dangling-reference fix):** buildable — deletion is
  a filesystem operation; the one live citation fix
  (`mcp-server/UNSUPPORTED-MECHANISMS.md`) is a small, precisely-scoped
  text edit with the replacement content already fully specified in
  `requirements.md`.

No flow is infeasible on what exists.

## Assumptions

None — every fact traces to a direct repo check at discover time (`git
ls-files`, `.gitignore` content, `grep` across README/CONTRIBUTING, a
repo-wide reference scan).

## Gate (`.lsa.yaml` `gate:` block, docs-mode repo)

`bash scripts/gate.sh` (2026-08-25, pre-delegation, baseline before
deletion):

```
PASS  docs-invariants  bash scripts/lint.sh → exit 0
PASS  citations        bash scripts/check-citations.sh → exit 0
PASS  links            bash scripts/check-links.sh → exit 0
PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
PASS  tests            bash scripts/run-tests.sh → exit 0
PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0
gate: PASS — every configured check exited 0
```

Note: this baseline gate run confirms the repo is green *before* the
scripts are deleted, so the implementer's post-deletion gate run is the
real proof this epic needs (deleting a script that a live doc still cites
would flip `citations`/`links` to FAIL — the requirement this epic exists
to prevent).

## Verdict

**GROUNDED.** Every cited reference resolves, the flow is buildable, and
the gate block exits 0 on the pre-deletion baseline. Cleared for
`lsa:delegate`.
