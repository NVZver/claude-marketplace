Feature: AGENTS.md is the single home of the always-on discipline

  Scenario: A non-Claude-Code reader gets the full discipline from AGENTS.md
    Given a clone of the repo with no Claude Code installed
    When the reader opens "AGENTS.md" at repo root
    Then it contains the always-on discipline verbatim
    And it contains the literal string "The always-on card lives at" exactly once
    And every relative link in it resolves to an existing file

  Scenario: CLAUDE.md is an import plus Claude-Code-specific lines only
    Given the rewired root "CLAUDE.md"
    When "wc -l < CLAUDE.md" runs
    Then the value is 20 or less
    And the file contains a line equal to "@AGENTS.md"
    And the file does NOT contain "The always-on card lives at"
    And the only remaining prose is the Claude-Code-specific install block and the /core:doctor pointer

  Scenario: Install step 2 names a tool-conditional destination
    Given "README.md" install step 2
    When it is read
    Then the source fragment link is still "[`core/CLAUDE.md`](./core/CLAUDE.md)"
    And the destination names "CLAUDE.md" for Claude Code
    And the destination names "AGENTS.md" for every other agent tool
    And the sentence "This is the step that activates the always-on rules — skip it and the discipline layer silently never engages." is preserved verbatim

  Scenario: C16 passes on the clean tree
    Given the repo with the discipline text only in "AGENTS.md"
    When "bash scripts/lint.sh" runs
    Then a PASS line naming "C16" is printed
    And it exits 0

  Scenario: NEGATIVE CONTROL — C16 fails when a second copy of the discipline exists
    Given a scratch file "scratch-c16-probe.md" at repo root
    And it contains the line "The always-on card lives at [core/CLAUDE.md](./core/CLAUDE.md)."
    When "bash scripts/lint.sh" runs
    Then it exits 1
    And the output contains a FAIL line whose text includes "C16"
    And that FAIL line's indented paths include both "AGENTS.md" and "scratch-c16-probe.md"

  Scenario: NEGATIVE CONTROL — deleting the duplicate restores a green lint
    Given the failing state from the previous scenario
    When "scratch-c16-probe.md" is deleted
    And "bash scripts/lint.sh" runs
    Then a PASS line naming "C16" is printed
    And it exits 0

  Scenario: C16 fails when the discipline text is missing entirely
    Given "AGENTS.md" does not contain "The always-on card lives at"
    When "bash scripts/lint.sh" runs
    Then it prints a FAIL line whose text includes "C16" and states the marker is missing from AGENTS.md
    And it exits 1

  Scenario: C15 and the doctor fragment check are untouched
    Given the change is complete
    When "bash scripts/lint.sh" runs
    Then C15 passes for ".lsa/VISION.md"
    And C15 passes for "core/CLAUDE.md"
    And "core/skills/doctor/SKILL.md" is unchanged in the diff
    And "core/CLAUDE.md" still exists at that exact path

  Scenario: Exactly one plugin version bump
    Given the completed diff
    When the changed files are listed
    Then "core/.claude-plugin/plugin.json" shows version "0.21.0"
    And "core/CHANGELOG.md" has a new "[0.21.0]" entry
    And no other plugin's plugin.json or CHANGELOG.md is modified

  Scenario: The full gate is green
    When "bash scripts/lint.sh", "bash scripts/check-citations.sh", "bash scripts/check-links.sh", "bash lsa/scripts/project-map-check.sh", "bash scripts/run-tests.sh", and "bash scripts/check-version-changelog.sh" each run
    Then each exits 0
