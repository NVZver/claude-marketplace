#!/usr/bin/env bash
# scripts/check-citations.sh — deterministic path:line citation checker.
#
# The repo's fact-grounding rule (core/ground-rules Rule 1) says every claim
# carries a source. A large share of those sources are `path:line` citations
# (e.g. `core/skills/output/SKILL.md:13`). This script mechanically confirms,
# for every such citation in a tracked *.md file, that the path exists and the
# cited line number is within the file's line count.
#
# MECHANICAL ONLY. It does NOT verify that the quoted text still lives at that
# line (verbatim quote-match is fragile — an insertion above shifts every line;
# that stays a human/LLM judgement, explicitly out of scope). A green run here
# means "the citation still points at a real line", not "the quote is intact".
#
# Scope + exemptions (false-positive control, mirroring scripts/lint.sh):
#   - Only tracked *.md files (`git ls-files '*.md'`).
#   - Excluded surfaces (point-in-time records, not live references):
#       * every CHANGELOG.md (frozen Keep-a-Changelog history — lint.sh excludes
#         it too: scripts/lint.sh line 38 `--exclude=CHANGELOG.md`)
#       * the .lsa/ spec+archive tree (living-spec drafts, per-feature specs,
#         research, observations, dated design docs — their citations are frozen
#         at authoring time; lint.sh already excludes archive/plans/pitches).
#       * tests/ docs (repo-anchored test fixtures cite illustrative before/after
#         paths + line numbers by design; lint.sh line 59 exempts them too).
#     The gate therefore guards the maintained, shipped plugin surface + the
#     top-level project docs (README/CONTRIBUTING/CLAUDE).
#   - Fenced code blocks (```…```) and lines carrying an [illustrative] /
#     [unverified] marker are skipped: citations there are examples, not real
#     references (mirrors the repo's reference-discipline marker convention).
#   - A citation path is resolved repo-root-relative, then relative to the
#     citing file's plugin root (its first path segment), then relative to the
#     citing file's own directory; only if none exists is it a violation.
#   - External URLs and ${var}-templated paths are not treated as citations.
#
# Repo-internal only — NOT shipped in any plugin (references this repo's own
# files). Lives outside every plugin's artifact_paths in .lsa.yaml, so it
# triggers no plugin version bump or CHANGELOG entry.
#
# Exit 0 = every citation resolves. Exit 1 = at least one broken citation.

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi

# A citation token: a path ending in a .ext, then ':' then a line-spec
# (a number, optionally a ,/-separated list like 18-23 or 40,45).
CITE_RE='[A-Za-z0-9_./-]+\.[A-Za-z0-9]+:[0-9][0-9,-]*'

violations=0
checked=0

# Cache of file -> line count (bash 3.2: parallel-ish via a temp var per call).
line_count() { wc -l < "$1" 2>/dev/null | tr -d ' '; }

while IFS= read -r md; do
  [[ -z "${md}" ]] && continue
  [[ -f "${md}" ]] || continue
  md_dir="$(dirname "${md}")"
  plugin_root="${md%%/*}"          # first path segment (e.g. prompt-engineer)

  # Blank out fenced code-block lines while preserving line numbers, then
  # grep -n for citation tokens so the reported line is the real .md line.
  while IFS= read -r hit; do
    [[ -z "${hit}" ]] && continue
    src_line="${hit%%:*}"          # grep -n prefix
    tok="${hit#*:}"                # path.ext:linespec (path has no other colon)
    linespec="${tok##*:}"          # trailing number/list
    cpath="${tok%:*}"              # everything before the last colon

    # Skip URL leftovers (`//`), ${var}-templated paths (matched tail begins
    # with `/`, e.g. `${specs_root}/roadmap.md`), and absolute-looking paths.
    case "${cpath}" in
      *//*) continue ;;
      /*)   continue ;;
    esac

    checked=$((checked + 1))

    # Resolve: repo-root, then plugin-root, then citing-file-relative.
    target=""
    if [[ -f "${cpath}" ]]; then
      target="${cpath}"
    elif [[ -f "${plugin_root}/${cpath}" ]]; then
      target="${plugin_root}/${cpath}"
    elif [[ -f "${md_dir}/${cpath}" ]]; then
      target="${md_dir}/${cpath}"
    fi

    if [[ -z "${target}" ]]; then
      printf '  %sVIOLATION%s %s:%s → path not found: %s\n' \
        "${RED}" "${OFF}" "${md}" "${src_line}" "${cpath}"
      violations=$((violations + 1))
      continue
    fi

    total="$(line_count "${target}")"
    [[ -n "${total}" ]] || total=0

    # Validate every integer in the line-spec (splitting on , and -).
    bad=""
    for n in $(printf '%s' "${linespec}" | tr ',-' '  '); do
      [[ -z "${n}" ]] && continue
      if [[ "${n}" -gt "${total}" || "${n}" -lt 1 ]]; then
        bad="${bad}${n} "
      fi
    done
    if [[ -n "${bad}" ]]; then
      printf '  %sVIOLATION%s %s:%s → %s has %s lines, cited line(s): %s\n' \
        "${RED}" "${OFF}" "${md}" "${src_line}" "${target}" "${total}" "${bad% }"
      violations=$((violations + 1))
    fi
  done < <(
    awk '
      /^[[:space:]]*```/                { fence = !fence; print ""; next }
      fence                             { print ""; next }
      /\[illustrative\]|\[unverified\]/ { print ""; next }
                                        { print }
    ' "${md}" | grep -noE "${CITE_RE}" 2>/dev/null || true
  )
done < <(git ls-files '*.md' | grep -vE '(^|/)CHANGELOG\.md$' | grep -vE '^\.lsa/' | grep -vE '(^|/)tests/')

echo
if [[ "${violations}" -eq 0 ]]; then
  printf '%sOK%s  %s citation(s) checked, all resolve.\n' "${GREEN}" "${OFF}" "${checked}"
  exit 0
fi
printf '%sFAIL%s %s broken citation(s) of %s checked — see VIOLATION lines above.\n' \
  "${RED}" "${OFF}" "${violations}" "${checked}"
exit 1
