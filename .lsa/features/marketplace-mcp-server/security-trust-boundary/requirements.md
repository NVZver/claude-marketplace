Parent: [Marketplace-as-MCP-server](../../../pitches/marketplace-mcp-server.md)
Epic: marketplace-mcp-server/security-trust-boundary
Date: 2026-08-25
Status: draft

# SECURITY.md trust-boundary update

Update `SECURITY.md` to accurately describe the new `mcp-server/` local
server, replacing the now-stale "There is no server, no hosted service"
claims with an accurate trust-boundary description — local, stdio-spawned,
no network listener, no outbound calls, no credentials, no PII.

## User flow

### Flow 1 — SECURITY.md accurately describes the new local MCP server's trust boundary

- **Flow:** A prospective installer or security reviewer reads
  `SECURITY.md` to decide whether to trust and install this marketplace.
- **Success:** The stale "no server, no hosted service" claims are
  replaced with an accurate description — a local, stdio-spawned,
  no-credentials, no-network-listener, no-outbound-calls server — with the
  same evidentiary rigor (citations, "what it does and does not do") the
  doc already uses for the `SessionStart` hook. No new secrets/PII/
  network-exposure claim is introduced, because none exists.
- **I/O:** Input = current `SECURITY.md` + the proven facts about
  `mcp-server/`; Output = updated `SECURITY.md`.
- **Test:** Human review confirms the update matches the pitch's confirmed
  gate decisions and introduces no new secrets/PII/network-exposure claim;
  `scripts/check-citations.sh` and `scripts/check-links.sh` (already part
  of the repo gate) pass on every new citation/link.

## Requirements (EARS)

1. **The system shall** replace `SECURITY.md:3-4`'s "There is no server, no
   hosted service" claim with an accurate statement that a local,
   stdio-spawned MCP server now exists, scoped precisely (local only, no
   network listener, no outbound calls, no credentials, no PII).
2. **The system shall** replace `SECURITY.md:37,45-46`'s "No server, no
   network service..." claim in the "What this project is" section with
   the same corrected scoping.
3. **The system shall** add one new subsection, following the existing
   `## The SessionStart hook` subsection's "what it does and does not do"
   pattern, describing the MCP server: what it reads, what it returns,
   that it opens no network listener, makes no outbound calls, and is
   spawned by the connecting client's own config (not a standalone
   daemon).
4. **The system shall** add one new row to the "Summary of controls" table
   citing the no-network-listener / no-outbound-calls property and its
   source.
5. **The system shall not** introduce any claim of secret handling, PII
   processing, or network exposure for the MCP server, since none exists
   in the shipped implementation.
6. **Every new citation** (`path:line` or URL) **the system adds**
   **shall** resolve — verified by `scripts/check-citations.sh` and
   `scripts/check-links.sh`.

## Facts this spec is grounded on (from discover)

- Current stale claims to correct: `SECURITY.md:3-4` "There is no server,
  no hosted service, and no secret or PII handling — the entire product is
  Markdown instruction files plus one shell hook." `SECURITY.md:37,45-46`
  "There is no executable application in this repo beyond shell
  scripts... No server, no network service, no database, no credential
  store, no PII processing."
- `mcp-server/` genuinely exists now (shipped across 3 already-reconciled
  epics: `core-server`, `agent-prompts`, `unsupported-mechanism-gap-list`)
  with these independently-proven properties:
  - stdio transport only, no network listener — proven at
    `.lsa/features/marketplace-mcp-server/core-server/conformance.md:87`
    (grep for `listen(`/`createServer`/`http.`/`net.` → no matches; only
    `StdioServerTransport` constructed).
  - zero outbound network/LLM API calls — proven at
    `core-server/conformance.md:86` and
    `agent-prompts/conformance.md:59,125` (grep for
    fetch/http/net/axios/websocket/anthropic/openai → no matches; manual
    full-file read of the actual callback code confirmed nothing but
    file-read-and-return).
  - only two direct dependencies: `@modelcontextprotocol/sdk`,
    `gray-matter` (`mcp-server/package.json`) — no credential-handling
    libraries, no database client, no PII-processing library.
  - spawned by the connecting client's own MCP config (stdio, not a
    standalone daemon) — confirmed pitch gate decision
    (`.lsa/pitches/marketplace-mcp-server.md` Gate decisions: "local
    transport = stdio process, spawned by each client's own MCP config").
  - additive to Claude Code's native plugin path — confirmed pitch gate
    decision ("CC scope = additive... Claude Code keeps its native plugin
    format + SessionStart hook").
  - reads and serves this repo's own already-public Markdown content
    (skills, knowledge, agent files) unchanged — no new data source, no
    secrets, no PII (same content already shipped in the plugins
    themselves).
- `SECURITY.md`'s existing "Summary of controls" table
  (`SECURITY.md:314-323`) is the established place to add a one-line
  control row; the existing "## The SessionStart hook (what actually runs
  on your machine)" subsection (`SECURITY.md:210`) is the established
  pattern/precedent for a dedicated "what it does and does not do"
  subsection for a new mechanism.
- DoD is explicitly human-review-gated ("human review confirms the update
  matches the confirmed gate decisions and introduces no new
  secrets/PII/network-exposure claim") — no automated test can prove a
  security-narrative document is accurate; the acceptance mechanism is
  human review + citation-checking (`scripts/check-citations.sh`,
  `scripts/check-links.sh`, already part of the repo gate).
