# Dogfood pin — `actions/checkout`

## Summary

Author the repo's first (and, for now, only) pinned library spec: `actions/checkout`, the
one version-pinned external dependency this repo declares. It is used exactly once, at
`.github/workflows/lint.yml:12` (`      - uses: actions/checkout@v4`), with no `with:`
parameters. Because that line is a real in-repo file the pin can be asserted against, the
staleness check resolves `OK` and exits 0 — the gate can go **green**.

**Supersedes the pitch's Fork 1 gate decision.** The pitch named the Claude Code platform
surface as the dogfood target. That target is **cancelled by owner decision (2026-07-19)**:
the Claude Code platform has no manifest and no lockfile, so its staleness check would
resolve `[cannot verify]` and exit 2 permanently (epic 1 R5-R6). `.lsa.yaml`'s `gate:` block
turns any non-zero check into FAIL (`scripts/gate.sh:86`), and a non-zero `gate:` check
"BLOCKS the GROUNDED verdict" (`lsa/skills/verify/SKILL.md:42`) — so pinning the platform
would render **every** `lsa:verify` in this repo permanently NOT-GROUNDED. That is a
permanent blocker, not an honest unknown, and the owner re-targeted the pin rather than
accept it. Epic 1's rule that a genuine `[cannot verify]` still exits non-zero is
**unchanged** — it simply never fires for this pin.

**Honest caveat — this pin is weaker than a lockfile pin, and must say so.**
`actions/checkout@v4` is a **floating major tag**, not an exact version. GitHub moves the
`v4` tag as new `4.x` releases ship. So this pin detects only changes to **our own file** —
someone bumping the workflow to `@v5` (or `@v3`) without re-authoring the pinned spec. It
does **not** detect upstream releases within `v4`; the action's code can change completely
underneath us while the check reads green. This is exactly the failure mode the pitch's
rabbit hole 4 warns about — a `^4.0.0`-style range that "let[s] the installed version drift
inside the range while the check reads green." This pin has that property. A green
`lib-pins` line for `actions-checkout` means *"our declared pin still says v4"*, never
*"the dependency has not changed."* The pinned spec file must state this in its own body
(R5) so no future reader mistakes the green for upstream stability.

- Source: `.lsa/pitches/pinned-library-specs.md` Fork 1 (dogfood target — **superseded**, see
  above), rabbit hole 3 (one-screen cap), rabbit hole 4 (version-range false negatives),
  rabbit hole 5 (human review is the promotion boundary), rabbit hole 6 (no conventional
  dogfood target — **partially resolved**: one does exist, in `.github/`).
- Applies: `.lsa/VISION.md` §1 (dogfooding is non-negotiable DNA), §2 principle 1
  ("Trust is the product. A fast wrong answer is a defect"), principle 10 (deterministic
  work is scripted).
- Target surface: new `.lsa/libs/actions-checkout.md`, `.lsa.yaml` `libs:` block.
- Style precedent: `.lsa/modules/lsa/spec.md` (module-spec shape) — a pinned spec is a
  module spec pointed at an external dep (`.lsa/VISION.md` §6 Adjust item 2).
- Depends on: epic `format-and-staleness-gate` (`new`) — the `libs:` schema (its R3), the
  pinned-spec file format and metadata keys (its R1), `scripts/check-lib-pins.sh` and its
  resolution order and exit codes (its R4-R6), the ≤60-line cap (its R2), and
  `lsa/knowledge/pinned-library-specs.md` (its R8). Every format detail below is `new` and
  defined there; do not re-derive it.

## User Flows

1. **Author (one-off, human-driven).** The human names `actions/checkout`. The agent reads
   the single in-repo call site and drafts a pinned spec scoped to what that call site
   actually uses. The human reviews and commits it. No agent commits a pinned spec
   unreviewed (pitch rabbit hole 5).
2. **Verify — green.** `bash scripts/check-lib-pins.sh` finds `actions/checkout@v4`
   verbatim in `.github/workflows/lint.yml`, prints an `OK` line for `actions-checkout`,
   and exits 0. `scripts/gate.sh` reports PASS for `lib-pins`; `lsa:verify` is unaffected.
3. **Drift — red.** Someone bumps the workflow to `actions/checkout@v5` without re-authoring
   the pin. The assertion no longer appears in the file, the check prints `STALE` and exits
   1, the gate goes red, and `lsa:verify` yields NOT-GROUNDED until the human re-pins.

## Functional requirements (EARS)

- R1. The file. `.lsa/libs/actions-checkout.md` SHALL exist, in the format defined by epic 1
  R1 (`new`).

- R2. Metadata block (literal values). Its metadata block SHALL be exactly:
  ```
  - Pinned-Version: v4
  - Manifest: .github/workflows/lint.yml
  - Lockfile: .github/workflows/lint.yml
  - Lockfile-Assertion: actions/checkout@v4
  ```
  The workflow file serves as both `Manifest` and `Lockfile` because it is simultaneously
  the declaration and the resolved reference — there is no separate resolved artifact for a
  GitHub Actions `uses:` line. Per epic 1 R6 only the `Lockfile` + `Lockfile-Assertion` pair
  decides freshness; the `Manifest` value is recorded for the human and MAY be echoed in the
  status line only. `[ASSUMPTION]` Pointing `Lockfile` at the workflow file is designed here.
  Epic 1 R6 defines the lockfile path purely as "a file that must contain the assertion
  verbatim" and places no constraint on what kind of file it is, so this is consistent with
  epic 1 rather than an extension of it. `[ASSUMPTION]` `Pinned-Version: v4` records the tag
  as written, not a resolved semver — an exact `4.x.y` is not knowable from anything in this
  repo, and inventing one would be the "invent a version source" defect (pitch rabbit hole 6).

- R3. Covered symbols — exactly what this repo uses, nothing else. The body SHALL document
  only the single call site `.github/workflows/lint.yml:12` and the fact that it passes **no
  `with:` parameters** — so the action runs with its defaults. The action's full input
  surface (`repository`, `ref`, `token`, `path`, `fetch-depth`, `submodules`, …) SHALL NOT
  be documented: this repo calls none of it, and anything off the map falls through to the
  reactive protocol (pitch rabbit hole 3, epic 3 flow 3). The call site SHALL be cited as
  `path:line`.

- R4. Provenance header. The file SHALL carry, above the metadata block, a one-line
  provenance statement naming how the content was obtained and when — e.g.
  `Authored 2026-07-19 from the in-repo call site .github/workflows/lint.yml:12;
  human-reviewed before commit.` Any content originating from fetched external docs entered
  as untrusted data (`SECURITY.md`) and was promoted to trusted in-repo instruction surface
  by a person, never by an agent (pitch rabbit hole 5).

- R5. Floating-tag caveat (mandatory, not optional). The file SHALL carry a literal notice
  stating, in substance: `v4` is a floating major tag, not an exact version; GitHub moves it
  as new `4.x` releases ship; therefore an `OK` status asserts only that **this repo's own
  declaration still reads `actions/checkout@v4`**, and does **not** assert that the upstream
  action is unchanged. The notice SHALL name pitch rabbit hole 4 as the known limitation it
  instantiates. It SHALL NOT be softened to "usually fine", omitted, or relegated to a
  parenthetical — mistaking a green check for upstream stability is the precise defect this
  requirement prevents.

- R6. One-screen cap. The file SHALL be ≤ **60 lines** total (`wc -l`), per epic 1 R2, and
  in practice SHALL be far under it — one call site with no parameters needs no padding.

- R7. Registration and its consequence — the gate goes GREEN. `.lsa.yaml` SHALL register:
  ```yaml
  libs:
    actions-checkout:
      spec: .lsa/libs/actions-checkout.md
      manifest: .github/workflows/lint.yml
  ```
  After this, `bash scripts/check-lib-pins.sh` SHALL print an `OK` line for
  `actions-checkout` and exit **0** (epic 1 R6 path 5: the lockfile exists and contains the
  assertion verbatim via `grep -qF`), `bash scripts/gate.sh` SHALL exit **0**, and
  `lsa:verify` SHALL be unblocked by this check. Verified precondition:
  `.github/workflows/lint.yml:12` contains `      - uses: actions/checkout@v4`.

- R8. The `[cannot verify]` rule is preserved, not weakened. This epic SHALL NOT add an
  allowlist, a skip flag, a `|| true`, an exit-code remap, or any other mechanism that lets
  `[cannot verify]` or `STALE` read as green. Epic 1 R5's rule — never exit 0 when any lib is
  `[cannot verify]` — SHALL remain intact and untouched; it simply does not fire for this
  pin because a real assertion source exists.

- R9. C18 stays green. With one registered lib, `scripts/lint.sh` C18 (epic 1 R9, `new`)
  SHALL report PASS (1 ≤ 5).

- R10. Read-precedence consistency. When epic 3 (`conditional-read-precedence`, `new`) has
  landed, a claim sourced from this pin SHALL be cited as
  `lib:actions-checkout:<api> via pin@v4`, matching epic 3 R5's `via pin@<pinned-version>`
  token. This epic authors no protocol text — it only conforms to that token.

- R11. Versioning — no plugin bump. This epic touches `.lsa/libs/**`, `.lsa.yaml`, and
  nothing under any plugin directory. None of those paths is inside any plugin's
  `artifact_paths` in `.lsa.yaml`, and `.github/**` is likewise outside every plugin, so
  **no plugin version bump and no plugin CHANGELOG entry** are required. No README changes —
  no user-facing plugin surface changed.

## Out of Scope

- Pinning any second library — one pin, and the cap is 5 (pitch appetite; epic 1 R9).
- Documenting `actions/checkout` inputs this repo does not pass (R3).
- Resolving `v4` to an exact `4.x.y`, querying the GitHub API, or adding any network call to
  the staleness script (R2, pitch no-go 2 — detection only, no new runtime dependency).
- Detecting upstream releases inside the `v4` tag — out of reach by construction (R5). Closing
  that gap would require a commit-SHA pin, which is a separate owner decision.
- Any change to read precedence or `lsa/knowledge/conventions.md` (epic 3).
- Auto-re-pinning when the workflow bumps to `@v5` (pitch no-go 3 — the human re-pins).
- The `libs:` schema, `scripts/check-lib-pins.sh`, and the C18 cap themselves (epic 1).
