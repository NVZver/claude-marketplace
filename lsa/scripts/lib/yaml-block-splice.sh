# lsa/scripts/lib/yaml-block-splice.sh — shared "find a top-level block by
# name, replace it (or append a new one if absent) with given text"
# mechanism. Sourced (not executed) by lsa/scripts/seed-canonical-paths.sh
# and lsa/scripts/bootstrap-rag.sh — extracted from two structurally
# identical implementations found during a PR review pass.
#
# Pure mechanism only: each caller still owns its own business logic for
# what the new block's content should be (union computation, missing-key
# detection, etc.) — this function only splices already-decided text into
# the file. Matches this repo's own established 2-space-per-level .lsa.yaml
# indentation convention by construction, since the caller supplies the
# fully-formed block text verbatim.
#
# Usage: splice_yaml_block <file> <top-level-key> <new-block-text>
#   <new-block-text> is the FULL block, starting with "<key>:" itself
#   (e.g. $'rag:\n  canonical_paths:\n    - a\n    - b').
#   Prints "replaced" or "appended" to stdout (for the caller's own
#   messaging) on success; returns 1 without printing on a write failure.
splice_yaml_block() {
  local file="$1" key="$2" new_block="$3"
  local start_line end_line total_lines tmp_file

  start_line="$(grep -n "^${key}:[[:space:]]*\$" "${file}" | head -n 1 | cut -d: -f1 || true)"

  if [[ -z "${start_line}" ]]; then
    # No existing block with this key — append a new one at EOF.
    tmp_file="$(mktemp "${file}.XXXXXX")" || return 1
    { cat "${file}"; printf '\n%s\n' "${new_block}"; } >"${tmp_file}" || { rm -f "${tmp_file}"; return 1; }
    mv "${tmp_file}" "${file}" || return 1
    echo "appended"
    return 0
  fi

  total_lines="$(wc -l < "${file}" | tr -d ' ')"
  end_line="$(awk -v start="${start_line}" '
    NR > start && /^[^[:space:]#]/ { print NR; exit }
  ' "${file}")"
  [[ -n "${end_line}" ]] || end_line=$(( total_lines + 1 ))

  tmp_file="$(mktemp "${file}.XXXXXX")" || return 1
  {
    if [[ "${start_line}" -gt 1 ]]; then
      sed -n "1,$(( start_line - 1 ))p" "${file}"
    fi
    printf '%s\n' "${new_block}"
    if [[ "${end_line}" -le "${total_lines}" ]]; then
      # Restore the blank-line section separator this repo's own .lsa.yaml
      # convention uses (e.g. between top-level blocks) — swallowed by
      # end_line's "first non-blank/non-comment line" definition above,
      # otherwise lost on every splice.
      printf '\n'
      sed -n "${end_line},\$p" "${file}"
    fi
  } >"${tmp_file}" || { rm -f "${tmp_file}"; return 1; }
  mv "${tmp_file}" "${file}" || return 1
  echo "replaced"
  return 0
}
