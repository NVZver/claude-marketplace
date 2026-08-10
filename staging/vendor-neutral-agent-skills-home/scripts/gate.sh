#!/usr/bin/env bash
# scripts/gate.sh — deterministic aggregate runner for the .lsa.yaml gate: block.
#
# The verify/reconcile "gate pre-pass" offload (pitch pro-tier-token-affordability
# WS3): instead of an agent orchestrating each gate command model-side and
# collecting exit codes one by one, this runs the WHOLE .lsa.yaml `gate:` block in
# one pass and prints the Rule-7 artifact — each check's `name`, `command`, and
# `exit N` — plus an aggregate. lsa:verify (Step 4) and lsa:reconcile (Step 1)
# cite this consolidated output.
#
# DRY: the check list is READ from the `gate:` block (the single source of truth,
# lsa/knowledge/quality-gate-contract.md §Schema); this runner hardcodes no
# commands and is never itself a member of the block. Add a gate check by editing
# .lsa.yaml only.
#
# Zero model calls, Pro-safe local bash. Repo-internal — NOT shipped in any
# plugin; lives outside every plugin's artifact_paths, so it triggers no plugin
# version bump or CHANGELOG entry.
#
# Exit 0 = every configured check passed. Exit 1 = at least one check failed.
# Exit 2 = NOT-RUNNABLE (no gate: block in .lsa.yaml) — reported, never silent
# (matches reconcile's NOT-RUNNABLE contract).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi

CFG=".lsa.yaml"
echo "=== .lsa.yaml gate: block ==="

if [[ ! -f "${CFG}" ]]; then
  printf 'gate: NOT-RUNNABLE — no %s found\n' "${CFG}"
  exit 2
fi

# Extract "name<TAB>command" lines from the gate: block: 2-space-indented
# `name: command` pairs between `gate:` and the next top-level key. Comments and
# blank lines inside the block are skipped. (while-read, not mapfile — macOS
# ships bash 3.2.)
entries=()
while IFS= read -r line; do
  [[ -n "${line}" ]] && entries+=("${line}")
done < <(awk '
  /^gate:[[:space:]]*$/            { ing=1; next }
  ing && /^[^[:space:]#]/          { ing=0 }
  ing && /^[[:space:]]*#/          { next }
  ing && /^[[:space:]]*$/          { next }
  ing && /^[[:space:]]+[A-Za-z0-9_-]+:[[:space:]]*[^[:space:]]/ {
    l=$0; sub(/^[[:space:]]+/,"",l)
    key=l; sub(/:.*/,"",key)
    cmd=l; sub(/^[^:]+:[[:space:]]*/,"",cmd)
    print key "\t" cmd
  }
' "${CFG}")

if [[ "${#entries[@]}" -eq 0 ]]; then
  echo "gate: NOT-RUNNABLE — no gate: block in ${CFG}"
  exit 2
fi

fail=0
for e in "${entries[@]}"; do
  name="${e%%$'\t'*}"
  cmd="${e#*$'\t'}"
  bash -c "${cmd}" >/dev/null 2>&1
  rc=$?
  if [[ "${rc}" -eq 0 ]]; then
    printf '  %sPASS%s  %-16s %s → exit 0\n' "${GREEN}" "${OFF}" "${name}" "${cmd}"
  else
    printf '  %sFAIL%s  %-16s %s → exit %s\n' "${RED}" "${OFF}" "${name}" "${cmd}" "${rc}"
    fail=1
  fi
done

echo
if [[ "${fail}" -eq 0 ]]; then
  printf '%sgate: PASS%s — every configured check exited 0\n' "${GREEN}" "${OFF}"
  exit 0
fi
printf '%sgate: FAIL%s — see the failing check(s) above\n' "${RED}" "${OFF}"
exit 1
