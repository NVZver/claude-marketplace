Feature: Seed script derives a correct starting config from a repo's own module structure

  Scenario: Seed script derives entries from a repo's own modules.*.artifact_paths
    Given a scratch repo with its own .lsa.yaml modules: block (directory names distinct from claude-marketplace's lsa/core/manager/prompt-engineer/observer)
    When lsa/scripts/seed-canonical-paths.sh is run against that scratch repo
    Then the scratch repo's .lsa.yaml gains a rag: canonical_paths: block containing exactly the unique top-level path segments from its own modules.*.artifact_paths
    And any pre-existing hand-added entry in that block is preserved, not deleted
