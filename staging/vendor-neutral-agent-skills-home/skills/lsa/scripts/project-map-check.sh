#!/usr/bin/env bash
# lsa/scripts/project-map-check.sh — freshness gate for project-map.yaml.
#
# Runs project-map-build.sh, then fails if project-map.yaml is dirty in git
# (modified, deleted, or untracked). Pass only when a rebuild is a no-op
# against the committed map — ownership stays with the human (commit the
# refreshed file); this script never stages or commits.
#
# Wire into .lsa.yaml gate: e.g.
#   project-map: bash lsa/scripts/project-map-check.sh
# (or via ${CLAUDE_PLUGIN_ROOT}/scripts/project-map-check.sh when installed).
#
# Exit 0 = fresh. Exit 1 = stale / missing from git / build failed.

set -euo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD="${SCRIPT_DIR}/project-map-build.sh"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  echo "ERROR: not inside a git work tree." >&2
  exit 1
fi
cd "${repo_root}" || exit 1

bash "${BUILD}"

MAP="project-map.yaml"
status="$(git status --porcelain -- "${MAP}" 2>/dev/null || true)"
if [[ -n "${status}" ]]; then
  echo "FAIL: ${MAP} is stale or uncommitted after rebuild:" >&2
  printf '%s\n' "${status}" >&2
  echo "Regenerate is already done — commit ${MAP}, or run: bash lsa/scripts/project-map-build.sh" >&2
  exit 1
fi

echo "OK: ${MAP} is fresh (rebuild matches git)"
exit 0
