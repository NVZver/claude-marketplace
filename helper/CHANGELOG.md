# Changelog

All notable changes to the `helper` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

### Added

- Plugin scaffold per step 1 of [`vision/specs/features/2026-05-21-helper-agent/tasks.md`](../vision/specs/features/2026-05-21-helper-agent/tasks.md). Ships: `plugin.json` at v0.1.0, this CHANGELOG, [`./README.md`](./README.md), stub `helper/commands/help.md`, stub `helper/agents/helper.md`. Repo `.claude-plugin/marketplace.json` and root `README.md` updated in the same commit per `CLAUDE.md` *"READMEs are living documents"*. V1 probe ready: `/plugin install helper@NVZver` succeeds, `helper` appears in `/plugin list`. Helper agent body, `/help` command body, and friction-signal detection land in subsequent steps (2–4); both stubs respond with a pointer back to the spec until then.
