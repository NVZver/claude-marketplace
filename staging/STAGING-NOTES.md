# Staging notes — vendor-neutral-agent-skills-home

**Not part of the new repo.** Everything under `vendor-neutral-agent-skills-home/` mirrors the new repo's root exactly — once the repo name is decided and `gh repo create` runs, copy that directory's *contents* into the new repo root, `git add` + first commit, and you're most of the way there.

## Scope of this pass

Originally epic 1 (`repo-scaffold`) only staged 2 skills. Per `/goal "prepare a reliable 100% ready and covered lift-n-shift for the entire repository"`, this was expanded to the full repo: all 5 packs, the constitution, scripts, `.lsa.yaml`, `AGENTS.md`, `SECURITY.md`, CI workflow, and the `.lsa/` living-spec corpus (modules, pitches, roadmap, standards, libs).

## What's staged and verified

- **20 skills** across `core` (6), `lsa` (7), `manager` (5), `observer` (2) — all at `skills/<pack>/<name>/SKILL.md`.
- **4 agents**, **3 commands**, **21 knowledge files** — at `skills/<pack>/{agents,commands,knowledge}/`.
- **28 of 29 scripts** — `scripts/*.sh` (repo-root tooling) + `skills/lsa/scripts/*.sh` (project-map). **1 retired**: `check-version-changelog.sh` had no valid target once `.claude-plugin/plugin.json` stopped existing (nothing left to cross-check `CHANGELOG.md` against) — removed, not silently broken. Its CI step was also removed from `.github/workflows/lint.yml`.
- **Constitution**: `.lsa/VISION.md` → `.lsa/constitution.md` (+ digest), with principle 9, the primitives table, and the distribution paragraph rewritten to vendor-neutral language; a v0.15 changelog entry documents the migration. Historical changelog entries (v0.1–v0.14) are left verbatim — they're a period-accurate record, same convention as every pack's own `CHANGELOG.md`.
- **`AGENTS.md`**: full always-on card folded in directly (not a pointer to a separate `CLAUDE.md` — that file doesn't exist in this repo).
- **`.lsa.yaml`**: rewritten `artifact_paths` for the new layout; dropped `.claude-plugin/plugin.json` and `hooks/**` entries (§C leave-behind).
- **`.lsa/` corpus**: 5 module specs, all pitches, `roadmap.yaml`, `main.spec.md` (retargeted), `standards/`, `libs/`.
- **`SECURITY.md`**: paths mechanically fixed; **flagged with a migration note** at the top — its threat model was written for Claude Code's plugin-marketplace distribution and has not been re-derived for `npx skills`/Agent Skills distribution. Don't trust its specific guidance until that review happens.
- **Zero remaining `AskUserQuestion` or Claude `/loop` hard-binds** anywhere in the live product surface (skills, knowledge, agents, commands, module specs) — verified by repo-wide grep.

## Gate status (`bash scripts/gate.sh` inside the staged tree)

```
PASS  docs-invariants  (scripts/lint.sh — 17/20 checks; see below)
PASS  citations
PASS  links
FAIL  project-map      — expects project-map.yaml committed; this is a fresh, uncommitted repo (nested git init, zero commits)
FAIL  tests             — metrics-harvest-test.sh's "real historical file" fixture depends on `.lsa/features/` history that wasn't migrated (see below) and on commit history a brand-new repo doesn't have yet
PASS  lib-pins
```

`scripts/lint.sh` itself: **17/20 pass outright**; the 3 that don't (C11/C19/C20 report `0 checked`) aren't failures — there's nothing to check yet (no `VERIFICATION.md` Scope lines with a pack that also has a mismatched CHANGELOG; no post-contract `conformance.md` files, since nothing's been reconciled in this repo yet). They'll start reporting real numbers once the new repo has its own build history.

**Both remaining gate failures are artifacts of "this repo has no history yet," not defects in the migrated content** — they should self-resolve once the new repo gets its first real commits and reconcile cycles.

## Deliberately NOT duplicated (stays in `NVZver/claude-marketplace` as historical record)

- `.lsa/features/` — the complete per-epic build record (requirements/grounding/conformance for every past feature). Registry §A only asked for "modules, pitches, roadmap" as the *living* spec corpus; `features/` is frozen history of the *source* repo's own development, not part of what a consumer needs. Citations to `.lsa/features/<name>/...` from the constitution, module specs, and pitches are valid pointers into the source repo, not broken links within this one.
- `.lsa/archive/`, `.lsa/observations/`, `.lsa/research/`, `.lsa/plans/` — same reasoning.
- Per Registry §C (already established): `.claude-plugin/**`, `hooks/` (`hooks.json` + `session-start-drift-check.sh`), repo-internal `.claude/**`, `dist/cursor/**`.

## Known gaps / follow-ups

1. **Repo name still open** (`<TBD-repo-name>` throughout) — the one gate only the user can resolve.
2. **`SECURITY.md`'s threat model** needs a from-scratch review for the new distribution path (flagged inline, not guessed at).
3. **F1/F2/F7 from the epic-1 spec** — actual `gh repo create` and the `npx skills add` fan-out smoke test need a real, published repo; can't be done from a staging directory.
4. **Some `CHANGELOG.md` / pitch prose** still names old paths/terms (`core/CLAUDE.md`, `AskUserQuestion`, `.claude-plugin/plugin.json`) — left untouched deliberately, matching the existing convention that historical records aren't rewritten. Not a gap in the *live* surface.
5. Two lint checks (C11, C19, C20) report `0 checked` rather than a real pass — expected for a repo with no build history yet, not a defect.

## Tooling used (lives in `staging/`, not part of the new repo)

- `relink.py` — mechanical re-linker; recomputes relative paths for the new layout, resolves markdown-links relative-to-file and inline-code-citations root-relative (two different conventions this repo uses — conflating them was an early bug, now fixed).
- `check-staged-links.py` — link-resolution checker; flags every reference that doesn't resolve.
- `fix-linktext.py`, `fix-constitution-depth.py` — narrow one-off fixers for specific bug classes found during verification (bracket-text lagging behind href; depth miscalculation from a sequencing issue between two rename passes).

All four are safe to re-run (idempotent) if more content gets migrated later.
