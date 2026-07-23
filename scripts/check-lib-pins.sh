#!/usr/bin/env bash
# scripts/check-lib-pins.sh — deterministic staleness check for pinned library
# specs registered under the .lsa.yaml `libs:` block.
#
# Three outcomes only, never a silent green: OK (exit 0), STALE/BROKEN (exit 1),
# [cannot verify] (exit 2). A lockfile assertion missing is reported as unknown
# and BLOCKS — never treated as a pass (pitch pinned-library-specs, rabbit
# hole 4). The `manifest:` value is informational only and never decides
# freshness — a manifest range (e.g. `^4.0.0`) lets the installed version drift
# while a naive manifest-only check would read green.
#
# Style precedent: scripts/gate.sh's awk block-extraction technique, nested one
# level deeper to read `libs:` → `<lib-name>:` → `spec:`/`manifest:`.
#
# Repo-internal — NOT shipped in any plugin; lives outside every plugin's
# artifact_paths, so it triggers no plugin version bump or CHANGELOG entry.
#
# Usage: check-lib-pins.sh   (no arguments)

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

CFG=".lsa.yaml"

if [[ ! -f "${CFG}" ]]; then
  # No config at all — nothing to check.
  exit 0
fi

# Extract lib names + their `spec:`/`manifest:` values from the `libs:` block.
# One line per lib: "<lib-name>\t<spec-path>\t<manifest-path>".
libs="$(awk '
  /^libs:[[:space:]]*$/ { inlibs=1; next }
  inlibs && /^[^[:space:]#]/ { inlibs=0 }
  inlibs && /^[[:space:]]{2}[A-Za-z0-9_-]+:[[:space:]]*$/ {
    if (name != "") { print name "\t" spec "\t" manifest }
    l=$0; sub(/^[[:space:]]+/,"",l); sub(/:.*/,"",l); name=l; spec=""; manifest=""
    next
  }
  inlibs && /^[[:space:]]{4}spec:/ {
    v=$0; sub(/^[[:space:]]*spec:[[:space:]]*/,"",v); spec=v; next
  }
  inlibs && /^[[:space:]]{4}manifest:/ {
    v=$0; sub(/^[[:space:]]*manifest:[[:space:]]*/,"",v); manifest=v; next
  }
  END { if (name != "") print name "\t" spec "\t" manifest }
' "${CFG}")"

if [[ -z "${libs}" ]]; then
  # libs: absent or empty — nothing to check.
  exit 0
fi

any_stale_or_broken=0
any_unverifiable=0

while IFS=$'\t' read -r lib spec manifest; do
  [[ -z "${lib}" ]] && continue

  if [[ ! -f "${spec}" ]]; then
    printf '  BROKEN      %s — spec file not found: %s\n' "${lib}" "${spec}"
    any_stale_or_broken=1
    continue
  fi

  # Pinned-Version:, Lockfile:, Lockfile-Assertion: from the spec's first 20 lines.
  meta="$(head -n 20 "${spec}" | awk '
    /^- Pinned-Version:/ { v=$0; sub(/^- Pinned-Version:[[:space:]]*/,"",v); pv=v }
    /^- Lockfile-Assertion:/ { v=$0; sub(/^- Lockfile-Assertion:[[:space:]]*/,"",v); la=v; la_seen=1 }
    /^- Lockfile:/ { v=$0; sub(/^- Lockfile:[[:space:]]*/,"",v); lf=v }
    END { printf "%s\t%s\t%s\t%s\n", pv, lf, la, (la_seen ? "1" : "0") }
  ')"
  pinned_version="$(printf '%s' "${meta}" | cut -f1)"
  lockfile="$(printf '%s' "${meta}" | cut -f2)"
  assertion="$(printf '%s' "${meta}" | cut -f3)"
  assertion_seen="$(printf '%s' "${meta}" | cut -f4)"

  if [[ -z "${pinned_version}" ]]; then
    printf '  BROKEN      %s — Pinned-Version: absent from %s\n' "${lib}" "${spec}"
    any_stale_or_broken=1
    continue
  fi

  if [[ -z "${lockfile}" || "${lockfile}" == "none" ]]; then
    printf '  [cannot verify]  %s pinned %s — no lockfile (Lockfile: none)\n' "${lib}" "${pinned_version}"
    any_unverifiable=1
    continue
  fi

  if [[ ! -f "${lockfile}" ]]; then
    printf '  [cannot verify]  %s pinned %s — no lockfile (lockfile not found: %s)\n' "${lib}" "${pinned_version}" "${lockfile}"
    any_unverifiable=1
    continue
  fi

  if [[ "${assertion_seen}" != "1" || -z "${assertion}" ]]; then
    printf '  BROKEN      %s — Lockfile-Assertion: absent while Lockfile: %s is set\n' "${lib}" "${lockfile}"
    any_stale_or_broken=1
    continue
  fi

  if grep -qF -- "${assertion}" "${lockfile}"; then
    printf '  OK          %s %s — assertion found in %s\n' "${lib}" "${pinned_version}" "${lockfile}"
  else
    printf '  STALE       %s pinned %s — assertion not found in %s\n' "${lib}" "${pinned_version}" "${lockfile}"
    any_stale_or_broken=1
  fi
done <<< "${libs}"

# Precedence: STALE/BROKEN (1) outranks [cannot verify] (2) outranks OK (0).
if [[ "${any_stale_or_broken}" -eq 1 ]]; then
  exit 1
elif [[ "${any_unverifiable}" -eq 1 ]]; then
  exit 2
else
  exit 0
fi
