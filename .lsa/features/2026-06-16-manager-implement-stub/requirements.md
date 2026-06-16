# Epic 3 — `manager:implement` read-only preview stub

## Summary
Add the `manager:implement` command as a **read-only preview stub** that lists recent roadmap
backlog items and states which could run in parallel — explicitly deferring the execution engine
(dependency-wave planning, worktree dispatch, gating, serialized merge) to the separate
parallel-agent-delivery feature. Names the command surface now; ships no engine.
Parent: `.lsa/pitches/function-command-naming-and-manager-rename.md` (Epic 3)

## Functional requirements (doc-mode — about the artifact)
- R1. A new `manager/skills/implement/SKILL.md` (`manager:implement [epics] [--parallel|--sequential]`)
  SHALL exist, mirroring the existing manager skill format (frontmatter name+description, trace header,
  Goal/Input/Steps/Output/Constraints, `/manager:implement` footer).
- R2. The skill SHALL be **read-only**: it reads `${specs_root}/roadmap.md` and prints a preview of the
  last X backlog/not-started items with a parallel-vs-sequential indication; it writes nothing and
  dispatches no implementer.
- R3. The skill SHALL explicitly state that the execution engine (dependency-wave planning, isolated
  worktree dispatch, gating, serialized merge, autonomy) is **not yet implemented** and is owned by the
  `parallel-agent-delivery` feature (`.lsa/pitches/parallel-agent-delivery.md`) — so no false "it runs" claim.
- R4. The description SHALL follow the function-naming convention (`manager/knowledge/command-naming.md`)
  and reuse the fast-path read discipline (`core/knowledge/fast-path-source-of-truth.md`) for the roadmap read.
- R5. Per-plugin CHANGELOG `[0.10.0]` entry + README delta (add `manager:implement` to the skill table)
  in the same commit; version 0.9.0 → 0.10.0.

## Acceptance
- `manager:implement` (no args) prints a read-only preview of recent backlog items + a "engine pending"
  notice; makes zero writes. `scripts/lint.sh` PASS C1–C6. README lists the command.

## Out of scope
- The execution engine itself (parallel-agent-delivery). No worktree/merge/autonomy logic here.
