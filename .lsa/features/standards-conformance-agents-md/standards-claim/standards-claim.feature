Feature: The Agent Skills conformance claim carries a source

  Scenario: C7 cites the open standard alongside the vendor doc
    Given the C7 banner comment in "scripts/lint.sh"
    When it is read
    Then it still cites "platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices"
    And it also cites "https://agentskills.io/specification"
    And it states that description ≤ 1024 and name↔directory are normative in that spec

  Scenario: C9 cites the open standard alongside the internal fork
    Given the C9 banner comment in "scripts/lint.sh"
    When it is read
    Then it still references the internal pitch fork
    And it also cites "https://agentskills.io/specification"
    And it states the spec recommends bodies under 500 lines

  Scenario: Only comments changed in lint.sh
    Given the completed diff
    When "git diff scripts/lint.sh" runs
    Then every added or changed line begins with "#"
    And "DESC_LIMIT=1024" is unchanged
    And "BODY_LIMIT=500" is unchanged
    And no pass_line or fail_line string is modified

  Scenario: The validator run is transcribed as external evidence
    Given the new section in "core/VERIFICATION.md"
    When it is read
    Then it shows the exact skills-ref command in a fenced code block
    And it records the run date as YYYY-MM-DD
    And it contains the literal string "20/20"
    And it records the counts "core 6", "lsa 7", "manager 5", "observer 2"
    And it cites "https://agentskills.io/specification"

  Scenario: An unrunnable validator is reported honestly, not as a pass
    Given skills-ref cannot be executed in the implementation environment
    When the section is written
    Then the result line carries the literal marker "[unverified]"
    And it states what blocked the run
    And it does NOT claim "20/20" as observed

  Scenario: license and metadata are recorded as deliberately unset
    Given "core/VERIFICATION.md"
    When "grep -n 'license' core/VERIFICATION.md" runs
    Then exactly one line matches
    And that line contains both "license" and "metadata"
    And it states the root LICENSE file is the single source

  Scenario: No skill file is touched
    Given the completed diff
    When the changed paths are listed
    Then no path matching "*/skills/**/SKILL.md" appears
    And no SKILL.md frontmatter gained a "license:" or "metadata:" key

  Scenario: The gate block stays npm-free
    Given ".lsa.yaml"
    When its "gate:" block is compared to the pre-change version
    Then it is byte-identical with the five keys docs-invariants, citations, links, project-map, tests
    And no package.json, package-lock.json, or node_modules/ was added to the repo

  Scenario: Both standards are named by URL on the human-facing surfaces
    Given "README.md" section "Status + substrate" and ".lsa/VISION.md"
    When each is read
    Then both name "https://agents.md/"
    And both name "https://agentskills.io/specification"
    And the README section points at "core/VERIFICATION.md" for the validator evidence
    And the existing tool-agnosticism claim sentence is kept, now sourced

  Scenario: Exactly one plugin version bump
    Given the completed diff
    When the changed files are listed
    Then "core/.claude-plugin/plugin.json" shows its PATCH digit incremented by one
    And "core/CHANGELOG.md" has a matching new entry
    And no other plugin's plugin.json or CHANGELOG.md is modified

  Scenario: The full gate is green
    When "bash scripts/lint.sh", "bash scripts/check-citations.sh", "bash scripts/check-links.sh", "bash lsa/scripts/project-map-check.sh", "bash scripts/run-tests.sh", and "bash scripts/check-version-changelog.sh" each run
    Then each exits 0
