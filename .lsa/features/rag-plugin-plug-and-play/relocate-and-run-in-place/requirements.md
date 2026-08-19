# requirements.md — rag-plugin-plug-and-play/relocate-and-run-in-place

Epic 1 of 4 of the `rag-plugin-plug-and-play` pitch. Foundational — hard-blocks `bootstrap-trigger` and `dogfood-migration`; parallel with `generic-canonical-config`.

## Scoping note

`dogfood-migration` (epic 4) is explicitly the epic that cuts claude-marketplace's own CI/config over to the new location (pitch: *"claude-marketplace ... migrates from its hand-authored root-level RAG files/config to the plugin-shipped, bootstrap-produced equivalent, with a sequencing plan that keeps `.github/workflows/lint.yml`'s gate checks green throughout"*). This epic therefore **adds** a new, parallel, plugin-shipped location at `lsa/docker/` + `lsa/scripts/` and proves it works standalone — it does **not** remove or modify the existing root-level `Dockerfile`, `docker/rag_cli.py`, or `scripts/rag-*.sh`, which keep serving this repo's own dogfood usage unchanged until epic 4.

## User flows

| Flow | Success | I/O | Test |
|---|---|---|---|
| 1. Plugin-shipped RAG engine works standalone against an arbitrary repo | From any target repo, invoking the plugin-shipped scripts builds the image from `lsa/docker/`'s Dockerfile and produces a working index, with zero files written into the target repo's tracked tree | In: target repo path (or CWD). Out: built image + populated `.lsa/.rag-index/` in the target repo only | Real scratch git repo, unrelated to claude-marketplace |
| 2. Existing dogfood path stays fully unaffected | This repo's own root-level `Dockerfile`/`docker/rag_cli.py`/`scripts/rag-*.sh` and `.lsa.yaml gate:` block keep working exactly as today | In: existing gate commands. Out: unchanged pass/fail | `bash scripts/gate.sh` before and after, same result |

## Requirements

- R1. The system shall provide plugin-shipped copies of the RAG engine (`Dockerfile`, `docker/rag_cli.py`) at `lsa/docker/`, functionally identical to the current root-level container-side behavior — no logic changes, only location.
- R2. The system shall provide plugin-shipped copies of the four wrapper scripts (`rag-index.sh`, `rag-query.sh`, `check-rag-index-fresh.sh`, `check-rag-index-matches-head.sh`) at `lsa/scripts/`.
- R3. While resolving where its own Docker build context lives, each plugin-shipped script shall prefer `$CLAUDE_PLUGIN_ROOT` when set, and otherwise derive its own directory from its own script path (`${BASH_SOURCE[0]}`-relative) — never from the target repo.
- R4. While resolving the target repo to index/query, the plugin-shipped scripts shall use the same resolution behavior as the existing root-level scripts (`git rev-parse --show-toplevel` from CWD) — fully independent of wherever the plugin's own Dockerfile/rag_cli.py physically live.
- R5. The system shall build and tag a single shared Docker image, reused across every target repo — no target-repo-specific image tag.
- R6. Invoking the plugin-shipped `rag-index.sh` against a target repo shall write zero files into that repo's own tracked tree — only its existing gitignored `.lsa/.rag-index/`, unchanged from current behavior.
- R7. The existing root-level `Dockerfile`, `docker/rag_cli.py`, and `scripts/rag-*.sh` shall remain unchanged and fully functional — this epic adds a new, parallel, plugin-shipped location; removal is `dogfood-migration`'s scope, not this epic's.
- R8. `.lsa.yaml`'s `lsa` module `artifact_paths` shall include the new `lsa/docker/**` location.
- R9. The `lsa` plugin version shall bump with a CHANGELOG entry (new shipped files = user-facing surface change), per this initiative's established pattern.

## Grounding facts (from discover)

- `scripts/rag-index.sh:49-51`, `scripts/rag-query.sh:49-51`: both resolve `repo_root` via `git rev-parse --show-toplevel` — currently the SAME value used both as Docker build context and target repo. These two uses split in the relocated copies.
- `scripts/rag-index.sh:131-144` / `scripts/rag-query.sh:131-144`: `SOURCE_HASH` and `docker build` both currently read from `${repo_root}/Dockerfile` (the target repo). The plugin-shipped copies must instead read from wherever `lsa/docker/` physically lives.
- `scripts/check-rag-index-fresh.sh:25-29`, `scripts/check-rag-index-matches-head.sh:46-48`: same `repo_root` self-location pattern, used for `INDEX_DIR` only — moves location, no build-context fix needed.
- `Dockerfile:29-47`: `COPY docker/rag_cli.py /app/rag_cli.py` — path relative to build context.
- `lsa/skills/init/SKILL.md:41`: established dual-mode invocation precedent already in this codebase (prefer `$CLAUDE_PLUGIN_ROOT`, fall back to a marketplace-checkout-relative path).
- `.lsa.yaml:75-88`: `lsa` module `artifact_paths` already includes `lsa/scripts/**/*.sh` — the relocated scripts fall under this glob automatically; `lsa/docker/**` needs a new entry.
- `docker/rag_cli.py` already takes `--scope`, `--index-dir`, `--repo-root` as CLI args — container-side code is already target-repo-agnostic; only the two host-side wrapper scripts' own build/invocation logic couples build-context to target-repo today.

## Scope

`Dockerfile`, `docker/rag_cli.py` (new copies at `lsa/docker/`), `scripts/rag-index.sh`, `scripts/rag-query.sh`, `scripts/check-rag-index-fresh.sh`, `scripts/check-rag-index-matches-head.sh` (new copies at `lsa/scripts/`), `.lsa.yaml` (`artifact_paths` addition), `lsa/.claude-plugin/plugin.json` (version bump), `lsa/CHANGELOG.md`. No third-party library delegation (pre-commit framework, Testcontainers — researched and rejected this session).
