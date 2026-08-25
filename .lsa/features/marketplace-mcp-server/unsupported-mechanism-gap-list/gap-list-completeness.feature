Feature: Gap-list doc covers every Rabbit-hole-#1 mechanism with an accurate disposition

  Scenario: All 8 mechanisms appear, each with a fact-checked disposition
    Given the pitch's Rabbit hole #1 (.lsa/pitches/marketplace-mcp-server.md:87-89) names 8 mechanisms: AskUserQuestion, ToolSearch, deferred tools, TaskOutput, ScheduleWakeup, CronCreate, EnterPlanMode/ExitPlanMode, the SessionStart hook
    When the new gap-list doc is reviewed
    Then all 8 mechanisms appear, each with a disposition
    And no disposition claims an MCP equivalent absent from the installed SDK (mcp-server/package.json: "@modelcontextprotocol/sdk": "^1.30.0")

  Scenario: AskUserQuestion's disposition reflects the real elicitation/create primitive
    Given the installed MCP SDK implements ElicitRequestSchema (mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/types.js:1729-1783) with form-based and URL-based modes
    When the gap-list doc's AskUserQuestion entry is reviewed
    Then it cites elicitation/create as a partial equivalent, not a blanket "unavailable" claim
    And it names the concrete UI gaps (no per-option preview field, no header chip label, generic JSON-schema form vs Claude Code's specific 2-4-option card picker)
    And it does not claim multiSelect is unsupported (MultiSelectEnumSchemaSchema exists, non-experimental, per types.js:1687-1719)

  Scenario: TaskOutput's disposition reflects the experimental, unstable status of MCP tasks
    Given the installed MCP SDK's server-side tasks feature is marked "@experimental" / "may change without notice" (mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/experimental/tasks/interfaces.d.ts:1-3)
    When the gap-list doc's TaskOutput entry is reviewed
    Then it cites the experimental tasks feature as a partial analog
    And it explicitly flags it as experimental / not a stable, confirmed-supported primitive
