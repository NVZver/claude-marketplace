#!/usr/bin/env bash
# scripts/lint.sh — repo-internal invariant lint for the NVZver claude-marketplace.
#
# Enforces the repo's "write each fact once, cite everywhere else" rule
# mechanically. These checks are the executable form of grep recipes already
# documented (in prose) at:
#   - core/tests/repo-anchored.md            §"D2" (output-discipline drift)
#   - prompt-engineer/tests/repo-anchored.md §"A2" (actor ground-rules single def)
# This script is the source of truth for the *executable* checks.
#
# Repo-internal only — NOT shipped in any plugin (the checks reference this
# repo's own files by path). Lives outside every plugin's artifact_paths in
# .lsa.yaml, so it triggers no plugin version bump or CHANGELOG entry.
#
# Exit 0 = all invariants hold. Exit 1 = at least one violation.

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

CANON="core/skills/output/SKILL.md"
fail=0

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

echo "=== marketplace invariant lint ==="

# ---------------------------------------------------------------------------
# C1 — output-discipline rule COUNT is stated only in the canonical file.
# A literal "(N golden rules)" anywhere else goes stale when the count changes.
# ---------------------------------------------------------------------------
hits="$(grep -rEn '\([0-9]+ (format )?golden rules' --include='*.md' \
  --exclude-dir=archive --exclude-dir=plans --exclude-dir=pitches --exclude-dir=.git \
  --exclude=CHANGELOG.md . 2>/dev/null \
  | grep -v "^\./${CANON}:" || true)"
if [[ -z "${hits}" ]]; then
  pass_line "C1 rule-count stated only in ${CANON}"
else
  fail_line "C1 rule-count restated outside ${CANON}:"
  printf '%s\n' "${hits}" | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C2 — output-discipline rule NAME LIST is stated only in the canonical file.
# A hit is allowed when the line also cites the canonical file (a re-grounding)
# or carries the full canonical enumeration (…, concrete). The test doc that
# describes this recipe is exempt — it is allowed to name what it catches.
# ---------------------------------------------------------------------------
raw="$(grep -rEn 'structured[ ,/]+minimal[ ,/]+formatted[ ,/]+sourced' --include='*.md' \
  --exclude-dir=archive --exclude-dir=plans --exclude-dir=pitches --exclude-dir=.git \
  --exclude=CHANGELOG.md . 2>/dev/null || true)"
viol="$(printf '%s\n' "${raw}" \
  | grep -v '^$' \
  | grep -v "^\./${CANON}:" \
  | grep -v '^\./core/tests/repo-anchored\.md:' \
  | grep -vE 'skills/output/SKILL\.md' \
  | grep -vE 'structured[ ,/]+minimal[ ,/]+formatted[ ,/]+sourced[ ,/]+concrete' \
  || true)"
if [[ -z "${viol}" ]]; then
  pass_line "C2 rule-name list stated only in ${CANON} (or cited)"
else
  fail_line "C2 rule-name list restated outside ${CANON}:"
  printf '%s\n' "${viol}" | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C3 — the prompt-engineer actor ground-rules list is defined once, in a
# knowledge file. A copy under agents/ or commands/ is a Knowledge-in-Actor
# boundary violation (the repo's highest-severity defect).
# ---------------------------------------------------------------------------
needle='Declare: Goal, Input, Steps, Output'
leak="$(grep -rn "${needle}" prompt-engineer/agents prompt-engineer/commands 2>/dev/null || true)"
canon_hit="$(grep -rn "${needle}" prompt-engineer/knowledge 2>/dev/null || true)"
if [[ -n "${leak}" ]]; then
  fail_line "C3 actor ground-rules list leaked into an Actor body:"
  printf '%s\n' "${leak}" | sed 's/^/        /'
elif [[ -z "${canon_hit}" ]]; then
  fail_line "C3 actor ground-rules list missing from prompt-engineer/knowledge (moved/renamed?)"
else
  pass_line "C3 actor ground-rules list defined once in prompt-engineer/knowledge"
fi

# Plugin dirs that ship Actors (SKILL.md + agents). Kept as a single list so C4
# and C5 scan the same surface. A literal `find` over these avoids globbing
# surprises and is bash 3.2 (macOS) safe.
PLUGIN_DIRS="core lsa helper manager prompt-engineer observer"

# ---------------------------------------------------------------------------
# C4 — every Actor file (*/skills/**/SKILL.md and */agents/*.md) carries the
# load-time trace directive near the top. The directive (`> **Trace.** On load,
# print first:`) is what makes a skill/agent announce which file is driving the
# turn — a transparency invariant. It sits just below frontmatter, so we scan
# the first 30 lines (the widest real offset today is line 17 — a multi-line
# `description:` agent). Missing it is reported, not auto-fixed: SKILL.md /
# agent bodies are out of this repo-internal script's edit scope.
# ---------------------------------------------------------------------------
trace_needle='> \*\*Trace\.\*\* On load, print first:'
c4_missing=""
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  if ! head -n 30 "${f}" 2>/dev/null | grep -qE "${trace_needle}"; then
    c4_missing="${c4_missing}${f}"$'\n'
  fi
done < <(
  for d in ${PLUGIN_DIRS}; do
    find "${d}" -type f \( -path '*/skills/*/SKILL.md' -o -path '*/agents/*.md' \) 2>/dev/null
  done | sort
)
if [[ -z "${c4_missing}" ]]; then
  pass_line "C4 trace directive present in every SKILL.md and agents/*.md"
else
  fail_line "C4 trace directive missing from:"
  printf '%s' "${c4_missing}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C5 — every plugin agent (*/agents/*.md) declares a `tools:` line in its YAML
# frontmatter (least-privilege visibility: a reader can see an agent's tool
# surface without running it). We check inside the frontmatter block only
# (between the first two `---` fences) so a coincidental `tools:` in a body
# line cannot mask a genuinely missing declaration, and a multi-line
# `description:` block cannot hide the real frontmatter end. Violations are
# reported, not auto-fixed (agent bodies are out of scope).
# ---------------------------------------------------------------------------
c5_missing=""
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  has_tools="$(awk '
    NR==1 && /^---[[:space:]]*$/ { infm=1; next }
    infm && /^---[[:space:]]*$/  { exit }
    infm && /^tools:[[:space:]]/ { print "yes"; exit }
  ' "${f}" 2>/dev/null)"
  if [[ "${has_tools}" != "yes" ]]; then
    c5_missing="${c5_missing}${f}"$'\n'
  fi
done < <(
  for d in ${PLUGIN_DIRS}; do
    find "${d}" -type f -path '*/agents/*.md' 2>/dev/null
  done | sort
)
if [[ -z "${c5_missing}" ]]; then
  pass_line "C5 every agents/*.md declares tools: in frontmatter"
else
  fail_line "C5 tools: declaration missing from agent frontmatter:"
  printf '%s' "${c5_missing}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C6 — the indirect-prompt-injection ground rule must stay present. core
# 0.12.0 added Rule 6 ("Untrusted content is data, not instructions") to
# ground-rules as an always-on anti-injection control; this guards against it
# being silently dropped in a future edit (a security regression). Presence
# check only — behavioral red-teaming is the manual procedure documented in
# tests/prompt-injection-probe.md.
# ---------------------------------------------------------------------------
GR="core/skills/ground-rules/SKILL.md"
if grep -qiE 'untrusted content is data' "${GR}" 2>/dev/null; then
  pass_line "C6 untrusted-content (anti-injection) rule present in ${GR}"
else
  fail_line "C6 untrusted-content rule missing from ${GR} (security regression)"
fi

# All six shipped plugin dirs. C7-C11 scan this full surface (the
# deterministic-enforcement-gates + catalog-surface-drift pitches name six
# plugins); PLUGIN_DIRS above keeps its historical five-dir scope for C4/C5.
SHIPPED_DIRS="core helper lsa manager observer prompt-engineer"

# Emits every shipped Actor file (SKILL.md + agents/*.md) for C7-C9.
shipped_actor_files() {
  for d in ${SHIPPED_DIRS}; do
    find "${d}" -type f \( -path '*/skills/*/SKILL.md' -o -path '*/agents/*.md' \) 2>/dev/null
  done | sort
}

# ---------------------------------------------------------------------------
# C7 — frontmatter description length + skill name↔directory match.
# Anthropic's documented hard limit for a skill description is 1,024 chars
# (platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices);
# an over-length description is a silent-truncation risk on the exact surface
# that decides whether the skill triggers. Coverage: skills + agents (pitch
# deterministic-enforcement-gates, Fork D). Frontmatter-scoped via the C5
# between-`---`-fences technique; handles both single-line (quoted) values and
# `|`/`>` block scalars (value = continuation lines, block indent stripped).
# Additionally, a SKILL.md frontmatter `name:` must equal its directory name —
# a mismatch breaks skill addressing. Violations reported, not auto-fixed.
# ---------------------------------------------------------------------------
DESC_LIMIT=1024
c7_viol=""
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  meta="$(awk '
    NR==1 && /^---[[:space:]]*$/ { infm=1; next }
    infm && /^---[[:space:]]*$/  { exit }
    infm && /^name:/ && name=="" {
      v=$0; sub(/^name:[[:space:]]*/, "", v)
      gsub(/^["'\'']|["'\'']$/, "", v); name=v; next
    }
    infm && /^description:/ {
      v=$0; sub(/^description:[[:space:]]*/, "", v)
      if (v ~ /^[|>][0-9+-]{0,2}[[:space:]]*$/) { indesc=1; dlen=0; next }
      if (v ~ /^".*"$/ || v ~ /^'\''.*'\''$/) v=substr(v, 2, length(v)-2)
      dlen=length(v); next
    }
    infm && indesc {
      if ($0 ~ /^[A-Za-z_-]+:/) { indesc=0; next }
      line=$0
      if (ind==0 && line ~ /[^[:space:]]/) { t=line; sub(/[^ ].*$/, "", t); ind=length(t) }
      if (ind>0) line=substr(line, ind+1)
      dlen += length(line) + 1
      next
    }
    END { printf "%d\t%s\n", dlen, name }
  ' "${f}" 2>/dev/null)"
  dlen="${meta%%$'\t'*}"
  fname="${meta#*$'\t'}"
  if [[ "${dlen:-0}" -gt "${DESC_LIMIT}" ]]; then
    c7_viol="${c7_viol}${f}: description ${dlen} chars > ${DESC_LIMIT}"$'\n'
  fi
  if [[ "${f}" == */skills/*/SKILL.md ]]; then
    dir="$(basename "$(dirname "${f}")")"
    if [[ "${fname}" != "${dir}" ]]; then
      c7_viol="${c7_viol}${f}: frontmatter name '${fname:-<missing>}' != directory '${dir}'"$'\n'
    fi
  fi
done < <(shipped_actor_files)
if [[ -z "${c7_viol}" ]]; then
  pass_line "C7 every shipped SKILL.md/agent description ≤ ${DESC_LIMIT} chars; skill name: matches its directory"
else
  fail_line "C7 frontmatter description/name violations:"
  printf '%s' "${c7_viol}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C8 — no hardcoded model pin in shipped Actor frontmatter. The marketplace
# must run 100% on Claude Pro; .lsa/standards/code.md calls a hardcoded model
# "a hard error, not a fallback". Frontmatter-only scope (pitch Fork B): a
# repo-wide grep would false-trip on the standard documenting the ban and on
# CHANGELOG history, so we scan only between the `---` fences of shipped
# skill/agent files (C5 technique). An optional surrounding quote is tolerated
# so `model: "opus"` cannot slip past.
# ---------------------------------------------------------------------------
c8_viol=""
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  hit="$(awk '
    NR==1 && /^---[[:space:]]*$/ { infm=1; next }
    infm && /^---[[:space:]]*$/  { exit }
    infm && /^model:/ { v=tolower($0); if (v ~ /(opus|haiku|fable)/) { print NR ": " $0; exit } }
  ' "${f}" 2>/dev/null)"
  if [[ -n "${hit}" ]]; then
    c8_viol="${c8_viol}${f}:${hit}"$'\n'
  fi
done < <(shipped_actor_files)
if [[ -z "${c8_viol}" ]]; then
  pass_line "C8 no hardcoded model pin (opus/haiku/fable) in shipped Actor frontmatter"
else
  fail_line "C8 hardcoded model pin in frontmatter (Pro-plan-breaking):"
  printf '%s' "${c8_viol}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C9 — 500-line cap on the BODY (lines after the closing ---) of every shipped
# SKILL.md and agents/*.md. Hard-fail (pitch Fork A): nothing shipped is near
# the cap (~190 max at decision time), and a warn-that-never-fails is itself
# tech debt. A file with no frontmatter counts every line as body.
# ---------------------------------------------------------------------------
BODY_LIMIT=500
c9_viol=""
while IFS= read -r f; do
  [[ -z "${f}" ]] && continue
  body_lines="$(awk '
    NR==1 && /^---[[:space:]]*$/ { infm=1; next }
    infm && /^---[[:space:]]*$/  { infm=0; next }
    infm { next }
    { n++ }
    END { print n+0 }
  ' "${f}" 2>/dev/null)"
  if [[ "${body_lines:-0}" -gt "${BODY_LIMIT}" ]]; then
    c9_viol="${c9_viol}${f}: body ${body_lines} lines > ${BODY_LIMIT}"$'\n'
  fi
done < <(shipped_actor_files)
if [[ -z "${c9_viol}" ]]; then
  pass_line "C9 every shipped SKILL.md/agent body ≤ ${BODY_LIMIT} lines"
else
  fail_line "C9 Actor body over the ${BODY_LIMIT}-line cap:"
  printf '%s' "${c9_viol}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C10 — knowledge/index.md integrity (pitch catalog-surface-drift, Fork 1:
# pure integer count + file existence, no fuzzy matching). Two sub-checks:
#   (a) the "## Catalog — N knowledge files" header count equals the on-disk
#       count of */knowledge/*.md across the six shipped plugins;
#   (b) every `](../<plugin>/knowledge/...)` link in the index resolves to an
#       existing file (a dangling row breaks navigation silently).
# ---------------------------------------------------------------------------
KIDX="knowledge/index.md"
c10_viol=""
if [[ ! -f "${KIDX}" ]]; then
  c10_viol="${KIDX}: file missing"$'\n'
else
  header_n="$(grep -E '^## Catalog' "${KIDX}" 2>/dev/null | grep -oE '[0-9]+' | head -n 1 || true)"
  disk_n="$(for d in ${SHIPPED_DIRS}; do
    find "${d}/knowledge" -type f -name '*.md' 2>/dev/null
  done | grep -c . || true)"
  if [[ -z "${header_n}" ]]; then
    c10_viol="${c10_viol}${KIDX}: no '## Catalog — N knowledge files' header found"$'\n'
  elif [[ "${header_n}" -ne "${disk_n}" ]]; then
    c10_viol="${c10_viol}${KIDX}: header says ${header_n} knowledge files; on disk: ${disk_n}"$'\n'
  fi
  while IFS= read -r rel; do
    [[ -z "${rel}" ]] && continue
    if [[ ! -f "${rel}" ]]; then
      c10_viol="${c10_viol}${KIDX}: dangling link ../${rel}"$'\n'
    fi
  done < <(grep -oE '\]\(\.\./[A-Za-z0-9_-]+/knowledge/[^)#]*' "${KIDX}" 2>/dev/null \
    | sed 's|^](\.\./||' | sort -u || true)
fi
if [[ -z "${c10_viol}" ]]; then
  pass_line "C10 ${KIDX} header count matches on-disk knowledge files and every index link resolves"
else
  fail_line "C10 ${KIDX} integrity violations:"
  printf '%s' "${c10_viol}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C11 — VERIFICATION.md version-scope matches plugin.json. A VERIFICATION file
# that declares "Scope: vX.Y" must match the major.minor of its plugin's
# manifest version, so probe scope can't silently go stale (pitch
# eval-coverage-tracks-complexity: "the version-scope lint makes the drift a
# gate finding, not a manual catch"). Adoptable incrementally: plugins whose
# VERIFICATION.md has no Scope line (or no VERIFICATION.md) are skipped.
# ---------------------------------------------------------------------------
c11_viol=""
c11_checked=0
for d in ${SHIPPED_DIRS}; do
  vf="${d}/VERIFICATION.md"
  [[ -f "${vf}" ]] || continue
  scope="$(grep -m1 -oE 'Scope: v[0-9]+\.[0-9]+' "${vf}" 2>/dev/null | sed 's/^Scope: v//' || true)"
  [[ -n "${scope}" ]] || continue
  c11_checked=$((c11_checked + 1))
  pj="${d}/.claude-plugin/plugin.json"
  ver="$(grep -m1 '"version"' "${pj}" 2>/dev/null \
    | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([0-9]+\.[0-9]+)\.[0-9][^"]*".*/\1/' || true)"
  if [[ -z "${ver}" || "${ver}" == *'"version"'* ]]; then
    c11_viol="${c11_viol}${pj}: could not parse a SemVer version"$'\n'
  elif [[ "${scope}" != "${ver}" ]]; then
    c11_viol="${c11_viol}${vf}: Scope: v${scope} != plugin.json ${ver}.x"$'\n'
  fi
done
if [[ -z "${c11_viol}" ]]; then
  pass_line "C11 every VERIFICATION.md Scope line matches its plugin.json major.minor (${c11_checked} checked)"
else
  fail_line "C11 VERIFICATION.md version-scope drift:"
  printf '%s' "${c11_viol}" | grep -v '^$' | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C12 — constitution digest exists and is fresh. .lsa/VISION-digest.md is
# generated by scripts/build-vision-digest.sh from .lsa/VISION.md and embeds a
# source-sha256 of its input. The LSA read protocol reads the digest as the
# mandatory constitution read (lsa/knowledge/conventions.md §"Read protocol"
# step 2), so a stale digest silently feeds every LSA skill an outdated
# constitution. FAIL names the stale digest and the regeneration command.
# ---------------------------------------------------------------------------
DIGEST=".lsa/VISION-digest.md"
VISION=".lsa/VISION.md"
if [[ ! -f "${DIGEST}" ]]; then
  fail_line "C12 constitution digest missing: ${DIGEST} — generate it: bash scripts/build-vision-digest.sh"
else
  embedded="$(grep -m1 -oE 'source-sha256: [0-9a-f]{64}' "${DIGEST}" 2>/dev/null | awk '{print $2}' || true)"
  current="$(shasum -a 256 "${VISION}" 2>/dev/null | awk '{print $1}' || true)"
  if [[ -z "${embedded}" ]]; then
    fail_line "C12 ${DIGEST} carries no source-sha256 marker — regenerate: bash scripts/build-vision-digest.sh"
  elif [[ "${embedded}" != "${current}" ]]; then
    fail_line "C12 stale constitution digest: ${DIGEST} was built from a different ${VISION} (embedded sha256 ${embedded} != current ${current}) — regenerate: bash scripts/build-vision-digest.sh"
  else
    pass_line "C12 ${DIGEST} source-sha256 matches current ${VISION}"
  fi
fi

# ---------------------------------------------------------------------------
# C13 — project-map.yaml token budget. The pitch (pro-tier-token-affordability,
# WS2 + rabbit-hole 2) caps the script-generated map at 1k tokens — an
# unbudgeted map is the next context-killer. Enforced here, not advisory, using
# the chars/4 token heuristic (1024 tokens ≈ 4096 chars). Freshness is a
# separate gate (lsa/scripts/project-map-check.sh); this checks size only.
# Repo-internal: the shipped plugin carries the freshness check, not this cap.
# ---------------------------------------------------------------------------
PMAP="project-map.yaml"
PMAP_CHAR_LIMIT=4096
if [[ ! -f "${PMAP}" ]]; then
  pass_line "C13 no ${PMAP} to size (skipped)"
else
  pm_chars="$(wc -c < "${PMAP}" | tr -d ' ')"
  pm_tokens=$(( pm_chars / 4 ))
  if [[ "${pm_chars}" -gt "${PMAP_CHAR_LIMIT}" ]]; then
    fail_line "C13 ${PMAP} over budget: ~${pm_tokens} tokens (${pm_chars} chars > ${PMAP_CHAR_LIMIT}) — a map, not a catalog; keep it to directories (bash lsa/scripts/project-map-build.sh)"
  else
    pass_line "C13 ${PMAP} within 1k-token budget (~${pm_tokens} tokens)"
  fi
fi

# ---------------------------------------------------------------------------
# C14 — roadmap.yaml schema gate (pitch yaml-ledger-selective-load, F11). The
# roadmap ledger is now YAML; a malformed file or an item missing a required key
# would silently break every read-consumer's slice. This validates structure
# deterministically (pure awk — no yq/python): the file must carry `version:` +
# `items:`, and every item must have a non-empty slug + title, a priority in
# {Must,Should,Could}, and a status in {backlog,not_started,in_progress,shipped,
# deferred}. Absent ledger is skipped (the read scripts fall through per F8).
# Repo-internal: this ledger is outside every plugin's artifact_paths.
# ---------------------------------------------------------------------------
RMAP=".lsa/roadmap.yaml"
if [[ ! -f "${RMAP}" ]]; then
  pass_line "C14 no ${RMAP} to validate (skipped)"
else
  c14_viol="$(awk '
    function chk(){
      if(slug==""){ return }
      if(title=="")               print "  item @ line " sline " (slug " slug "): missing/empty title"
      if(prio!="Must"&&prio!="Should"&&prio!="Could") print "  item @ line " sline " (slug " slug "): priority \x27" prio "\x27 not in Must|Should|Could"
      if(status!="backlog"&&status!="not_started"&&status!="in_progress"&&status!="shipped"&&status!="deferred") \
                                  print "  item @ line " sline " (slug " slug "): status \x27" status "\x27 not in the F4 enum"
    }
    /^version:/                   { hasver=1 }
    /^items:[[:space:]]*$/        { initems=1; hasitems=1; next }
    initems && /^[^[:space:]#]/   { chk(); slug=""; initems=0 }
    !initems                      { next }
    /^  - slug: /                 { chk(); slug=$0; sub(/^  - slug: /,"",slug); sline=FNR; title="";prio="";status=""; blk=""; nitems++; next }
    /^    title: \|[[:space:]]*$/ { blk="title"; next }
    /^    priority: /             { prio=$0; sub(/^    priority: /,"",prio); blk=""; next }
    /^    status: /               { status=$0; sub(/^    status: /,"",status); blk=""; next }
    /^      / { if(blk=="title"){ t=$0; sub(/^      /,"",t); if(title=="")title=t } next }
    /^    [a-z_]+: / { blk=""; next }
    END{
      chk()
      if(!hasver)   print "  file: missing top-level version: key"
      if(!hasitems) print "  file: missing top-level items: key"
      if(nitems==0) print "  file: no items entries found"
    }
  ' "${RMAP}" 2>/dev/null)"
  if [[ -z "${c14_viol}" ]]; then
    pass_line "C14 ${RMAP} well-formed: every item has slug/title + valid priority + valid status"
  else
    fail_line "C14 ${RMAP} schema violations:"
    printf '%s\n' "${c14_viol}" | sed 's/^/      /'
  fi
fi

# ---------------------------------------------------------------------------
# C15 — the "deterministic work is scripted" principle must stay present on
# both surfaces. Vision v0.13 added §2 principle 10 and a one-line pointer on
# the core always-on card (core 0.19.0); this guards against either being
# silently dropped in a future edit (a doctrine regression). Presence check
# only — detecting whether a *new* skill reintroduced inline determinism is a
# judgment, not a grep, and stays with reconcile / human review.
# ---------------------------------------------------------------------------
DW_MARKER='Deterministic work is scripted'
DW_VISION=".lsa/VISION.md"
DW_CARD="core/CLAUDE.md"
if grep -qiF "${DW_MARKER}" "${DW_VISION}" 2>/dev/null; then
  pass_line "C15 deterministic-work-is-scripted principle present in ${DW_VISION}"
else
  fail_line "C15 deterministic-work-is-scripted principle missing from ${DW_VISION} (§2 principle 10 dropped)"
fi
if grep -qiF "${DW_MARKER}" "${DW_CARD}" 2>/dev/null; then
  pass_line "C15 deterministic-work-is-scripted pointer present in ${DW_CARD}"
else
  fail_line "C15 deterministic-work-is-scripted pointer missing from ${DW_CARD} (always-on card no longer references principle 10)"
fi

# ---------------------------------------------------------------------------
# C16 — the always-on discipline text must live in exactly one file. AGENTS.md
# (0.21.0) is canonical; CLAUDE.md holds an @AGENTS.md import, never a copy.
# This anti-duplication gate is the mitigation named in the
# standards-conformance-agents-md pitch's rabbit hole 1: "if the chosen wiring
# cannot be gated by a script, it is the wrong wiring." Excludes .lsa/** (spec/
# pitch prose quotes the marker by design), this script (defines the marker),
# and CHANGELOG.md files (frozen history).
# ---------------------------------------------------------------------------
DISCIPLINE_MARKER='The always-on card lives at'
DISCIPLINE_HOME='AGENTS.md'
c16_hits="$(git grep -lIF --untracked "${DISCIPLINE_MARKER}" -- ':(exclude).lsa/**' ':(exclude)scripts/lint.sh' ':(exclude)**/CHANGELOG.md' 2>/dev/null | sort)"
c16_count="$(printf '%s' "${c16_hits}" | grep -c . || true)"
if [[ "${c16_count}" -eq 1 && "${c16_hits}" == "${DISCIPLINE_HOME}" ]]; then
  pass_line "C16 discipline text present in exactly one file (${DISCIPLINE_HOME})"
elif [[ "${c16_count}" -eq 0 ]]; then
  fail_line "C16 discipline marker missing from ${DISCIPLINE_HOME}"
else
  fail_line "C16 discipline text duplicated — found in:"
  printf '%s\n' "${c16_hits}" | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C17 — the reconcile metrics-emit step must stay present. `lsa` 0.16.0
# silently removed the `.lsa/metrics.md` writer as refactor collateral and
# nothing caught it (restore-tracked-metrics-harvest pitch, rabbit hole 2);
# the metrics layer was rebuilt in epic reconcile-emit-guard specifically to
# not die the same way twice. This guards the two literal markers that prove
# the emit step is still wired into lsa/skills/reconcile/SKILL.md — the
# script name that performs the harvest and the file it appends to.
# Presence check only — verifying the emit step actually RAN on a given
# cycle is reconcile's own job, not a grep (mirrors the C15 comment above).
# ---------------------------------------------------------------------------
METRICS_SKILL="lsa/skills/reconcile/SKILL.md"
METRICS_SCRIPT_MARKER='scripts/metrics-harvest.sh'
METRICS_FILE_MARKER='.lsa/metrics.md'
if grep -qF "${METRICS_SCRIPT_MARKER}" "${METRICS_SKILL}" 2>/dev/null; then
  pass_line "C17 metrics-harvest emit step present in ${METRICS_SKILL} (${METRICS_SCRIPT_MARKER})"
else
  fail_line "C17 metrics-harvest emit step missing from ${METRICS_SKILL} (metrics writer dropped again — see lsa 0.16.0)"
fi
if grep -qF "${METRICS_FILE_MARKER}" "${METRICS_SKILL}" 2>/dev/null; then
  pass_line "C17 metrics-harvest emit step present in ${METRICS_SKILL} (${METRICS_FILE_MARKER})"
else
  fail_line "C17 metrics-harvest emit step missing from ${METRICS_SKILL} (metrics writer dropped again — see lsa 0.16.0)"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "All invariants hold."
  exit 0
fi
echo "Invariant violations found — see FAIL lines above."
exit 1
