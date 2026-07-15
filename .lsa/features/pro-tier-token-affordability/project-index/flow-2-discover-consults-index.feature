Feature: Discovery scopes its reads through the index instead of walking the tree
  Scenario: The read protocol names the index as the scoping map
    Given an LSA skill runs its read protocol                             # F6
    When it reaches the "code/specs the request touches" step             # F6
    Then it consults .lsa/PROJECT-index.md to locate those files first     # F6, AC4
    And lsa/skills/discover/SKILL.md Step 1 names the index                # F6, AC4

  Scenario: A Pro session bounds discovery reads
    Given the repo has 200+ tracked markdown files                        # F6 (context)
    When discover locates the files a request touches                     # F6
    Then it reads the index (<= 1k tokens) rather than walking all files   # F3, F6

  Scenario: An absent index degrades, never blocks
    Given .lsa/PROJECT-index.md does not exist                            # F7
    When the read protocol runs                                           # F6
    Then it notes the gap and falls back to the tree-walk                  # F7
    And no hard error blocks the skill                                     # F7
