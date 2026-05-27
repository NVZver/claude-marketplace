# Changelog

All notable changes to the `prompt-engineer` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.1.0] – 2026-05-27

Initial release. Migrated from workspace-local `.claude/` files into a standalone marketplace plugin.

### Added

- **Prompt-engineer agent** ([`./agents/prompt-engineer.md`](./agents/prompt-engineer.md)). Principal prompt engineer with six rule categories: actor ground rules (10 rules), knowledge file quality checks (6 rules), separation of concerns (5 boundary violations), KISS/DRY audit (5 rules), AI over-engineering checks (5 rules), context budget checks (4 rules). Three severity levels (HIGH / MEDIUM / LOW).
- **Prompt-review command** ([`./commands/prompt-review.md`](./commands/prompt-review.md)). Scans target prompts against all rule categories and reports findings as a summary + markdown table with severity and rule citation per issue.
- **Prompt-optimize command** ([`./commands/prompt-optimize.md`](./commands/prompt-optimize.md)). Applies fixes for issues found by prompt-review, grouped by severity. Re-verifies after fixes; iterates until clean or same issue recurs.
- **Prompt-create command** ([`./commands/prompt-create.md`](./commands/prompt-create.md)). Scaffolds a new agent or command file with all required sections filled, then runs prompt-review for compliance verification.
- **Plugin manifest** ([`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)) at v0.1.0.
- **README** ([`./README.md`](./README.md)). Install instructions, command table, agent description.

### Removed

- **Workspace-local files.** `.claude/agents/prompt-engineer.md`, `.claude/commands/prompt-review.md`, `.claude/commands/prompt-create.md`, `.claude/commands/prompt-optimize.md` deleted — replaced by this plugin.
