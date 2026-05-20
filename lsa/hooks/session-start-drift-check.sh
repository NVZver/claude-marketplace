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

# Plain (non-associative) array — bash 3.2 ships on macOS and has no `declare -A`.
# De-dup is done inline before each append.
drift_modules=()

while IFS=$'\t' read -r module path; do
  [[ -z "${module}" || -z "${path}" ]] && continue
  sha="$(sha_for_module "${module}")"
  [[ -z "${sha}" ]] && continue
  # Run --quiet and consume its exit code via `|| rc=$?`. Two reasons:
  #   1. Capture the actual exit code (0 = clean, 1 = drift, >=128 = bad ref).
  #   2. The trailing `||` keeps `git diff` in a tested-exit context, so the
  #      `trap ... ERR` above does NOT fire on the expected rc=1 (drift) case.
  rc=0
  git diff --quiet "${sha}" -- "${path}" 2>/dev/null || rc=$?
  if [[ "${rc}" -eq 1 ]]; then
    # De-dup: skip append if module is already in the array.
    already=0
    if [[ "${#drift_modules[@]}" -gt 0 ]]; then
      for existing in "${drift_modules[@]}"; do
        if [[ "${existing}" == "${module}" ]]; then
          already=1
          break
        fi
      done
    fi
    [[ "${already}" -eq 0 ]] && drift_modules+=("${module}")
  fi
done < <(emit_module_paths)

if [[ "${#drift_modules[@]}" -gt 0 ]]; then
  # sort -u for stable, dedup output (belt-and-braces; inner loop already dedups).
  names="$(printf '%s\n' "${drift_modules[@]}" | sort -u | paste -sd, -)"
  echo "LSA: drift detected in modules [${names}] — run /lsa:reconcile to absorb."
fi

exit 0
