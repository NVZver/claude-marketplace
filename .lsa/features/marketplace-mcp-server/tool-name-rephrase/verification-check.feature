Feature: Grep-based verification finds zero unconditioned tool-name matches

  Scenario: Check passes after the rewrite, correctly excluding the citation pattern
    Given the first-slice tree has been reworded per the rewrite table
    When the grep-based check scans body prose across core/, lsa/, manager/ skill and agent files, excluding frontmatter "tools:" lines
    Then it reports zero unconditioned literal Claude-Code-tool-name matches
    And it does not flag any line matching the "(<ToolName> in Claude Code)" pattern
