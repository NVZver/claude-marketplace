Parent: [Marketplace-as-MCP-server](../../../pitches/marketplace-mcp-server.md)
Epic: marketplace-mcp-server/agent-prompts
Date: 2026-08-24
Status: draft

# Agent MCP prompts — product-manager, project-manager, orchestrator

Extend the stdio MCP server built in `core-server` to also register
`manager/agents/product-manager.md`, `manager/agents/project-manager.md`,
and `lsa/agents/orchestrator.md` as MCP prompt primitives. Scope was
expanded at discover time beyond the epic's originally-decomposed 2-agent
DoD (product-manager, project-manager only) to include `orchestrator.md` —
confirmed by gate decision this session, since it is also a first-slice
(core+lsa+manager) agent and was omitted from decomposition by oversight.

## User flows

### Flow 1 — Server startup & prompt registration

- **Flow:** The same stdio MCP server built in `core-server` reads
  `manager/agents/product-manager.md`, `manager/agents/project-manager.md`,
  `lsa/agents/orchestrator.md` at startup, in addition to its existing
  tool/resource registration.
- **Success:** Three MCP prompts are registered, one per agent file,
  alongside the existing 18 tools and 17 resources — same server process,
  same stdio transport.
- **I/O:** Input = server startup; Output = `prompts/list` populated.
- **Test:** `prompts/list` returns exactly 3 prompts (`product-manager`,
  `project-manager`, `orchestrator`).

### Flow 2 — Prompt request returns the agent body unchanged, executed by the client, not the server

- **Flow:** A connected client requests a registered prompt (e.g.
  `project-manager`).
- **Success:** The server returns the exact body of the corresponding agent
  `.md` file, byte-identical, as the prompt content — no paraphrase, no
  reformatting. The server makes no outbound network/LLM call while doing
  this and does not itself execute the agent's instructions; running the
  returned content is the connecting client's own responsibility.
- **I/O:** Input = prompt name; Output = prompt message content (text).
- **Test:** request the `project-manager` prompt; response content equals
  the content of `manager/agents/project-manager.md`; the server process
  makes zero outbound network calls while serving the request.

## Requirements (EARS)

1. **While** the server is starting, **when** it reads the configured agent
   files (`manager/agents/product-manager.md`,
   `manager/agents/project-manager.md`, `lsa/agents/orchestrator.md`), **the
   system shall** register one MCP prompt per file, using the file's
   frontmatter `name` as the prompt name and frontmatter `description` as
   the prompt description.
2. **When** a connected client requests a registered prompt, **the system
   shall** return the full body of the corresponding agent file unchanged
   (byte-identical) as the prompt content — no paraphrasing, translation, or
   reformatting.
3. **While** serving prompt requests, **the system shall not** make any
   outbound network or LLM API call, and **shall not** itself execute the
   referenced agent's instructions.
4. **If** an agent file is missing required frontmatter (`name` or
   `description`) **while** the server is starting, **then the system
   shall** skip registering that file as a prompt and **shall not** fail
   server startup.
5. **The system shall** expose prompts over the same stdio transport
   already used for tools and resources, opening no additional network
   listener or second server process.

## Facts this spec is grounded on (from discover)

- Agent file frontmatter shape matches skill frontmatter: YAML with `name`,
  `description`, `tools` keys. `manager/agents/product-manager.md:1-4` (63
  lines total), `manager/agents/project-manager.md:1-4` (114 lines total),
  `lsa/agents/orchestrator.md:1-5` (50 lines total).
- The installed MCP SDK (`mcp-server/package.json`:
  `"@modelcontextprotocol/sdk": "^1.30.0"`) supports prompt primitives
  directly: `McpServer.registerPrompt(name, {title, description,
  argsSchema}, callback)`
  (`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/server/mcp.js:727-733`),
  which wires `prompts/list` and `prompts/get` request handlers (same file,
  lines 397-420) — confirmed feasible with the existing dependency, no new
  package needed.
- Existing server (`mcp-server/src/index.js:1-40`,
  `mcp-server/src/registry.js`) already reads core/lsa/manager trees and
  registers 18 tools + 17 resources over the same `McpServer`
  instance/stdio transport (built in the `core-server` epic,
  `.lsa/features/marketplace-mcp-server/core-server/` — `reconcile: PASS`).
  This epic extends that same server process; it does not stand up a
  second server.
- Existing precedent for the byte-identical-passthrough +
  missing-frontmatter-skip requirements already implemented for
  tools/resources in this same server (`mcp-server/src/registry.js`
  `scanSkills`/`scanKnowledge`) — this epic's registry logic for agents
  follows the same read-unchanged, skip-on-malformed-frontmatter pattern
  already proven and reconciled.
- Confirmed pitch constraint already locked (not open for this spec):
  agents expose as prompt/content only — "the connecting client's own
  agent loop runs it; the server itself never spawns a sub-agent
  conversation or makes its own LLM calls"
  (`.lsa/pitches/marketplace-mcp-server.md` Solution sketch component 3).
