Shaped by: Nikita Zverev
Date: 2026-05-26
Status: approved
Why now: The marketplace ships four plugins; the prompt-engineer is the only remaining workspace-local capability that marketplace consumers could use — and it is already battle-tested.

# Package prompt-engineer as a standalone marketplace plugin

Move the existing prompt-engineer agent and its three commands from workspace-local `.claude/` into a distributable marketplace plugin so any Claude Code user can install it via `/plugin install prompt-engineer@NVZver`.

## Problem

Any Claude Code user who installs plugins from this marketplace cannot access the prompt-engineer today. The agent and its three commands (`prompt-review`, `prompt-create`, `prompt-optimize`) live under `.claude/` — the workspace-local config directory. They are available only when working inside this repository and cannot be installed via `/plugin install`.

Evidence:

- The agent is at `.claude/agents/prompt-engineer.md` — workspace scope, not plugin scope.
- The three commands are at `.claude/commands/prompt-review.md`, `.claude/commands/prompt-create.md`, `.claude/commands/prompt-optimize.md` — same workspace scope.
- Every distributable plugin in this repo follows the `<plugin-name>/.claude-plugin/plugin.json` convention (see `core/`, `lsa/`, `helper/`, `manager/`). The prompt-engineer follows none of it.
- `.claude/rules/plugin-development.md` (lines 1-6) scopes itself to `core/**/*`, `lsa/**/*`, `helper/**/*` — no `prompt-engineer/` directory exists to cover.

Current workaround: Anyone who wants these capabilities in another project must manually copy the four files into their own `.claude/` directory. There is no versioning, no changelog, no install path, and no update mechanism.

Definition of success: A user can run `/plugin install prompt-engineer@NVZver`, get the agent and all three commands, and use them immediately. The plugin follows the same structural conventions as `helper` and `manager` (plugin.json, CHANGELOG.md, README.md, SemVer). No new functionality — same agent, same commands, same prompt-engineering rules.

## Appetite

Small batch. This is a repackaging task, not a feature-building task. The agent and all three commands already exist and are battle-tested. The work is structural: create the plugin scaffold, move the files into the correct layout, add the standard metadata files (plugin.json, CHANGELOG.md, README.md), delete the workspace-local originals, and verify everything resolves.

What is out of appetite:

1. No new commands, agents, or features. Ship exactly what exists today.
2. No refactoring of the agent's internal structure. The 159-line monolith with inline ground rules stays monolithic this cycle.
3. No dependency wiring. The prompt-engineer is self-contained — it does not depend on `core` or `lsa` at runtime.

## Solution sketch

**Key user interactions:** User runs `/plugin install prompt-engineer@NVZver`. After install, the `prompt-engineer` agent auto-engages on matching natural-language requests, and three commands appear: `/prompt-review`, `/prompt-create`, `/prompt-optimize` (or their namespaced equivalents if Claude Code prefixes plugin commands). No workflow change — same capabilities, now distributable.

**Main components:**

| What | Action |
|------|--------|
| `prompt-engineer/agents/prompt-engineer.md` | Create — agent moved from `.claude/agents/` |
| `prompt-engineer/commands/prompt-review.md` | Create — command moved from `.claude/commands/` |
| `prompt-engineer/commands/prompt-create.md` | Create — command moved from `.claude/commands/` |
| `prompt-engineer/commands/prompt-optimize.md` | Create — command moved from `.claude/commands/` |
| `prompt-engineer/.claude-plugin/plugin.json` | Create — plugin manifest (v0.1.0) |
| `prompt-engineer/CHANGELOG.md` | Create — initial entry |
| `prompt-engineer/README.md` | Create — install instructions, command table |
| `.claude/agents/prompt-engineer.md` | Delete |
| `.claude/commands/prompt-review.md` | Delete |
| `.claude/commands/prompt-create.md` | Delete |
| `.claude/commands/prompt-optimize.md` | Delete |
| `.claude/agents/claude-dev.md` line 67 | Update — `/prompt-review` reference |
| `.claude/rules/plugin-development.md` lines 1-6 | Update — add `prompt-engineer/**/*` to paths scope |

**Critical path:**

1. Create `prompt-engineer/.claude-plugin/plugin.json` scaffold (name, description, version `0.1.0`, author).
2. Move agent and three commands into the plugin directory structure.
3. Update the three commands' internal path references from `.claude/agents/prompt-engineer.md` to the plugin-relative path.
4. Add the file-load trace directive to each of the four files — per `core` v0.5.4 convention.
5. Write `CHANGELOG.md` (initial `0.1.0` entry) and `README.md` (install instructions, command table, description).
6. Delete the four workspace-local files from `.claude/`.
7. Update `.claude/agents/claude-dev.md` line 67 and `.claude/rules/plugin-development.md` paths scope.
8. Verify: commands resolve, agent description-matches, no broken cross-references.

## Rabbit holes

1. **Command path references to the agent file.** `prompt-review.md` line 19 and `prompt-create.md` line 21 instruct the LLM to `Read .claude/agents/prompt-engineer.md`. After migration, this path changes. If Claude Code's plugin loader copies files to an external cache rather than serving them from the repo tree, the hardcoded `Read` path breaks. Mitigation: verify path resolution during implementation; if the repo-relative path does not resolve, switch the commands to reference the agent via description-match dispatch instead of a direct file read.

2. **Command namespacing.** Today the commands are `/prompt-review`, `/prompt-create`, `/prompt-optimize` (bare slash commands). As plugin commands, Claude Code may namespace them as `prompt-engineer:prompt-review`, etc. This changes user-facing invocation and breaks the `claude-dev.md` line 67 reference. Mitigation: check Claude Code plugin docs during implementation to confirm namespacing behavior; update `claude-dev.md` accordingly.

3. **Duplicate command names during transition.** If the workspace-local `.claude/commands/` files are not deleted before the plugin is installed, two commands with the same name exist simultaneously. Behavior is undefined — the local copy may shadow the plugin copy. Mitigation: delete workspace files as part of the same commit that adds the plugin; do not leave both in place.

## No-gos

1. This pitch does NOT cover refactoring the agent's internal structure — the monolith with inline ground rules, KISS/DRY audit, AI sweep, context budget, and severity levels stays as-is. Decomposing into separate knowledge files is a future pitch.
2. This pitch does NOT cover adding new commands or capabilities — no new prompt-engineering features. Ship exactly what exists.
3. This pitch does NOT cover adding a `core` dependency — the prompt-engineer is self-contained.
4. This pitch does NOT cover updating the root `README.md` install block — whether `prompt-engineer` joins the default recommended install set is a separate decision.
