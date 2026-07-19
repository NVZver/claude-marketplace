#!/usr/bin/env bash
# scripts/resolve-refs.sh — deterministic per-symbol reference resolver for verify.
#
# lsa:verify Step 1 grounds a spec by resolving each named module / function / type
# to a real location or marking it `new`. Deciding WHICH tokens the spec names is the
# model's judgment; resolving each one is pure lookup — deterministic work the model
# should cite, not recompute over multiple Grep rounds (.lsa/VISION.md §2 principle 10).
# This script takes the symbols the model identified and emits, one line per symbol:
#   <symbol> → exists @ <path>            (a path that exists on disk)
#   <symbol> → new                        (a path / identifier with no match)
#   <symbol> → exists @ <path>:<line>     (a path:line in range, or an identifier hit)
#   <symbol> → MISSING                    (a path:line whose path is absent)
#   <symbol> → OUT-OF-RANGE               (a path:line past the file's end)
#
# RESOLUTION ONLY. It never parses a spec to guess which tokens are symbols — that
# stays the model's judgment (no fragile matching, mirroring the doc-lint gate's
# no-guess-semantics discipline). It resolves exactly the list it is given.
#
# Repo-internal — NOT shipped in any plugin; lives outside every plugin's
# artifact_paths, so it triggers no plugin version bump or CHANGELOG entry.
# Pure git + grep, bash 3.2-safe (no mapfile/assoc arrays), zero model calls, Pro-safe.
#
# Usage: resolve-refs.sh <symbol>…   or symbols piped on stdin (one per line).
# Arguments take precedence: stdin is read ONLY when no arguments are given, so an
# arg-only call never blocks on a pipe that never closes (grep/cat precedence).
# Exit 0 = every input resolved (a `new`/`MISSING`/`OUT-OF-RANGE` line is
# informational, NOT a failure). Non-zero + one-line diagnostic only on empty input.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

# R1: arguments take precedence — stdin is read ONLY when no arguments are given.
# With args present the script never touches stdin, so it can never block on a pipe
# that stays open (the agent-harness case: lsa:verify calls this from a context whose
# stdin is an open pipe with no EOF). Conventional Unix precedence (grep, cat).
symbols=()
if [[ $# -gt 0 ]]; then
  for a in "$@"; do
    [[ -n "${a}" ]] && symbols+=("${a}")
  done
else
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -n "${line}" ]] && symbols+=("${line}")
  done
fi

# R1: both empty → usage error.
if [[ "${#symbols[@]}" -eq 0 ]]; then
  echo "resolve-refs: usage: resolve-refs.sh <symbol>… (and/or symbols on stdin, one per line)" >&2
  exit 1
fi

line_count() { wc -l < "$1" 2>/dev/null | tr -d ' '; }

resolve() {
  local sym="$1" path line total out rc hit rest

  # R3: <path>:<line> — a trailing `:<digits>` suffix.
  if [[ "${sym}" == *:* ]]; then
    line="${sym##*:}"
    if [[ "${line}" =~ ^[0-9]+$ ]]; then
      path="${sym%:*}"
      if [[ ! -e "${path}" ]]; then
        echo "MISSING"; return 0
      fi
      total="$(line_count "${path}")"
      [[ -n "${total}" ]] || total=0
      if [[ "${line}" -le "${total}" ]]; then
        echo "exists @ ${path}:${line}"
      else
        echo "OUT-OF-RANGE"
      fi
      return 0
    fi
  fi

  # R2: contains `/` (and no :line suffix) → a filesystem path.
  if [[ "${sym}" == */* ]]; then
    if [[ -e "${sym}" ]]; then
      echo "exists @ ${sym}"
    else
      echo "new"
    fi
    return 0
  fi

  # R4: bare identifier → first git grep hit over tracked files (fallback grep -rn).
  # Fixed-string match (-F) to avoid regex surprises.
  out="$(git grep -n -F -- "${sym}" 2>/dev/null)"; rc=$?
  if [[ "${rc}" -gt 1 ]]; then
    out="$(grep -rn -F -- "${sym}" . 2>/dev/null | grep -v '/\.git/')"
  fi
  hit="$(printf '%s\n' "${out}" | head -n1)"
  if [[ -z "${hit}" ]]; then
    echo "new"; return 0
  fi
  path="${hit%%:*}"          # git grep / grep -rn prefix: file:line:text
  path="${path#./}"          # normalize grep -rn's leading ./
  rest="${hit#*:}"
  line="${rest%%:*}"
  echo "exists @ ${path}:${line}"
}

for sym in "${symbols[@]}"; do
  printf '%s → %s\n' "${sym}" "$(resolve "${sym}")"
done

exit 0
