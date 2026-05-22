# Module Spec — `maintenance`

A single-skill plugin for repo-content discipline. Stages but never commits; refuses to run on `main` or with uncommitted changes; preserves 6 invariants on every patch.

**Plugin manifest:** [`maintenance/.claude-plugin/plugin.json`](../../../../maintenance/.claude-plugin/plugin.json) (v0.1.0)
**Plugin README** (install, usage, budgets): [`maintenance/README.md`](../../../../maintenance/README.md)
**Per-skill behavior** (source of truth per skill): [`maintenance/skills/*/SKILL.md`](../../../../maintenance/skills/)

## Role in the marketplace

`maintenance` is an opt-in plugin (not always-installed; absent from `CLAUDE.md` "Default plugins"). Per `vision/VISION.md` §3 *"packs/ (load on demand)"* — it is a domain pack rather than core discipline. The pack's discipline is content-shape (slimness, citation integrity, per-class token budgets), distinct from `core`'s output/fact discipline and `lsa`'s spec-lifecycle discipline.

One skill in v0.1.0:

- `maintenance/cleanup` — 6-phase actor (Preconditions → Inventory → Classify → Stage → Verify → Report). Produces a staged uncommitted diff + a report at `vision/reports/cleanup-<date>.md`. Encodes the 12-step procedure validated by the manual cleanup pass on `feature/2026-05-21-maintenance-cleanup` (commits `35b1068`, `9c1a9f2`, `cb2bad1`).

## Invariants

- **Versioning.** `maintenance` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*). Currently v0.1.0.
- **Markdown-only.** No `/src/`; the skill is pure Markdown. Per `vision/specs/standards/code.md` *"Markdown-only"*.
- **Depends on `core` v0.5.3+** for `core/actor-template` (skill body shape) and `core/output` Rule 5 (concrete prompt voice on every picker). Documented in `maintenance/.claude-plugin/plugin.json: description` and `maintenance/README.md` *"Depends on"*.
- **Does NOT depend on `lsa`.** Orthogonal to the spec lifecycle by design (`vision/specs/features/2026-05-21-maintenance-cleanup/design.md` § Cross-Module Contracts).
- **Stages but never commits.** The cleanup skill modifies the working tree + staging area, but the commit is human-owned (`vision/specs/features/2026-05-21-maintenance-cleanup/requirements.md` AC4, AC5).
- **Refuses unsafe preconditions.** Will not run on `main` branch or with uncommitted changes (AC9). Will not overwrite a same-day report (AC10).
- **Six invariants preserved on every patch.** Frontmatter `description:` byte-identical; public `name` fields unchanged; cited `file:line` links resolve; rule IDs unchanged; SemVer + CHANGELOG head unchanged; actor frontmatter unchanged (`vision/specs/features/2026-05-21-maintenance-cleanup/requirements.md` F3).
- **Spec source-of-truth.** The skill's behavior is owned by its `SKILL.md`; this module spec carries module-level invariants only — not a behavior catalog (that's the SKILL.md body) and not a usage catalog (that's `maintenance/README.md`).
- **Manual-before-automate validation.** <!-- added: 2026-05-21-maintenance-cleanup 2026-05-22 --> Any future skill in this plugin (e.g., a future `redundancy-extractor` or `prose-density-trimmer`) must be validated end-to-end manually on real repo content before being encoded as a SKILL.md. The cleanup skill itself was validated this way via 3 commits on `feature/2026-05-21-maintenance-cleanup` (`35b1068`, `9c1a9f2`, `cb2bad1`) achieving -52.1% shipped-non-archive tokens before the SKILL.md was authored. Per `vision/specs/archive/2026-05-21-maintenance-cleanup/requirements.md` NF6 and the user's *manual-before-automate* discipline (memory).
