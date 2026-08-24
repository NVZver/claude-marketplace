Parent: [Marketplace-as-MCP-server](../../../pitches/marketplace-mcp-server.md)
Epic: marketplace-mcp-server/core-server
Date: 2026-08-24
Status: draft

# Core MCP server — skill/knowledge registration

Stand up a stdio MCP server that, at startup, reads the existing `core/`, `lsa/`,
`manager/` Markdown trees with zero content duplication and registers each
`SKILL.md` as a callable MCP tool and each `knowledge/*.md` file as a readable
MCP resource.

## User flows

### Flow 1 — Server startup & primitive registration

- **Flow:** An MCP client (Cursor, VS Code, Antigravity, etc.) spawns the
  marketplace MCP server as a stdio subprocess per its own MCP client config.
- **Success:** The server reads `core/skills/`, `core/knowledge/`,
  `lsa/skills/`, `lsa/knowledge/`, `manager/skills/`, `manager/knowledge/`
  from the repo tree at startup and registers one MCP tool per `SKILL.md` and
  one MCP resource per knowledge `*.md` file — reading source files directly,
  never a copied/duplicated tree.
- **I/O:** Input = client's stdio spawn; Output = server ready, `tools/list`
  and `resources/list` populated.
- **Test:** `tools/list` returns 18 tools (6 core + 7 lsa + 5 manager, per the
  discover inventory); `resources/list` returns 17 resources (2 core + 5 lsa +
  10 manager).

### Flow 2 — Tool invocation returns the skill body unchanged

- **Flow:** A connected client calls a registered tool (e.g. the
  `ground-rules` tool).
- **Success:** The server returns the exact Markdown body of the
  corresponding `SKILL.md`, byte-identical — no paraphrase, no reformatting,
  no translation.
- **I/O:** Input = tool name (+ no required args); Output = Markdown text.
- **Test:** call the `ground-rules` tool; response equals the content of
  `core/skills/ground-rules/SKILL.md`.

### Flow 3 — Resource read returns the knowledge file unchanged

- **Flow:** A connected client reads a registered resource (e.g. a knowledge
  file).
- **Success:** The server returns the exact content of the corresponding
  knowledge file, byte-identical.
- **I/O:** Input = resource URI; Output = Markdown text.
- **Test:** read the resource for `lsa/knowledge/conventions.md`; response
  equals that file's content.

## Requirements (EARS)

1. **While** the server is starting, **when** it reads the configured
   `core/`, `lsa/`, `manager/` skill directories, **the system shall**
   register one MCP tool per `SKILL.md` file found, using the file's
   frontmatter `name` as the tool name and frontmatter `description` as the
   tool description.
2. **While** the server is starting, **when** it reads the configured
   `core/`, `lsa/`, `manager/` knowledge directories, **the system shall**
   register one MCP resource per Markdown file found, keyed by its source
   file path.
3. **When** a connected client invokes a registered tool, **the system
   shall** return the full body of the corresponding `SKILL.md` file
   unchanged (byte-identical) — no paraphrasing, translation, or
   reformatting.
4. **When** a connected client reads a registered resource, **the system
   shall** return the full content of the corresponding knowledge file
   unchanged (byte-identical).
5. **While** serving tool calls and resource reads, **the system shall
   not** make any outbound network or LLM API call.
6. **The system shall** communicate exclusively over stdio, opening no
   network listener.
7. **If** a `SKILL.md` file is missing required frontmatter (`name` or
   `description`) **while** the server is starting, **then the system
   shall** skip registering that file as a tool and **shall not** fail
   server startup.

## Facts this spec is grounded on (from discover)

- No existing MCP implementation anywhere in-repo (`grep -rli mcp` across
  `*.md`/`*.json`/`*.sh` outside `dist/` found only prose mentions of the
  `context7` MCP as an external tool — `core/skills/ground-rules/SKILL.md:100`,
  `lsa/knowledge/conventions.md:50` — not a server).
- No root `package.json`/`pyproject.toml`/`Cargo.toml`/`go.mod` exists (repo
  root listing, 2026-08-24) — no language/runtime is pre-selected
  (`.lsa/pitches/marketplace-mcp-server.md` No-go #4 defers the SDK/language
  pick past shaping).
- First-slice inventory (core+lsa+manager): `core/skills/` has 6 `SKILL.md`
  (actor-template, doctor, flow-selector, ground-rules, output, reuse-first) +
  `core/knowledge/` has 2 files; `lsa/skills/` has 7 `SKILL.md` (delegate,
  discover, init, reconcile, revise-constitution, specify, verify) +
  `lsa/knowledge/` has 5 files; `manager/skills/` has 5 `SKILL.md` (check,
  decompose, implement, next, shape) + `manager/knowledge/` has 10 files.
  Total: 18 skills as tools, 17 knowledge files as resources. Agent files
  (`lsa/agents/orchestrator.md`, `manager/agents/product-manager.md`,
  `manager/agents/project-manager.md`) are explicitly OUT of this epic — see
  the sibling `marketplace-mcp-server/agent-prompts` epic.
- `SKILL.md` frontmatter shape (`core/skills/ground-rules/SKILL.md:1-3`):
  YAML with `name` and `description` keys, matching MCP tool `name`/
  `description` fields directly with no reshaping needed.
- The static-copy precedent this epic's live server replaces:
  `scripts/opencode-dist-generate.sh` drives `claude -p` to LLM-translate each
  source skill into a duplicated, drifting copy in `dist/opencode/`
  (`scripts/opencode-dist-generate.sh:129-140` loops the same core+manager+lsa
  skill names this epic must register directly from source). This epic's
  server must read source Markdown live at startup — zero duplicated content.
- No `mcp` or `mcp-server` module is declared in `.lsa.yaml`'s `modules:` map
  (`.lsa.yaml:62-113` lists core, lsa, manager, prompt-engineer, observer
  only).

## Open assumption (not a numbered requirement — build-time layout, not behavior)

Where the server's own source code lives is undecided. Proposed: a new
top-level `mcp-server/` directory, sibling to `core/`, `lsa/`, `manager/` —
matching this repo's existing top-level-per-component convention, requiring a
new `mcp-server` entry in `.lsa.yaml`'s `modules:` map. `[ASSUMPTION]` —
confirm at `lsa:verify` before delegation.
