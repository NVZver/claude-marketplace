#!/usr/bin/env bash
# scripts/build-vision-digest.sh — deterministic structural digest of the
# constitution.
#
# Extracts, STRUCTURALLY ONLY (verbatim lines picked by shape — no prose
# paraphrase, no model calls; same input → same output):
#   1. the `#`/`##` heading map of .lsa/VISION.md,
#   2. the two spine invariants (§1 "The two invariants — the spine"), and
#   3. the §2 first-principles list (bold titles only, sub-principles included)
# and writes them to .lsa/VISION-digest.md with a trace directive, a
# generated-do-not-edit banner, and an embedded source-sha256 of the input for
# staleness detection (scripts/lint.sh check C12 compares that hash against
# the current .lsa/VISION.md).
#
# The digest is the mandatory constitution read of the LSA read protocol
# (lsa/knowledge/conventions.md §"Read protocol" step 2); the full
# .lsa/VISION.md loads only for constitutional tasks. Never hand-edit the
# digest — rerun this script after any .lsa/VISION.md change.
#
# Repo-internal only — NOT shipped in any plugin. Lives outside every
# plugin's artifact_paths in .lsa.yaml, so it triggers no plugin version bump
# or CHANGELOG entry.
#
# Exit 0 = digest written. Exit 1 = source constitution missing.

set -euo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

SRC=".lsa/VISION.md"
OUT=".lsa/VISION-digest.md"

if [[ ! -f "${SRC}" ]]; then
  echo "ERROR: ${SRC} not found — nothing to digest." >&2
  exit 1
fi

src_sha="$(shasum -a 256 "${SRC}" | awk '{print $1}')"

{
  printf '> **Trace.** On load, print first: `=============== [.lsa/VISION-digest.md] [vision] ===============`\n'
  printf '<!-- GENERATED — DO NOT EDIT. Structural digest of .lsa/VISION.md built by scripts/build-vision-digest.sh; regenerate with: bash scripts/build-vision-digest.sh -->\n'
  printf '<!-- source-sha256: %s -->\n' "${src_sha}"
  printf '\n'

  printf '## Section map (`#`/`##` headings, verbatim)\n'
  grep -E '^#{1,2} ' "${SRC}" | sed 's/^/- /'
  printf '\n'

  printf '## The two spine invariants (§1, verbatim)\n'
  awk '/^\*\*The two invariants/ { f = 1; next }
       f && /^[0-9]+\. /        { print; next }
       f && /^\*\*/             { exit }' "${SRC}"
  printf '\n'

  printf '## §2 First principles (titles, verbatim)\n'
  awk '/^## 2\. First principles/ { s = 1; next }
       s && /^## /                { exit }
       s                          { print }' "${SRC}" \
    | grep -E '^([0-9]+\. \*\*|[[:space:]]+- \*\*[0-9]+[a-z]\.)' \
    | sed -E 's/^([0-9]+\. \*\*[^*]+\*\*).*/\1/; s/^[[:space:]]+(- \*\*[0-9]+[a-z]\.[^*]*\*\*).*/  \1/'
} > "${OUT}"

echo "OK: wrote ${OUT} ($(wc -l < "${OUT}" | tr -d ' ') lines) from ${SRC} (sha256 ${src_sha})"
