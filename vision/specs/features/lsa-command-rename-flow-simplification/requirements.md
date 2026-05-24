# Feature: LSA Command Rename + Flow Simplification

## Summary

LSA commands are confusing: the `lsa:lsa-*` double-prefix is verbose, the correct workflow order isn't obvious from names, `lsa-specify` and `lsa-discover` are separate with an unclear relationship, and `lsa-sync` sounds like code-to-spec when it's actually spec-to-spec promotion. Starting a new feature requires manual branch creation and knowing to run flow-selector before discover. This feature renames all LSA skills to drop the `lsa-` prefix, merges specify+discover into a single `discover` command, removes `sync` entirely, adds two entry-point commands (`new` and `next`) that eliminate setup friction, and rewrites every skill description to state input/output clearly.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | Drop `lsa-` prefix from all LSA skill directory names (`lsa/skills/lsa-X/` → `lsa/skills/X/`), making commands `lsa:discover`, `lsa:plan`, `lsa:verify`, `lsa:init`, `lsa:reconcile`, `lsa:revise-constitution` | Must |
| F2 | Merge `lsa-specify` and `lsa-discover` into a single `lsa:discover` skill with three internal phases: (1) specify — user describes intent, (2) discover — agent reads codebase and infers answers, (3) confirm — user approves. Extended flow produces the full spec artifacts (requirements.md, test-suites.md, design.md, optional contract.yaml). Standard flow stays light (three-question confirm + stop). | Must |
| F3 | Remove `lsa-sync` entirely — delete `lsa/skills/lsa-sync/` directory. Feature specs are the permanent record; no promotion into module specs. | Must |
| F4 | Keep `lsa-reconcile` as exception-path only (renamed to `lsa/skills/reconcile/`), for code-first edits that bypassed the spec | Must |
| F5 | Rewrite every LSA skill `description` field (in YAML frontmatter) to state (a) what input is required before running and (b) what the output will be. The main flow order (discover → plan → implement → verify) must be evident from descriptions alone. | Should |
| F6 | Add `lsa:new` entry-point skill: user provides a feature name or intent → skill creates `feature/<name>` branch → runs `core/flow-selector` → kicks off `lsa:discover` with the confirmed flow type. Single command to go from idea to discovery. | Must |
| F7 | Add `lsa:next` entry-point skill: reads `${specs_root}/roadmap.md` → identifies highest-priority item with status "backlog" → presents the candidate with context for user confirmation → on confirm, creates `feature/<name>` branch → kicks off `lsa:discover`. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Single `lsa` minor version bump (0.8.0) in the same commit as all renames + CHANGELOG entry. `core` gets a patch bump only if its cross-references change. |
| NF2 | Archive files, old CHANGELOG entries, and archived feature specs keep the old names. Only active behavior files are renamed. Same policy as the Gate N → User Verification rename (lsa v0.6.2, per `vision/specs/roadmap.md:18`). |
| NF3 | `lsa:new` and `lsa:next` must hand off to `lsa:discover` (not duplicate its logic). They are orchestrators, not reimplementations. |

## Inputs & Outputs

- Input: the current LSA plugin codebase (8 skills, plugin.json, knowledge files, hooks, READMEs, cross-references in core + vision)
- Output: renamed LSA plugin with 9 skills (specify+discover merged into `discover`, sync removed, `new` and `next` added), updated cross-references across the entire repo
- Side effects: `lsa` version bumped to 0.8.0; `core` version bumped if its files change; both CHANGELOGs updated

## Constraints

- Per-plugin SemVer + CHANGELOG discipline (`vision/VISION.md` §1 "Distribution + versioning")
- Archive files don't rewrite — historical references stay as-is (established by the Gate N rename, `vision/specs/roadmap.md:18`)
- READMEs are living documents — any user-visible change updates the relevant README in the same commit (`CLAUDE.md` §"Discipline (sourced)")
- Knowledge vs Actor separation (`vision/VISION.md:40`) — the merged `discover` skill remains an Actor (Goal/Input/Steps/Output/Constraints)

## Out of Scope

- Changing internal behavior/logic of any skill beyond what the merge, removal, and new entry points require
- Rethinking the role of module specs after `lsa-sync` removal (deferred — per roadmap §"2026-05-24 backlog detail" #1, decision 3)
- Updating the SessionStart drift hook's baseline-SHA logic (currently reads `.lsa-sync-state.json` written by `lsa-sync` — that file's future is tied to the module-spec role question, which is deferred)
- Adding new internal phases to existing skills beyond what F2/F6/F7 require

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->
- [ ] AC1: When the user invokes `lsa:discover` on an Extended flow, the system shall execute the merged specify+discover workflow (three phases: specify → discover → confirm) and produce the same spec artifacts as the former `lsa-specify` (requirements.md, test-suites.md, design.md, optional contract.yaml, empty tasks.md).
- [ ] AC2: When the user invokes `lsa:discover` on a Standard flow, the system shall execute the light three-question discovery (module, change, AC) and stop — same behavior as the former `lsa-discover` Standard path.
- [ ] AC3: When the user invokes any renamed LSA command (`lsa:plan`, `lsa:verify`, `lsa:init`, `lsa:reconcile`, `lsa:revise-constitution`), the system shall respond to the command without the `lsa-` prefix stutter.
- [ ] AC4: When the user invokes `lsa:sync` or `lsa:lsa-sync`, the system shall not find a matching skill (sync is removed).
- [ ] AC5: When a user reads any LSA skill description (YAML frontmatter `description` field), the description shall state what input is required before running and what the output will be.
- [ ] AC6: While the main flow commands are listed together (e.g., in README skill table or plugin.json), the workflow order discover → plan → implement → verify shall be evident from the descriptions without consulting external documentation.
- [ ] AC7: When the user invokes `lsa:new` with a feature name or intent, the system shall create a `feature/<name>` branch, determine the flow type via `core/flow-selector`, and hand off to `lsa:discover` with the confirmed flow — all without the user manually creating a branch or invoking flow-selector.
- [ ] AC8: When the user invokes `lsa:next`, the system shall read the roadmap, present the highest-priority backlog item with context, wait for user confirmation, and then create the branch and hand off to `lsa:discover` — without the user manually identifying the next item or creating a branch.
