Feature: SECURITY.md accurately reflects the new local MCP server

  Scenario: Stale "no server" claims are corrected, no new risk claim is introduced
    Given SECURITY.md:3-4 and SECURITY.md:37,45-46 currently claim "no server, no hosted service" / "No server, no network service... no credential store, no PII processing"
    And mcp-server/ is proven (core-server, agent-prompts, unsupported-mechanism-gap-list conformance.md) to be stdio-only, zero outbound calls, only 2 dependencies (@modelcontextprotocol/sdk, gray-matter), spawned by the connecting client's own config
    When SECURITY.md is reviewed after this epic
    Then the stale claims are replaced with an accurate local/stdio/no-network/no-credentials description
    And no new claim of secret handling, PII processing, or network exposure appears anywhere in the file

  Scenario: New subsection follows the existing hook-transparency pattern
    Given "## The SessionStart hook (what actually runs on your machine)" (SECURITY.md:210) is the established "what it does and does not do" pattern for a shipped mechanism
    When the new MCP-server subsection is reviewed
    Then it follows the same pattern: what it reads, what it returns, no network listener, no outbound calls, how it's spawned

  Scenario: Every new citation resolves
    Given the repo gate configures citations and links checks (.lsa.yaml gate: citations, links)
    When "bash scripts/check-citations.sh" and "bash scripts/check-links.sh" run against the updated SECURITY.md
    Then both exit 0
