Epic: vendor-neutral-agent-skills-home/repo-scaffold
Pitch: .lsa/pitches/vendor-neutral-agent-skills-home.md

## Summary

Scaffold the new vendor-neutral Agent Skills home repo: resolve the open repo-name gate, create an empty GitHub repo, land the root `skills/<pack>/<name>/SKILL.md` catalog architecture + `AGENTS.md`, migrate `core/ground-rules` + `core/output` as the smoke-test pair (rewriting their `AskUserQuestion` hard-binds in the same move), and prove the install path via `npx skills add` fanning both into a scratch consumer's `.agents/skills/`, with manual copy documented as fallback.

## User Flows

| Flow | Success | I/O | Scenario |
|---|---|---|---|
| Resolve name & create empty repo | Repo exists under a user-confirmed name; no history imported | In: confirmed name → Out: empty GitHub repo | `repo-scaffold.feature` |
| Scaffold catalog architecture | Root has `skills/<pack>/<name>/SKILL.md` tree + `AGENTS.md`; no `.agents/skills/` at source | In: none → Out: directory structure | `repo-scaffold.feature` |
| Migrate + rewrite smoke-test skills | `ground-rules` + `output` present at `skills/core/*`, `AskUserQuestion` hard-bind rewritten in both | In: source `SKILL.md` files → Out: migrated, rewritten files | `migration.feature` |
| Prove install via `npx skills` | `npx skills add <org>/<repo>` installs both into a scratch consumer's `.agents/skills/` | In: published repo → Out: installed skill dirs in consumer checkout | `install-smoke-test.feature` |
| Document fallback | README/CONTRIBUTING states manual-copy fallback + names `npx skills` as third-party | In: none → Out: doc section | `install-smoke-test.feature` |

## Functional (EARS)

- **F1** — While the repo-name decision is unresolved, when this epic's work begins, the system shall use the placeholder `<TBD-repo-name>` in all specs/scripts and shall not create the GitHub repository until a name is confirmed.
- **F2** — When the repo name is confirmed, the system shall create an empty GitHub repository under that name, with no history imported from `claude-marketplace` (clean import — pitch Gate decision, Fork "history").
- **F3** — When the new repo is scaffolded, the system shall create skill directories at `skills/<pack>/<name>/SKILL.md` (catalog layout) at repo root, not at `.agents/skills/`.
- **F4** — When the new repo is scaffolded, the system shall create a root `AGENTS.md`.
- **F5** — When `core/ground-rules/SKILL.md` is migrated, the system shall place it at `skills/core/ground-rules/SKILL.md` with its `AskUserQuestion` hard-bind (source `core/skills/ground-rules/SKILL.md:28`) rewritten to the vendor-agnostic "ask the human with labelled options (and one-line outcomes)" contract.
- **F6** — When `core/output/SKILL.md` is migrated, the system shall place it at `skills/core/output/SKILL.md` with its `AskUserQuestion` hard-bind (source `core/skills/output/SKILL.md:86`) rewritten to the same contract.
- **F7** — When migration is complete, the system shall verify, via `npx skills add <org>/<repo>` run from a scratch consumer checkout, that both migrated skills land in that checkout's `.agents/skills/`.
- **F8** — When `npx skills` is unavailable or fails, the system shall provide manual file-copy as a documented fallback install path in the new repo's README/CONTRIBUTING.
- **F9** — The system shall document, in the new repo's README/CONTRIBUTING, that `npx skills` is a third-party (Vercel Labs) tool, not part of the Agent Skills protocol itself.

## Out of Scope

The other 4 core skills (`actor-template`, `doctor`, `flow-selector`, `reuse-first`) and `core/CLAUDE.md` (epic 2); `lsa` pack (epic 3); `VISION.md` → `constitution.md` rename and Vision retarget (epic 4); optional packs (epics 5–7); publish/cutover (epic 8).
