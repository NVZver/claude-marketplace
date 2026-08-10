# Contributing

## Install

The primary install path is:

```
npx skills add <org>/<repo>
```

`npx skills` ([vercel-labs/skills](https://github.com/vercel-labs/skills), companion directory at [skills.sh](https://skills.sh)) fans this repo's `skills/<pack>/<name>/SKILL.md` files out into your agent host's own install directory — `.agents/skills/` (the cross-client convention several hosts share, e.g. Cursor, Cline) or a host-specific path (e.g. `.claude/skills/` for Claude Code).

**`npx skills` is a third-party tool (built by Vercel Labs), not part of the Agent Skills protocol itself.** The protocol is just files — a `SKILL.md` with YAML frontmatter. If the CLI is unavailable, renamed, or you'd rather not depend on it:

### Manual install (always available)

1. Pick the skill(s) you want from `skills/<pack>/<name>/` in this repo.
2. Copy the whole skill directory (the `SKILL.md` plus any `scripts/`, `references/`, `assets/` it bundles) into your agent host's own skills directory.
3. No build step, no registration — hosts that implement the Agent Skills spec discover skills by scanning for `SKILL.md` files.

## Versioning

`npx skills`' own update mechanism (`npx skills update`) detects drift by comparing a content hash of each installed skill folder against upstream — it does not read or enforce semantic versions. This repo's own version discipline (per-pack `CHANGELOG.md` + SemVer) is the human-facing source of truth for what changed and why; it is independent of the CLI's hash-based drift detection.

## Structure

Skills are organized by pack: `skills/<pack>/<name>/SKILL.md` (e.g. `skills/core/ground-rules/SKILL.md`). This preserves the logical pack boundaries from the source repo (`core`, `lsa`, and others as they migrate) as directory prefixes, rather than flattening everything into one undifferentiated skill list.
