Feature: Plugin-shipped RAG engine works standalone against an arbitrary target repo

  Scenario: Build and index a real, unrelated scratch repo with no $CLAUDE_PLUGIN_ROOT set
    Given a real git repository unrelated to claude-marketplace
    And docker/rag_cli.py:406-417's schema (id, path, start_line, end_line, content_hash, embed_model, chunk_schema, text, vector) is already target-repo-agnostic
    And scripts/rag-index.sh:49-51's current repo_root resolution couples build context to the target repo (the coupling this epic removes)
    When the plugin-shipped lsa/scripts/rag-index.sh is invoked directly against that scratch repo, with no $CLAUDE_PLUGIN_ROOT in the environment
    Then the image builds from lsa/docker/Dockerfile (self-located via the script's own path)
    And a working index is produced for the scratch repo
    And zero new files appear in the scratch repo's own tracked tree (only its gitignored .lsa/.rag-index/)

  Scenario: The same shared image tag is reused, not rebuilt per target repo
    Given the plugin-shipped image was already built once against the scratch repo above
    When lsa/scripts/rag-index.sh is invoked again against a second, different scratch repo
    Then no rebuild occurs (source hash unchanged) — the same image tag serves both repos
