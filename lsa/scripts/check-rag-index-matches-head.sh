#!/usr/bin/env bash
# lsa/scripts/check-rag-index-matches-head.sh — plugin-shipped copy of
# scripts/check-rag-index-matches-head.sh (rag-plugin-plug-and-play,
# relocate-and-run-in-place epic). See that file for the full rationale;
# this header only calls out what differs.
#
# R3/R4 CI check (.lsa/features/rag-context-engine-and-repo-indexing/
# commit-triggered-sync/requirements.md): is the RAG index, once (re)built
# here, current with HEAD?
#
# This is the enforcement point R2 explicitly says the pre-commit hook is NOT.
# The pre-commit hook (.githooks/pre-commit) is opt-in, local, best-effort, and
# never blocks a commit — so a hook that's uninstalled, skipped, bypassed
# (`--no-verify`), or failed leaves a commit landing with no guarantee its
# content is indexed. This check closes that gap independently: it does not
# trust or inspect any locally-built index (.lsa/.rag-index/ is gitignored —
# never pushed, never available to CI) — it rebuilds the index itself, in the
# CI checkout, from HEAD's actual on-disk content, and fails the job if that
# build does not succeed cleanly.
#
# lsa/scripts/rag-index.sh's content-hash-keyed cache (lsa/docker/rag_cli.py:
# a row's identity is (path, content_hash, embed_model, chunk_schema)) makes
# rebuilding the whole repo ("." scope) idempotent and cheap — unchanged
# chunks are skipped, not re-embedded — so this check does not need to
# compute a PR/push diff against a base ref. It always verifies the full
# current tree against HEAD, covering every changed file by construction.
#
# Relocation note (relocate-and-run-in-place epic, R2-R4): the root-level
# version calls the sibling `scripts/rag-index.sh` by a CWD-relative path,
# which only resolves inside claude-marketplace itself. This plugin-shipped
# copy instead self-locates its own sibling `rag-index.sh` via
# `${BASH_SOURCE[0]}` (same self-location pattern `rag-index.sh`/
# `rag-query.sh` use for their Docker build context), so it keeps working
# when invoked from any target repo, independent of CWD or where the plugin
# physically lives. `repo_root` (used only for `cd`) is unchanged — still
# resolved from CWD via `git rev-parse --show-toplevel`, since that is the
# TARGET repo being verified, not the plugin's own location.
#
# Exit codes:
#   0 = OK   — rag-index.sh rebuilt the index cleanly against HEAD;
#              every file's current content is reflected in the index (R4).
#   1 = FAIL — rag-index.sh could not build/update the index for HEAD's
#              content, for ANY reason (R3) — including Docker being
#              unreachable (rag-index.sh exit 2). Unlike the local
#              check-rag-index-fresh.sh gate check (best-effort dev
#              convenience, where daemon-unreachable is reported as
#              [cannot verify], exit 2, and does not by itself fail the local
#              gate), this script IS the enforcement point, so there is no
#              [cannot verify] pass-through here: Docker not being reachable
#              in CI means the invariant cannot be proven, which is a FAIL.
#
# Usage: check-rag-index-matches-head.sh   (no arguments; always scope ".")

set -uo pipefail
export LC_ALL=C

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

"${script_dir}/rag-index.sh" .
rc=$?

if [[ "${rc}" -ne 0 ]]; then
  printf '  FAIL             rag-index-matches-head — rag-index.sh exited %s against HEAD; changed files are not fully reflected in the index\n' "${rc}"
  exit 1
fi

printf '  OK               rag-index-matches-head — index rebuilt cleanly against HEAD\n'
exit 0
