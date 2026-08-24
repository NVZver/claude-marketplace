#!/usr/bin/env bash
# lsa/scripts/seed-canonical-paths.sh — derives a starting `rag:
# canonical_paths:` block for a TARGET repo's own .lsa.yaml, sourced from
# that repo's own `modules.*.artifact_paths` (generic-canonical-config
# epic, R5).
#
# Usage: lsa/scripts/seed-canonical-paths.sh <target-repo-path>
#
# Companion to lsa/docker/rag_cli.py's `load_canonical_paths_config`, which
# reads the block this script writes. A minimal, dependency-free, awk-based
# line parser keyed on indentation — the same style precedent
# scripts/lint.sh's C18 check already applies to the `libs:` block — no real
# YAML library, matching this repo's established minimal-dependency
# convention.
#
# Derivation rule (R5, "one entry per unique top-level path segment before
# the first wildcard"): for each `artifact_paths:` glob entry,
#   - no "*" at all           -> kept as the whole literal path, unchanged
#                                 (e.g. "core/CLAUDE.md" -> "core/CLAUDE.md")
#   - "*" present, has a "/"  -> reduced to the segment up to and including
#                                 the first "/" (e.g. "lsa/skills/**/SKILL.md"
#                                 -> "lsa/")
#   - "*" present, no "/"     -> a bare top-level glob with no directory to
#                                 derive (e.g. "*.md") -- dropped, not guessed
# Deduplicated (sort -u).
#
# Merge, not overwrite (R5): any EXISTING `rag: canonical_paths:` entries in
# the target's .lsa.yaml are read first and always kept — a human-added
# entry is never removed just because it isn't derivable from
# artifact_paths. Newly-derived entries are unioned in, capped at 40 total
# (R6, same cap lsa/docker/rag_cli.py's load_canonical_paths_config
# enforces); if the union would exceed the cap, every existing entry is
# still kept and only as many new entries as fit are added, with a one-line
# stderr notice naming how many were dropped.
#
# Writes ONLY <target-repo-path>/.lsa.yaml — never this plugin's own repo,
# regardless of what target path is given (that guardrail is the caller's
# responsibility to point this at an actual target, not this script's).

set -uo pipefail
export LC_ALL=C

CANONICAL_PATHS_CAP=40

TARGET_REPO="${1:-}"
if [[ -z "${TARGET_REPO}" ]]; then
  printf 'Usage: %s <target-repo-path>\n' "$0" >&2
  exit 1
fi

TARGET_YAML="${TARGET_REPO%/}/.lsa.yaml"
if [[ ! -f "${TARGET_YAML}" ]]; then
  printf 'ERROR: %s not found\n' "${TARGET_YAML}" >&2
  exit 1
fi

# --- Step 1: raw artifact_paths glob entries from every module ------------
# awk state machine, indentation-keyed (2-space core:/lsa:/... under
# modules:, 4-space artifact_paths: under each module, 6-space "- entry"
# list items) — mirrors scripts/lint.sh's C18 libs: block parser.
raw_globs="$(awk '
  /^modules:[[:space:]]*$/ { inmodules=1; inpaths=0; next }
  inmodules && /^[^[:space:]#]/ { inmodules=0; inpaths=0 }
  inmodules && inpaths && /^      - / {
    entry=$0
    sub(/^      - /, "", entry)
    gsub(/[[:space:]]+$/, "", entry)
    print entry
    next
  }
  inmodules && inpaths { inpaths=0 }
  inmodules && !inpaths && /^    artifact_paths:[[:space:]]*$/ { inpaths=1; next }
' "${TARGET_YAML}")"

# --- Step 2: reduce each glob to its top-level path segment (R5) ----------
derived_sorted="$(printf '%s\n' "${raw_globs}" | awk '
  NF == 0 { next }
  {
    entry = $0
    if (index(entry, "*") == 0) {
      print entry
      next
    }
    slash = index(entry, "/")
    if (slash > 0) {
      print substr(entry, 1, slash)
    }
    # else: bare top-level glob, no directory segment to derive -- dropped.
  }
' | sort -u)"

# --- Step 3: existing rag: canonical_paths: entries, preserved verbatim ---
# Same awk shape as Step 1, keyed on rag:/canonical_paths: instead of
# modules:/artifact_paths: — matches lsa/docker/rag_cli.py's
# load_canonical_paths_config exactly (2-space rag:, 4-space
# canonical_paths:, 4-space "- entry" list items).
existing_raw="$(awk '
  /^rag:[[:space:]]*$/ { inrag=1; incanon=0; next }
  inrag && /^[^[:space:]#]/ { inrag=0; incanon=0 }
  inrag && incanon && /^    - / {
    entry=$0
    sub(/^    - /, "", entry)
    gsub(/[[:space:]]+$/, "", entry)
    print entry
    next
  }
  inrag && incanon { incanon=0 }
  inrag && !incanon && /^  canonical_paths:[[:space:]]*$/ { incanon=1; next }
' "${TARGET_YAML}")"

# Preserve original file order, deduped, for the part of the final block
# that came from the human (minimizes diff noise on repeat runs).
existing_ordered="$(printf '%s\n' "${existing_raw}" | awk 'NF>0 && !seen[$0]++')"
existing_sorted="$(printf '%s\n' "${existing_ordered}" | sort -u)"

# --- Step 4: union — existing wins, cap at 40 (R6) -------------------------
if [[ -z "${existing_sorted}" ]]; then
  new_only="${derived_sorted}"
else
  new_only="$(comm -23 <(printf '%s\n' "${derived_sorted}") <(printf '%s\n' "${existing_sorted}"))"
fi
new_only="$(printf '%s\n' "${new_only}" | awk 'NF>0')"

existing_count=0
if [[ -n "${existing_ordered}" ]]; then
  existing_count="$(printf '%s\n' "${existing_ordered}" | wc -l | tr -d ' ')"
fi
new_count=0
if [[ -n "${new_only}" ]]; then
  new_count="$(printf '%s\n' "${new_only}" | wc -l | tr -d ' ')"
fi

room=$(( CANONICAL_PATHS_CAP - existing_count ))
if [[ "${room}" -lt 0 ]]; then
  room=0
fi

added=""
dropped_count=0
if [[ "${new_count}" -gt 0 ]]; then
  if [[ "${room}" -gt 0 ]]; then
    added="$(printf '%s\n' "${new_only}" | head -n "${room}")"
  fi
  if [[ "${new_count}" -gt "${room}" ]]; then
    dropped_count=$(( new_count - room ))
  fi
fi

if [[ "${dropped_count}" -gt 0 ]]; then
  printf 'NOTICE: %s newly-derived canonical_paths entries dropped -- the %s-entry cap already holds %s existing entries (see requirements.md R6).\n' \
    "${dropped_count}" "${CANONICAL_PATHS_CAP}" "${existing_count}" >&2
fi

final_entries="$(printf '%s\n%s\n' "${existing_ordered}" "${added}" | awk 'NF>0')"

if [[ -z "${final_entries}" ]]; then
  printf 'NOTICE: no modules.*.artifact_paths entries found and no existing rag: canonical_paths: block -- nothing to seed, %s left unchanged.\n' "${TARGET_YAML}" >&2
  exit 0
fi

# --- Step 5: build the new block, splice it into the target .lsa.yaml -----
new_block="rag:
  canonical_paths:"
while IFS= read -r entry; do
  [[ -n "${entry}" ]] || continue
  new_block="${new_block}
    - ${entry}"
done <<< "${final_entries}"

# Shared splice_yaml_block() — was a structurally-identical implementation
# duplicated in this script and lsa/scripts/bootstrap-rag.sh's
# append_gate_entries; extracted during a PR review pass. Sourced relative
# to this script's own location.
lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${lib_dir}/lib/yaml-block-splice.sh"

action="$(splice_yaml_block "${TARGET_YAML}" "rag" "${new_block}")" || {
  printf 'ERROR: failed to write %s\n' "${TARGET_YAML}" >&2
  exit 1
}
entry_count="$(printf '%s\n' "${final_entries}" | awk 'NF>0' | wc -l | tr -d ' ')"
if [[ "${action}" == "replaced" ]]; then
  printf 'Replaced existing rag: canonical_paths: block in %s (%s entries).\n' "${TARGET_YAML}" "${entry_count}" >&2
else
  printf 'Appended new rag: canonical_paths: block to %s (%s entries).\n' "${TARGET_YAML}" "${entry_count}" >&2
fi

exit 0
