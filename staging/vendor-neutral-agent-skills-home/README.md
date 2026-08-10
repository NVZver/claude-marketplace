# <TBD-repo-name>

A vendor-neutral Agent Skills home — migrated from `NVZver/claude-marketplace`, whose distribution was Claude Code–plugin-native. This repo ships the same discipline packs as open [Agent Skills](https://agentskills.io/specification): a `skills/<pack>/<name>/SKILL.md` catalog tree at root, installable by any compliant host, not just Claude Code.

## Install

```
npx skills add <org>/<repo>
```

This installs every skill in this repo into your agent host's own skills directory. See [CONTRIBUTING.md](./CONTRIBUTING.md) if `npx skills` isn't available or you'd rather install manually.

## What's here

See [AGENTS.md](./AGENTS.md) for the always-on entry point and current migration status.

## Origin

Migrated incrementally from [`NVZver/claude-marketplace`](https://github.com/NVZver/claude-marketplace), per `.lsa/pitches/vendor-neutral-agent-skills-home.md` in that repo.
