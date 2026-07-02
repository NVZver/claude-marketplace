> **Trace.** On load, print first: `=============== [.lsa/features/2026-07-01-plugin-discipline-commit-hook/requirements.md] [vision] ===============`

# Feature: plugin-discipline commit hook (STRICT · repo-internal)

> Source: approved pitch *plugin-discipline-commit-hook (fork: STRICT + REPO-INTERNAL)*. Fork decision locked: PreToolUse on `Bash` `git commit`; HARD BLOCK on violation; hosted in repo-internal `.claude/settings.json` (never shipped in a plugin).

## Summary

A deterministic guardrail that moves the forgettable, memory-enforced per-plugin
commit discipline onto a mechanical check. Before any `git commit` runs in THIS
repo, a PreToolUse hook inspects the staged set: for every plugin whose files are
staged, it verifies the same-commit trio — a `version` bump in
`<plugin>/.claude-plugin/plugin.json`, a new `<plugin>/CHANGELOG.md` entry, and the
`> **Trace.** On load, print first:` directive on every staged new/edited
`SKILL.md` and `agents/**/*.md`. It **detects and reports only** — never edits, never
auto-fixes. A violation blocks the commit (exit 2) with an actionable per-plugin
message. The hook is **repo-internal** (registered in `.claude/settings.json`, not in
any plugin), so it preserves `SECURITY.md`'s "exactly one shipped hook" story and
**no-ops in consumer repos**.

Discipline sourced from: `.lsa/standards/code.md:22` (*"Bump the version in the same
commit as the changelog entry. No exceptions."*) and `.claude/rules/plugin-development.md`
(version bump + CHANGELOG + trace, checklist lines ~59-68).

**Repo-internal → no plugin version bump / no plugin CHANGELOG entry.** This change
edits repo infra only (`.claude/`, `.lsa/`, `SECURITY.md`) — it touches no
`<plugin>/` artifact — mirroring the `scripts/lint.sh` precedent
(`SECURITY.md:40-43`: *"Repo-internal only — NOT shipped in any plugin … it triggers
no plugin version bump or CHANGELOG entry."*).

## Functional Requirements

EARS form per `.lsa/VISION.md:204`.

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | **Trigger scoping.** When a `Bash` tool call is about to run and its command is a `git commit`, the system shall run the commit-discipline check; for any non-`git-commit` `Bash` command (or an unparseable payload) the system shall exit 0 (no-op). | Must |
| F2 | **Repo self-detection.** While evaluating a `git commit`, if the repository root lacks `.claude-plugin/marketplace.json` (the marketplace fingerprint) — i.e. this is a consumer repo or a non-repo directory — the system shall exit 0 without inspecting any files. | Must |
| F3 | **Plugin discovery.** The system shall treat as a plugin exactly those top-level directories that contain `.claude-plugin/plugin.json`, so repo-internal infra (`scripts/`, `.lsa/`, `.claude/`, `tests/`, root docs) is exempt by construction. | Must |
| F4 | **Version-bump check.** When a plugin has ≥1 staged file, the system shall require a staged change to a `"version":` line in `<plugin>/.claude-plugin/plugin.json`; if absent it shall record a violation for that plugin. | Must |
| F5 | **CHANGELOG check.** When a plugin has ≥1 staged file, the system shall require the first `## [x.y.z]` SemVer heading in the staged `<plugin>/CHANGELOG.md` (skipping `## [Unreleased]`) to equal the staged `plugin.json` `"version"`; if it differs or is absent it shall record a violation for that plugin. *(Hardened from "≥1 staged added line" by epic `deterministic-enforcement-gates/commit-hook-hardening`, 2026-07-02 — drift absorbed per Level 2.5.)* Additionally, when a merge is in progress (`$GIT_DIR/MERGE_HEAD` exists) the system shall exit 0 before this and the F4 check (the bump landed on the branch). | Must |
| F6 | **Trace-directive check.** For every staged, non-deleted `<plugin>/**/SKILL.md` and `<plugin>/**/agents/**/*.md`, the system shall require the staged content to contain the line `> **Trace.** On load, print first:`; if absent it shall record a violation naming that file. | Must |
| F7 | **Block semantics.** When ≥1 violation is recorded, the system shall print an actionable per-plugin message to stderr (naming each plugin and each missing item) and exit 2 (PreToolUse BLOCK); when no violation is recorded it shall exit 0 silently. | Must |
| F8 | **Detect-and-report only.** The system shall never write, modify, stage, or auto-fix any file, and shall make no network calls — it runs read-only git plumbing only. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | **Transparency & minimal surface** (`SECURITY.md` hook-transparency contract, `SECURITY.md:210-242`). The hook runs only read-only git plumbing (`git rev-parse`, `git diff --cached`, `git show`), never writes, never calls the network. Documented in `SECURITY.md`. |
| NF2 | **One shipped hook preserved.** This is a repo-internal PreToolUse check in `.claude/settings.json`, NOT shipped in any plugin. The `lsa` SessionStart hook remains the only *shipped* hook (`SECURITY.md:212-216`). |
| NF3 | **No consumer-repo firing** (F2). The check exits 0 whenever the marketplace fingerprint is absent. |
| NF4 | **Style parity with the drift hook.** Bash with `set -uo pipefail`, `trap 'exit 0' ERR`, and jq/sed dual-path payload parse — mirrors `lsa/hooks/session-start-drift-check.sh`. |
| NF5 | **Repo-internal → no plugin SemVer/CHANGELOG.** No `<plugin>/` artifact changes, so no plugin version bump or plugin CHANGELOG entry (`SECURITY.md:40-43` precedent). |

## Acceptance Scenarios (Gherkin)

```gherkin
Feature: plugin-discipline commit hook

  Background:
    Given the repository root contains .claude-plugin/marketplace.json
    And a plugin "alpha" with .claude-plugin/plugin.json, CHANGELOG.md, and skills/foo/SKILL.md

  Scenario: Non-commit command is ignored
    Given a Bash tool call whose command is "git status"
    When the hook runs
    Then it exits 0 and prints nothing

  Scenario: Compliant plugin change passes
    Given staged edits to alpha/skills/foo/SKILL.md (with the trace directive)
    And a staged "version" bump in alpha/.claude-plugin/plugin.json
    And a staged added line in alpha/CHANGELOG.md
    When a "git commit" is about to run
    Then the hook exits 0 and prints nothing

  Scenario: Plugin edit without version bump or changelog is blocked
    Given a staged edit to alpha/skills/foo/SKILL.md
    And no staged change to alpha/.claude-plugin/plugin.json
    And no staged addition to alpha/CHANGELOG.md
    When a "git commit" is about to run
    Then the hook exits 2
    And stderr names "[alpha]" and lists the missing version bump and CHANGELOG entry

  Scenario: New SKILL.md missing the trace directive is blocked
    Given a staged new file alpha/skills/bar/SKILL.md without the trace directive
    And a staged version bump and CHANGELOG entry for alpha
    When a "git commit" is about to run
    Then the hook exits 2
    And stderr names "alpha/skills/bar/SKILL.md" as needing the trace directive

  Scenario: Repo-internal infra change is exempt
    Given the only staged file is scripts/tool.sh
    When a "git commit" is about to run
    Then the hook exits 0 and prints nothing

  Scenario: Consumer repo never fires
    Given the repository root has no .claude-plugin/marketplace.json
    And a staged edit under a plugin-shaped directory
    When a "git commit" is about to run
    Then the hook exits 0 and prints nothing
```

## Inputs & Outputs

- **Input.** The PreToolUse JSON envelope on stdin (`.tool_input.command`); the staged git index of the current repo.
- **Output.** Exit 0 (silent) on compliance / no-op; exit 2 with an actionable per-plugin stderr message on violation. No file writes.

## Artifacts

- `.claude/hooks/commit-discipline-check.sh` — the hook (new).
- `.claude/settings.json` — PreToolUse registration matching `Bash` (edited).
- `SECURITY.md` — hook documentation + "one shipped hook" wording update (edited).
- `.lsa/features/2026-07-01-plugin-discipline-commit-hook/requirements.md` — this spec (new).
