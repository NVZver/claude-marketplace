# grounding.md — rag-context-engine-and-repo-indexing/reconcile-wiring

## Reference map (`bash scripts/resolve-refs.sh`)

| Symbol | Resolution |
|---|---|
| `scripts/rag-query.sh` | exists @ `scripts/rag-query.sh` (epic 1, commit `7a22662`) |
| `lsa/skills/reconcile/SKILL.md` | exists @ `lsa/skills/reconcile/SKILL.md` |
| `lsa/.claude-plugin/plugin.json` | exists @ `lsa/.claude-plugin/plugin.json` (current version `0.34.0`) |
| `lsa/CHANGELOG.md` | exists @ `lsa/CHANGELOG.md` |
| `lsa/README.md` | exists @ `lsa/README.md` |

## Feasibility per flow

- **Flow 1 (sha-pinned filtering):** buildable — `scripts/rag-query.sh` exists and works; the `git diff --quiet <sha> HEAD -- <path>` mechanism is a real, verified git command, no schema/chunking-logic change needed (confirmed at discover time by reading `docker/rag_cli.py`'s actual schema directly).
- **Flow 2 (reconcile wiring):** buildable — Step 4 is a real, existing step to extend; Steps 1/2/3/5 and the Constraints section (independent-grader rule, `SKILL.md:62,64`) stay untouched per R3.
- **R4 (version/CHANGELOG/README):** buildable, same mechanical pattern as epic 3.

## Gate (`bash scripts/gate.sh`)

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1
  PASS  citations                bash scripts/check-citations.sh → exit 0
  PASS  links                    bash scripts/check-links.sh → exit 0
  PASS  project-map              bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests                    bash scripts/run-tests.sh → exit 0
  PASS  lib-pins                 bash scripts/check-lib-pins.sh → exit 0
  FAIL  rag-index-fresh          bash scripts/check-rag-index-fresh.sh → exit 2
  FAIL  rag-index-matches-head   bash scripts/check-rag-index-matches-head.sh → exit 1

gate: FAIL
```

Same known, non-defective pattern as epics 1–3: `docs-invariants` fails on C20 (this epic's own `conformance.md` doesn't exist yet); both `rag-index-*` checks fail on this sandbox's still-down Docker daemon, unrelated to this epic.

## Verdict

**NOT-GROUNDED**, same structural gate constraint as epics 1–3. Proceeding to `delegate` on the same owner-established precedent.
