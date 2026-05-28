#!/usr/bin/env bash
# LSA SessionStart hook — surface artifact drift at session start.
#
# Reads .lsa.yaml (module → spec + artifact_paths). For each module: resolves
# the baseline SHA as the last commit on the current branch that modified the
# module's spec file (via `git log -1 --format=%H -- <spec-path>`); diffs the
# working tree against that SHA across the module's artifact_paths; if any path
# differs, prints a one-line drift notice naming the modules. Exits 0 always —
# this is informational, must not block session start.
#
# No-op when:
#   - not in a git repo
#   - .lsa.yaml is absent (no opt-in)
#   - the module has no spec key (no baseline source)
#   - git log returns empty for the spec path (no commit yet — silent)
#   - the baseline SHA is unreachable (history rewrite — silent)

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

[[ -f "${cfg}" ]] || exit 0

cd "${repo_root}" || exit 0

# Parse .lsa.yaml.  Prefer yq; fall back to a constrained awk parser that
# understands the documented modules.<name>.{spec,artifact_paths} schema from
# .lsa/2026-05-20-lsa-v0.2.0-design.md §6.
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

# Emits "name<TAB>spec-path" rows on stdout — one row per module that declares
# a spec key. Mirrors emit_module_paths's yq + awk dual-path; same indentation
# contract (2-space module names under modules:, 4-space spec key).
emit_module_specs() {
  if command -v yq >/dev/null 2>&1; then
    yq -r '
      .modules // {} | to_entries[] |
      select(.value.spec) |
      "\(.key)\t\(.value.spec)"
    ' "${cfg}" 2>/dev/null
    return
  fi

  awk '
    BEGIN { in_modules = 0; modname = "" }
    /^modules:[[:space:]]*$/ { in_modules = 1; next }
    in_modules && /^[^[:space:]]/ { in_modules = 0; modname = "" }
    in_modules && /^  [^[:space:]][^:]*:[[:space:]]*$/ {
      line = $0
      sub(/^  /, "", line)
      sub(/:[[:space:]]*$/, "", line)
      modname = line
      next
    }
    in_modules && modname != "" && /^    spec:[[:space:]]*/ {
      s = $0
      sub(/^    spec:[[:space:]]*/, "", s)
      gsub(/^"|"$|^'\''|'\''$/, "", s)
      if (s != "") print modname "\t" s
    }
  ' "${cfg}"
}

# Plain (non-associative) array — bash 3.2 ships on macOS and has no `declare -A`.
# De-dup is done inline before each append.
drift_modules=()

# Build the module → spec-path map once, up front. One pass per file, no cache
# layer needed downstream.
spec_modules=()
spec_paths=()
while IFS=$'\t' read -r m s; do
  [[ -z "${m}" ]] && continue
  spec_modules+=("${m}")
  spec_paths+=("${s}")
done < <(emit_module_specs)

sha_for_module() {
  local module="$1"
  if [[ "${#spec_modules[@]}" -eq 0 ]]; then
    return
  fi
  local i=0
  for cached in "${spec_modules[@]}"; do
    if [[ "${cached}" == "${module}" ]]; then
      local spec="${spec_paths[${i}]}"
      [[ -n "${spec}" ]] && git log -1 --format=%H -- "${spec}" 2>/dev/null
      return
    fi
    i=$((i + 1))
  done
}

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
