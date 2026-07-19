# CLAUDE.md

@AGENTS.md

`AGENTS.md` is canonical; this file exists only because Claude Code does not read `AGENTS.md` natively (`anthropics/claude-code#6235`, open).

## Claude Code specifics

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

Run [`/core:doctor`](./core/skills/doctor/SKILL.md) to verify the install is wired.
