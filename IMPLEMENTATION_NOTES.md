# Implementation notes — RAG context engine + plug-and-play (parked 2026-08-24)

This feature is **parked, not abandoned**. This file is the handoff: what shipped, what's mid-flight, what's unverified, and exactly what to do first when picking it back up.

## What's fully shipped and merged-ready

Branch: `feature/rag-context-engine-index-query-pipeline`. PR: [#89](https://github.com/NVZver/claude-marketplace/pull/89).

Two pitches, 13 epics, all independently reconciled with live verification (not self-reports) — see `.lsa/metrics.md` for every epic's accuracy/citation/only-required-changes scores (all 1.00):

1. **`rag-context-engine-and-repo-indexing`** (9 epics) — Docker-packaged local vector + lexical search, wired into `discover`/`verify`/`reconcile`.
2. **`rag-plugin-plug-and-play`** (4 epics) — the same engine made a true plug-and-play capability of the `lsa` plugin: relocated into `lsa/`'s own shipped tree, config-driven (not hardcoded) canonical/historical ranking, a `SessionStart` hook + `bootstrap-rag` skill for one-invocation setup in any repo, and the capstone — cutting claude-marketplace itself over to the mechanism.

`bash scripts/gate.sh` is fully green as of `ca04426` (the tip of this branch).

## What's mid-flight: a self-requested PR review pass

After PR #89 was opened, a review was requested with the lens "what can be removed/optimized/replaced with stdlib." Eight findings came back (see the PR review comment thread, or re-derive: `git log --oneline` around commits `dc56d07`/`e5fde7e` has the full writeup). The user said "fix all." Status:

### Done and fully verified (commit `dc56d07`)

1. **Real bug, not just style**: `rc=$?` immediately inside `if ! docker run ...; then` always reads `0` — bash's `!` negation overwrites the exit status before the nested `rc=$?` can capture it. Masked genuine, reproducible `docker run` failures (confirmed firing organically multiple times across this whole initiative) behind the self-contradictory message `ERROR: ... (exit 0)`. Fixed in `lsa/scripts/rag-index.sh` and `lsa/scripts/rag-query.sh`'s no-`--sha` path — the `--sha` path in the same file already used the correct pattern, so the fix is a proven, in-file precedent. **Proof, not assertion**: an isolated bash test (`fake_cmd() { return 42; }`) showed the old pattern captures `0`, the new pattern captures `42`. Plus full live reruns of both scripts on the real index.
2. **`docker_daemon_reachable()` duplicated 4x** (`rag-index.sh`, `rag-query.sh`, `check-rag-index-fresh.sh`, `rag-bootstrap-check.sh`) — extracted to `lsa/scripts/lib/docker-reachable.sh`, now takes an optional timeout-seconds argument (default 5; `rag-bootstrap-check.sh` calls `docker_daemon_reachable 3` to keep its tighter `SessionStart`-budget behavior exactly). Live-verified: full index rebuild, a real query, and the hook's silent-when-already-bootstrapped case.
3. Bonus fix found while in the file: `check-rag-index-fresh.sh`'s header comment still claimed "NOT shipped in any plugin" — stale, true only of the root-level version `dogfood-migration` (epic 4) replaced.

### Done but NOT fully verified (commit `e5fde7e`, marked WIP in its own message + CHANGELOG entry)

4. **YAML block-splice duplication** between `seed-canonical-paths.sh` and `bootstrap-rag.sh`'s `append_gate_entries` — extracted to `lsa/scripts/lib/yaml-block-splice.sh` (`splice_yaml_block <file> <top-level-key> <new-block-text>`, pure mechanism only; each caller still owns its own business logic for what the new block's content should be).

   **What's confirmed working:**
   - `seed-canonical-paths.sh`'s append case (no `rag:` block yet) and idempotent-replace case (re-run, unchanged) — both reproduce pre-refactor output **byte-for-byte** (tested against real scratch repos).
   - `bootstrap-rag.sh`'s fresh-block-creation case (no `gate:` block at all) — works correctly end-to-end, including a real Docker index build.
   - `bootstrap-rag.sh`'s idempotent-no-op case (both `rag-index-fresh` and `rag-index-matches-head` already present) — correctly prints "nothing to add" and does not touch the file.

   **What's NOT confirmed:** the case that most exercises the refactor — an existing `gate:` block containing an *unrelated* key (e.g. `lint: bash scripts/lint.sh`) plus *only one* of the two RAG keys already present (e.g. `rag-index-fresh:` present, `rag-index-matches-head:` missing). This is the case where `append_gate_entries` must preserve the unrelated key and the already-present RAG key while adding only the missing one.

   **Why it's unconfirmed, precisely:** I ran the test, but in the same command block I then read `.lsa.yaml` without re-`cd`-ing into the scratch repo first — this sandbox resets the shell's working directory between tool calls, so that specific `cat .lsa.yaml` read *this repo's own* `.lsa.yaml`, not the scratch repo's. That's a test-harness mistake, not evidence of a bug — but I was interrupted before re-running the check correctly, so it is **genuinely unverified either way**. The full unfiltered script output from that run (visible in the transcript) shows `Updated gate: block in .../repo-b/.lsa.yaml with rag-index-fresh/rag-index-matches-head.` printed with exit 0, which is consistent with success — but I have not independently confirmed the resulting file content.

   **Exactly what to do first, in order:**
   ```bash
   SCRATCH=/tmp/splice-verify/repo-b
   rm -rf /tmp/splice-verify && mkdir -p "$SCRATCH" && cd "$SCRATCH"
   git init -q
   cat > .lsa.yaml <<'YAML'
   specs_root: .lsa/

   gate:
     lint: bash scripts/lint.sh
     rag-index-fresh: bash old-path/check.sh

   modules:
     core:
       spec: .lsa/modules/core/spec.md
       artifact_paths:
         - core/**/*.py
   YAML
   git add -A && git -c user.email=t@t.com -c user.name=t commit -q -m init

   export CLAUDE_PLUGIN_ROOT=/path/to/claude-marketplace/lsa
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-rag.sh" "$SCRATCH"
   cat "$SCRATCH/.lsa.yaml"   # <-- explicit path this time, not a bare `cat .lsa.yaml`
   ```
   Expected correct output: `lint:` line unchanged, `rag-index-fresh: bash old-path/check.sh` line **unchanged** (must NOT be overwritten with the new plugin path — `append_gate_entries` only adds missing keys, never touches existing ones), and a new `rag-index-matches-head: bash $CLAUDE_PLUGIN_ROOT/scripts/check-rag-index-matches-head.sh` line added. If any of those three don't hold, the bug is almost certainly in `append_gate_entries`'s `block_body` extraction or in how `new_block` is assembled in `lsa/scripts/bootstrap-rag.sh` (search for `append_gate_entries` — the function is short, ~45 lines).

### Not started at all

5. **`_normalize()` in `lsa/docker/rag_cli.py`** (~line 470) — per-vector Python loop, vectorizable with a single numpy operation (`numpy` is already a dependency). Real perf win at index-build scale (thousands of vectors). Not attempted.
6. **`get_model()` in `lsa/docker/rag_cli.py`** (~line 455) — hand-rolled `global _model` singleton, replaceable with stdlib `functools.lru_cache(maxsize=1)`. Not attempted.
7. **Regex for fixed-literal strings** in `load_canonical_paths_config` (~line 314, 325) — `re.match(r"^rag:\s*$", line)` etc. could be a plain string comparison. Not attempted.
8. **`CANONICAL_PATHS_CAP = 40`** hardcoded independently in both `lsa/docker/rag_cli.py` and `lsa/scripts/seed-canonical-paths.sh` — no shared source of truth across the Python/bash boundary. Lowest-severity finding (maintainability, not correctness); the planned fix was a cross-reference comment in each location, not a full unification (a full fix would mean threading the cap through as a container env var — judged not worth the added surface for one integer).

## Unrelated discovery — not mine, do not touch without checking with the repo owner first

When I resumed this session, the working tree already had **uncommitted changes I did not make**:
- `README.md`'s title changed from `# claude-marketplace` to `# SpecForge`.
- Two new untracked files: `scripts/opencode-dist-deploy.sh`, `scripts/opencode-dist-generate.sh` (an OpenCode config deployment pair, unrelated to this feature).

These were **not staged or committed by any of the work described in this file** — every commit above (`dc56d07`, `e5fde7e`, `ca04426`) explicitly excludes them. They're still sitting in the working tree as of this writing. If you're picking this back up, check with whoever made those changes before doing anything that could discard them (`git status` first, always, per this repo's own standing safety rule).

## How to resume

1. Read this file, then re-run the exact verification command in the "What to do first" block above.
2. If the partial-`gate:`-block case passes: findings 1-4 are done, update the `0.39.4` CHANGELOG entry to drop the "WIP, NOT fully verified" framing, and move on to findings 5-8 (all small, mechanical, described above with exact locations).
3. If it fails: the bug is in `append_gate_entries` (`lsa/scripts/bootstrap-rag.sh`) or `splice_yaml_block` (`lsa/scripts/lib/yaml-block-splice.sh`) — both are short, read them together, the fix is very likely small.
4. Once findings 1-8 are all done and verified, squash or leave the WIP commit as-is (repo convention this whole initiative used real, uncondensed history — see `git log --oneline` on this branch for the pattern), update PR #89's description to remove the "in progress" section, and it's ready for actual human review/merge.

## Current branch state

```
ca04426 chore: regenerate project-map.yaml for the new lsa/scripts/lib/ dir
e5fde7e wip(lsa): shared YAML block-splice lib -- one edge case unverified
dc56d07 fix(lsa): rc=$? exit-code bug + shared docker-reachable lib
e935f17 docs(lsa): fix stale README paths, add RAG start/maintain guide
16d0478 reconcile: PASS — dogfood-migration @ 723d801
... (13 epics + their verdicts before that)
```

`bash scripts/gate.sh` is green at `ca04426`. Nothing here blocks anyone from using the shipped 13-epic feature today — the review-fix pass is pure follow-up polish, not a functional blocker.
