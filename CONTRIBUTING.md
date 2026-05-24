# Contributing to claude-marketplace

How to build and contribute. Operating rules live in [`vision/VISION.md`](./vision/VISION.md). Design rationale lives in [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md). This file is only the contributor workflow.

**This file (and every contribution) follows the discipline established by the 2026-05-20 simplification refactor:**

- **DRY** — one source of truth per fact; cite, don't restate.
- **SRP** — one purpose per file; one Goal per Step (per [`core/skills/actor-template/SKILL.md`](./core/skills/actor-template/SKILL.md)).
- **KISS** — short, scannable; ≤2-sentence frontmatter descriptions with trigger phrases preserved.
- **Factual** — every claim carries a source + verbatim quote per [`core/skills/ground-rules/SKILL.md`](./core/skills/ground-rules/SKILL.md) Rule 1.
- **Concrete + actionable** — file paths and commands; "do X", not "consider Y".

---

## Setup

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/reload-plugins
```

After editing any `SKILL.md`, hook, or plugin manifest: `/reload-plugins` picks it up without restart. Per [`core/README.md`](./core/README.md) "Install on Claude Code".

---

## Classify the work first

Every non-trivial change invokes [`core/flow-selector`](./core/skills/flow-selector/SKILL.md) (renamed from `core/tier-selector` in `core` v0.5.2) before touching code or specs. Boundary signals + worked examples at [`vision/VISION.md`](./vision/VISION.md) §4.

| Flow | When | Loop |
|---|---|---|
| **Quick** (was `T1`) | One file / one string / no behavior change | Single pass; `ground-rules` still applies |
| **Standard** (was `T2`) | Bug in a spec'd module, refactor | `lsa:discover` (light) → TDD → `lsa:verify` |
| **Extended** (was `T3`) | New feature, new contract, new module | `lsa:discover` → `lsa:plan` → implement → `lsa:verify` |

For doc-only refactors that span many files, a plan file at `vision/plans/YYYY-MM-DD-<name>.md` may serve as the feature spec — **declare that judgment upfront** and reflect every change against the plan in your verification report.

---

## Adding a skill

1. Pick the plugin: `core/` (domain-neutral discipline) or `lsa/` (spec-first methodology).
2. Create `<plugin>/skills/<kebab-name>/SKILL.md`.
3. Follow the Actor shape from [`core/skills/actor-template/SKILL.md`](./core/skills/actor-template/SKILL.md) — Goal / Input / Steps / Output / Constraints, no section renames, every Step produces an observable result.
4. Frontmatter: `name:` + `description:` (≤ 2 sentences — verb + trigger phrases that drive description-match).
5. **Do not restate Knowledge in the Actor body.** Cross-cutting conventions belong in a Knowledge surface — see below.
6. Add the skill to the plugin's README skill table.
7. Add the skill's path to `.lsa.yaml: modules.<plugin>.artifact_paths` if a new path pattern is introduced (the existing glob `<plugin>/skills/**/SKILL.md` covers the standard case).
8. Bump version + add CHANGELOG entry (see "Versioning" below).

---

## Adding a Knowledge surface

Knowledge files capture cross-cutting reference content (defaults, protocols, definitions, tables). Pattern established by [`lsa/knowledge/conventions.md`](./lsa/knowledge/conventions.md):

- Lives at `<plugin>/knowledge/<topic>.md`.
- **Pure Knowledge: no Goal / Input / Steps / Output / Constraints.**
- Add `<plugin>/knowledge/**/*.md` to `.lsa.yaml: modules.<plugin>.artifact_paths` so it's tracked by `verify` doc-mode.
- Actors cite by section name: `[<topic>.md](...) §"Section name"`. **Cite by section, not by line number** — line numbers drift, section names survive edits.

---

## Editing an existing skill

1. Classify (Quick / Standard / Extended — was `T1` / `T2` / `T3`).
2. Preserve the five-section Actor shape — Goal / Input / Steps / Output / Constraints.
3. If you find Knowledge content in an Actor body, **move it** to a Knowledge surface and cite from the skill (per [`vision/VISION.md:40`](./vision/VISION.md) — *"Knowledge is not Actor; boundary violations are the highest-severity defect."*).
4. Bump version + add CHANGELOG entry.

---

## Versioning + CHANGELOG

Per [`vision/specs/standards/code.md`](./vision/specs/standards/code.md) *"Per-plugin SemVer + CHANGELOG"*:

- Each plugin has its own SemVer in `<plugin>/.claude-plugin/plugin.json`.
- Each plugin has its own `<plugin>/CHANGELOG.md` (Keep a Changelog format).
- **Bump the version in the same commit as the changelog entry.** No exceptions.

SemVer mapping for this repo:

| Bump | When |
|---|---|
| Patch (`0.x.Y`) | Docs / metadata only, no skill behavior change. |
| Minor (`0.X.0`) | New skill, new Knowledge surface, or material change to a skill body. |
| Major (`X.0.0`) | Breaking change to a skill's contract or to `.lsa.yaml` schema. |

Repo-level files (root `CLAUDE.md`, `CONTRIBUTING.md`, plan files under `vision/plans/`) live outside per-plugin `artifact_paths` and do not trigger plugin version bumps.

---

## Verifying before merge

Per [`vision/specs/standards/testing.md`](./vision/specs/standards/testing.md):

- **V1 — installs cleanly.** `/plugin install <plugin>@NVZver`; `/help` lists every skill in the plugin.
- **V2 — description-match triggers reliably.** One probe per affected skill in a fresh session. Target ~90% trigger rate.
- **V3 — behavior changes observably.** Run the same small task with and without the plugin; compare on the three Vision §5 metrics: accuracy / facts-with-sources / only-required-changes.

For LSA-tracked changes (anything under `artifact_paths`): run `lsa:verify` against the feature spec. If the change wasn't preceded by `lsa:discover`/`lsa:plan`, **declare what's serving as the spec** (e.g., a plan file at `vision/plans/`) and walk every change against it in your verification report.

---

## Multi-step refactors

Pattern established by the 2026-05-20 simplification refactor at [`vision/plans/2026-05-20-simplification-refactor-plan.md`](./vision/plans/2026-05-20-simplification-refactor-plan.md):

1. **Write a plan** at `vision/plans/YYYY-MM-DD-<name>.md` listing every file change per PR with explicit deltas.
2. **Get explicit human sign-off** on the plan (and any open decisions) before executing.
3. **Execute one PR at a time.** After each PR, write a verification report that walks every plan item against file state (`grep`/`wc`/`ls`) — not memory.
4. **Mark `[todo] → [in_progress] → [done]`** in the plan file as PRs land.
5. **Declare honesty flags** for any judgment calls (deferred items, scope expansions, decisions taken inline).

---

## Discipline (sourced)

Every contribution obeys:

- The four discipline rules at [`core/skills/ground-rules/SKILL.md`](./core/skills/ground-rules/SKILL.md) — fact-grounding, no fake-confidence hedging, read before write, deliver only what was asked.
- The Knowledge vs Actor separation at [`vision/VISION.md:40`](./vision/VISION.md) and [`core/skills/actor-template/SKILL.md`](./core/skills/actor-template/SKILL.md). Boundary violations are the highest-severity defect.
- The eight first principles at [`vision/VISION.md`](./vision/VISION.md) §2.

---

## Commits + GitHub

- Push under the `NVZver` GitHub account (`gh auth switch` if needed). Per [`CLAUDE.md`](./CLAUDE.md) "Discipline".
- Branch naming per [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) §4 *"Branch Management"*: `feature/<name>`, `feature/<name>-e<N>`, `constitution/<change>`, `replan/<desc>`.
- No direct commits to `main`.
- License: this repo is licensed under [`LICENSE`](./LICENSE); contributions are accepted under the same terms.

---

## Anti-patterns (don't)

- **Restate Knowledge inside an Actor body.** Cite the Knowledge surface instead.
- **Make a factual claim without a source + verbatim quote.** Mark uncertainty with `[assumption: <why>]` or `[cannot verify]`.
- **Bump a version without a CHANGELOG entry** (or vice versa).
- **Use "typically" / "probably" / "based on convention"** in place of actually checking.
- **Pad output** with summaries, recaps, or unrequested extras.
- **Expand scope silently.** Flag any unplanned change explicitly.
- **Inline a table or rule** that's already canonical elsewhere. Cite by file + section instead.
