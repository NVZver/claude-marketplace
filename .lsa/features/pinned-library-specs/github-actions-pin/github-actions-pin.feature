Feature: The actions/checkout pin verifies green — and says what green does not mean

  Background:
    Given ".github/workflows/lint.yml:12" contains "      - uses: actions/checkout@v4"
    And it is the only version-pinned external dependency in this repo

  Scenario: The pinned spec exists in the epic-1 format
    Given ".lsa/libs/actions-checkout.md" exists                               # R1
    Then its metadata block carries "Pinned-Version: v4"                       # R2
    And it carries "Manifest: .github/workflows/lint.yml"                      # R2
    And it carries "Lockfile: .github/workflows/lint.yml"                      # R2
    And it carries "Lockfile-Assertion: actions/checkout@v4"                   # R2
    And it carries a provenance line naming the source and the review          # R4

  Scenario: It covers only what this repo uses
    Given the pinned spec body                                                 # R3
    Then it documents the single call site cited as "path:line"                # R3
    And it states that the call site passes no "with:" parameters              # R3
    And no other action input appears in the body                              # R3

  Scenario: It fits far inside one screen
    When "wc -l .lsa/libs/actions-checkout.md" runs
    Then the count is 60 or fewer                                              # R6

  Scenario: The registered pin resolves OK and the gate goes green
    Given ".lsa.yaml" registers "actions-checkout" with its spec and manifest  # R7
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints a line starting with "  OK" naming "actions-checkout"       # R7
    And it exits 0                                                             # R7
    When "bash scripts/gate.sh" runs
    Then the "lib-pins" check reports PASS                                     # R7
    And "bash scripts/gate.sh" exits 0                                         # R7
    And "lsa:verify" is not blocked by the "lib-pins" check                    # R7

  Scenario: A bump to v5 without re-pinning is STALE
    Given ".github/workflows/lint.yml" is edited to "uses: actions/checkout@v5" # R7
    And ".lsa/libs/actions-checkout.md" still asserts "actions/checkout@v4"     # R2
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints a line starting with "  STALE" naming "actions-checkout"     # R7
    And it exits 1                                                              # R7
    And "bash scripts/gate.sh" exits 1                                          # R7
    And "lsa:verify" yields NOT-GROUNDED per verify/SKILL.md:42                 # R7

  # adversarial — rabbit hole 4: green must not be read as "the dependency is unchanged"
  Scenario: The spec states plainly what a green check does NOT prove
    Given ".lsa/libs/actions-checkout.md"                                      # R5
    Then it states that "v4" is a floating major tag, not an exact version     # R5
    And it states that GitHub moves the tag as new "4.x" releases ship         # R5
    And it states that OK asserts only that this repo's declaration reads v4   # R5
    And it states that OK does NOT assert the upstream action is unchanged     # R5
    And it names pitch rabbit hole 4 as the limitation it instantiates         # R5
    And the caveat is not softened, omitted, or reduced to a parenthetical     # R5

  # adversarial — an upstream 4.x release is invisible to this pin, by construction
  Scenario: An upstream release inside v4 does not move the check
    Given upstream ships a new "4.x" release under the same "v4" tag
    And ".github/workflows/lint.yml" is unchanged
    When "bash scripts/check-lib-pins.sh" runs
    Then it still prints "OK" for "actions-checkout"                           # R5
    And this is a known and documented limitation, not a defect to patch here  # R5

  # adversarial — the preserved rule must survive a green epic
  Scenario: The [cannot verify] rule is untouched
    Given the implemented change                                              # R8
    Then no allowlist, skip flag, "|| true", or exit-code remap exists for
      the "lib-pins" check                                                    # R8
    And a lib with "Lockfile: none" would still exit 2                        # R8
    And no synthetic manifest or lockfile file was created for this pin       # R8

  Scenario: One registered lib keeps the cap green
    When "bash scripts/lint.sh" runs
    Then C18 reports PASS for 1 registered lib                                # R9

  Scenario: A pinned answer is cited with the epic-3 token
    Given epic "conditional-read-precedence" has landed                       # R10
    When a claim is sourced from this pin
    Then it is cited as "lib:actions-checkout:<api> via pin@v4"               # R10

  Scenario: No plugin version bump is triggered
    Given the epic's diff                                                     # R11
    Then it touches only ".lsa/libs/**" and ".lsa.yaml"                       # R11
    And neither path is inside any plugin's "artifact_paths"                  # R11
    And no "plugin.json" version and no plugin "CHANGELOG.md" changes         # R11
