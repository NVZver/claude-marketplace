# Conformance — retire-static-ports

`reconcile: PASS @ uncommitted` (graded 2026-08-25, independent grader, fresh
context, no memory of the implementer's session). This epic deletes files, so
every claim below was independently re-checked against the live filesystem
and `git`, not read off the implementer's own report.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | no tracked hunk — remove `dist/cursor/`, `dist/opencode/` (both were gitignored/untracked, so their removal shows nothing in `git status` or the diff) | `ls dist/ 2>&1` → `ls: dist/: No such file or directory`. Independently confirmed `dist/` was genuinely untracked before deletion, not lost from history: `git ls-files dist/ \| wc -l` → `0`; `.gitignore:7` read directly → `dist/` | ✅ |
| R2 | `scripts/opencode-dist-deploy.sh` (D), `scripts/opencode-dist-generate.sh` (D) — `git status --short` | `ls scripts/opencode-dist-*.sh 2>&1` → `no matches found`. Recoverability independently verified: `git log --oneline -1 -- scripts/opencode-dist-generate.sh` → `a82bd3d chore: commit uncommitted dist/opencode generate+deploy scripts before retirement`; same commit for `scripts/opencode-dist-deploy.sh`. `git checkout a82bd3d -- <path>` would restore either file — the preservation commit's safety property holds | ✅ |
| R3 | `mcp-server/UNSUPPORTED-MECHANISMS.md` — `git diff` shows 2 hunks (fix the two dangling citations into `scripts/opencode-dist-generate.sh`, preserve the blockquote) | Full `git diff mcp-server/UNSUPPORTED-MECHANISMS.md` read directly. Both citations (`[scripts/opencode-dist-generate.sh:50-52]` markdown link + bare `path:line`) replaced with "this repo's now-retired OpenCode port used to follow" / "the repo's now-retired OpenCode port used to follow" — neither remaining reference is a live path or link (`grep -n "opencode-dist\|dist/cursor\|dist/opencode" mcp-server/UNSUPPORTED-MECHANISMS.md` → 0 matches). Blockquote (`> Claude-Code-only mechanisms with no OpenCode equivalent...`) byte-compared against the already-reconciled `unsupported-mechanism-gap-list/conformance.md`'s R4 citation of the same text — identical, unchanged. Read both edited paragraphs in full as a fresh reader: both still parse and carry the same meaning (precedent-by-reference instead of precedent-by-link). `git diff` shows no other line touched in the file | ✅ |
| R4 | none — README.md / CONTRIBUTING.md must not be modified | `git diff --stat README.md CONTRIBUTING.md` → empty output (no changes). `grep -n "dist/cursor\|dist/opencode\|opencode-dist\|OpenCode\|Cursor" README.md CONTRIBUTING.md` → 0 matches, independently confirming the discover-time claim (nothing to redirect) | ✅ |
| R5 | none — `.lsa/roadmap.yaml`'s `cursor-equal-support` note, `.lsa/features/marketplace-mcp-server/*`, `.lsa/pitches/*` must stay untouched | `git diff --stat .lsa/roadmap.yaml` → empty. This epic's own spec dir (`.lsa/features/marketplace-mcp-server/retire-static-ports/`) contains only the 3 pre-existing spec files (`requirements.md`, `static-ports-retired.feature`, `grounding.md`) — no implementer-authored file there, confirmed by directory listing | ✅ |
| R6 | n/a — post-removal gate must stay green; proven by direct re-run, not a hunk | Independently re-ran (not trusting any implementer-supplied output): `bash scripts/check-citations.sh` → `OK 100 citation(s) checked, all resolve.` exit 0; `bash scripts/check-links.sh` → `OK 527 relative-file link(s) checked, all resolve.` exit 0; `bash scripts/gate.sh` → full 6/6 PASS (below) | ✅ |

## Repo-wide dangling-reference sweep (independent, not reused from discover)

`grep -rln "dist/cursor\|dist/opencode\|opencode-dist" --include="*.md" --include="*.sh" --include="*.yaml" --include="*.json" . 2>/dev/null` returned 14 files; every one is under the `.lsa/` frozen-record tree (`.lsa/roadmap.yaml`, `.lsa/metrics.md`, and 6 `.lsa/features/marketplace-mcp-server/*/{requirements,grounding,conformance}.md` files, `.lsa/pitches/marketplace-mcp-server.md`) — exempted by R5 and by `scripts/check-citations.sh`'s own documented scope. Excluding that tree (`grep -v "^\./.lsa/pitches\|^\./.lsa/features\|^\./.lsa/roadmap.yaml\|^\./.lsa/metrics.md"`) returns **zero** matches. No live file outside `.lsa/` references the deleted paths.

## Orphan hunks

Orphan hunks: none.

Traced: `mcp-server/UNSUPPORTED-MECHANISMS.md` → R3. `scripts/opencode-dist-deploy.sh`,
`scripts/opencode-dist-generate.sh` (both `D`) → R2. `dist/cursor/`, `dist/opencode/`
(untracked, gitignored, invisible to `git status`) → R1, verified directly via
filesystem check rather than via a diff hunk. `bash scripts/coverage-skeleton.sh
.lsa/features/marketplace-mcp-server/retire-static-ports` enumerates 1915 candidate
hunks total; 1912 of those are `.lsa/.rag-index/` LanceDB index artifacts from a
separate, concurrent, unrelated workstream (same false-inflation pattern already
documented in the `core-server`, `agent-prompts`, `tool-name-rephrase`, and
`unsupported-mechanism-gap-list` rows of `.lsa/metrics.md`) — excluded as out of
this epic's scope. The remaining 3 candidate hunks are exactly the 3 files listed
above; all 3 trace to a requirement. Excluded, out of scope, unrelated to this
epic (confirmed via `git status --short --untracked-files=all`): `.lsa/.rag-index/`
(separate workstream); this epic's own spec files (`requirements.md`,
`static-ports-retired.feature`, `grounding.md`, this `conformance.md`) — excluded
per `scripts/coverage-skeleton.sh`'s own convention of excluding spec files under
the graded feature dir.

## Gate

```
=== .lsa.yaml gate: block ===
  PASS  docs-invariants  bash scripts/lint.sh → exit 0
  PASS  citations        bash scripts/check-citations.sh → exit 0
  PASS  links            bash scripts/check-links.sh → exit 0
  PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests            bash scripts/run-tests.sh → exit 0
  PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0

gate: PASS — every configured check exited 0
```

## Verdict

**reconcile: PASS @ uncommitted**

All 6 requirements independently re-verified from scratch: `dist/cursor/` and
`dist/opencode/` confirmed gone from the filesystem and confirmed never
tracked by git (R1); `scripts/opencode-dist-generate.sh` and
`scripts/opencode-dist-deploy.sh` confirmed gone from the working tree and
confirmed recoverable via `git checkout a82bd3d -- <path>` (R2, the epic's
core safety property); both dangling citations in
`mcp-server/UNSUPPORTED-MECHANISMS.md` fixed, the quoted policy blockquote
byte-identical to the already-reconciled `unsupported-mechanism-gap-list`
epic's version, prose reads naturally, no other line in the file touched
(R3); `README.md`/`CONTRIBUTING.md` untouched and independently re-confirmed
to carry zero references to the retired mechanism (R4);
`.lsa/roadmap.yaml` and this epic's own spec dir untouched by the
implementer (R5); citations/links/gate all independently re-run and green
(R6). A repo-wide sweep outside `.lsa/`'s frozen-record tree found zero
remaining references to the deleted paths. This closes out the 6-epic
`marketplace-mcp-server` pitch (`core-server`, `agent-prompts`,
`tool-name-rephrase`, `unsupported-mechanism-gap-list`,
`security-trust-boundary`, `retire-static-ports`) — all six now reconciled
PASS.
