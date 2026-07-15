Feature: The project index is deterministically script-generated
  Scenario: Same input produces byte-identical output
    Given the repo's tracked markdown surface is unchanged                 # F1
    When bash scripts/build-index.sh runs twice                            # F1
    Then both runs write byte-identical .lsa/PROJECT-index.md              # F1, AC1
    And no model call is made                                              # F1, No-go 6

  Scenario: Headings are the descriptions
    Given the .lsa/ live spine files each carry an H1                      # F4
    When the index is generated                                           # F1
    Then each spine file appears with its verbatim H1                      # F4, AC1
    And features/ pitches/ archive/ are collapsed to counts + slug lists   # F4, AC1

  Scenario: The index announces itself as generated
    Given the generator wrote .lsa/PROJECT-index.md                        # F2
    Then it opens with a trace directive and a GENERATED — DO NOT EDIT banner  # F2, AC5
    And loading it prints the file-load trace line                         # F8, AC5
