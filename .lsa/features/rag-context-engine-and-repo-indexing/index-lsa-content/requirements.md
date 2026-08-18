# requirements.md — rag-context-engine-and-repo-indexing/index-lsa-content

Epic 7 of `rag-context-engine-and-repo-indexing` (discovered via stress-testing epic 6, not pre-planned). `docker/rag_cli.py`'s directory walk excludes every dot-prefixed directory, catching `.lsa/` along with genuine tool internals (`.git/`) — silently excluding this project's own specs, pitches, roadmap, research, and standards from indexing since epic 1. Corrected size, verified directly (not the initially-overstated 9.0 MB, which wrongly included the index's own 7.8 MB output directory): **2.4 MB** of genuinely unindexed content, roughly 2.4x the current indexed corpus.

- R1. The basename-level `SKIP_DIR_NAMES` exclusion (`.git`, `.rag-index`, `node_modules`,
  `__pycache__`) SHALL remain — pure tool/VCS internals, excluded anywhere they appear in
  the tree.
- R2. The blanket "skip every directory starting with `.`" rule SHALL be removed —
  dot-prefixed directories (`.lsa/`, `.githooks/`, `.github/`, `.claude/`) SHALL be walked
  and indexed like any other directory, except where R3 applies.
- R3. `.lsa/archive/` SHALL remain excluded via a **path-prefix** check (not a basename
  check — must not accidentally exclude an unrelated directory elsewhere in the tree that
  happens to be named "archive") — frozen historical record per this repo's own "archive
  files don't rewrite" convention, matching the prior-art pitch's own corpus definition
  (`.lsa/pitches/rag-retrieve-before-read.md` on the unmerged PR #85 branch: "exclude
  `.lsa/archive`, binaries, secrets").
- R4. `.lsa/.rag-index/` (the index's own output) SHALL remain excluded — already covered
  by R1's `.rag-index` basename skip; verify this still holds under the new logic.
- R5. Re-indexing the whole repo after this change SHALL index substantially more content —
  verify `files_seen` increases meaningfully, and confirm specific previously-invisible
  content is now findable: `.githooks/pre-commit` (closes the original P6 gap as a side
  effect — not this epic's target, but a real, disclosable bonus if it happens), and
  `.lsa/plans/2026-05-20-credo-rollout-plan.md`'s `[illustrative]`-tagged Redis mention
  (now genuinely a candidate for the first time — re-test whether hybrid search correctly
  judges it as unrelated for real, not by omission).
- R6. Real index build time on the expanded corpus SHALL be measured and reported honestly
  — if it grows enough to matter for the commit-triggered sync story (epic 2), that's a
  real finding to disclose, not a reason to silently skip measuring.
- R7. No plugin surface touched (still `docker/rag_cli.py` only) — no version bump.
- R8. **Found during this epic's own verification, not pre-planned:** `dist/` (gitignored
  Cursor-export build output, `.gitignore:7`) SHALL also be excluded — not dot-prefixed,
  so untouched by R1-R3, but it contains duplicate copies of already-indexed source files
  and this repo already applies the identical exclusion for the identical reason in
  `scripts/coverage-skeleton.sh` (per `.gitignore:7`'s own comment). Added to
  `SKIP_DIR_NAMES` (basename-level, matching R1's existing pattern), not a new mechanism.
- R9. **Found the same way, same pass:** `.remember/` (entirely gitignored by its own
  nested `.remember/.gitignore`, private-mode on disk) SHALL also be excluded — personal,
  machine-local session notes, not project content. **Disclosed, not resolved as a general
  fix:** this is the second gitignored directory found leaking into the index this pass.
  R8/R9 are pragmatic, targeted patches; the real fix (the indexer consulting `.gitignore`
  itself, e.g. via host-side `git ls-files --others --exclude-standard`) is a larger change
  flagged for a human decision, not built unilaterally in this epic.

## Traceability

| Requirement | Verification |
|---|---|
| R1-R4 | Re-index, confirm `.git`/`.rag-index`/`node_modules`/`__pycache__` and specifically `.lsa/archive/**` are absent from the indexed file list; confirm `.lsa/features/**`, `.lsa/pitches/**`, etc. are present |
| R5 | Live queries for `.githooks/pre-commit`'s content and the Redis/credo-plan probe, both scoped and unscoped |
| R6 | Timed `bash scripts/rag-index.sh .` run, reported in the commit/conformance |
| R7 | No `lsa/` file in the diff |
