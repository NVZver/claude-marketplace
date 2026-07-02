# Changelog

All notable changes to the `prompt-engineer` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.8.2] – 2026-07-02

Public-readiness documentation pass (docs only, no agent/command behavior change).

### Added

- **`README.md`** — an `[illustrative]` `prompt-review` usage example showing the severity/rule/finding output table.

## [0.8.1] – 2026-07-02

Self-conformance fixes surfaced by the repo-wide prompt review the 0.8.0 discipline itself ran (2 MEDIUM in this plugin, 5 of 7 files clean).

### Fixed

- **`agents/prompt-engineer.md`** — step 4 now applies "KISS/DRY 1-6" (said "1-5"; rule 6 shipped in 0.6.0 and the agent silently skipped it — same stale-tally family as the 0.8.0 README/manifest count fixes).
- **`knowledge/quality-checks.md`** — Knowledge File Quality check 6 (no execution logic) cites `separation-of-concerns.md` §Boundary violations instead of restating the same normative rule (its own KISS/DRY 2 pattern applied to itself).

## [0.8.0] – 2026-07-02

Course-driven improvement session: named the prompt-engineering paradigms the plugin already embodies (in-context learning, prompt elements, chain-of-thought — its own AI Over-Engineering check 5 applied to itself) and added two new behaviors: a demonstration-consistency rule and a self-consistency stability bar for judgment-based findings.

### Added

- **`knowledge/actor-ground-rules.md`** — rule 11: an actor's Example Output must match its declared Output spec (format + length); a mismatched demonstration teaches the model the wrong shape. New §"Why examples: in-context learning" names the paradigm behind rules 4/10/11 (few-shot prompting, Brown et al. 2020) — the plugin's own AI Over-Engineering check 5 (cite adapted paradigms) applied to itself. §Scope notes rule 11 applies only where an Example Output section exists (leaner contracts stay exempt).
- **`commands/prompt-review.md`** — step 3 check `m`: where an `## Example Output` section exists, verify it matches the declared Output format and length → mismatch = MEDIUM (rule 11).
- **`tests/repo-anchored.md`** — probe B5: a planted Output-spec/Example-Output mismatch (table declared, prose demonstrated) surfaces as the sole MEDIUM, cited to rule 11 / check `3m`.
- **`knowledge/actor-ground-rules.md`** — mapping note under the actor format template naming its paradigm: the template refines the four standard prompt elements (instruction / context / input data / output indicator, [Prompt Engineering Guide](https://www.promptingguide.ai/introduction/elements)) — Goal+Steps+Constraints = instruction, Role + cited knowledge files = context (referenced, never inlined), Input = input data, Output + Example Output = output indicator. Provenance only; completeness of the slots was already enforced by rules 1 + 3.
- **`knowledge/actor-ground-rules.md`** — two more paradigm names: the shot ladder in §Why examples (zero-shot = the §Scope leaner contracts, one-shot = the template default, few-shot = AI Over-Engineering-4-governed escalation), and chain-of-thought ([Wei et al. 2022](https://www.promptingguide.ai/techniques/cot)) as the paradigm behind the Steps arrow notation (rule 5's observable intermediate steps).
- **`knowledge/quality-checks.md`** — self-consistency stability bar after the Severity Levels table ([Wang et al. 2022](https://www.promptingguide.ai/techniques/consistency)): a judgment-based finding (vague step, formalized common sense, padding) that would not recur on an independent re-derivation is dropped, not reported; deterministic checks exempt; re-derive only contested calls (no blanket multi-sampling — Pro-tier cost). Wired into `commands/prompt-review.md` step 4 and noted in the README `prompt-review` row.

### Changed

- **`knowledge/quality-checks.md`** — AI Over-Engineering 4 and Context Budget 3 now cite the in-context-learning note in `actor-ground-rules.md` (demonstration coverage / demonstration bias); severity table MEDIUM row covers the new Example-Output-mismatch finding.
- **`agents/prompt-engineer.md`** — step 3 checks actor rules 1-11 (was 1-10).
- **`README.md`** — actor ground rules tally 10 → 11; KISS/DRY tally corrected 5 → 6 (rule 6 shipped in 0.6.0 but the rule-categories table was never updated); lede now states the craft's premise (*how* you ask — clear, specific, context-backed — determines what the model returns) so the opening explains the discipline before the mechanism.

## [0.7.5] – 2026-07-02

Consistency-sweep minor (Fork 2d of [`.lsa/pitches/sonnet-robustness-consistency-sweep.md`](../.lsa/pitches/sonnet-robustness-consistency-sweep.md)): the agent-description examples now follow the Claude Code agent convention.

### Fixed

- **`agents/prompt-engineer.md`** — frontmatter description examples restructured from one `<example>` block wrapping six `user:` lines into six `<example>` blocks, one per example (the Claude Code agent-description convention). Example text unchanged; description parses to 515 characters (limit 1,024). No behavior change — structure only.

## [0.7.4] – 2026-07-01

Doc-hygiene fix surfaced by the new deterministic doc-lint gate on its first full-repo run. Feature: [`.lsa/features/2026-07-01-deterministic-doc-lint-gate/requirements.md`](../.lsa/features/2026-07-01-deterministic-doc-lint-gate/requirements.md).

### Fixed

- **`prompt-engineer/commands/prompt-review.md`** — marked the sample review-output row citing `skills/sync/SKILL.md:42` as `[illustrative]` (non-rendering HTML comment); it is a fictional example finding, not a live reference (`skills/sync` does not exist).

## [0.7.3] – 2026-06-18

Self-conformance fix from the repository quality audit (iteration 4): the `prompt-engineer` agent now follows the actor shape it enforces.

### Fixed

- **`agents/prompt-engineer.md`** — promoted Role/Goal/Input from inline `Label:` lines to `##` headers and moved Constraints to a `## Constraints` section after Output (canonical Goal/Input/Steps/Output/Constraints ordering, matching the other four agents); added an explicit `Observable result:` to each of the 6 steps (actor-template requires every step to produce an observable result). No behavior change — structure only.

## [0.7.2] – 2026-06-18

### Fixed

- **`knowledge/separation-of-concerns.md`** — the `knowledge/*.md` classification example cited `spec-templates.md`, which was deleted in `lsa` 0.20.2. Replaced with `quality-gate-contract.md` (a live `lsa` knowledge file).

## [0.7.1] – 2026-06-18

Two execution-correctness fixes in `prompt-review`, surfaced by a repository quality audit.

### Fixed

- **`commands/prompt-review.md` step 3b — wrong rule citation.** The section-existence check cited "Actor ground rules 1-4", but in `actor-ground-rules.md` the five sections come from **rule 1** (Goal/Input/Steps/Output) + **rule 3** (Constraints); rules 2 (Role) and 4 (Output spec) are separate checks already covered by 3c/3f. A missing-Constraints finding would have mis-cited the rule (the constraint at `:18` makes the citation load-bearing). Now cites "rules 1 + 3".
- **`commands/prompt-review.md` step 3e — missing leaner-contract exemption.** Flagged a missing Example Output as HIGH unconditionally, but `actor-ground-rules.md` §Scope says **not** to flag it when the actor cites a leaner contract (`core/actor-template`, `lsa/CORE.md §4`). The step now carries that exemption, eliminating the false positives the §Scope rule exists to prevent.

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
