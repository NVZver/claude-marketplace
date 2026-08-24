# grounding.md — rag-context-engine-and-repo-indexing/index-lsa-content

## Facts, verified directly

`docker/rag_cli.py:214`: `dirs[:] = [d for d in dirs if d not in SKIP_DIR_NAMES and not d.startswith(".")]` — the blanket dot-directory exclusion. `docker/rag_cli.py:102`: `SKIP_DIR_NAMES = {".git", "node_modules", ".rag-index", "__pycache__"}`.

Corrected size measurement: `du -sh --exclude=.rag-index .lsa` = **2.4 MB** genuinely unindexed (not the initially-overstated 9.0 MB, which wrongly counted `.lsa/.rag-index/`'s own 7.8 MB output). `.lsa/archive/` = 352 KB of that 2.4 MB.

## Gate

Same structural C20-only pattern as epics 1-6.

## Verdict

**NOT-GROUNDED** on the same single structural artifact. Proceeding to `delegate` on the same established precedent.
