Feature: Repo name resolution and catalog-tree scaffold
  Scenario: Repo is not created before the name is confirmed
    Given the repo-name gate is open (.lsa/pitches/vendor-neutral-agent-skills-home.md Gate decisions)
    When epic work begins
    Then the placeholder <TBD-repo-name> is used everywhere a name would appear
    And no `gh repo create` command runs

  Scenario: Empty repo created under the confirmed name
    Given the user has confirmed a repo name
    When the repo is created
    Then it is empty with no imported history from claude-marketplace

  Scenario: Catalog layout, not consumer install path, at repo root
    Given the new repo exists
    When the architecture is scaffolded
    Then `skills/<pack>/<name>/SKILL.md` directories exist at root
    And no `.agents/skills/` directory exists at repo root
    And a root `AGENTS.md` file exists
