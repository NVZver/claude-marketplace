# grounding.md — rag-context-engine-and-repo-indexing/index-freshness

## Facts, verified directly

`git ls-files --others --ignored --exclude-standard --directory -- .` (run directly this session) returns a real, mixed list of whole-directory and individual-file entries: `.DS_Store`, `.claude/settings.local.json`, `.claude/worktrees/`, `.lsa/.rag-index/`, `.lsa/planned-lsa-run.log`, `.remember/` (plus some individual files within it, not fully collapsed by `--directory`). Confirms both that the command works and that real gitignored content exists beyond what epic 7's two hardcoded patches (`dist`, `.remember`) covered.

`scripts/rag-index.sh`/`scripts/rag-query.sh` currently only check `docker image inspect "${IMAGE_NAME}"` for *existence* before deciding to skip a rebuild — confirmed by direct reading this session, and confirmed to have actually caused a real incident (epic 7's `.remember/` fix silently not taking effect on the first attempt).

## Gate

Same structural C20-only pattern as epics 1-7.

## Verdict

**NOT-GROUNDED** on the same single structural artifact. Proceeding to `delegate` on the same established precedent.
