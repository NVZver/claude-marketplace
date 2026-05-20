# Core

Two domain-neutral discipline skills that make output trustworthy and any actor (skill / slash command / workflow) follow a single, observable shape. For the "why" behind this package, see [`../vision/VISION.md`](../vision/VISION.md).

## What's here

- **`ground-rules`** — Apply on every substantive task. Enforces: every factual claim carries a source + quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked.
- **`actor-template`** — Apply when authoring or editing a Skill, slash command, or workflow. Enforces the Goal / Input / Steps / Output / Constraints shape and demands every Step produce an observable result.
- **`tier-selector`** — Apply before any non-trivial task. Classifies the work as T1 / T2 / T3 by chain-of-thought reasoning over Vision §4 boundary signals, then waits for human confirmation before any LSA ceremony fires.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
/reload-plugins
```

Invoke directly via `/core:ground-rules`, `/core:actor-template`, or `/core:tier-selector`, or let Claude trigger them automatically by description match. Run `/reload-plugins` after editing skill files to pick up changes without restart.

### Merge the CLAUDE.md fragment

Copy the content of [`core/CLAUDE.md`](./CLAUDE.md) into your project's `/CLAUDE.md` (or whichever path your `.lsa.yaml` configures as the constitution). The fragment declares two always-on rules: `ground-rules` application and `tier-selector` invocation before non-trivial tasks.

## Install on Claude.ai

Each skill uploads separately (Claude.ai's native model). From the repo root:

```bash
cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/
```

Then in Claude.ai → **Settings → Features → Custom Skills**, upload `ground-rules.zip` and `actor-template.zip` separately.

Per Anthropic docs (`platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`): *"Custom Skills do not sync across surfaces. Skills uploaded to one surface are not automatically available on others."* The upload is one-time, per user; there is no organization-wide distribution path on Claude.ai today.
