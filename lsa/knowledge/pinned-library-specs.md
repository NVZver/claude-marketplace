# Pinned library specs

A small, capped registry (≤ 5 entries) of version-pinned specs for the libraries this repo
calls most — the shrunk version of Tessl's proactive spec-cache idea (`.lsa/VISION.md` §6
"Adjust #2"). Not a general library-doc cache: a pinned spec is written once, for a symbol
this repo actually calls, and checked for staleness on every `lsa:verify` run.

## File format

A pinned library spec is a markdown file at `${specs_root}/libs/<lib-name>.md` (this repo:
`.lsa/libs/<lib-name>.md`). Its first 20 lines carry a metadata block of literal
`- <Key>: <value>` lines:

```
# stripe

- Pinned-Version: 18.5.0
- Manifest: package.json
- Lockfile: package-lock.json
- Lockfile-Assertion: "stripe": "18.5.0"

## Symbols this repo calls

stripe.charges.create(...) — ...
```

| Key | Required | Value |
|---|---|---|
| `Pinned-Version` | always | The literal version string this spec was written against. |
| `Manifest` | always | Repo-root-relative path to the manifest declaring the dependency (e.g. `package.json`), or the literal `none`. Informational — never used to decide freshness (a manifest range like `^4.0.0` lets the installed version drift while a naive manifest-only check reads green). |
| `Lockfile` | always | Repo-root-relative path to the lockfile pinning the exact installed version, or the literal `none` if there isn't one. |
| `Lockfile-Assertion` | when `Lockfile` is not `none` | The literal substring that must appear verbatim in the lockfile while the pin holds (e.g. `"stripe": "18.5.0"`). A substring match (`grep -qF`), not a parsed version field — lockfile-format-agnostic, no `jq`/`yq`/parser needed. |

**≤ 60 lines total** — roughly one screen — and cover only the symbols this repo actually
calls, not the library's full surface. This cap is documentation-enforced (an author
convention), not script-enforced.

## Registration (`.lsa.yaml`)

```yaml
libs:
  <lib-name>:
    spec: <repo-root-relative path to the pinned spec>
    manifest: <repo-root-relative path, or the literal `none`>
```

Sibling to `modules:`, but structurally different — no `artifact_paths`, since an external
dependency has no in-repo artifact globs to enumerate.

## The staleness gate

`scripts/check-lib-pins.sh` (wired into `.lsa.yaml`'s `gate:` block as `lib-pins`) runs on
every `lsa:verify`, zero model calls. For each registered lib it resolves, in order:

1. `spec` path doesn't exist → **BROKEN**.
2. `Pinned-Version:` absent from the spec's first 20 lines → **BROKEN**.
3. `Lockfile:` is `none`, or the named lockfile doesn't exist → **`[cannot verify]`**.
4. `Lockfile:` exists but `Lockfile-Assertion:` is absent → **BROKEN**.
5. Lockfile exists and contains the assertion verbatim → **OK**.
6. Lockfile exists and does not contain it → **STALE**.

Exit codes — three outcomes only, never a silent green:

- **0** — every lib is OK, or `libs:` is absent/empty.
- **1** — at least one lib is STALE or BROKEN (outranks 2).
- **2** — no STALE/BROKEN, but at least one is `[cannot verify]`.

A stale **or** unverifiable pin turns the repo gate red — `scripts/gate.sh` treats any
non-zero check as FAIL, and `lsa/skills/verify/SKILL.md` blocks the `GROUNDED` verdict on a
non-zero gate. That's the intended enforcement: an unknown is reported as an unknown and
blocks, never treated as a pass.

## Cap

`scripts/lint.sh` C18 fails the build if the `libs:` block exceeds **5 entries** — this stays
a small, curated set for the libraries that actually matter, not a general-purpose registry
(that's Tessl's product, not this one's — `.lsa/VISION.md` §6 "Adjust #2").

## Promotion boundary

Registering a new pin means fetching and reading real library documentation — that fetched
content is **untrusted data**, not instructions, per `SECURITY.md`'s indirect-prompt-injection
stance. A human reviews the pinned spec before it's committed; an agent never promotes a fetch
straight into `${specs_root}/libs/` unreviewed.
