# Standards claim — cite the Agent Skills spec we already conform to

## Summary

All 20 shipped skills already satisfy https://agentskills.io/specification (name↔parent-directory
20/20; longest body 192 lines against the spec's recommended 500). This epic changes only what we
*cite*: `scripts/lint.sh` C7 and C9 gain the open-standard reference alongside their existing refs,
a one-off `skills-ref validate` run is transcribed into `core/VERIFICATION.md` as external evidence,
and `README.md` + `.lsa/VISION.md` name both standards by URL. **No skill content, name, or
directory changes. The `.lsa.yaml` `gate:` block stays npm-free.**

- Source: `.lsa/pitches/standards-conformance-agents-md.md` (approved 2026-07-19) — finding B, Fork D and its 2026-07-19 revision, rabbit hole 6.
- Applies: pitch success criteria 3 and 4.
- Target surface: `scripts/lint.sh` (comments only), `core/VERIFICATION.md`, `README.md` §"Status + substrate", `.lsa/VISION.md`.
- Style precedent: the existing C7 / C9 banner comments in `scripts/lint.sh:179-190` and `scripts/lint.sh:265-270`; the probe-and-expected-result prose already in `core/VERIFICATION.md`.

## User Flows

1. **An outside evaluator asks "is this really tool-agnostic?"** They read
   `README.md` §"Status + substrate", find both standards named with URLs, and
   find in `core/VERIFICATION.md` a transcribed `skills-ref validate` run — a
   third-party validator, not our own script — reporting 20/20 with a run date.
2. **A maintainer reads lint C7 or C9 and asks where the limit comes from.** The
   banner comment cites both the Anthropic doc / internal fork it already cited
   *and* https://agentskills.io/specification, so the constraint reads as
   conformance to a public spec rather than a vendor allowance.
3. **A maintainer asks why no skill declares `license`.** One greppable line in
   `core/VERIFICATION.md` states both `license` and `metadata` are deliberately
   unset because the root `LICENSE` is the single source — so it is not re-litigated.

## Functional requirements (EARS)

- R1. The C7 banner comment in `scripts/lint.sh` SHALL cite
  `https://agentskills.io/specification` **in addition to** its existing citation
  of *"Anthropic's documented hard limit ... platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices"*.
  The existing citation text SHALL NOT be removed or reworded. The added text
  SHALL state that the same constraints (`description` ≤ 1024 chars; `name`
  matching the parent directory) are normative in the open Agent Skills spec.

- R2. The C9 banner comment in `scripts/lint.sh` SHALL cite
  `https://agentskills.io/specification` **in addition to** its existing internal
  pitch-fork reference (*"Hard-fail (pitch Fork A)"*). The existing reference SHALL
  NOT be removed. The added text SHALL state that the spec *recommends* bodies
  under 500 lines and that our 500 is a hard cap on the same number.

- R3. Only comment lines SHALL change in `scripts/lint.sh` for R1 and R2. The
  executable logic of C7 and C9 — including `DESC_LIMIT=1024`, `BODY_LIMIT=500`,
  the `awk` programs, and every `pass_line` / `fail_line` string — SHALL be
  byte-identical before and after. `git diff scripts/lint.sh` SHALL show added or
  changed lines beginning with `#` only.

- R4. `core/VERIFICATION.md` SHALL gain a new section (heading level `##`) that
  transcribes one manual run of the Agent Skills reference validator over all 20
  shipped skills. The section SHALL record, literally:
  - the exact command(s) run, in a fenced code block;
  - the run date in `YYYY-MM-DD` form;
  - a result line containing the literal string `20/20`;
  - the per-plugin skill counts `core 6`, `lsa 7`, `manager 5`, `observer 2`,
    which sum to 20;
  - the validator source URL `https://agentskills.io/specification`.
  The 20 skill directories are exactly: `core/skills/{actor-template, doctor,
  flow-selector, ground-rules, output, reuse-first}`, `lsa/skills/{delegate,
  discover, init, reconcile, revise-constitution, specify, verify}`,
  `manager/skills/{check, decompose, implement, next, shape}`,
  `observer/skills/{observe, verify-checkpoint}`. (`helper` and `prompt-engineer`
  ship no `skills/*/SKILL.md` — verified 2026-07-19.)

- R5. If `skills-ref` cannot be run in the implementation environment, the section
  SHALL still be written but SHALL mark the result line with the literal marker
  `[unverified]` and SHALL state what blocked the run. It SHALL NOT report `20/20`
  as observed unless the validator actually produced it. Reporting an unrun result
  as passed is a failed requirement.

- R6. `core/VERIFICATION.md` SHALL contain exactly one greppable line stating that
  the optional per-skill `license` and `metadata` frontmatter fields are
  deliberately left unset because the root `LICENSE` file is the single source of
  that fact. The line SHALL contain both literal tokens `license` and `metadata`
  and SHALL be findable by `grep -n 'license' core/VERIFICATION.md`.

- R7. No `SKILL.md` frontmatter SHALL gain a `license` or `metadata` field. Per the
  pitch's revised Fork D, writing the license into 20 files would copy one fact
  into twenty independently-driftable places — the exact failure mode the sibling
  epic's C16 check exists to prevent. `git diff` SHALL show **zero** changes under
  any `*/skills/**/SKILL.md` path.

- R8. The `gate:` block in `.lsa.yaml` (currently `.lsa.yaml:14-19`, five keys:
  `docs-invariants`, `citations`, `links`, `project-map`, `tests`) SHALL be
  byte-identical after this epic. `skills-ref` is a one-off manual run and SHALL
  NOT be wired into the gate, into `scripts/`, into CI, or into any `package.json`.
  No `package.json`, `package-lock.json`, or `node_modules/` SHALL be added to the
  repo.

- R9. `README.md` §"Status + substrate" (currently `README.md:130-132`) SHALL name
  both standards by URL — `https://agents.md/` and
  `https://agentskills.io/specification` — so the existing tool-agnosticism claim
  carries a source. The existing claim sentence SHALL be kept and sourced, not
  deleted. The section SHALL point at `core/VERIFICATION.md` as the location of the
  validator evidence.

- R10. `.lsa/VISION.md` SHALL name both standards by URL in the section that states
  the substrate/portability position, recording that the repo's agent instructions
  live in `AGENTS.md` per the vendor-neutral standard and that its skills conform to
  the Agent Skills spec. No VISION principle SHALL be added, removed, or renumbered.

- R11. `core` SHALL bump SemVer by one PATCH level with a matching `core/CHANGELOG.md`
  entry in the same commit, because `core/VERIFICATION.md` is in `core`'s
  `artifact_paths` (`.lsa.yaml`). If this epic lands **after** the sibling epic
  `agents-md-canonical`, the bump is **0.21.0 → 0.21.1**; if it lands **before** it,
  the bump is **0.20.0 → 0.20.1**. Read the current value in
  `core/.claude-plugin/plugin.json` and increment the PATCH digit. `scripts/lint.sh`,
  `README.md`, and `.lsa/VISION.md` are in no plugin's `artifact_paths`, so `core` is
  the **only** plugin bumped; no other plugin's `plugin.json` or `CHANGELOG.md` SHALL
  be touched.

- R12. `project-map.yaml` SHALL be regenerated with
  `bash lsa/scripts/project-map-build.sh` and committed if
  `bash lsa/scripts/project-map-check.sh` reports it stale.

- R13. After the change, `bash scripts/lint.sh` and `bash scripts/check-citations.sh`
  SHALL each exit **0**, as SHALL `bash scripts/check-links.sh`,
  `bash lsa/scripts/project-map-check.sh`, `bash scripts/run-tests.sh`, and
  `bash scripts/check-version-changelog.sh`.

## Out of Scope

- Any change to skill content, `name:`, `description:`, or directory (R7 — all 20 already conform).
- Wiring `skills-ref` into the gate, CI, or `scripts/` (R8 — rabbit hole 6).
- Publishing a JSON Schema for `.lsa.yaml` or registering it with SchemaStore (Fork C).
- The `AGENTS.md` / `CLAUDE.md` rewiring and lint C16 — that is epic
  `standards-conformance-agents-md/agents-md-canonical`.
- Running an LSA cycle inside another tool, or any external promotion.
