Parent: [Marketplace-as-MCP-server](../../../pitches/marketplace-mcp-server.md)
Epic: marketplace-mcp-server/unsupported-mechanism-gap-list
Date: 2026-08-25
Status: draft

# Unsupported-mechanism gap list

Document, in one new standalone file, every Claude-Code-only mechanism
named in the pitch's Rabbit hole #1, each with an accurate,
fact-checked disposition — not a blanket "no equivalent" claim where a
real (even if partial) MCP primitive exists, and no invented equivalent
where none exists. Reuses the no-fake-equivalent policy already proven at
`scripts/opencode-dist-generate.sh:50-52`.

## User flow

### Flow 1 — Gap-list doc gives every Rabbit-hole-#1 mechanism an accurate disposition

- **Flow:** A developer connecting to the marketplace via a non-Claude-Code
  MCP client (or a maintainer reviewing what the port covers) reads a new
  standalone doc.
- **Success:** All 8 mechanisms named in the pitch's Rabbit hole #1 appear,
  each with a disposition that is fact-checked against the installed MCP
  SDK — not a blanket "unavailable" claim where a real (even if partial)
  equivalent exists, and no invented equivalent where none exists.
- **I/O:** Input = the 8 named mechanisms + the installed SDK's actual
  capabilities; Output = one new Markdown file.
- **Test:** Manual review confirms all 8 mechanisms appear, and that
  `AskUserQuestion`'s and `TaskOutput`'s dispositions correctly cite real
  (if partial/experimental) MCP primitives rather than being marked flatly
  "no equivalent."

## Requirements (EARS)

1. **The system shall** create one new file listing all 8 mechanisms named
   in the pitch's Rabbit hole #1: `AskUserQuestion`, `ToolSearch`, deferred
   tools, `TaskOutput`, `ScheduleWakeup`, `CronCreate`,
   `EnterPlanMode`/`ExitPlanMode`, the `SessionStart` hook.
2. **For** `AskUserQuestion`, **the system shall** record a disposition
   citing MCP's `elicitation/create` primitive (form-based and URL-based
   modes) as a genuine partial equivalent, and **shall** note the concrete
   gaps (no per-option `preview` field; no `header` chip label; a generic
   JSON-schema form rather than Claude Code's specific card-based picker
   UI with its 2-4-option cap — `multiSelect` IS supported natively via
   `MultiSelectEnumSchemaSchema`, corrected 2026-08-25 after reconcile
   found the original draft's "no native multiSelect" claim was false).
3. **For** `TaskOutput`, **the system shall** record a disposition citing
   MCP's experimental server-side tasks feature (create/get/list/cancel) as
   a partial analog, and **shall** flag it explicitly as experimental / not
   a stable, confirmed-supported primitive.
4. **For** `ToolSearch` and deferred tools, `ScheduleWakeup`, `CronCreate`,
   `EnterPlanMode`/`ExitPlanMode`, and the `SessionStart` hook, **the
   system shall** record a "dropped / no MCP equivalent" disposition, and
   **shall not** invent a fake substitute — consistent with the
   no-fake-equivalent policy already proven at
   `scripts/opencode-dist-generate.sh:50-52`.
5. **For** `ToolSearch` / deferred tools specifically, **the system shall**
   additionally note that the gap is moot in this server's own
   architecture, since it already registers its full, small tool set
   directly at startup rather than needing progressive disclosure.
6. **The system shall not** claim MCP support for any mechanism beyond
   what the installed SDK (`mcp-server/package.json`) actually implements.

## Facts this spec is grounded on (from discover)

- Pitch's Rabbit hole #1 (`.lsa/pitches/marketplace-mcp-server.md:87-89`)
  names exactly 8 mechanisms: `AskUserQuestion`, `ToolSearch`, deferred
  tools, `TaskOutput`, `ScheduleWakeup`, `CronCreate`,
  `EnterPlanMode`/`ExitPlanMode`, the one `SessionStart` hook (cited to
  `SECURITY.md:5` "Markdown instruction files plus one shell hook").
- `AskUserQuestion` — MCP DOES have a real, spec-level primitive:
  `elicitation/create`
  (`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/types.js:1729-1783`),
  supporting form-based elicitation (JSON-schema object with
  enum/boolean/string/number properties) or URL-based elicitation
  (redirect the user to a URL). The enum type genuinely includes a
  non-experimental `MultiSelectEnumSchemaSchema`
  (`types.js:1687-1719`, an `array` of enum-backed items with optional
  titles/`minItems`/`maxItems`) — **`multiSelect` IS supported**, unlike
  an earlier draft of this fact claimed. The real remaining gaps vs.
  Claude Code's `AskUserQuestion`: no per-option `preview` field, no
  `header` chip label, and it's a generic JSON-schema form rather than
  Claude Code's specific card-based picker with a 2-4-option cap. Genuine
  partial equivalent, real and usable for confirmation gates. Consistent
  with the already-shipped `tool-name-rephrase` epic's rewording of
  `AskUserQuestion` mentions to "an interactive confirmation gate" — that
  generic phrasing already correctly describes what MCP `elicitation/create`
  provides.
  **Correction (2026-08-25, post-reconcile):** the original discover-time
  draft of this fact claimed "no native `multiSelect`" — independent
  reconcile grading read `types.js` directly and found this false
  (`MultiSelectEnumSchemaSchema` exists, non-experimental, is a member of
  `PrimitiveSchemaDefinitionSchema`). Corrected here and in the shipped
  doc; this is exactly the kind of fact-checking error the epic's own
  purpose (accuracy, no over- or under-claiming) exists to catch.
- `TaskOutput` — MCP has an **experimental** server-side tasks feature
  (`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/experimental/tasks/`,
  files explicitly marked "WARNING: These APIs are experimental and may
  change without notice" in `interfaces.d.ts:1-3` and `server.d.ts:1-5`)
  offering task create/get/list/cancel — a partial analog for checking on
  background work, but not a stable, confirmed-supported primitive
  (client support unconfirmed, spec marked experimental).
- `ToolSearch` / deferred tools — no MCP equivalent found in the installed
  SDK; moot in this server's own architecture regardless, since
  `mcp-server/src/index.js` already registers its full, small tool set (18
  tools) directly via `tools/list` at startup — the progressive-disclosure
  problem `ToolSearch` solves in a large Claude-Code session with many
  available tools doesn't arise here.
- `ScheduleWakeup`, `CronCreate` — no MCP equivalent found in the installed
  SDK; Claude Code harness/cloud-scheduling primitives with no
  protocol-level analog.
- `EnterPlanMode`/`ExitPlanMode` — no MCP equivalent found; client-side UI
  mode toggle, not something a server can invoke. Existing precedent
  already declined to overstate a loose analog for a different client
  (`scripts/opencode-dist-generate.sh:50-52`: "OpenCode's Tab-key
  Plan/Build toggle is a loose analog to plan mode if a substitute is
  genuinely needed — don't overstate the equivalence") — this epic's
  disposition follows the same discipline.
- The `SessionStart` hook — no MCP equivalent found; MCP has no
  client-lifecycle-hook concept a server can register for. The closest
  incidental analog is the server's own startup code path (which already
  runs once per connection), but that is a different mechanism
  (server-initiated vs. harness-triggered), not a port of the hook.
- Existing no-fake-equivalent policy this epic reuses:
  `scripts/opencode-dist-generate.sh:50-52` — "Claude-Code-only mechanisms
  with no OpenCode equivalent (hooks, ToolSearch, deferred tools,
  TaskOutput, ScheduleWakeup, CronCreate, EnterPlanMode/ExitPlanMode) ->
  drop, or note briefly as unavailable. Do not invent a fake OpenCode
  equivalent."
- No `mcp-server/README.md` exists yet (`ls mcp-server/`, 2026-08-25) —
  this epic's DoD calls for "a new file"; a focused standalone doc (not a
  full README rewrite, out of this epic's scope) is the right size.
