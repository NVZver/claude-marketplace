# grounding.md — rag-context-engine-and-repo-indexing/path-scoped-query-fix

## Reference map — all exist, all resolve

`docker/rag_cli.py`, `scripts/rag-query.sh`, `lsa/knowledge/conventions.md`, `lsa/skills/discover/SKILL.md`, `lsa/skills/verify/SKILL.md`, `lsa/.claude-plugin/plugin.json` (current `0.35.0`).

## Gate

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1   (C20, expected — no conformance.md yet)
  PASS  citations
  PASS  links
  PASS  project-map
  PASS  tests
  PASS  lib-pins
  PASS  rag-index-fresh          exit 0 — Docker now reachable, index present
  PASS  rag-index-matches-head   exit 0 — index matches HEAD
```

Notably, both `rag-index-*` checks now PASS for the first time in this build — Docker recovered and the whole-repo index was freshly rebuilt for the eval. Only the same structural C20 pattern as epics 1-4 remains.

## Verdict

**NOT-GROUNDED** on the same single structural artifact as every prior epic. Proceeding to `delegate` on the same established precedent.
