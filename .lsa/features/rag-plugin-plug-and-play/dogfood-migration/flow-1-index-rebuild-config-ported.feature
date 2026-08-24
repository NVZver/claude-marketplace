Feature: Real index rebuilds correctly, canonical-paths config ported not regressed

  Scenario: Seeded config covers at least epic 9's original classification
    Given .lsa.yaml has no rag: canonical_paths: block yet
    And docker/rag_cli.py:592-611's now-superseded CANONICAL_PATH_PREFIXES named 17 real entries
    When the 12 non-module entries are added manually and lsa/scripts/seed-canonical-paths.sh is run against this repo
    Then .lsa.yaml's rag: canonical_paths: block covers at least the same 17 paths, plus the ~23 auto-derived module sub-paths
    And lsa/scripts/rag-index.sh rebuilds the full-repo index successfully using this config
