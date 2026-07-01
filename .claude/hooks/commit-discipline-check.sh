#!/usr/bin/env bash
# Repo-internal PreToolUse hook — enforce per-plugin commit discipline.
#
# Fires before a `Bash` tool call runs `git commit` in THIS repo. For every
# plugin whose files are in the staged set, it verifies the same-commit
# discipline mandated by .lsa/standards/code.md:22 ("Bump the version in the
# same commit as the changelog entry. No exceptions.") and
# .claude/rules/plugin-development.md (version bump + CHANGELOG + trace):
#
#   (a) <plugin>/.claude-plugin/plugin.json has a staged-changed "version:" line
#   (b) <plugin>/CHANGELOG.md has at least one staged added line
#   (c) every staged new/edited SKILL.md and agents/**/*.md carries the
#       `> **Trace.** On load, print first:` directive
#
# DETECT-AND-REPORT ONLY. It never writes, never auto-fixes, never touches the
# network — it runs read-only git plumbing and, on a violation, prints an
# actionable per-plugin message to stderr and exits 2 (PreToolUse BLOCK).
# Compliant commits exit 0 silently.
#
# NO-OP (exit 0) when this is not the claude-marketplace repo — mirrors the
# self-detection of lsa/hooks/session-start-drift-check.sh so the check never
# fires in a consumer repo:
#   - not in a git repo
#   - the marketplace catalog (.claude-plugin/marketplace.json) is absent
#   - the tool call is not a `git commit`
#
# BYPASS (transparent, documented in SECURITY.md): non-artifact paths never
# trigger the check. Only top-level directories that contain
# .claude-plugin/plugin.json are treated as plugins, so repo-internal infra
# (scripts/, .lsa/, .claude/, tests/, root docs) is exempt by construction.

set -uo pipefail
trap 'exit 0' ERR

TRACE_DIRECTIVE='> **Trace.** On load, print first:'

# --- Read the PreToolUse payload from stdin -------------------------------
# PreToolUse passes a JSON envelope with .tool_input.command for Bash calls.
# Parse with jq when available; fall back to a grep/sed extraction otherwise.
payload="$(cat 2>/dev/null || true)"

extract_command() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "${payload}" | jq -r '.tool_input.command // ""' 2>/dev/null
    return
  fi
  # Fallback: pull the "command" string field out of the JSON. Best-effort;
  # if it fails the trap/`|| true` keeps us in a no-op-safe state.
  printf '%s' "${payload}" \
    | tr -d '\n' \
    | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p'
}

command_str="$(extract_command)"

# Only guard git commits. Anything else (or an unparseable payload) is a no-op.
# Match `git commit` allowing global flags between (e.g. `git -c x=y commit`).
printf '%s' "${command_str}" | grep -Eq '(^|[[:space:]&;|(])git([[:space:]]+-[^[:space:]]+|[[:space:]]+[A-Za-z]+=[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' || exit 0

# --- Self-detect: only run inside the claude-marketplace repo --------------
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  repo_root="${CLAUDE_PROJECT_DIR:-}"
fi
[[ -n "${repo_root}" && -d "${repo_root}" ]] || exit 0
cd "${repo_root}" || exit 0

# The marketplace catalog is the fingerprint of THIS repo. A consumer repo that
# merely installed the plugins has no such file — so we no-op there.
[[ -f "${repo_root}/.claude-plugin/marketplace.json" ]] || exit 0

# --- Gather the staged file set -------------------------------------------
staged="$(git diff --cached --name-only 2>/dev/null || true)"
[[ -n "${staged}" ]] || exit 0   # nothing staged → nothing to enforce

# Discover plugins: top-level dirs that carry .claude-plugin/plugin.json.
plugins=()
for d in "${repo_root}"/*/ ; do
  name="$(basename "${d}")"
  [[ -f "${repo_root}/${name}/.claude-plugin/plugin.json" ]] && plugins+=("${name}")
done
[[ "${#plugins[@]}" -gt 0 ]] || exit 0

# Returns 0 if the named plugin has a staged-changed "version": line.
version_bumped() {
  local plugin="$1"
  git diff --cached -U0 -- "${plugin}/.claude-plugin/plugin.json" 2>/dev/null \
    | grep -Eq '^\+[[:space:]]*"version"[[:space:]]*:'
}

# Returns 0 if the named plugin's CHANGELOG.md has ≥1 staged added line.
changelog_added() {
  local plugin="$1"
  local added
  added="$(git diff --cached --numstat -- "${plugin}/CHANGELOG.md" 2>/dev/null | awk '{print $1; exit}')"
  [[ -n "${added}" && "${added}" != "-" && "${added}" -gt 0 ]] 2>/dev/null
}

# Returns 0 if the staged content of $1 contains the trace directive.
has_trace_directive() {
  local path="$1"
  git show ":${path}" 2>/dev/null | grep -qF "${TRACE_DIRECTIVE}"
}

violations=()

for plugin in "${plugins[@]}"; do
  # Files under this plugin that are staged (any status).
  plugin_files="$(printf '%s\n' "${staged}" | grep -E "^${plugin}/" || true)"
  [[ -n "${plugin_files}" ]] || continue   # plugin untouched → skip

  msgs=()

  version_bumped "${plugin}" \
    || msgs+=("bump \"version\" in ${plugin}/.claude-plugin/plugin.json")

  changelog_added "${plugin}" \
    || msgs+=("add a ${plugin}/CHANGELOG.md entry (Keep a Changelog)")

  # Trace check: staged, non-deleted SKILL.md and agents/**/*.md files.
  while IFS=$'\t' read -r status path; do
    [[ -z "${path}" ]] && continue
    [[ "${status}" == D* ]] && continue   # deletions can't carry a directive
    case "${path}" in
      "${plugin}"/*SKILL.md|"${plugin}"/*/agents/*.md|"${plugin}"/agents/*.md)
        has_trace_directive "${path}" \
          || msgs+=("add the trace directive to ${path} — the line: ${TRACE_DIRECTIVE} \`...\`")
        ;;
    esac
  done < <(git diff --cached --name-status -- "${plugin}/" 2>/dev/null)

  if [[ "${#msgs[@]}" -gt 0 ]]; then
    violations+=("[${plugin}]")
    for m in "${msgs[@]}"; do
      violations+=("    - ${m}")
    done
  fi
done

if [[ "${#violations[@]}" -gt 0 ]]; then
  {
    echo "BLOCKED: plugin commit-discipline check failed."
    echo "This commit touches plugin files but does not satisfy the same-commit"
    echo "discipline (version bump + CHANGELOG entry + trace directive)."
    echo "Source: .lsa/standards/code.md:22, .claude/rules/plugin-development.md."
    echo ""
    printf '%s\n' "${violations[@]}"
    echo ""
    echo "Fix the items above and re-stage, or (repo-internal infra only) keep"
    echo "the change out of any <plugin>/ path. This hook only reports — it never"
    echo "edits your files. See SECURITY.md → 'The commit-discipline PreToolUse hook'."
  } >&2
  exit 2
fi

exit 0
