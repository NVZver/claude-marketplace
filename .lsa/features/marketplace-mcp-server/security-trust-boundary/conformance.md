Epic: marketplace-mcp-server/security-trust-boundary
Reconciled: 2026-08-25
Diff graded: `git diff SECURITY.md` (uncommitted working-tree change)

## Coverage-skeleton (`bash scripts/coverage-skeleton.sh .lsa/features/marketplace-mcp-server/security-trust-boundary`)

The script emitted an **empty requirement table** (header row only, zero `R`/`F`
rows):

```
| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|

## Candidate hunks
...
```

Root cause: the script's requirement-ID extraction regex is
`^- [RF][0-9]+\.` (a dash-bulleted `- R1.` / `- F1.` line — see
`scripts/coverage-skeleton.sh:70`). This spec's `requirements.md` uses a plain
numbered list (`1. **The system shall** …`, no `- R1.` prefix), so the script
found zero IDs. This is a pre-existing format gap in the enumeration tool, not
a defect in the diff — the reconcile below builds the requirement↔hunk mapping
manually (R1-R6, matching the requirements.md numbering) as the task calls for.

Candidate-hunks checklist (from the same run) correctly listed `SECURITY.md` as
the sole in-scope changed file. It also listed `.lsa/.rag-index/**` (many
files) and `scripts/opencode-dist-deploy.sh` / `scripts/opencode-dist-generate.sh`
— these are pre-existing untracked items unrelated to this epic (confirmed via
`git status --short` before any of this epic's work: they were already
untracked), explicitly out of scope per the grading brief, and not graded here.

## Requirement coverage (R1-R6)

| Req | Implementing hunk | Verdict |
|---|---|---|
| R1 | `SECURITY.md:3-6` opening paragraph — replaced "There is no server, no hosted service, and no secret or PII handling" with "The product is Markdown instruction files, one shell hook, and — additively — a local, stdio-spawned MCP server (`mcp-server/`, see below) with no network listener, no outbound calls, no credentials, and no PII handling. There is no hosted service." | ✅ |
| R2 | `SECURITY.md:37-47` "What this project is" section — replaced "There is no executable application in this repo beyond shell scripts" / "No server, no network service, no database, no credential store, no PII processing" with text that lists the MCP server alongside the existing hook/scripts and narrows the claim to "No network service exposed externally, no database, no credential store, no PII processing." | ✅ |
| R3 | New `## The MCP server (what runs when you connect a non-Claude-Code client)` subsection, inserted directly after the existing `## The SessionStart hook` subsection ends (was `SECURITY.md:246-248` pre-diff) and before `## The commit-discipline PreToolUse hook` — same position/pattern as the precedent subsection. Covers: what it reads, what it returns, no network listener, no outbound calls, dependency count, how it's spawned (client's own MCP config, not a standalone daemon). | ✅ |
| R4 | New row appended to the "Summary of controls" table: `| MCP server: no network exposure | stdio-only, zero outbound calls, 2 direct deps | [core-server conformance](...), [mcp-server/package.json](...) |` | ✅ |
| R5 | No new claim of secret handling, PII processing, or network exposure anywhere in the diff — verified by full line-by-line read of the diff (see "R5 — safety check" below). | ✅ |
| R6 | Every new citation resolves — `scripts/check-citations.sh` and `scripts/check-links.sh` both exit 0 (see below), plus each one independently content-verified against its source (see "Independent fact verification" below), which goes beyond what either script checks. | ✅ |

## Independent fact verification (beyond citation resolution)

`scripts/check-citations.sh` only proves a `path:line` citation resolves to a
real line — its own header says so explicitly ("MECHANICAL ONLY... does NOT
verify that the quoted text still lives at that line"). Every citation
`SECURITY.md` adds was independently re-read against its source:

- **No network listener.** Re-read `core-server/conformance.md:87` (F6 row:
  "stdio only, no network listener... `StdioServerTransport` is the only
  transport constructed... grep... → no matches"). Independently re-ran
  `grep -rn "listen(\|createServer\|http\.\|net\." mcp-server/src/ mcp-server/test/*.mjs`
  against the CURRENT tree myself: the only hits are inside the regex
  *pattern string* in `test/verify.mjs:179` (the checker's own detection
  regex), not actual usage. Read `mcp-server/src/index.js` in full: only
  `StdioServerTransport` is constructed (line 115), `server.connect(transport)`
  once (line 116). No `http`/`net` import anywhere. Claim confirmed accurate
  against current code, not just the old conformance record.

- **No outbound calls.** Re-read `core-server/conformance.md:86` (F5) and
  `agent-prompts/conformance.md:59,125`. Independently re-ran
  `grep -rniE "fetch\(|https?\.request|axios|XMLHttpRequest|WebSocket|anthropic|openai" mcp-server/src/ mcp-server/test/*.mjs`
  myself: same result — only the detection-regex string itself matches, no
  real usage. Read `mcp-server/src/index.js` and `mcp-server/src/registry.js`
  in full: imports are `node:fs`, `node:path`, `node:url`, `gray-matter`,
  `@modelcontextprotocol/sdk/server/{mcp,stdio}.js` — nothing else. Every
  callback (`registerTool`, `registerResource`, `registerPrompt`) does nothing
  but `readFileSync` and return an object literal. Also grepped for
  `process.env|token|secret|password|api_key|credential|auth` across
  `src/` and `test/*.mjs` — zero matches, confirming no credential/env
  handling exists anywhere in the server. Claim confirmed accurate.

- **2 direct dependencies.** Read `mcp-server/package.json` myself:
  `"dependencies": { "@modelcontextprotocol/sdk": "^1.30.0", "gray-matter":
  "^4.0.3" }` — exactly two. Claim confirmed accurate.

- **Byte-identical passthrough.** Spot-checked the three cited rows:
  `core-server/conformance.md:84` (F3, tool call → exact `SKILL.md` body),
  `:85` (F4, resource read → exact knowledge content),
  `agent-prompts/conformance.md:124` (F2, prompt request → exact agent-file
  body). All three describe `readFileSync(filePath, "utf8")` returned
  verbatim with no transform — matches what `SECURITY.md` claims, and matches
  what I read directly in `registry.js`/`index.js` (`read: () =>
  readFileSync(filePath, "utf8")`, callbacks wrap the raw string in a JSON
  envelope with no reformatting).

- **`.lsa/pitches/marketplace-mcp-server.md:4` citations (used twice).** Read
  line 4 directly: *"CC scope = additive (Claude Code keeps its native plugin
  format + SessionStart hook; MCP server is the connection layer for other
  clients...)"* and *"...local transport = stdio process, spawned by each
  client's own MCP config."* Both phrases `SECURITY.md` quotes are present
  verbatim on that line. Confirmed accurate, not just resolvable.

- **"What it reads" scope.** `SECURITY.md` claims the server reads "core/,
  lsa/, and manager/ skill, knowledge, and agent Markdown." Read
  `mcp-server/src/registry.js:19-31`: `PLUGINS = ["core", "lsa", "manager"]`,
  `AGENT_FILES` = the three manager/lsa agent files. Matches exactly — no
  broader or narrower scope than claimed.

## R5 — safety check (line-by-line read of the full diff)

Read every hunk of `git diff SECURITY.md` in full. No hunk introduces any of:

- **Secret handling** — no mention of API keys, tokens, credential storage,
  auth flows, or environment-variable secrets anywhere in the diff. The text
  only ever *negates* credential handling ("no credentials", "no credential
  store").
- **PII processing** — no mention of user data, personal information
  collection, logging of user content, or telemetry. The diff only negates
  this ("no PII handling", "no PII processing").
- **Network exposure** — the diff is explicit and consistent that the MCP
  server (a) opens no listener, (b) makes no outbound calls, (c) is spawned
  by the connecting client's own local config over stdio, not a daemon with
  a network-facing lifecycle. The one softened phrase — "No network service
  exposed externally" (replacing the flat "No server, no network service") —
  is *more* precise than the original, not an overclaim: it still asserts zero
  network exposure, just scoped correctly now that a process (the MCP server)
  genuinely exists. It does not claim the process has *any* network
  capability; independent code reading (above) confirms it has none.

No overclaim, no underclaim, no new risk surface stated. R5 holds.

## Gate results

`bash scripts/check-citations.sh`:
```
OK  102 citation(s) checked, all resolve.
```
exit 0.

`bash scripts/check-links.sh`:
```
OK  528 relative-file link(s) checked, all resolve.
```
exit 0.

`bash scripts/gate.sh`:
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
exit 0.

## Only what's needed / all of the plan

`git diff --name-only` against the working tree shows exactly one changed
file: `SECURITY.md`. No other tracked file was touched. Pre-existing
untracked items (`.lsa/.rag-index/`, `scripts/opencode-dist-deploy.sh`,
`scripts/opencode-dist-generate.sh`) predate this epic and are unrelated —
confirmed out of scope per the grading brief, not part of this diff. All 6
requirements (R1-R6) are covered by hunks in `SECURITY.md`.

Orphan hunks: none.

## Verdict

**reconcile: PASS @ uncommitted**

All 6 requirements independently verified against current source, not just
against the citations' own resolution. R5 (the critical no-new-risk-claim
check) confirmed clean by a full line-by-line diff read. Gate green.
