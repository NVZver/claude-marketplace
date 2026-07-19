#!/usr/bin/env bash
# scripts/check-links.sh — deterministic relative-file markdown link checker.
#
# READMEs and skills cross-link each other with relative markdown links
# (e.g. `[CORE.md](../../CORE.md)`). This script mechanically confirms, for
# every relative-file link `[text](path)` in a tracked *.md file, that the
# target file exists on disk (resolved relative to the linking file).
#
# Scope + exemptions (false-positive control, mirroring scripts/lint.sh):
#   - Only tracked *.md files (`git ls-files '*.md'`).
#   - Excluded surfaces (point-in-time records): every CHANGELOG.md (frozen
#     history — lint.sh excludes it too) and the .lsa/ spec+archive tree
#     (living-spec drafts, per-feature specs, research, observations, dated
#     designs) plus tests/ docs (illustrative fixtures — lint.sh exempts them).
#     The gate guards the maintained plugin surface + top-level docs.
#   - INCLUDED by name: .lsa/roadmap.yaml. It sits inside the excluded .lsa/
#     tree but is not a point-in-time record — it is the live ledger, and its
#     `Pitch: [slug](pitches/<slug>.md)` links are load-bearing navigation. It
#     is also the only tracked non-*.md file carrying markdown links, so the
#     `git ls-files '*.md'` glob alone never reached it: a dangling pitch link
#     sat unnoticed here until found by hand on 2026-07-19. Added by name
#     rather than by widening the .lsa/ filter, which would pull in ~157
#     frozen spec/archive files the exemption above exists to exclude.
#   - Fenced code blocks (```…```) and lines carrying an [illustrative] /
#     [unverified] marker are skipped: links there are examples.
#   - OUT OF SCOPE (skipped, not checked):
#       * external URLs (http://, https://, mailto:, other `scheme:` links)
#       * pure anchors (`#heading`), site-absolute (`/path`), protocol-relative
#         (`//host/…`), and ${var}/<placeholder> template targets
#     A `path#anchor` link has its `#…` fragment stripped and the file part
#     checked; the anchor target itself is NOT validated (out of scope).
#
# Repo-internal only — NOT shipped in any plugin. Lives outside every plugin's
# artifact_paths in .lsa.yaml, so it triggers no plugin bump or CHANGELOG entry.
#
# Exit 0 = every relative-file link resolves. Exit 1 = at least one dangling.

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi

# Markdown inline link target: the (...) after a ](  — captured group only.
LINK_RE='\]\(([^) ]+)'

violations=0
checked=0

while IFS= read -r md; do
  [[ -z "${md}" ]] && continue
  [[ -f "${md}" ]] || continue
  md_dir="$(dirname "${md}")"

  while IFS= read -r hit; do
    [[ -z "${hit}" ]] && continue
    src_line="${hit%%:*}"
    match="${hit#*:}"
    # Strip the leading `](` that grep -oE kept, leaving the raw target.
    raw="${match#*](}"

    # Strip any anchor fragment: `path#heading` -> `path` (anchor out of scope).
    filepart="${raw%%#*}"

    # Skip out-of-scope link kinds.
    [[ -z "${filepart}" ]] && continue            # pure #anchor
    case "${filepart}" in
      *://*) continue ;;                            # http://, https://, etc.
      mailto:*) continue ;;
      //*) continue ;;                              # protocol-relative
      /*) continue ;;                               # site-absolute
      \$*) continue ;;                              # ${var}-templated
      *:*) continue ;;                              # any other scheme:...
      *"<"*|*">"*) continue ;;                      # <placeholder> template
      "..."|path|path/*) continue ;;                # illustrative placeholders
    esac

    checked=$((checked + 1))

    # Resolve relative to the linking file's directory; -e allows dir targets.
    if [[ ! -e "${md_dir}/${filepart}" && ! -e "${filepart}" ]]; then
      printf '  %sVIOLATION%s %s:%s → dangling link target: %s\n' \
        "${RED}" "${OFF}" "${md}" "${src_line}" "${filepart}"
      violations=$((violations + 1))
    fi
  done < <(
    awk '
      /^[[:space:]]*```/                { fence = !fence; print ""; next }
      fence                             { print ""; next }
      /\[illustrative\]|\[unverified\]/ { print ""; next }
                                        { print }
    ' "${md}" | grep -noE "${LINK_RE}" 2>/dev/null || true
  )
done < <(
  {
    git ls-files '*.md' | grep -vE '(^|/)CHANGELOG\.md$' | grep -vE '^\.lsa/' | grep -vE '(^|/)tests/'
    # The live roadmap ledger — see "INCLUDED by name" in the header.
    git ls-files '.lsa/roadmap.yaml'
  }
)

echo
if [[ "${violations}" -eq 0 ]]; then
  printf '%sOK%s  %s relative-file link(s) checked, all resolve.\n' "${GREEN}" "${OFF}" "${checked}"
  exit 0
fi
printf '%sFAIL%s %s dangling link(s) of %s checked — see VIOLATION lines above.\n' \
  "${RED}" "${OFF}" "${violations}" "${checked}"
exit 1
