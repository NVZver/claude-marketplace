#!/usr/bin/env bash
# lsa/scripts/project-map-build.sh — deterministic 3-level repo project map.
#
# Emits project-map.yaml at the repo root: dirs + files for the first 3 path
# levels under the root (depth ≤ 3). Deeper paths truncate at level 3 as `dir`
# without children. STRUCTURAL ONLY — no model calls; same tracked tree ⇒
# byte-identical output.
#
# Skip: node_modules (any path segment). .git is never in git ls-files.
#
# Consumed by lsa:discover / conventions §"Read protocol". Freshness:
# lsa/scripts/project-map-check.sh (rebuild + porcelain must be clean).
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

leaves="$(mktemp)"
trap 'rm -f "${leaves}"' EXIT

# Records (tab-separated), one leaf per line — sorted unique:
#   file<TAB>p1
#   file<TAB>p1<TAB>p2
#   file<TAB>p1<TAB>p2<TAB>p3
#   dir<TAB>p1<TAB>p2<TAB>p3
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  [[ "${f}" == "project-map.yaml" ]] && continue
  # Skip index entries deleted in the working tree (not yet staged)
  [[ -e "${f}" || -L "${f}" ]] || continue
  case "/${f}/" in
    */node_modules/*) continue ;;
  esac

  rest="${f}"
  p1="${rest%%/*}"
  if [[ "${rest}" != */* ]]; then
    printf 'file\t%s\n' "${p1}"
    continue
  fi
  rest="${rest#*/}"
  p2="${rest%%/*}"
  if [[ "${rest}" != */* ]]; then
    printf 'file\t%s\t%s\n' "${p1}" "${p2}"
    continue
  fi
  rest="${rest#*/}"
  p3="${rest%%/*}"
  if [[ "${rest}" == */* ]]; then
    printf 'dir\t%s\t%s\t%s\n' "${p1}" "${p2}" "${p3}"
  else
    printf 'file\t%s\t%s\t%s\n' "${p1}" "${p2}" "${p3}"
  fi
done < <(git ls-files) | sort -u > "${leaves}"

# Top-level keys (files at depth 1 + dirs that have children)
tops="$(mktemp)"
trap 'rm -f "${leaves}" "${tops}"' EXIT
{
  awk -F '\t' 'NF==2 && $1=="file" { print $2 }
               NF>=3 { print $2 }' "${leaves}"
} | sort -u > "${tops}"

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
  printf 'version: 1\n'
  printf 'depth: %s\n' "${DEPTH}"
  printf 'tree:\n'

  while IFS= read -r top; do
    [[ -z "${top}" ]] && continue
    # Pure root file? (file\ttop with no deeper rows for top)
    if grep -qx "file	${top}" "${leaves}" \
      && ! awk -F '\t' -v t="${top}" 'NF>=3 && $2==t { found=1; exit } END { exit !found }' "${leaves}"; then
      printf '  %s: file\n' "$(yq_key "${top}")"
      continue
    fi

    printf '  %s:\n' "$(yq_key "${top}")"

    # Depth-2 keys under top
    d2="$(mktemp)"
    awk -F '\t' -v t="${top}" 'NF>=3 && $2==t { print $3 }' "${leaves}" | sort -u > "${d2}"
    while IFS= read -r mid; do
      [[ -z "${mid}" ]] && continue
      # Pure depth-2 file?
      if grep -qx "file	${top}	${mid}" "${leaves}" \
        && ! awk -F '\t' -v t="${top}" -v m="${mid}" 'NF==4 && $2==t && $3==m { found=1; exit } END { exit !found }' "${leaves}"; then
        printf '    %s: file\n' "$(yq_key "${mid}")"
        continue
      fi

      printf '    %s:\n' "$(yq_key "${mid}")"
      # Depth-3 leaves
      awk -F '\t' -v t="${top}" -v m="${mid}" 'NF==4 && $2==t && $3==m { print $1 "\t" $4 }' "${leaves}" \
        | sort -t $'\t' -k2,2 | while IFS=$'\t' read -r typ name; do
            [[ -z "${name}" ]] && continue
            printf '      %s: %s\n' "$(yq_key "${name}")" "${typ}"
          done
    done < "${d2}"
    rm -f "${d2}"
  done < "${tops}"
} > "${OUT}"

chars="$(wc -c < "${OUT}" | tr -d ' ')"
echo "OK: wrote ${OUT} (${chars} chars, depth ${DEPTH})"
