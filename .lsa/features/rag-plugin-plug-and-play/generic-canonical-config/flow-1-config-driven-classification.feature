Feature: A target repo's own configured canonical paths drive its ranking boost

  Scenario: A second scratch repo's own canonical_paths correctly differ from claude-marketplace's
    Given a scratch repo with its own .lsa.yaml rag: canonical_paths: block naming a directory unique to that repo
    And lsa/docker/rag_cli.py:592-611's hardcoded CANONICAL_PATH_PREFIXES (the behavior being replaced) would default that repo's directory to "historical"
    When the scratch repo is indexed via lsa/scripts/rag-index.sh
    Then /index/.canonical-paths.txt contains the scratch repo's own configured entries, not claude-marketplace's
    And a subsequent query against that repo boosts content under its own configured canonical directory
