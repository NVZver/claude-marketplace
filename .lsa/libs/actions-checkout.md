# actions-checkout

Authored 2026-07-20 from the in-repo call site `.github/workflows/lint.yml:12`;
human-reviewed before commit.

- Pinned-Version: v4
- Manifest: .github/workflows/lint.yml
- Lockfile: .github/workflows/lint.yml
- Lockfile-Assertion: actions/checkout@v4

## ⚠️ Floating-tag caveat — read before trusting a green check

`v4` is a **floating major tag**, not an exact version — GitHub moves the tag as new
`4.x` releases ship. An `OK` status from `scripts/check-lib-pins.sh` asserts only that
**this repo's own declaration still reads `actions/checkout@v4`**. It does **not** assert
that the upstream action is unchanged — the action's code can change completely
underneath this pin while the check reads green. This is the exact failure mode named in
`.lsa/pitches/pinned-library-specs.md` rabbit hole 4 (a version range that "let[s] the
installed version drift ... while the check reads green"). Closing that gap would require
a commit-SHA pin, a separate owner decision — out of scope here.

## Symbols this repo calls

One call site, no parameters:

```yaml
# .github/workflows/lint.yml:12
      - uses: actions/checkout@v4
```

No `with:` block — the action runs with its defaults (default `ref`, default
`fetch-depth: 1`, default `token`, etc.). This spec documents nothing beyond that single
call site; the action's full input surface (`repository`, `ref`, `token`, `path`,
`fetch-depth`, `submodules`, …) is undocumented here by design — this repo calls none of
it, and anything off this map falls through to the reactive discovery protocol.

The `Manifest` and `Lockfile` fields both point at `.github/workflows/lint.yml` because
it is simultaneously the declaration and the resolved reference — there is no separate
resolved artifact for a GitHub Actions `uses:` line, unlike an npm lockfile.
