# Core

Two domain-neutral discipline skills that make output trustworthy and any actor (skill / slash command / workflow) follow a single, observable shape. For the "why" behind this package, see [`../vision/VISION.md`](../vision/VISION.md).

## What's here

- **`ground-rules`** — Apply on every substantive task. Enforces 6 content rules — see [`core/CLAUDE.md`](./CLAUDE.md) for the canonical list.
- **`output`** — Apply to every human-facing output. Enforces 7 format golden rules (structured, minimal, formatted, sourced, concrete, what-and-why preamble, show-changes-inline) — see [`core/CLAUDE.md`](./CLAUDE.md). Each component picks its own format within these rules. **Since v0.8.0,** Rule 7 *Show changes inline — write, show, comment* requires every write/edit/mark performed by an agent to be echoed back inline (single-change block or compressed inspection table) before commentary; generalizes the 8-element drift block from `lsa-reconcile`. New operational checkpoint #4 in `core/CLAUDE.md`. **Since v0.7.0,** Rule 6 *What-and-why preamble — verdicts carry a one-sentence frame* requires every verdict label drawn from [`core/knowledge/output-vocabulary.md`](./knowledge/output-vocabulary.md) §"Verdicts" to be preceded by a one-sentence preamble naming (a) the action in the user's frame and (b) the concrete consequence if the human does not act. **Since v0.5.5,** declared the **single marketplace-wide source-of-truth** for output discipline — other plugins cite this file by markdown link, never restate the count or rule names (re-grounded summaries permitted only when they cite canonical at the top, per `helper/knowledge/output-discipline.md` precedent). Enforced by `core/tests/repo-anchored.md` D2. **Since v0.5.4,** *sourced* requires a one-line trace directive at the top of every marketplace instructional file; on load the agent prints `=============== [<file>] [<plugin>] ===============` verbatim, one line per loaded file, in load order, before the response body. Replaces the v0.5.3 single-line `[plugin:skill]` marker.
- **`actor-template`** — Apply when authoring or editing a Skill, slash command, or workflow. Enforces the Goal / Input / Steps / Output / Constraints shape and demands every Step produce an observable result.
- **`flow-selector`** — Apply before any non-trivial task. Classifies the work as Quick / Standard / Extended by chain-of-thought reasoning over Vision §4 boundary signals, then waits for human confirmation before any LSA ceremony fires. Renamed from `tier-selector` (T1 / T2 / T3) in `core` v0.5.2.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/reload-plugins
```

Invoke directly via `/core:ground-rules`, `/core:output`, `/core:actor-template`, or `/core:flow-selector` (renamed from `/core:tier-selector` in `core` v0.5.2), or let Claude trigger them automatically by description match. Run `/reload-plugins` after editing skill files to pick up changes without restart.

### Merge the CLAUDE.md fragment

Copy the content of [`core/CLAUDE.md`](./CLAUDE.md) into your project's `/CLAUDE.md` (or whichever path your `.lsa.yaml` configures as the constitution). The fragment declares three always-on rules: `ground-rules` application, `output` discipline, and `flow-selector` invocation before non-trivial tasks.

## Install on Claude.ai

Each skill uploads separately (Claude.ai's native model). From the repo root:

```bash
cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/
```

Then in Claude.ai → **Settings → Features → Custom Skills**, upload `ground-rules.zip` and `actor-template.zip` separately.

Per Anthropic docs (`platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`): *"Custom Skills do not sync across surfaces. Skills uploaded to one surface are not automatically available on others."* The upload is one-time, per user; there is no organization-wide distribution path on Claude.ai today.
