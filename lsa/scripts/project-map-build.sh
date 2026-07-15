#!/usr/bin/env bash
# lsa/scripts/project-map-build.sh — deterministic 3-level repo DIRECTORY map.
#
# Emits project-map.yaml at the repo root: the directory tree for the first 3
# path levels under the root (depth ≤ 3). DIRECTORIES ONLY — a navigational map,
# not a file catalog: it tells an agent where things live, then discovery reads
# the actual files under the chosen directory. Deeper dirs truncate at level 3.
# STRUCTURAL ONLY — no model calls; same tracked tree ⇒ byte-identical output.
#
# Skip: node_modules (any path segment). .git is never in git ls-files.
#
# Consumed by lsa:discover / conventions §"Read protocol". Freshness:
# lsa/scripts/project-map-check.sh (rebuild + porcelain must be clean).
# Size budget: scripts/lint.sh C13 (repo-internal) caps the map at 1k tokens.
#
# Shipped with the lsa plugin (artifact_paths: lsa/scripts/**/*.sh).
#
# Exit 0 = map written. Exit 1 = not inside a git work tree.
# bash 3.2 / macOS portable (no mapfile, no gawk asort).

set -euo pipefail
export LC_ALL=C

DEPTH=3
OUT="project-map.yaml"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  echo "ERROR: not inside a git work tree — cannot enumerate tracked files." >&2
  exit 1
fi
cd "${repo_root}" || exit 1

dirs="$(mktemp)"
trap 'rm -f "${dirs}"' EXIT

# One tab-separated record per ancestor directory of every tracked file, capped
# at 3 components (depth ≤ 3) — sorted unique:
#   p1
#   p1<TAB>p2
#   p1<TAB>p2<TAB>p3
# A root-level file (no directory) contributes nothing: this is a dir map.
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  [[ "${f}" == "project-map.yaml" ]] && continue
  # Skip index entries deleted in the working tree (not yet staged)
  [[ -e "${f}" || -L "${f}" ]] || continue
  case "/${f}/" in
    */node_modules/*) continue ;;
  esac
  [[ "${f}" == */* ]] || continue   # root file: no directory to record

  dir="${f%/*}"                      # strip filename → directory path
  p1="${dir%%/*}"; printf '%s\n' "${p1}"
  [[ "${dir}" == */* ]] || continue
  rest="${dir#*/}"; p2="${rest%%/*}"; printf '%s\t%s\n' "${p1}" "${p2}"
  [[ "${rest}" == */* ]] || continue
  rest="${rest#*/}"; p3="${rest%%/*}"; printf '%s\t%s\t%s\n' "${p1}" "${p2}" "${p3}"
done < <(git ls-files) | sort -u > "${dirs}"

yq_key() {
  # Quote YAML keys that are unsafe as bare keys
  local s="$1"
  if [[ "${s}" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]*$ ]]; then
    printf '%s' "${s}"
  else
    local t="${s//\\/\\\\}"
    t="${t//\"/\\\"}"
    printf '"%s"' "${t}"
  fi
}

{
  printf '# GENERATED — DO NOT EDIT. Regenerate: bash lsa/scripts/project-map-build.sh\n'
  printf 'version: 2\n'
  printf 'depth: %s\n' "${DEPTH}"
  printf 'tree:  # directories only (depth ≤ %s)\n' "${DEPTH}"

  # Render by exact parent match per level (collision-proof: a sibling like
  # ".claude-plugin" cannot capture ".claude"'s children).
  awk -F '\t' '{ print $1 }' "${dirs}" | sort -u | while IFS= read -r top; do
    [[ -z "${top}" ]] && continue
    printf '  %s:\n' "$(yq_key "${top}")"
    awk -F '\t' -v t="${top}" 'NF>=2 && $1==t { print $2 }' "${dirs}" | sort -u \
      | while IFS= read -r mid; do
          [[ -z "${mid}" ]] && continue
          printf '    %s:\n' "$(yq_key "${mid}")"
          awk -F '\t' -v t="${top}" -v m="${mid}" 'NF==3 && $1==t && $2==m { print $3 }' "${dirs}" | sort -u \
            | while IFS= read -r leaf; do
                [[ -z "${leaf}" ]] && continue
                printf '      %s:\n' "$(yq_key "${leaf}")"
              done
        done
  done
} > "${OUT}"

chars="$(wc -c < "${OUT}" | tr -d ' ')"
echo "OK: wrote ${OUT} (${chars} chars, depth ${DEPTH}, directories only)"
