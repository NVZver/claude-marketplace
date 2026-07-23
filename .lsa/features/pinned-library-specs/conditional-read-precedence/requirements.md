# Conditional read precedence — a pinned spec outranks external docs only while green

## Summary

Insert pinned-spec reads into `lsa/knowledge/conventions.md` §"Library documentation
protocol" **ahead of** the external-fetch step — but conditionally. A pinned library spec is
an in-repo doc that *represents* an external source, so under `.lsa/VISION.md` §2 principle 6
(in-repo config → in-repo docs → the code itself → external sources → ask the human) it jumps
the queue by construction. If it is stale, principle 6 would then actively prefer a wrong
answer over a fetchable right one — making the system worse at exactly the failure this pitch
set out to fix. The fix: precedence is **conditional, not positional**. Freshness is the
price of precedence.

- Source: `.lsa/pitches/pinned-library-specs.md` rabbit hole 1 ("the sharpest risk"),
  solution sketch item 3 ("the pinned spec **demotes itself**"), no-go 4 (the reactive
  protocol is not replaced).
- Applies: `.lsa/VISION.md` §2 principle 6 (truth ordering), principle 1 (a fast wrong
  answer is a defect).
- Target surface: `lsa/knowledge/conventions.md` §"Library documentation protocol"
  (currently `lsa/knowledge/conventions.md:45-54`).
- Style precedent: the numbered-step protocol already in that section; the `# adversarial`
  comment marker in
  `.lsa/features/pro-tier-token-affordability/model-routing/flow-3-grader-floor.feature`.
- Depends on: epic `format-and-staleness-gate` (`new`) for the `libs:` block and
  `scripts/check-lib-pins.sh` exit codes. It does **not** depend on
  `github-actions-pin` (re-targeted 2026-07-19) — the scenarios below use a fixture pin, and epics 2 and 3 run
  concurrently after epic 1.

## User Flows

1. **Fresh pin — local read, zero fetch.** A skill needs an API of a registered library.
   The pin's staleness check is green, so the pinned spec is read and the answer is cited
   from it. No `resolve-library-id`, no `query-docs`, no `WebSearch`.
2. **Stale or unverifiable pin — demotion.** The check is non-zero. The pinned spec is
   **not** treated as authoritative. The existing 4-step reactive protocol runs unchanged,
   and the answer is cited from the external source, not from the pin.
3. **Symbol off the map.** The pin is green but does not cover the symbol asked about. The
   reactive protocol runs for that symbol (pitch rabbit hole 3, no-go 4).

## Functional requirements (EARS)

- R1. New step 0.** `lsa/knowledge/conventions.md` §"Library documentation protocol" SHALL
  gain a step **ahead of** today's step 1 (`Check available tools for resolve-library-id`),
  reading in substance: *"If the library is registered under `libs:` in `.lsa.yaml`, run
  `bash scripts/check-lib-pins.sh` and read its status line for that library. On `OK`, read
  the registered pinned spec; if it covers the symbol, cite it as `lib:<name>:<api> via
  pin@<pinned-version>` and stop — make no external call. On any other status, or if the
  symbol is not covered, continue to step 1."*

- R2. Conditional, never positional.** The section SHALL state explicitly that a pinned
  spec's precedence is **conditional on its staleness check being green**, and that on
  `STALE`, `BROKEN`, or `[cannot verify]` it ranks **below external sources** — it is not
  read as authoritative and is not cited as a source. The section SHALL name
  `.lsa/VISION.md` §2 principle 6 and state that a pinned spec is an in-repo doc
  representing an external source, so it earns the in-repo-doc rank only while verified.

- R3. Freshness signal is the script, not the model's judgment.** The green/not-green
  determination SHALL come from `scripts/check-lib-pins.sh`'s status line and exit code
  (epic 1 R4-R5, `new`). The protocol SHALL NOT ask the model to eyeball a version, compare
  a manifest range, or infer freshness (`.lsa/VISION.md` §2 principle 10).

- R4. Exactly one status maps to authoritative.** Only `OK` SHALL permit the pinned read.
  `STALE`, `BROKEN`, and `[cannot verify]` SHALL all fall through to the reactive protocol.
  `[cannot verify]` SHALL NOT be treated as a soft pass, a warn-and-proceed, or a
  "probably fine" — it is an unknown, and an unknown does not outrank a fetchable answer
  (pitch rabbit hole 4).

- R5. Distinct citation form.** A claim sourced from a pinned spec SHALL be cited as
  `lib:<name>:<api> via pin@<pinned-version>`, distinguishable at a glance from the existing
  `lib:<name>:<api> via context7` and `lib:<name>:<api> via <url>` forms — so a reader can
  tell a local pinned answer from a fetched one.
  `[ASSUMPTION]` The `via pin@<version>` token is designed here; the existing section
  defines only the `via context7` and `via <url>` forms, and the pitch specifies no citation
  syntax. Chosen to mirror the established `via <source>` shape.

- R6. The reactive protocol is unchanged.** Today's four numbered steps and the
  "Skills that perform discovery (`lsa:discover`) do this proactively" sentence SHALL survive
  verbatim in substance, renumbered only if the new step is numbered. The terminal case
  ("If nothing found: state it… Never guess API signatures") SHALL survive unchanged (pitch
  no-go 4). No behavior SHALL change for any non-registered library.

- R7. No new runtime network dependency.** Reading a pinned spec is a local file read;
  running `check-lib-pins.sh` is local bash with zero model calls (pitch no-go 2).

- R8. Versioning.** `lsa/knowledge/conventions.md` is inside the `lsa` module's
  `artifact_paths` (`lsa/knowledge/**/*.md`), so `lsa` SHALL bump one MINOR
  (**0.29.0 → 0.30.0** if epic 1 landed first) with a `lsa/CHANGELOG.md` entry.
  `lsa/README.md` SHALL be updated only if a user-facing surface changed; a protocol edit
  inside a knowledge file that no README table names is exempt as a non-user-visible delta
  (`CLAUDE.md` §Discipline). `knowledge/index.md` needs no count change — no knowledge file
  is added or removed.
  `[ASSUMPTION]` The exact numbers assume epic 1 lands first at 0.29.0; take the next unused
  MINOR if the merge order differs.

- R9. Gate green.** `bash scripts/gate.sh` SHALL exit 0 after this epic **when no
  unverifiable pin is registered**. If epic 2 has already merged, `lib-pins` is expected to
  exit 2 and the gate red for that reason alone (epic 2 R7) — that failure SHALL NOT be
  attributed to this epic, and SHALL NOT be worked around here.

## Out of Scope

- The `libs:` schema, the staleness script, and the C18 cap (epic 1).
- Authoring any pinned spec (epic 2).
- Changing how non-pinned libraries are resolved (pitch appetite, no-go 4).
- Any auto-re-pin or auto-refresh on a stale read (pitch no-go 3 — the human re-pins).
