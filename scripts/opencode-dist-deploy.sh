#!/usr/bin/env bash
# scripts/opencode-dist-deploy.sh — install dist/opencode/ into the local
# OpenCode config, replacing existing files.
#
# Companion to scripts/opencode-dist-generate.sh, which produces dist/opencode/.
# This script only copies; it does no translation. Run generate first.
#
# Scope of "replace": only files this port owns — commands/agents prefixed
# core-, manager-, or lsa- — are touched. Anything else you've added by hand
# to ~/.config/opencode/{commands,agents}/ is left alone. A file that this
# port owned in a previous run but no longer produces (e.g. a skill later
# excluded) is removed from the target, same as the source.
#
# Exit 0 = deployed. Exit 1 = dist/opencode/ missing or empty (run generate first).

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

DIST="dist/opencode"
TARGET="${HOME}/.config/opencode"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi

if [[ ! -d "${DIST}/commands" || -z "$(ls -A "${DIST}/commands" 2>/dev/null)" ]]; then
  printf '%sFAIL%s  %s/commands is missing or empty — run scripts/opencode-dist-generate.sh first.\n' "${RED}" "${OFF}" "${DIST}"
  exit 1
fi

mkdir -p "${TARGET}/commands" "${TARGET}/agents"

# --delete is scoped by --include/--exclude to this port's own filename
# prefixes, so it only prunes stale files *we* previously deployed.
rsync -a --delete \
  --include='core-*.md' --include='manager-*.md' --include='lsa-*.md' --exclude='*' \
  "${DIST}/commands/" "${TARGET}/commands/"

if [[ -d "${DIST}/agents" ]]; then
  rsync -a --delete \
    --include='manager-*.md' --include='lsa-*.md' --exclude='*' \
    "${DIST}/agents/" "${TARGET}/agents/"
fi

n_cmd=$(find "${TARGET}/commands" -maxdepth 1 -name '*.md' \( -name 'core-*' -o -name 'manager-*' -o -name 'lsa-*' \) | wc -l | tr -d ' ')
n_agent=$(find "${TARGET}/agents" -maxdepth 1 -name '*.md' \( -name 'manager-*' -o -name 'lsa-*' \) | wc -l | tr -d ' ')

echo "${GREEN}Deployed${OFF}: ${n_cmd} commands, ${n_agent} agents -> ${TARGET}"
