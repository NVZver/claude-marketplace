#!/usr/bin/env bash
# LSA SessionStart hook — surface artifact drift at session start.
#
# Reads .lsa.yaml (module → artifact_paths) and .lsa-sync-state.json (last-sync
# SHA per module). For each module: diffs working tree against the recorded SHA;
# if any path differs, prints a one-line drift notice naming the modules. Exits 0
# always — this is informational, must not block session start.
#
# No-op when:
#   - not in a git repo
#   - .lsa.yaml is absent (no opt-in)
#   - .lsa-sync-state.json is absent (no baseline yet)
#   - recorded SHA is unreachable (history rewrite — silent)

set -uo pipefail
trap 'exit 0' ERR

# Resolve repo root. Fall back to ${CLAUDE_PROJECT_DIR} if not in a git repo.
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  repo_root="${CLAUDE_PROJECT_DIR:-}"
fi
if [[ -z "${repo_root}" || ! -d "${repo_root}" ]]; then
  exit 0
fi

cfg="${repo_root}/.lsa.yaml"
state="${repo_root}/.lsa-sync-state.json"

[[ -f "${cfg}" ]] || exit 0
[[ -f "${state}" ]] || exit 0

cd "${repo_root}" || exit 0

# Parse .lsa.yaml.  Prefer yq; fall back to a constrained awk parser that
# understands the documented modules.<name>.artifact_paths schema from
# vision/specs/2026-05-20-lsa-v0.2.0-design.md §6.
#
# Emits "name<TAB>path" rows on stdout, one row per (module, artifact_path) pair.
emit_module_paths() {
  if command -v yq >/dev/null 2>&1; then
    yq -r '
      .modules // {} | to_entries[] |
      .key as $m |
      (.value.artifact_paths // [])[] |
      "\($m)\t\(.)"
    ' "${cfg}" 2>/dev/null
    return
  fi

  awk '
    BEGIN { in_modules = 0; in_paths = 0; modname = "" }
    /^modules:[[:space:]]*$/ { in_modules = 1; next }
    in_modules && /^[^[:space:]]/ { in_modules = 0; in_paths = 0; modname = "" }
    in_modules && /^  [^[:space:]][^:]*:[[:space:]]*$/ {
      line = $0
      sub(/^  /, "", line)
      sub(/:[[:space:]]*$/, "", line)
      modname = line
      in_paths = 0
      next
    }
    in_modules && /^    artifact_paths:[[:space:]]*$/ { in_paths = 1; next }
    in_modules && in_paths && /^      - / {
      p = $0
      sub(/^      - /, "", p)
      gsub(/^"|"$|^'\''|'\''$/, "", p)
      if (modname != "" && p != "") print modname "\t" p
      next
    }
    in_modules && in_paths && /^    [^ ]/ { in_paths = 0 }
  ' "${cfg}"
}

# Parse .lsa-sync-state.json.  Prefer jq; fall back to a tolerant grep/sed pair.
sha_for_module() {
  local module="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg m "${module}" '.modules[$m].last_sync_sha // empty' "${state}" 2>/dev/null
    return
  fi
  python3 - "${module}" "${state}" <<'PY' 2>/dev/null || true
import json, sys
m, path = sys.argv[1], sys.argv[2]
try:
  with open(path) as f:
    data = json.load(f)
  print(data.get("modules", {}).get(m, {}).get("last_sync_sha", ""))
except Exception:
  print("")
PY
}

declare -A drift_modules=()

while IFS=$'\t' read -r module path; do
  [[ -z "${module}" || -z "${path}" ]] && continue
  sha="$(sha_for_module "${module}")"
  [[ -z "${sha}" ]] && continue
  # Use --quiet exit code (1 = drift, 0 = clean, 128 = bad ref → silent skip).
  if ! git diff --quiet "${sha}" -- "${path}" 2>/dev/null; then
    # Distinguish "drift" (exit 1) from "ref unreachable" (exit 128) where possible.
    rc=$?
    if [[ "${rc}" -eq 1 ]]; then
      drift_modules["${module}"]=1
    fi
  fi
done < <(emit_module_paths)

if [[ "${#drift_modules[@]}" -gt 0 ]]; then
  # Sort the module names for stable output.
  names="$(printf '%s\n' "${!drift_modules[@]}" | sort | paste -sd, -)"
  echo "LSA: drift detected in modules [${names}] — run /lsa:reconcile to absorb."
fi

exit 0
