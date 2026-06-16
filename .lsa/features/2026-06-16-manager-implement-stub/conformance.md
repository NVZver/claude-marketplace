# Conformance — Epic 3 manager:implement preview stub

Verdict: **PASS** (doc-mode) — verified on branch `feature/manager-implement-stub`.

| Requirement | Satisfied by (verified) |
|---|---|
| R1 | `manager/skills/implement/SKILL.md` exists; sibling format (frontmatter, trace header, Goal/Input/Steps/Output/Constraints, `/manager:implement [epics]` footer) |
| R2 | read-only: only file op in Steps is `Read`; no Write/Edit/Skill/Agent/dispatch; Constraint states "writes no file and dispatches no implementer" |
| R3 | Step 4 + intro + Constraint state the engine (wave planning, worktree dispatch, gating, serialized merge, autonomy) is not implemented and owned by `parallel-agent-delivery`; args preview only, never imply execution |
| R4 | description follows `command-naming.md`; roadmap read reuses `core/knowledge/fast-path-source-of-truth.md` |
| R5 | `manager/README.md` skill-table row added; `manager/CHANGELOG.md` `[0.10.0]`; `plugin.json` 0.9.0 → 0.10.0; module spec version pins + new read-only-stub invariant |

## Acceptance
- Read-only preview stub; zero writes; honest deferral ("execution pending — nothing was run").
- `scripts/lint.sh` PASS C1–C6. README lists `manager:implement`.

## Notes
- Embodies "done = a gate-proven predicate": the command names the surface but never claims execution that didn't happen — directly aligned with the parallel-agent-delivery thesis.
- Flagged (accepted): `manager:implement` not added to `core/knowledge/fast-path-source-of-truth.md` caller table (its trigger isn't a navigation-phrase shape; that's a `core` file).
