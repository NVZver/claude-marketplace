# Unsupported mechanisms

`marketplace-mcp-server` exposes this repo's skills/knowledge/agents to any
MCP client, not just Claude Code. Claude Code itself offers a few
harness-level mechanisms that have no protocol-level definition in MCP.
This doc lists all 8 such mechanisms named in the parent pitch's
[Rabbit hole #1](../.lsa/pitches/marketplace-mcp-server.md#rabbit-holes),
each with a disposition fact-checked against the installed MCP SDK
(`@modelcontextprotocol/sdk` `^1.30.0`, see `mcp-server/package.json`).

Two mechanisms have a genuine partial equivalent in MCP; the other six do
not. Where no equivalent exists, this doc says so plainly rather than
inventing one — following the same no-fake-equivalent policy already
applied to the OpenCode port at
[`scripts/opencode-dist-generate.sh:50-52`](../scripts/opencode-dist-generate.sh#L50-L52):

> Claude-Code-only mechanisms with no OpenCode equivalent (hooks,
> ToolSearch, deferred tools, TaskOutput, ScheduleWakeup, CronCreate,
> EnterPlanMode/ExitPlanMode) -> drop, or note briefly as unavailable. Do
> not invent a fake OpenCode equivalent.

## `AskUserQuestion`

**Disposition: partial equivalent exists.**

MCP's `elicitation/create` request
(`ElicitRequestSchema`, `mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/types.js:1729-1783`)
lets a server ask the connecting client to collect user input, in two
modes:

- **Form-based** — a message plus a `requestedSchema`: a restricted,
  non-nested JSON Schema object whose top-level properties can be
  `enum`, `boolean`, `string`, or `number`.
- **URL-based** — a message plus a URL the client should navigate the
  user to.

This is a real, spec-level primitive, not a workaround, and it's usable
for confirmation gates today. It is not a full port of Claude Code's
`AskUserQuestion`, though. Multi-select IS supported natively — the enum
schema includes a non-experimental `MultiSelectEnumSchemaSchema`
(`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/types.js:1687-1719`:
an `array` of enum-backed items, with optional
per-option titles and `minItems`/`maxItems`). The real remaining gaps:

- No per-option `preview` field.
- No `header` chip-label field.
- It's a generic JSON-schema form, not Claude Code's specific card-based
  picker UI. Claude Code's own `AskUserQuestion` tool schema caps each
  question at 2-4 options; MCP's enum schema has no such cap, and a
  client can render an `enum`/multi-select property however it likes.

## `TaskOutput`

**Disposition: partial analog exists, but experimental and unstable.**

The installed SDK ships an experimental server-side tasks feature
(`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/experimental/tasks/`)
offering task create/get/list/cancel — a partial analog for checking on
background work. Both
`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/experimental/tasks/interfaces.d.ts:1-3`
and
`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/experimental/tasks/server.d.ts:1-5`
carry the same warning verbatim:

> WARNING: These APIs are experimental and may change without notice.

Treat this as informational, not something to build on yet: client-side
support for it is unconfirmed, and the SDK itself does not treat it as a
stable primitive.

## `ToolSearch` and deferred tools

**Disposition: dropped — no MCP equivalent.**

No protocol-level analog was found in the installed SDK for either
`ToolSearch` or Claude Code's deferred-tool listing.

This gap is also moot for this specific server. `mcp-server/src/index.js`
already registers its full tool set directly via `tools/list` at
startup — currently 18 tools, one per `SKILL.md` under
`core/skills/`, `lsa/skills/`, and `manager/skills/` (`buildServer()`,
`mcp-server/src/index.js:47-66`). The progressive-disclosure problem
`ToolSearch` solves in a large Claude Code session with many available
tools doesn't arise here.

## `ScheduleWakeup`

**Disposition: dropped — no MCP equivalent.**

`ScheduleWakeup` is a Claude Code harness-level scheduling primitive. MCP
has no equivalent concept.

## `CronCreate`

**Disposition: dropped — no MCP equivalent.**

`CronCreate` is a Claude Code cloud-scheduling primitive. MCP has no
equivalent concept.

## `EnterPlanMode` / `ExitPlanMode`

**Disposition: dropped — no MCP equivalent.**

These toggle a client-side UI mode; a server cannot invoke them, and MCP
defines no such mode-toggle mechanism. Don't overstate a substitute here —
the same discipline already applied when porting to OpenCode
(`scripts/opencode-dist-generate.sh:50-52`) noted only that OpenCode's
Tab-key Plan/Build toggle is a loose analog "if a substitute is genuinely
needed," without claiming equivalence. No comparable analog is claimed
for MCP clients generally, since MCP has no UI-mode concept at all.

## The `SessionStart` hook

**Disposition: dropped — no MCP equivalent.**

This repo's one shell hook (`SECURITY.md:5`: "Markdown instruction files
plus one shell hook") fires on Claude Code's `SessionStart` event. MCP
has no client-lifecycle-hook concept a server can register for.

The server's own startup code path (`buildServer()` in
`mcp-server/src/index.js`, which runs once per connection) is *not* a
port of this hook — it's a different mechanism entirely: server-initiated
setup, not a callback triggered by harness lifecycle events.
