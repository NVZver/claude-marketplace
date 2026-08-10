Feature: npx skills install proof and fallback documentation
  Scenario: npx skills fans migrated skills into a consumer checkout
    Given the new repo is published with skills/core/ground-rules and skills/core/output
    When `npx skills add <org>/<repo>` runs from a scratch consumer checkout
    Then both skills appear under that checkout's `.agents/skills/`

  Scenario: Manual copy is documented as the fallback
    Given the new repo's README/CONTRIBUTING is written
    When a reader checks the install section
    Then it documents manual file-copy as an always-available fallback
    And it states that `npx skills` is a third-party Vercel Labs tool, not the protocol itself
