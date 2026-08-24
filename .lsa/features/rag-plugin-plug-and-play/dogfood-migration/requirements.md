# requirements.md — rag-plugin-plug-and-play/dogfood-migration

Epic 4 of 4 (capstone) of the `rag-plugin-plug-and-play` pitch. Hard-depends on all three prior epics (all shipped: `20ee294`/`93f62fc`, `9253977`/`82b6a94`, `555749c`/`43b64ef`). Not parallelizable — this is claude-marketplace cutting itself over to its own new mechanism.

## Risk note

This epic touches live CI config (`.github/workflows/lint.yml`) and removes working root-level files this repo currently depends on for its own `gate:` checks. Owner explicitly confirmed proceeding on this basis (live verification at every step, no step committed unverified) before this spec was written.

## User flows

| Flow | Success | Test |
|---|---|---|
| 1. Real index rebuilds correctly, config ported not regressed | Full-repo index built via the plugin-shipped engine; `rag: canonical_paths:` seeded to at least the same coverage as epic 9's hardcoded list, not silently emptied | Real rebuild + real query comparison |
| 2. `gate:` + CI point at the new location, verified green | `.lsa.yaml gate:` and `.github/workflows/lint.yml` reference `lsa/scripts/*`; both checks pass | `bash scripts/gate.sh` before/after |
| 3. Root-level RAG files removed; local hook repointed | Old files gone; `core.hooksPath` set to the plugin location | `git status`, `git config` |
| 4. Live docs updated; historical records untouched | README/CONTRIBUTING/SECURITY/conventions/skill prose reference new paths; `.lsa/features/`, `.lsa/observations/`, `.lsa/pitches/` untouched | Diff review |

## Requirements

- R1. The system shall seed this repo's own `.lsa.yaml` `rag: canonical_paths:` block to cover at least the same paths as epic 9's now-superseded hardcoded `CANONICAL_PATH_PREFIXES` list — the 5 module directories (auto-derivable via `lsa/scripts/seed-canonical-paths.sh`, confirmed against this repo's own real `.lsa.yaml` during epic 2's own verification to yield ~23 finer-grained entries, not just 5, since each module's `artifact_paths` has multiple distinct sub-globs) plus the 12 non-module entries (root docs, `.lsa/` meta-files) that auto-seed cannot derive, added manually first so the seed script's merge-preserve behavior (epic 2, R5) keeps them.
- R2. The system shall rebuild the real RAG index for this repo using the plugin-shipped engine (`lsa/scripts/rag-index.sh`) and confirm it reflects the seeded config from R1 before any `gate:`/CI change is made.
- R3. The system shall update `.lsa.yaml`'s `gate:` block to invoke `lsa/scripts/check-rag-index-fresh.sh` and `lsa/scripts/check-rag-index-matches-head.sh` via plain repo-relative paths (not `$CLAUDE_PLUGIN_ROOT`) — this repo *is* the marketplace checkout, so `lsa/` is always a real, present directory; a `$CLAUDE_PLUGIN_ROOT`-based command would silently fail in `.github/workflows/lint.yml`'s CI runner, where that variable is never set.
- R4. The system shall update `.github/workflows/lint.yml`'s two RAG gate steps (`.github/workflows/lint.yml:25-28`) to the same `lsa/scripts/*` paths as R3.
- R5. The system shall remove the root-level `Dockerfile`, `docker/rag_cli.py`, `scripts/rag-index.sh`, `scripts/rag-query.sh`, `scripts/check-rag-index-fresh.sh`, `scripts/check-rag-index-matches-head.sh`, and `.githooks/pre-commit` — fully superseded by the plugin-shipped equivalents (epics 1-3).
- R6. The system shall set local `git config core.hooksPath` to the plugin's `lsa/hooks` directory (this developer's own clone) and update `CONTRIBUTING.md`'s documented setup instruction (`CONTRIBUTING.md:66-80`) to match, for future contributors.
- R7. The system shall update every live-doc reference to the removed root-level paths — `README.md:26`, `CONTRIBUTING.md`, `SECURITY.md` (multiple references, `:46,316-400`), `lsa/knowledge/conventions.md:40`, `lsa/skills/discover/SKILL.md:29`, `lsa/skills/verify/SKILL.md:31`, `lsa/skills/reconcile/SKILL.md:36` — to the new `lsa/scripts/*` locations. `scripts/resolve-refs.sh` and `scripts/coverage-skeleton.sh` references stay unchanged (unrelated tools, not part of this migration).
- R8. The system shall NOT edit any historical record (`.lsa/features/**`, `.lsa/observations/**`, `.lsa/pitches/**`) — these are point-in-time artifacts, not living docs, per this repo's own canonical-vs-historical distinction (epic 9, `rag-context-engine-and-repo-indexing`).
- R9. `bash scripts/gate.sh` shall report the same pass/fail pattern immediately before and after the cutover commit — specifically, `rag-index-fresh` and `rag-index-matches-head` PASS in both — no red window.

## Grounding facts (from discover)

- `.lsa.yaml` currently has no `rag: canonical_paths:` block at all (`grep -n "canonical_paths\|rag:" .lsa.yaml` — no match) — confirms R1's real gap.
- Epic 2's own reconcile (`generic-canonical-config/conformance.md`) ran `seed-canonical-paths.sh` against a full copy of this repo's real `.lsa.yaml` and found **23** entries derived from `modules:` — not the 5 top-level module directories, since each module's `artifact_paths` list has multiple distinct sub-globs (e.g. `core/skills/**/SKILL.md` → `core/skills/`, `core/knowledge/**/*.md` → `core/knowledge/`, etc., each a separate entry).
- `docker/rag_cli.py:592-611` (root-level, pre-migration) — the 17-entry hardcoded list this migration must not silently regress below in coverage; the 12 entries not derivable from `artifact_paths` (root docs + `.lsa/` meta-files) must be added manually before running the seed script.
- `.github/workflows/lint.yml:25-28` — the two CI steps calling `bash scripts/check-rag-index-fresh.sh` / `bash scripts/check-rag-index-matches-head.sh`.
- `CONTRIBUTING.md:66-80`, `SECURITY.md:316-400` — documented `git config core.hooksPath .githooks` setup instructions and `.githooks/pre-commit` behavior description.
- `lsa/knowledge/conventions.md:40`, `lsa/skills/discover/SKILL.md:29`, `lsa/skills/verify/SKILL.md:31`, `lsa/skills/reconcile/SKILL.md:36` — each references `scripts/rag-query.sh` (root-relative) in the Read-protocol prose.
- Repo-wide grep confirms `.lsa/features/**`, `.lsa/observations/**`, `.lsa/pitches/**` also reference the old paths, but these are historical/point-in-time records — R8 explicitly excludes them.

## Scope

`.lsa.yaml`, `.github/workflows/lint.yml`, `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `lsa/knowledge/conventions.md`, `lsa/skills/discover/SKILL.md`, `lsa/skills/verify/SKILL.md`, `lsa/skills/reconcile/SKILL.md`, plus removal of `Dockerfile`, `docker/rag_cli.py`, `scripts/rag-index.sh`, `scripts/rag-query.sh`, `scripts/check-rag-index-fresh.sh`, `scripts/check-rag-index-matches-head.sh`, `.githooks/pre-commit`. No `lsa/` plugin `artifact_paths` change (no new plugin-shipped files this epic) — no version bump expected unless review finds otherwise.
