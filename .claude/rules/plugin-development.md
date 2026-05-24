---
paths:
  - "core/**/*"
  - "lsa/**/*"
  - "helper/**/*"
---

# Plugin Development Rules

## Version Management

When modifying any file under `{plugin-name}/`:
1. **Always** bump version in `.claude-plugin/plugin.json`
2. Use semantic versioning: `MAJOR.MINOR.PATCH`
   - PATCH: Bug fixes, typo corrections
   - MINOR: New features, new commands/agents/rules/skills
   - MAJOR: Breaking changes

## File Structure Requirements

### Plugin Manifest

Every plugin must have `.claude-plugin/plugin.json`:

```json
{
  "name": "plugin-name",
  "description": "Clear description",
  "version": "1.0.0",
  "author": { "name": "Author Name" }
}
```

### Commands

- Location: `commands/{verb}.md`
- Frontmatter: `description` required
- Must include: Target, Execution, Output sections

### Agents

- Location: `agents/{role}.md`
- Frontmatter: `name`, `description`, `tools` required
- Purpose section explains when to use

### Rules

- Location: `rules/{topic}.md`
- Frontmatter: `paths` for file matching
- Applied automatically when matching files are active

### Skills

- Location: `skills/{feature}/SKILL.md`
- Optional: `resources/` subdirectory for additional content
- Optional: `knowledge/` for cross-cutting conventions

## Quality Checklist

Before committing plugin changes:

- [ ] Version bumped in plugin.json
- [ ] CHANGELOG.md entry added
- [ ] All cross-references valid (skill/command names match files)
- [ ] README.md updated if user-visible surface changed
- [ ] No broken links in documentation

## Official Documentation Reference

Consult before implementing new patterns:
- https://docs.anthropic.com/en/docs/claude-code/plugins
