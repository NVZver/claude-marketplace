#!/usr/bin/env bash
# scripts/check-version-changelog.sh — deterministic version↔CHANGELOG mirror check.
#
# The repo's same-commit discipline (.lsa/standards/code.md:22 — "Bump the
# version in the same commit as the changelog entry. No exceptions.") implies a
# standing invariant: for every plugin, the top released heading in
# <plugin>/CHANGELOG.md names the same SemVer as "version" in
# <plugin>/.claude-plugin/plugin.json. The local PreToolUse hook
# (.claude/hooks/commit-discipline-check.sh) guards this at commit time, but it
# never fires on a GitHub-UI merge — this script mirrors the discipline in CI
# (deterministic-enforcement-gates pitch, Fork C: "yes, hook + CI").
#
# Semantics (mirroring the hook's version↔CHANGELOG discipline):
#   - Plugins are discovered exactly as the hook discovers them: top-level
#     directories that carry .claude-plugin/plugin.json.
#   - The CHANGELOG's authoritative version is the FIRST `## [x.y.z]` heading
#     whose bracket holds a real SemVer — any `## [Unreleased]` (or other
#     non-SemVer bracket) above it is skipped.
#   - That version must equal plugin.json's "version" string, exactly.
#
# DETECT-AND-REPORT ONLY: read-only, no network, no model calls. Repo-internal —
# NOT shipped in any plugin (lives outside every plugin's artifact_paths in
# .lsa.yaml), so it triggers no plugin version bump or CHANGELOG entry.
#
# Exit 0 = every plugin's version mirrors its CHANGELOG. Exit 1 = mismatch,
# missing file, or unparseable version — each reported with an actionable line.

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi

violations=0
checked=0

# First "version": "x.y.z" string in a plugin.json (bash 3.2 / no-jq safe).
manifest_version() {
  sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" 2>/dev/null | head -1
}

# First real-SemVer `## [x.y.z]` heading in a CHANGELOG (skips [Unreleased]).
changelog_version() {
  grep -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$1" 2>/dev/null \
    | head -1 \
    | sed -n 's/^## \[\([0-9][0-9.]*\)\].*/\1/p'
}

# Discover plugins the same way the commit-discipline hook does: top-level
# dirs carrying .claude-plugin/plugin.json (core lsa helper manager
# prompt-engineer observer today).
for d in */ ; do
  plugin="${d%/}"
  manifest="${plugin}/.claude-plugin/plugin.json"
  changelog="${plugin}/CHANGELOG.md"
  [[ -f "${manifest}" ]] || continue

  checked=$((checked + 1))

  if [[ ! -f "${changelog}" ]]; then
    printf '  %sVIOLATION%s %s: %s is missing — every plugin ships a CHANGELOG.md\n' \
      "${RED}" "${OFF}" "${plugin}" "${changelog}"
    violations=$((violations + 1))
    continue
  fi

  mv_="$(manifest_version "${manifest}")"
  cv_="$(changelog_version "${changelog}")"

  if [[ -z "${mv_}" ]]; then
    printf '  %sVIOLATION%s %s: no "version" string found in %s\n' \
      "${RED}" "${OFF}" "${plugin}" "${manifest}"
    violations=$((violations + 1))
    continue
  fi
  if [[ -z "${cv_}" ]]; then
    printf '  %sVIOLATION%s %s: no `## [x.y.z]` SemVer heading found in %s (only [Unreleased]?)\n' \
      "${RED}" "${OFF}" "${plugin}" "${changelog}"
    violations=$((violations + 1))
    continue
  fi

  if [[ "${mv_}" != "${cv_}" ]]; then
    printf '  %sVIOLATION%s %s: %s has "version": "%s" but the top %s heading is [%s] — bump both in the same commit (.lsa/standards/code.md:22)\n' \
      "${RED}" "${OFF}" "${plugin}" "${manifest}" "${mv_}" "${changelog}" "${cv_}"
    violations=$((violations + 1))
  fi
done

echo
if [[ "${checked}" -eq 0 ]]; then
  printf '%sFAIL%s no plugin (top-level dir with .claude-plugin/plugin.json) found — wrong working directory?\n' \
    "${RED}" "${OFF}"
  exit 1
fi
if [[ "${violations}" -eq 0 ]]; then
  printf '%sOK%s  %s plugin(s) checked, every plugin.json version mirrors its CHANGELOG heading.\n' \
    "${GREEN}" "${OFF}" "${checked}"
  exit 0
fi
printf '%sFAIL%s %s of %s plugin(s) out of mirror — see VIOLATION lines above.\n' \
  "${RED}" "${OFF}" "${violations}" "${checked}"
exit 1
