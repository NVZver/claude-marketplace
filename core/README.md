# Core

Two domain-neutral discipline skills that make output trustworthy and any actor (skill / slash command / workflow) follow a single, observable shape. For the "why" behind this package, see [`../vision/VISION.md`](../vision/VISION.md).

## What's here

- **`ground-rules`** — Apply on every substantive task. Enforces: every factual claim carries a source + quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked.
- **`actor-template`** — Apply when authoring or editing a Skill, slash command, or workflow. Enforces the Goal / Input / Steps / Output / Constraints shape and demands every Step produce an observable result.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
/reload-plugins
```

Invoke directly via `/core:ground-rules` or `/core:actor-template`, or let Claude trigger them automatically by description match. Run `/reload-plugins` after editing skill files to pick up changes without restart.

## Install on Claude.ai

Each skill uploads separately (Claude.ai's native model). From the repo root:

```bash
cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/
```

Then in Claude.ai → **Settings → Features → Custom Skills**, upload `ground-rules.zip` and `actor-template.zip` separately.

Per Anthropic docs (`platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`): *"Custom Skills do not sync across surfaces. Skills uploaded to one surface are not automatically available on others."* The upload is one-time, per user; there is no organization-wide distribution path on Claude.ai today.
