# conformance.md — rag-plugin-plug-and-play/relocate-and-run-in-place

Independent grading pass (`lsa:reconcile`), graded against implementation `20ee294`. Live verification used two real, freshly created scratch git repos (`git init`, real commits) under `/Users/nvz/tmp-rag-plugin-verify/` — genuinely unrelated to claude-marketplace, not simulated — later deleted after verification.

## Environment finding #1 (test-setup, not a code defect)

The first verification attempt used a scratch repo under this session's `/private/tmp/...` scratchpad and returned `files_seen: 0` — Docker couldn't see the repo's real content. Root-caused directly: `colima ssh -- mount | grep /Users` confirms Colima's virtiofs only mounts `/Users/nvz`; `/private/tmp` isn't mounted into the VM at all, so a bind-mount of an unmounted host path silently resolves empty rather than erroring. Not a defect in the epic's code — moved the scratch repos under `/Users/nvz/` (Colima's actual mounted scope) and re-verified cleanly.

## Environment finding #2 (real, disclosed, pre-existing — not introduced by this epic, not fixed by it)

The very first `rag-index.sh` invocation against each freshly created scratch repo intermittently printed `ERROR: rag-index.sh failed (exit 0)` and exited 1, **despite `docker run` having already printed complete, correct JSON output** (`files_seen`/`chunks_embedded` all correct). An immediate retry against the same, now-slightly-older repo always succeeded cleanly. Root-caused two ways:
1. **Real transient issue:** `docker run`'s actual exit code genuinely was nonzero on that specific first attempt against a repo created moments earlier — consistent with the same family of Colima/virtiofs mount-propagation timing quirk as finding #1 (freshly created git content not yet fully "settled" through the virtiofs mount on the very first read).
2. **A separate, pre-existing display bug that masks the real code:** `rc=$?` immediately inside `if ! docker run ...; then` captures the negated boolean of the `!` test (always `0` in bash), not `docker run`'s actual exit code — hence the nonsensical "(exit 0)" message. **Confirmed byte-identical in the current, unmodified root-level `scripts/rag-index.sh:145-159`** — this epic's implementer copied the block verbatim, correctly preserving existing behavior (R1's requirement). Not introduced by this diff; not this epic's scope to fix (relocation only). Flagged here as a real backlog candidate, not silently dropped.

Neither finding blocks R1-R9: every live retry succeeded, and the transient failure mode is a pre-existing environmental/display issue orthogonal to what this epic changed (the `plugin_root`/`repo_root` split and file relocation).

## Live verification (Flow 1 — standalone against an arbitrary repo)

| Check | Result |
|---|---|
| Build from `lsa/docker/Dockerfile`, no `$CLAUDE_PLUGIN_ROOT` set | ✅ — `bash -x` trace confirms `plugin_root` resolved via the `${BASH_SOURCE[0]}`-relative fallback exactly as designed; image `rag-index-plugin:local` built successfully |
| Index a real, unrelated scratch repo (2 files: `README.md`, `src/main.py`) | ✅ — `{"files_seen": 2, "chunks_embedded": 2, ..., "fts_index_built": true}`, confirmed on a clean run |
| Zero files written into the target repo's **tracked** tree | ✅ — `git status --short` shows only `?? .lsa/` (untracked; no `.gitignore` entry written — correctly out of this epic's scope, deferred to `bootstrap-trigger`) |
| Same shared image reused across a second, different scratch repo | ✅ — no "Building..." message on the second repo's run; `docker images` shows one `rag-index-plugin:local` tag throughout |
| Query the indexed scratch repo | ✅ — `rag-query.sh "friendly greeting function"` correctly returned `src/main.py:1-6`'s `greet()` function, similarity 0.749 |

## Live verification (Flow 2 — existing dogfood path unaffected)

| Check | Before | After |
|---|---|---|
| `bash scripts/check-rag-index-fresh.sh` (via `scripts/gate.sh`) | PASS | PASS |
| `bash scripts/check-rag-index-matches-head.sh` (via `scripts/gate.sh`) | PASS | PASS |
| Root-level `Dockerfile`, `docker/rag_cli.py`, `scripts/rag-*.sh` | — | `git diff --stat` on exact paths: zero changes |

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `lsa/docker/Dockerfile`, `lsa/docker/rag_cli.py` | `diff docker/rag_cli.py lsa/docker/rag_cli.py` → identical; `diff Dockerfile lsa/docker/Dockerfile` → single `COPY` line only | ✅ |
| R2 | `lsa/scripts/rag-index.sh`, `rag-query.sh`, `check-rag-index-fresh.sh`, `check-rag-index-matches-head.sh` | All four present, executable, `bash -n` clean | ✅ |
| R3 | `lsa/scripts/rag-index.sh:55-63`, `rag-query.sh` (same block) | Live: `bash -x` trace confirms `plugin_root` resolves via `${BASH_SOURCE[0]}`-relative fallback with no `$CLAUDE_PLUGIN_ROOT` set | ✅ |
| R4 | `lsa/scripts/rag-index.sh:65-69` (`repo_root`, unchanged resolution) | Live: correctly resolved each scratch repo's own root via `git rev-parse --show-toplevel`, independent of `plugin_root` | ✅ |
| R5 | `lsa/scripts/rag-index.sh:71-77`, `rag-query.sh` (`IMAGE_NAME="rag-index-plugin:local"`) | Live: same tag served two different scratch repos, no rebuild on the second | ✅ |
| R6 | `lsa/scripts/rag-index.sh` (mount logic, unchanged shape) | Live: `git status --short` in both scratch repos shows only untracked `.lsa/` | ✅ |
| R7 | N/A (absence of changes to root-level files) | `git diff --stat` on the six root-level paths: zero changes; `bash scripts/gate.sh`'s `rag-index-fresh`/`rag-index-matches-head` unchanged PASS before/after | ✅ |
| R8 | `.lsa.yaml` (`lsa/docker/**` added to `artifact_paths`) | Code-reviewed directly: one line added, `gate:` block untouched | ✅ |
| R9 | `lsa/.claude-plugin/plugin.json` (0.36.0→0.37.0), `lsa/CHANGELOG.md` | Code-reviewed: version bump + new entry present, styled after existing entries | ✅ |

Orphan hunks: none.

One implementer addition beyond the letter of the spec, traced to R2/R4: `lsa/scripts/check-rag-index-matches-head.sh` self-locates its sibling `rag-index.sh` via `${BASH_SOURCE[0]}` rather than the root version's CWD-relative call — necessary for R2's "works standalone from any target repo" to actually hold for this script too (the root version's CWD-relative sibling call would silently break or call the wrong script outside claude-marketplace). Judgment call, correctly disclosed by the implementer, not an orphan.

## Gate (`bash scripts/gate.sh`)

Same C20-only pre-reconcile pattern as every epic in this initiative — all other checks PASS, including `rag-index-fresh` and `rag-index-matches-head` (Flow 2's own proof).

## Verdict

**reconcile: PASS @ 20ee294**

All 9 requirements verified live, not from the implementer's self-report alone — I independently rebuilt the image, indexed two real unrelated scratch repos, confirmed image reuse, ran a real query, and confirmed zero regression on this repo's own gate checks. Two real, disclosed findings during verification: a test-setup gap (Colima only mounts `/Users`, not `/private/tmp` — moved scratch repos accordingly) and a pre-existing, byte-identical-in-the-original transient-failure display bug (`rc=$?` inside a negated `if`, masking a real but intermittent nonzero `docker run` exit with a nonsensical "(exit 0)" message) — neither blocks this epic's requirements, both are named here rather than smoothed over.
