# Changelog

All notable changes to the `prompt-engineer` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.7.0] – 2026-06-12

Adopts the `core` 0.13.0 **gate-delivery contract** for the one approval-gated artifact this plugin produces.

### Changed

- **`prompt-engineer/commands/prompt-create.md` Step 7 + Output** — *write → show → confirm* inverted to **show → approve → write** (`core/output` Rule 7 *Authorization boundary*): the full generated content is delivered per the Rule 7 *Delivery test* (turn-final message or gate `preview`), approval runs via `AskUserQuestion`, and only then is the file written; on reject, nothing is written (Output/Example now cover the reject path).

### Fixed

- **`prompt-engineer/commands/prompt-review.md` check (l) + `prompt-engineer/README.md`** — dropped the claim that `lsa:verify` runs the complementary PR-time runtime-artifact scan (never implemented — removed from the canonical enforcement section in `core` 0.13.0); the stale `lsa:reconcile` 8-element-block cite now points at `core/output` Rule 7's *Single-change template*.

### Why

Sibling of `core` 0.13.0 (contract definition), `lsa` 0.17.0, `management` 0.6.0, `helper` 0.5.0. The triggering failure and full audit live in `core/CHANGELOG.md` 0.13.0 §Why.

## [0.6.0] – 2026-06-08

Review rule: no volatile component counts.

### Added

- **`prompt-engineer/knowledge/quality-checks.md`** — KISS/DRY rule 6: describe a surface by capability, not by counting components ("an agent and commands", not "one agent and three commands"); the inventory lives in the README table; counts return at release. Applies to components, not rule tallies. Enforced via `prompt-review`'s KISS/DRY check on prompt-file descriptions.

### Changed

- **`prompt-engineer/.claude-plugin/plugin.json`**, **`prompt-engineer/README.md`** — descriptions de-count components (self-applying rule 6).

## [0.5.0] – 2026-06-08

Review scope — defer to leaner actor contracts.

### Changed

- **`prompt-engineer/knowledge/actor-ground-rules.md`** — new "Scope" note: rules 4 and 10 (Output spec + Example Output) defer to a leaner documented contract when the actor follows one — `core/actor-template` (Goal/Input/Steps/Output/Constraints) or `lsa/CORE.md` §4 (Role/Goal/Inputs/Steps/Output). `prompt-review` no longer flags LSA skills/agents or `core/actor-template`-shaped actors for a missing Example Output. Resolves the false positives surfaced by the cross-plugin review (8 LSA actors + helper.md).

## [0.4.0] – 2026-06-08

Testability — repo-anchored self-tests + portable verification, matching the harness `core` ships with.

### Added

- **`tests/repo-anchored.md`** — 10 dogfood probes pinned to repo files, each citing a `file:line` source of truth. Sets: agent self-consistency (references-not-inlines, a grep invariant that the ground-rules list lives only in `knowledge/`, self-review-clean), `prompt-review` (every finding cites a rule, the show-changes-inline check is present, a behavioral catch of HIGH/MEDIUM/LOW on a command sample, a behavioral WARNING on a `**/SKILL.md` sample), `prompt-optimize` (fixes quoted inline, re-review confirms resolution), `prompt-create` (all sections quoted inline before the verdict, asks on missing input). The B3/B4 behavioral probes were calibrated against a fresh reviewer — findings matched exactly.
- **`VERIFICATION.md`** — portable probes (installs cleanly, description-match triggers, behavior change observable) + a falsifiable trigger threshold mirroring [`../core/VERIFICATION.md`](../core/VERIFICATION.md).

## [0.3.0] – 2026-06-02

Author-time show-changes-inline regression check + self-compliance.

### Added

- **`prompt-engineer/commands/prompt-review.md`** — new warning-only check (Step 3 item `l`): in prompt SOURCE files (`**/SKILL.md`, `**/agents/*.md`), flags any step body describing a write/edit/mark action without an accompanying show-changes-inline directive. Read/dispatch/present-only steps are exempt. Author-time half of `core/output` Rule 7 enforcement; the PR-time half lives in `lsa:verify`. README + Example Output table updated.

### Changed

- **`prompt-engineer/commands/prompt-create.md`**, **`prompt-optimize.md`** — generated / fixed content is now quoted inline before the verdict (self-compliance with the new check).

## [0.2.0] – 2026-05-27

Prompt audit remediation — knowledge extraction from agent. The agent file (161→58 lines) no longer inlines rules; six rule categories now live in dedicated knowledge files. All three commands updated to reference knowledge files directly instead of reading the agent.

### Added

- **`knowledge/separation-of-concerns.md`** — classification table (Actor vs Knowledge) and 5 boundary violation rules. Extracted verbatim from the agent.
- **`knowledge/actor-ground-rules.md`** — 10 actor ground rules + format template. Extracted verbatim from the agent.
- **`knowledge/quality-checks.md`** — knowledge quality (6 rules), KISS/DRY (5 rules), AI over-engineering (5 rules), context budget (4 rules), severity levels. Extracted verbatim from the agent.

### Changed

- **`agents/prompt-engineer.md`** — 161→58 lines. Extracted six knowledge sections into `knowledge/` files; Steps now reference knowledge files by path. Self-consistency fix: the agent no longer violates its own Separation of Concerns doctrine.
- **`commands/prompt-review.md`** — Step 1 reads knowledge files instead of agent; steps 3h-3j replaced with knowledge references.
- **`commands/prompt-optimize.md`** — Step 1 reads knowledge files; steps 4b-4c trimmed to reference knowledge files.
- **`commands/prompt-create.md`** — Step 3 reads knowledge files instead of agent.
- **`.claude-plugin/plugin.json`** — description updated to reflect knowledge file structure.

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
