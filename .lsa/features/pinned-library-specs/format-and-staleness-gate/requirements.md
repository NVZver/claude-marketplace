# Pinned library specs — file format, `libs:` registration, and the staleness gate

## Summary

Give a repo a place to register 3-5 version-pinned library specs and a deterministic
script that says, on every `lsa:verify`, whether each pin is still true. Three outcomes
only: **fresh** (exit 0), **stale** (exit 1), **`[cannot verify]`** (exit 2) — never a
silent green. A C-series lint check caps the registry at 5.

- Source: `.lsa/pitches/pinned-library-specs.md` (approved 2026-07-19) — Fork 2 (`libs:`
  block, keys `spec` + `manifest`), Fork 3 (`gate:` script only), Fork 4 (no new skill),
  rabbit hole 2 (hard cap), rabbit hole 3 (one-screen cap), rabbit hole 4 (lockfile or
  `[cannot verify]`).
- Applies: `.lsa/VISION.md` §2 principle 10 (deterministic work is scripted), principle 1
  (a fast wrong answer is a defect).
- Target surface: `.lsa.yaml` (new `libs:` block + new `gate:` entry), new
  `scripts/check-lib-pins.sh`, new `scripts/tests/check-lib-pins-test.sh`, new C18 in
  `scripts/lint.sh`, new `lsa/knowledge/pinned-library-specs.md`, `knowledge/index.md`,
  `lsa/ARCHITECTURE.md` §3.
- Style precedent: `scripts/gate.sh` (the `awk` block-extraction technique for reading a
  `.lsa.yaml` block — copy it), `scripts/coverage-skeleton.sh`, `scripts/resolve-refs.sh`
  (repo-internal bash, zero model calls, `set -uo pipefail`, bash 3.2-safe).

## User Flows

1. **Register a pin.** A human adds an entry under `libs:` in `.lsa.yaml` naming the
   pinned spec file and the manifest it is checked against, and commits the pinned spec
   file itself under `${specs_root}/libs/`.
2. **Verify (every session, zero model calls).** `lsa:verify` Step 4 runs the `.lsa.yaml`
   `gate:` block via `bash scripts/gate.sh`. The new `lib-pins` check runs
   `scripts/check-lib-pins.sh`, which prints one line per registered lib and exits 0 / 1 / 2.
   A non-zero exit blocks the GROUNDED verdict (`lsa/skills/verify/SKILL.md:42`).
3. **Hit the cap.** A sixth `libs:` entry is added. `bash scripts/lint.sh` FAILs on C18 and
   the whole gate goes red until the entry is removed or the cap is deliberately edited.

## Functional requirements (EARS)

- R1. Pinned-spec file format.** A pinned library spec SHALL be a markdown file at
  `${specs_root}/libs/<lib-name>.md` (this repo: `.lsa/libs/<lib-name>.md`). Its first 20
  lines SHALL contain a metadata block of literal `- <Key>: <value>` lines with these keys:
  - `- Pinned-Version: <literal version string>` — REQUIRED.
  - `- Manifest: <repo-root-relative path>` — REQUIRED; MAY be the literal `none`.
  - `- Lockfile: <repo-root-relative path>` — REQUIRED; MAY be the literal `none`.
  - `- Lockfile-Assertion: <literal substring>` — REQUIRED when `Lockfile` is not `none`;
    omitted otherwise. The substring that must appear verbatim in the lockfile while the
    pin holds (e.g. `"stripe": "18.5.0"`).
  `[ASSUMPTION]` The metadata-block shape (markdown list, these four key names, first-20-line
  window) is designed here — the pitch mandates only "a version assertion and a pointer to
  the manifest/lockfile entry", and no precedent for this schema exists in the repo.
  `[ASSUMPTION]` A literal substring (`Lockfile-Assertion`) rather than a parsed version
  field is chosen so the check is lockfile-format-agnostic and needs no `jq`/`yq`/python —
  consistent with `scripts/gate.sh`'s pure-`awk` posture.

- R2. One-screen cap.** A pinned spec file SHALL be ≤ **60 lines** total (the literal
  definition of "roughly one screen", rabbit hole 3) and SHALL cover only symbols the repo
  actually calls. `[ASSUMPTION]` 60 is chosen as the literal line number; the pitch says
  only "roughly one screen". This requirement is documentation-enforced in R8, not
  script-enforced — R2 is a convention the author applies, and epic 2's R6 asserts it for
  the first pin.

- R3. `libs:` block in `.lsa.yaml`.** `.lsa.yaml` SHALL gain a new top-level `libs:` block,
  sibling to `modules:`, whose entries carry exactly two keys:
  ```yaml
  libs:
    <lib-name>:
      spec: <repo-root-relative path to the pinned spec>
      manifest: <repo-root-relative path, or the literal `none`>
  ```
  It SHALL NOT reuse `modules:` and SHALL NOT declare `artifact_paths` — an external
  dependency has no in-repo artifact globs, which is why this is a new block (Fork 2).

- R4. The staleness script.** `scripts/check-lib-pins.sh` SHALL exist, take no arguments,
  read the `libs:` block from `.lsa.yaml` using the same `awk` block-extraction technique as
  `scripts/gate.sh:47-63` (nested one level deeper), and for each registered lib print
  exactly one status line to stdout:
  - `  OK          <lib> <pinned-version> — assertion found in <lockfile>`
  - `  STALE       <lib> pinned <pinned-version> — assertion not found in <lockfile>`
  - `  [cannot verify]  <lib> pinned <pinned-version> — no lockfile (<reason>)`
  - `  BROKEN      <lib> — <reason>` (spec file missing, or `Pinned-Version:` absent, or
    `Lockfile-Assertion:` absent while `Lockfile:` is not `none`)

- R5. Exit codes (literal, no other values).** `scripts/check-lib-pins.sh` SHALL exit:
  - **0** — every registered lib is `OK`, **or** `libs:` is absent/empty (nothing to check).
  - **1** — at least one lib is `STALE` or `BROKEN`. Precedence: 1 outranks 2.
  - **2** — no lib is `STALE`/`BROKEN` and at least one is `[cannot verify]`.
  It SHALL NEVER exit 0 when any lib is `[cannot verify]`. An unknown is reported as an
  unknown and blocks — never as a pass (rabbit hole 4).

- R6. The three resolution paths (literal decision order, per lib).**
  1. `spec` path does not exist → `BROKEN`.
  2. `Pinned-Version:` absent from the spec's first 20 lines → `BROKEN`.
  3. `Lockfile:` is the literal `none`, **or** the named lockfile path does not exist →
     `[cannot verify]` (reason: `Lockfile: none` / `lockfile not found: <path>`).
  4. `Lockfile:` names an existing file but `Lockfile-Assertion:` is absent → `BROKEN`.
  5. Lockfile exists and contains `Lockfile-Assertion` verbatim (`grep -qF`) → `OK`.
  6. Lockfile exists and does not contain it → `STALE`.
  The `manifest:` value SHALL NOT be used to decide freshness — a manifest range like
  `^4.0.0` lets the installed version drift while a naive check reads green (rabbit hole 4).
  It is recorded for the human and MAY be echoed in the status line only.

- R7. Gate registration.** `.lsa.yaml`'s `gate:` block SHALL gain
  `lib-pins: bash scripts/check-lib-pins.sh`. Consequence, stated so it is not a surprise:
  `scripts/gate.sh` treats any non-zero exit as FAIL, and `lsa/skills/verify/SKILL.md:42`
  makes a non-zero gate check block the GROUNDED verdict — so a stale **or** unverifiable
  pin turns the repo gate red. That is the intended enforcement (Fork 3), not a defect.

- R8. Knowledge file.** `lsa/knowledge/pinned-library-specs.md` SHALL be created and
  SHALL document: the R1 file format with a worked example; the R2 ≤60-line cap and the
  cover-only-what-you-call rule; the R3 `libs:` schema; the R5 exit codes; the 5-lib cap
  (R9); and the human-review-before-commit promotion boundary (pitch rabbit hole 5 — fetched
  content enters as untrusted data per `SECURITY.md` and is promoted by a person, never by
  an agent). It SHALL NOT describe read precedence — that is epic 3's surface.

- R9. C18 lint check.** `scripts/lint.sh` SHALL gain a check numbered **C18**, appended
  after C15, following the file's existing comment-banner + `pass_line`/`fail_line` shape.
  It SHALL count the entries under the `.lsa.yaml` `libs:` block and:
  - `pass_line` when the count is ≤ 5 (including 0, and including "no `libs:` block");
  - `fail_line` when the count is > 5, naming the count and the cap.
  C16 and C17 are reserved by `standards-conformance-agents-md` and
  `restore-tracked-metrics-harvest/reconcile-emit-guard` respectively; C18 SHALL NOT reuse
  either number even if those epics have not merged yet.

- R10. Test.** `scripts/tests/check-lib-pins-test.sh` SHALL exist (picked up automatically
  by `scripts/run-tests.sh`) and SHALL cover all three paths using hermetic fixtures in a
  `mktemp -d` sandbox — a fresh pin exits 0, a mismatched assertion exits 1, and a
  `Lockfile: none` pin exits 2 and prints `[cannot verify]` — plus one `BROKEN` case
  (missing spec file) exiting 1, and the empty/absent-`libs:` case exiting 0.
  `[ASSUMPTION]` The sandbox approach (fixture `.lsa.yaml` + fixture spec/lockfile under a
  temp root, script invoked with that root as cwd) mirrors the hermetic style
  `scripts/tests/` already uses; the script must therefore resolve its root via
  `git rev-parse --show-toplevel || pwd` exactly as `scripts/gate.sh:27-29` does, so a
  non-git temp dir falls back to `pwd`.

- R11. Documentation.** `lsa/ARCHITECTURE.md` §3 SHALL document the `libs:` block in the
  schema listing and add a bullet describing it, alongside the existing `modules:` / `gate:`
  bullets. The same section's SessionStart-hook paragraph SHALL state that the drift hook
  covers `modules:` only and that pin staleness is surfaced by the `gate:` check, not the
  hook. `[ASSUMPTION]` Not extending the SessionStart hook is a scope decision: the pitch's
  Fork 3 locks "a `gate:` script only".

- R12. Versioning.** `lsa/knowledge/pinned-library-specs.md` falls inside the `lsa` module's
  `artifact_paths` (`lsa/knowledge/**/*.md`) and `lsa/ARCHITECTURE.md` is listed explicitly,
  so `lsa` SHALL bump **0.28.1 → 0.29.0** (MINOR — new documented capability) with a
  `lsa/CHANGELOG.md` entry and an `lsa/README.md` note, in the same commit.
  `knowledge/index.md` SHALL be updated: the `## Catalog — 20 knowledge files` header becomes
  `21`, and a row is added for the new file (else C10 FAILs). `scripts/*.sh` and
  `scripts/tests/*.sh` are repo-internal, outside every `artifact_paths` — they drive no bump.
  `[ASSUMPTION]` If another epic bumps `lsa` first, take the next unused MINOR instead.

- R13. Gate green.** `bash scripts/gate.sh` SHALL exit 0 after this epic, with `libs:`
  present but **empty** (`libs: {}`). This epic registers no library — epic 2 registers the
  first one and knowingly turns the gate red (epic 2 R7).

## Out of Scope

- Registering any actual library (epic 2).
- Any change to read precedence or `lsa/knowledge/conventions.md` (epic 3).
- Auto-refresh, auto-re-pin, crawlers, registries, multi-version support (pitch no-gos 1, 3, 5).
- Extending the SessionStart drift hook (R11).
