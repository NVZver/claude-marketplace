# requirements.md — rag-plugin-plug-and-play/bootstrap-trigger

Epic 3 of 4 of the `rag-plugin-plug-and-play` pitch. Hard-depends on `relocate-and-run-in-place` (done, `20ee294`). Soft-depended on `generic-canonical-config` (also done, `9253977` — no longer just the safety-default fallback).

## Scope note (grounded at discover time, beyond the pitch's literal epic description)

`.githooks/pre-commit` calls `scripts/rag-index.sh` by a hardcoded root-relative path — not portable to a target repo, where no root-level copy of these files exists (epic 1's "run-in-place, no copy" decision). This epic therefore also ships a portable git hook (R5) — without it, "`core.hooksPath` wired" in the pitch's definition of success would silently not work.

## Scope boundary (disclosed, not glossed over)

The `.lsa.yaml gate:` entries this epic writes (R4) use `$CLAUDE_PLUGIN_ROOT` in their command string, since the plugin's install path is per-user/per-machine and changes across plugin version bumps — a literal absolute path would break portability the moment the plugin updates. `$CLAUDE_PLUGIN_ROOT` is reliably set inside a Claude Code session (where `verify`/`reconcile` actually invoke `gate:` commands) but is **not** set in a bare shell or a target repo's own CI runner outside Claude Code. Making these gate entries CI-runnable for an arbitrary target repo is explicitly out of this epic's scope — same category as the pitch's own no-go #3 (no auto-upgrade/resync concern).

## User flows

| Flow | Success | Test |
|---|---|---|
| 1. Detect + offer, within hook budget | Docker present + not yet bootstrapped → one-line offer, fast | Real repo, no `rag-index-fresh` gate entry |
| 2. Silent in every negative case | No offer when already bootstrapped, Docker absent, or no `.lsa.yaml` | Three separate negative cases |
| 3. One invocation bootstraps everything | Image built, index run, hook wired, gate entries + canonical-paths config + `.gitignore` written — unattended | Real scratch repo |
| 4. Portable git hook works from a shared plugin location | Reindexes the correct TARGET repo on commit, not wherever the plugin is installed | Real commit in a scratch repo |

## Requirements

- R1. `lsa/hooks/hooks.json`'s `SessionStart` array shall gain a new entry invoking a new detection script, independently timed from the existing drift-check hook. **[ASSUMPTION]**: Claude Code runs each `SessionStart` array entry as an independently-timed subprocess, not sharing one budget across entries — a reasonable, standard hook-runner assumption, not documented anywhere in this repo.
- R2. The detection script shall offer the bootstrap skill (one printed line) only when: `.lsa.yaml` exists, its `gate:` block lacks a `rag-index-fresh` entry, and `docker` is on `PATH` and reachable within a bounded ~3s check (scaled down from `rag-index.sh`'s existing `docker_daemon_reachable` 5s pattern, `lsa/scripts/rag-index.sh:86-101`, to fit a 10s hook budget).
- R3. The detection script shall exit 0 and print nothing whenever any R2 condition fails — never blocking session start (matches `lsa/hooks/session-start-drift-check.sh`'s own established constraint).
- R4. A new skill (`lsa:bootstrap-rag`) shall, given Docker installed and `lsa:init` already run: build the plugin-shipped image and run the initial full index (reusing `lsa/scripts/rag-index.sh`), set `git config core.hooksPath` to the plugin's own hooks directory, seed the canonical-paths config (reusing `lsa/scripts/seed-canonical-paths.sh`, epic 2), write `rag-index-fresh`/`rag-index-matches-head` into `.lsa.yaml`'s `gate:` block (command values using `$CLAUDE_PLUGIN_ROOT`, per the disclosed scope boundary above), and add `.lsa/.rag-index/` to `.gitignore` (matching the existing entry's format, `.gitignore:15-18`) — no further manual step from the user.
- R5. A new portable git hook at `lsa/hooks/pre-commit` (no extension — git's hook-naming convention) shall self-locate its sibling `lsa/scripts/rag-index.sh` the same way epic 1's `check-rag-index-matches-head.sh` self-locates its sibling — functionally equivalent to `.githooks/pre-commit` but correct when `core.hooksPath` points at a shared plugin-install location potentially serving multiple different target repos on the same machine (resolves the TARGET repo dynamically via `git rev-parse --show-toplevel`, which always reflects wherever `git commit` was actually invoked, never the plugin's own install path).
- R6. `.lsa.yaml`'s `lsa` module `artifact_paths` shall include `lsa/hooks/pre-commit` explicitly — not covered by the existing `lsa/hooks/**/*.sh` glob, since git's hook-naming convention requires no extension.
- R7. This epic shall modify only the plugin-shipped surface (`lsa/hooks/`, new `lsa/skills/bootstrap-rag/`) — the root-level `.githooks/pre-commit`, this repo's own `.lsa.yaml`, and `lsa/hooks/session-start-drift-check.sh` stay unchanged.

## Grounding facts (from discover)

- `lsa/hooks/hooks.json`: `SessionStart` is an array (`"hooks": [...]`) — currently one entry (`session-start-drift-check.sh`, `timeout: 10`).
- `lsa/hooks/session-start-drift-check.sh`: established pattern — `set -uo pipefail`, `trap 'exit 0' ERR`, resolves `repo_root` via `git rev-parse --show-toplevel` falling back to `$CLAUDE_PROJECT_DIR`, no-ops silently (exit 0) on any missing prerequisite.
- `.githooks/pre-commit`: calls `scripts/rag-index.sh` per staged file, hardcoded root-relative — the portability gap R5 closes.
- `.lsa.yaml:14-22`: current `gate:` block format — `rag-index-fresh: bash scripts/check-rag-index-fresh.sh` (this repo's own, root-level; a target repo's equivalent entries must reference the plugin-shipped copies instead).
- `.gitignore:15-18`: existing `.lsa/.rag-index/` entry and its explanatory comment — format to replicate in a target repo.
- `lsa/scripts/rag-index.sh:86-101`: `docker_daemon_reachable()` — bounded background-poll-and-kill pattern (10 × 0.5s = 5s), the model for R2's shorter ~3s check.
- Epic 1 (`relocate-and-run-in-place`, `20ee294`) precedent: `check-rag-index-matches-head.sh`'s `${BASH_SOURCE[0]}`-relative sibling self-location — the pattern R5 reuses.
- Epic 2 (`generic-canonical-config`, `9253977`) precedent: `lsa/scripts/seed-canonical-paths.sh` — reused as-is by R4, not reimplemented.

## Scope

`lsa/hooks/hooks.json`, new `lsa/hooks/<detection-script>.sh`, new `lsa/hooks/pre-commit`, new `lsa/skills/bootstrap-rag/SKILL.md`, `.lsa.yaml` (`artifact_paths` addition). No third-party library delegation (researched and rejected earlier this session).
