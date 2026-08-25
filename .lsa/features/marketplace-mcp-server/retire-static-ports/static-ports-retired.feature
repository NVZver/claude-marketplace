Feature: Static per-client ports removed with no dangling references

  Scenario: dist/ and its generator scripts are gone
    Given dist/cursor/ (59 files, hand-maintained) and dist/opencode/ (17 files, script-generated) currently exist, both gitignored and untracked
    And scripts/opencode-dist-generate.sh and scripts/opencode-dist-deploy.sh currently exist, committed at a82bd3d
    When the retirement is applied
    Then dist/cursor/ no longer exists
    And dist/opencode/ no longer exists
    And scripts/opencode-dist-generate.sh no longer exists
    And scripts/opencode-dist-deploy.sh no longer exists

  Scenario: The one live dangling-reference consequence is fixed
    Given mcp-server/UNSUPPORTED-MECHANISMS.md cites scripts/opencode-dist-generate.sh:50-52 twice (a markdown link and a bare path:line citation), with the cited policy text already quoted verbatim inline
    When the retirement is applied
    Then neither citation references scripts/opencode-dist-generate.sh as a live path
    And the inline blockquote of the policy text is unchanged
    And "bash scripts/check-citations.sh" and "bash scripts/check-links.sh" both exit 0

  Scenario: README and CONTRIBUTING need no change
    Given README.md and CONTRIBUTING.md contain zero references to dist/cursor, dist/opencode, opencode-dist, OpenCode, or Cursor
    When the retirement is applied
    Then neither file is modified

  Scenario: The repo gate stays green
    When "bash scripts/gate.sh" runs after the retirement
    Then it exits 0
