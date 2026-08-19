#!/usr/bin/env bash
# lsa/scripts/bootstrap-rag.sh — lsa:bootstrap-rag skill's deterministic
# helper (rag-plugin-plug-and-play, bootstrap-trigger epic, R4). Given a
# target repo (Docker installed, lsa:init already run), makes RAG search a
# fully working, unattended capability of that repo in one invocation:
#
#   1. Build the plugin-shipped image + run the initial full index, via the
#      sibling lsa/scripts/rag-index.sh (self-located, not reimplemented).
#   2. Seed rag: canonical_paths:, via the sibling
#      lsa/scripts/seed-canonical-paths.sh (epic 2, self-located, not
#      reimplemented).
#   3. git config core.hooksPath -> this plugin's own hooks directory
#      (self-located), so the portable lsa/hooks/pre-commit hook fires on
#      every future commit to the target repo.
#   4. Append rag-index-fresh / rag-index-matches-head to the target's
#      .lsa.yaml gate: block — creating the block if absent, appending
#      (never destroying existing keys) if present.
#   5. Append a .lsa/.rag-index/ entry (with an explanatory comment,
#      matching this repo's own .gitignore:15-18 format/spirit) to the
#      target's .gitignore — creating the file if absent, skipping if the
#      entry is already present.
#
# Usage: bootstrap-rag.sh <target-repo-path>
#
# Self-location: prefers $CLAUDE_PLUGIN_ROOT (installed-plugin mode);
# otherwise derives plugin_root from this script's own path
# (${BASH_SOURCE[0]}-relative) — same dual-mode precedent
# lsa/scripts/rag-index.sh already uses (lsa/scripts/rag-index.sh:55-63).
#
# Scope boundary (disclosed, requirements.md "Scope boundary"): the gate:
# command values written in Step 4 use the LITERAL string $CLAUDE_PLUGIN_ROOT
# (single-quoted here, never expanded by this script) rather than a resolved
# absolute path. $CLAUDE_PLUGIN_ROOT is reliably set inside a Claude Code
# session (where verify/reconcile actually invoke gate: commands) but is NOT
# set in a bare shell or a target repo's own CI runner outside Claude Code —
# a deliberate, disclosed design choice, not something to "fix" to a literal
# path.
#
# Exit codes:
#   0 — full success, all five steps completed
#   1 — bad usage, or any step failed — reported by name on stderr, never
#       swallowed silently

set -uo pipefail
export LC_ALL=C

if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  plugin_root="${CLAUDE_PLUGIN_ROOT}"
else
  plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# --- append rag-index-fresh / rag-index-matches-head into gate: -----------
# "Append, don't destroy" discipline — same shape lsa/scripts/
# seed-canonical-paths.sh already uses for the rag: block: find the block by
# name, splice new content in via a temp file + mv, keep every existing line.
append_gate_entries() {
  local yaml="$1"
  local fresh_line head_line block_start
  fresh_line='  rag-index-fresh: bash $CLAUDE_PLUGIN_ROOT/scripts/check-rag-index-fresh.sh'
  head_line='  rag-index-matches-head: bash $CLAUDE_PLUGIN_ROOT/scripts/check-rag-index-matches-head.sh'

  block_start="$(grep -n '^gate:[[:space:]]*$' "${yaml}" | head -n 1 | cut -d: -f1 || true)"

  if [[ -z "${block_start}" ]]; then
    # No existing gate: block -- append a new one at the end of the file.
    {
      printf '\ngate:\n%s\n%s\n' "${fresh_line}" "${head_line}"
    } >> "${yaml}" || return 1
    printf 'Created gate: block in %s with rag-index-fresh/rag-index-matches-head.\n' "${yaml}" >&2
    return 0
  fi

  local total_lines end_line
  total_lines="$(wc -l < "${yaml}" | tr -d ' ')"
  end_line="$(awk -v start="${block_start}" '
    NR > start && /^[^[:space:]#]/ { print NR; exit }
  ' "${yaml}")"
  if [[ -z "${end_line}" ]]; then
    end_line=$(( total_lines + 1 ))
  fi

  local block_body has_fresh=0 has_head=0
  block_body="$(sed -n "${block_start},$(( end_line - 1 ))p" "${yaml}")"
  if printf '%s\n' "${block_body}" | grep -q '^[[:space:]]*rag-index-fresh:'; then
    has_fresh=1
  fi
  if printf '%s\n' "${block_body}" | grep -q '^[[:space:]]*rag-index-matches-head:'; then
    has_head=1
  fi

  if [[ "${has_fresh}" -eq 1 && "${has_head}" -eq 1 ]]; then
    printf 'gate: block in %s already has rag-index-fresh and rag-index-matches-head -- nothing to add.\n' "${yaml}" >&2
    return 0
  fi

  local tmp
  tmp="$(mktemp "${yaml}.XXXXXX")" || return 1
  {
    if [[ "${end_line}" -gt 1 ]]; then
      sed -n "1,$(( end_line - 1 ))p" "${yaml}"
    fi
    if [[ "${has_fresh}" -eq 0 ]]; then
      printf '%s\n' "${fresh_line}"
    fi
    if [[ "${has_head}" -eq 0 ]]; then
      printf '%s\n' "${head_line}"
    fi
    if [[ "${end_line}" -le "${total_lines}" ]]; then
      # Restore the blank-line section separator this repo's own .lsa.yaml
      # convention uses (e.g. between gate: and modules:) — same fix
      # lsa/scripts/seed-canonical-paths.sh already applies for its rag:
      # block splice, for the same reason (the old separator is swallowed
      # by end_line's "first non-blank/non-comment line" definition above).
      printf '\n'
      sed -n "${end_line},\$p" "${yaml}"
    fi
    true
  } > "${tmp}" || { rm -f "${tmp}"; return 1; }
  mv "${tmp}" "${yaml}" || return 1
  printf 'Appended missing gate: entries to %s.\n' "${yaml}" >&2
  return 0
}

# --- append a .lsa/.rag-index/ entry to .gitignore -------------------------
append_gitignore_entry() {
  local target_repo="$1"
  local gi="${target_repo%/}/.gitignore"

  if [[ ! -f "${gi}" ]]; then
    : > "${gi}" || return 1
  fi

  if grep -qF '.lsa/.rag-index/' "${gi}" 2>/dev/null; then
    printf '.gitignore in %s already has a .lsa/.rag-index/ entry -- skipping.\n' "${target_repo}" >&2
    return 0
  fi

  {
    printf '\n# Local-only RAG vector index (lsa:bootstrap-rag / lsa/scripts/rag-index.sh).\n'
    printf '# Rebuilt on demand from the repo itself -- never committed, machine-local\n'
    printf '# build output, not behavior-bearing.\n'
    printf '.lsa/.rag-index/\n'
  } >> "${gi}" || return 1

  printf 'Appended .lsa/.rag-index/ entry to %s.\n' "${gi}" >&2
  return 0
}

TARGET_REPO="${1:-}"
if [[ -z "${TARGET_REPO}" ]]; then
  printf 'Usage: %s <target-repo-path>\n' "$0" >&2
  exit 1
fi
if [[ ! -d "${TARGET_REPO}" ]]; then
  printf 'ERROR: bootstrap-rag.sh -- target repo path does not exist: %s\n' "${TARGET_REPO}" >&2
  exit 1
fi
TARGET_REPO="$(cd "${TARGET_REPO}" && pwd)"

TARGET_YAML="${TARGET_REPO}/.lsa.yaml"
if [[ ! -f "${TARGET_YAML}" ]]; then
  printf 'ERROR: bootstrap-rag.sh -- %s not found. Run lsa:init against %s first.\n' "${TARGET_YAML}" "${TARGET_REPO}" >&2
  exit 1
fi

# --- Step 1: build the plugin-shipped image + run the initial full index --
# Set CWD to the TARGET repo before invoking rag-index.sh, which resolves
# its own `repo_root` (the repo it indexes) from CWD via
# `git rev-parse --show-toplevel` — independent of plugin_root (see
# lsa/scripts/rag-index.sh:65-68). Run in a subshell so this script's own
# CWD is unaffected for the steps that follow.
if ! ( cd "${TARGET_REPO}" && "${plugin_root}/scripts/rag-index.sh" ); then
  printf 'ERROR: bootstrap-rag.sh -- rag-index.sh failed against %s (see messages above, e.g. Docker unreachable).\n' "${TARGET_REPO}" >&2
  exit 1
fi

# --- Step 2: seed rag: canonical_paths: (epic 2's script, reused as-is) ---
if ! "${plugin_root}/scripts/seed-canonical-paths.sh" "${TARGET_REPO}"; then
  printf 'ERROR: bootstrap-rag.sh -- seed-canonical-paths.sh failed against %s.\n' "${TARGET_REPO}" >&2
  exit 1
fi

# --- Step 3: wire core.hooksPath to this plugin's own hooks directory -----
plugin_hooks_dir="${plugin_root}/hooks"
if [[ ! -d "${plugin_hooks_dir}" ]]; then
  printf 'ERROR: bootstrap-rag.sh -- plugin hooks directory not found at %s.\n' "${plugin_hooks_dir}" >&2
  exit 1
fi
if ! git -C "${TARGET_REPO}" config core.hooksPath "${plugin_hooks_dir}"; then
  printf 'ERROR: bootstrap-rag.sh -- git config core.hooksPath failed for %s.\n' "${TARGET_REPO}" >&2
  exit 1
fi

# --- Step 4: rag-index-fresh / rag-index-matches-head into gate: ----------
if ! append_gate_entries "${TARGET_YAML}"; then
  printf 'ERROR: bootstrap-rag.sh -- failed to update gate: block in %s.\n' "${TARGET_YAML}" >&2
  exit 1
fi

# --- Step 5: .lsa/.rag-index/ into .gitignore ------------------------------
if ! append_gitignore_entry "${TARGET_REPO}"; then
  printf 'ERROR: bootstrap-rag.sh -- failed to update .gitignore in %s.\n' "${TARGET_REPO}" >&2
  exit 1
fi

printf 'RAG bootstrap complete for %s: image built, index created, git hook wired, gate: entries added, canonical-paths seeded, .gitignore updated.\n' "${TARGET_REPO}"
exit 0
