# Conformance — unsupported-mechanism-gap-list

`reconcile: PASS @ uncommitted` (re-graded 2026-08-25, second pass, fresh
context — independent grader, separate from the implementer). First pass
found real drift (R2's "no native `multiSelect`" claim was false against
the installed SDK); that drift is fixed in this diff and re-verified from
scratch below, not carried forward as an assumption.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | all 8 mechanisms, one new file — `mcp-server/UNSUPPORTED-MECHANISMS.md`, 7 `##` headings covering all 8 named mechanisms: `AskUserQuestion` (L22), `TaskOutput` (L51), `ToolSearch and deferred tools` (L67), `ScheduleWakeup` (L82), `CronCreate` (L89), `EnterPlanMode`/`ExitPlanMode` (L96), `The SessionStart hook` (L108) | Re-read the file in full; grepped `^## ` — 7 headings, 8 mechanisms (`ToolSearch`+deferred tools share one) | ✅ |
| R2 | AskUserQuestion: `elicitation/create` cited, form+URL modes, accurate concrete gaps, no false multiSelect claim — `mcp-server/UNSUPPORTED-MECHANISMS.md:22-49` | Independently re-read `mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/types.js:1600-1790` myself. `ElicitRequestFormParamsSchema` (:1731), `ElicitRequestURLParamsSchema` (:1755), `ElicitRequestSchema` method `elicitation/create` (:1783) — form+URL modes both real. `MultiSelectEnumSchemaSchema` (:1719, built from `UntitledMultiSelectEnumSchemaSchema`:1687/`TitledMultiSelectEnumSchemaSchema`:1702) is a non-experimental member of `EnumSchemaSchema`(:1723)→`PrimitiveSchemaDefinitionSchema`(:1727), the exact type used in `requestedSchema.properties` — doc's "Multi-select IS supported natively" (L39-42) confirmed true, false claim from pass 1 is gone. Grepped `types.js` for `preview` and `header`: zero matches for either — confirms both "no per-option `preview` field" and "no `header` chip label" gap claims. Cross-checked Claude Code's own `AskUserQuestion` tool shape via public docs (WebSearch, not trained-memory recall): header is a ≤12-char label, options array is capped 2-4, each option carries an optional `preview` field — corroborates all three gap claims (`preview` and `header` exist on Claude Code's side / absent on MCP's; MCP's enum schema has no analogous option-count cap, confirmed by re-reading the enum schema definitions, which impose no length limit on the `enum`/`items` arrays) | ✅ |
| R3 | TaskOutput: experimental tasks feature cited, flagged unstable — `mcp-server/UNSUPPORTED-MECHANISMS.md:51-65` | Re-read `interfaces.d.ts:1-4` and `server.d.ts:1-6` myself — both carry "WARNING: These APIs are experimental and may change without notice" verbatim; doc's quote and "not something to build on yet" framing match exactly | ✅ |
| R4 | 6 mechanisms dropped, no fake substitute, cites opencode-dist-generate.sh:50-52 — `mcp-server/UNSUPPORTED-MECHANISMS.md:67-115` (ToolSearch/deferred tools, ScheduleWakeup, CronCreate, EnterPlanMode/ExitPlanMode, SessionStart hook) | Re-read all 5 entries — each says "dropped — no MCP equivalent," none invents a substitute; re-read `scripts/opencode-dist-generate.sh:50-52` myself, doc's quote (L17-20) matches verbatim | ✅ |
| R5 | ToolSearch/deferred tools: gap is moot, direct registration — `mcp-server/UNSUPPORTED-MECHANISMS.md:69-80`, `mcp-server/src/index.js:47-66` | Re-counted `find core/skills lsa/skills manager/skills -name SKILL.md` → 6+7+5 = 18, matches doc's "currently 18 tools" claim exactly. Re-read `mcp-server/src/index.js:47-66` — `buildServer()` loops `scanSkills()` results through `server.registerTool(...)` (line 59) directly at startup; not a search/discovery mechanism | ✅ |
| R6 | no MCP support claimed beyond installed SDK — `mcp-server/UNSUPPORTED-MECHANISMS.md` (whole file) | Re-read every entry; no claim exceeds what `types.js`/`experimental/tasks/` actually define. `mcp-server/package.json` pin (`^1.30.0`) matches installed `mcp-server/node_modules/@modelcontextprotocol/sdk/package.json` version `1.30.0` | ✅ |

## does — scenarios (`gap-list-completeness.feature`)

- S1 (all 8 mechanisms, each with a disposition, none claiming unsupported MCP capability) — 1/1, table above.
- S2 (AskUserQuestion cites `elicitation/create` as partial equivalent, names concrete UI gaps, does **not** claim multiSelect unsupported) — 1/1, R2 row above; this is the scenario the first pass failed and this pass re-verifies clean.
- S3 (TaskOutput cites experimental tasks feature, flags it explicitly unstable) — 1/1, R3 row above.

## Orphan hunks

Orphan hunks: none.

Traced: `mcp-server/UNSUPPORTED-MECHANISMS.md` → R1-R6 (the epic's one new file, sole
in-scope hunk). Excluded as out of this epic's scope (pre-existing/unrelated,
confirmed via `git status --short --untracked-files=all`): `.lsa/.rag-index/`
(LanceDB index artifacts from a separate concurrent workstream),
`scripts/opencode-dist-deploy.sh`, `scripts/opencode-dist-generate.sh` (pre-existing,
read-only referenced by this doc, not modified by it). The epic's own spec files
(`requirements.md`, `gap-list-completeness.feature`, `grounding.md`, this
`conformance.md`) are excluded per `scripts/coverage-skeleton.sh`'s own convention
of excluding spec files under the graded feature dir. No changes to `core/`,
`lsa/`, `manager/`, `mcp-server/src/`, `mcp-server/test/`; no `mcp-server/README.md`
was created (a focused standalone doc, not a README rewrite, matches
`grounding.md`'s scoping note).

## Reconcile-absorbed drift (first pass → this pass)

First-pass grading found the `AskUserQuestion` entry's "no native `multiSelect`"
gap claim was false: the installed SDK (`@modelcontextprotocol/sdk@1.30.0`)
defines a non-experimental `MultiSelectEnumSchemaSchema` usable in elicitation
form properties (`types.js:1687-1723`). That claim traced back through
`requirements.md`/`grounding.md`'s original discover-time facts, not something
the implementer introduced independently. The orchestrator confirmed the finding
independently against the SDK source, corrected `requirements.md`
(R2, `Facts` section) and `grounding.md` (`Assumptions` section) with a dated
correction note, and the implementer replaced the false claim with three
verified-accurate gaps: no per-option `preview` field, no `header` chip label,
and a generic JSON-schema form vs. Claude Code's specific 2-4-option card
picker — while correctly stating multiSelect IS supported. This pass re-derives
that verification from scratch (re-read `types.js` myself; did not reuse the
first pass's citations without re-checking them) rather than trusting the
correction's own citation report, per this task's independence requirement.

## Gate

```
=== .lsa.yaml gate: block ===
  PASS  docs-invariants  bash scripts/lint.sh → exit 0
  PASS  citations        bash scripts/check-citations.sh → exit 0
  PASS  links            bash scripts/check-links.sh → exit 0
  PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests            bash scripts/run-tests.sh → exit 0
  PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0

gate: PASS — every configured check exited 0
```

(This file's own first draft in this pass initially failed `docs-invariants`/C19
because the orphan-hunk line was written as a `##` heading, not a bare
column-0 line — the regex requires the literal text `Orphan hunks: none.` to
start the line. Fixed to the bare form immediately below its own `## Orphan
hunks` heading; content verdict was unaffected, this was a format-only defect
in the artifact I was writing, not in the graded diff.)

## Verdict

**reconcile: PASS @ uncommitted**

All 6 requirements independently re-verified against the current diff, from
scratch, in this pass: all 8 mechanisms present (R1); `AskUserQuestion`'s
`elicitation/create` citation, form/URL modes, and all three gap claims verified
accurate including the corrected multiSelect statement (R2); `TaskOutput`'s
experimental-tasks citation and unstable framing verified accurate (R3); all 6
"dropped" entries invent no substitute and correctly cite the
`opencode-dist-generate.sh:50-52` precedent (R4); the `ToolSearch`/deferred-tools
moot-in-this-server claim and 18-tool count independently re-counted and confirmed
(R5); no claim exceeds the installed SDK (R6). Diff scope is exactly the one new
file. Gate 6/6 green.
