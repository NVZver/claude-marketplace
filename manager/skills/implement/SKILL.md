---
name: implement
description: "Preview which roadmap items could be implemented next, and roughly which could run in parallel — a READ-ONLY PREVIEW STUB. Input: optional [epics] (slug/path list) and an optional --parallel / --sequential hint. Output: the last X (~5) backlog / not-started roadmap rows quoted with file:line citations plus an INDICATIVE parallel-vs-sequential note, and a prominent statement that the execution engine is not yet implemented. Writes nothing and dispatches no implementer. Reads ${specs_root}/roadmap.md."
---

> **Trace.** On load, print first: `=============== [manager/skills/implement/SKILL.md] [manager] ===============`


# Implement

Preview which roadmap items could be implemented next — and, indicatively, which might run in parallel — **without running anything**. This is a **read-only preview stub**: it reads `${specs_root}/roadmap.md`, lists the most recent `backlog` / `not started` items with `file:line` citations, and gives a coarse parallel-vs-sequential hint. The execution engine (dependency-wave planning, isolated git-worktree dispatch, per-PR gating, serialized merge, autonomy levels) is **not yet implemented** — it is owned by the `parallel-agent-delivery` feature ([`../../../.lsa/pitches/parallel-agent-delivery.md`](../../../.lsa/pitches/parallel-agent-delivery.md)). This skill names the command surface ahead of that engine; it writes nothing and dispatches no implementer.

## Goal

Show the user, in seconds, which backlog items are candidates for implementation and a rough sense of which could be worked in parallel — so the command surface exists and reads honestly — while making it unmistakable that nothing has been executed and the real engine is still pending. Embodies "done is a gate-proven predicate": the skill never implies work ran.

## Input

- **`[epics]`** — optional. A list of epic slugs or paths the user is interested in. When supplied, the preview is framed around those items; when absent, the skill defaults to the last X (~5) `backlog` / `not started` roadmap rows (per [`../../knowledge/command-naming.md`](../../knowledge/command-naming.md) §"The no-arg form does something useful").
- **`--parallel` / `--sequential`** — optional hint expressing how the user *imagines* running the items. It only colors the INDICATIVE note below; it triggers no execution.
- The fast-path read contract at [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) — governs the single bounded read of `${specs_root}/roadmap.md`.

## Steps

1. **Read the roadmap (one bounded read) — per the fast-path discipline.** `Read` `${specs_root}/roadmap.md`, locate the `## Feature Backlog` heading anchor, and collect the last X (~5) rows whose Status is `backlog` or `not started`, per [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) (single source-of-truth read, exact-anchor match, no sub-agent, no multi-round `Grep`). If `[epics]` were supplied, filter to those items. If the `## Feature Backlog` anchor is missing or the table is empty, emit the observable fall-through note ("`## Feature Backlog` not found — nothing to preview") and stop. Observable result: a candidate list, or an observable empty-state note.

2. **Quote the candidates with `file:line` citations.** Render each candidate row verbatim with its `file:line` citation per the fast-path §"Citation format" and [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 4 (Sourced). No row is summarized without its quote. Observable result: each candidate item quoted with a locatable citation.

3. **Give an INDICATIVE parallel-vs-sequential note — clearly labelled as a guess.** Offer a coarse hint at which items *might* be workable in parallel versus serially (e.g., distinct vs overlapping areas as suggested by their pitch links / titles), honoring any `--parallel` / `--sequential` hint. **State explicitly that this is indicative only** — true disjointness / dependency-wave analysis is part of the deferred execution engine and is NOT performed here. Observable result: a parallel-vs-sequential hint, explicitly marked non-authoritative.

4. **State the deferral prominently — the engine is not implemented.** Print a clear notice that the execution engine — dependency-wave planning, isolated git-worktree dispatch, per-PR gating, serialized merge, and autonomy levels — is **not yet implemented** and is owned by the `parallel-agent-delivery` feature ([`../../../.lsa/pitches/parallel-agent-delivery.md`](../../../.lsa/pitches/parallel-agent-delivery.md)). The merge half of that engine follows a defined contract — the serialized-merge + roadmap-write lock at [`../../knowledge/serialized-merge.md`](../../knowledge/serialized-merge.md) — but the dispatch engine that executes it is still pending (`parallel-agent-delivery` Epic 2). Even when called with `[epics]` and a `--parallel` / `--sequential` flag, this skill SHALL only preview and SHALL NOT imply anything ran. Observable result: an unmissable "execution pending — nothing was run" statement closes the turn.

## Output

A read-only preview: the last X (~5) `backlog` / `not started` candidates (or the filtered `[epics]`), each quoted with a `file:line` citation; an explicitly-indicative parallel-vs-sequential note; and a prominent statement that the execution engine is not implemented and is owned by `parallel-agent-delivery`. No file writes, no implementer dispatch. The skill never claims execution it did not perform.

### Example Output

[illustrative]

```
> /manager:implement --parallel
=============== [manager/skills/implement/SKILL.md] [manager] ===============

Preview (read-only) — last 3 backlog / not-started candidates:
  .lsa/roadmap.md:14 — "| onboarding-checklist | Should | backlog | pitch: .lsa/pitches/onboarding-checklist.md |"
  .lsa/roadmap.md:15 — "| plugin-scaffold      | Could  | not started | pitch: .lsa/pitches/plugin-scaffold.md |"
  .lsa/roadmap.md:16 — "| docs-refresh         | Could  | backlog | pitch: .lsa/pitches/docs-refresh.md |"

Indicative only (NOT a dependency analysis): onboarding-checklist and docs-refresh touch
separate areas → likely parallel-able; plugin-scaffold may block both → likely sequential first.

⚠ Execution engine NOT implemented. Dependency-wave planning, isolated git-worktree dispatch,
per-PR gating, serialized merge, and autonomy levels are owned by the parallel-agent-delivery
feature (.lsa/pitches/parallel-agent-delivery.md). Nothing was run — this is a preview only.
```

## Constraints

- **Read-only — preview stub.** This skill reads `${specs_root}/roadmap.md` and prints; it writes no file and dispatches no implementer. There is no execution path here.
- **No false completion — done is a gate-proven predicate.** Never imply any item was implemented, merged, or deployed. Arguments (`[epics]`, `--parallel` / `--sequential`) refine the *preview* only; they never run work. Per the `parallel-agent-delivery` pitch ([`../../../.lsa/pitches/parallel-agent-delivery.md`](../../../.lsa/pitches/parallel-agent-delivery.md)) Definition of success #1.
- **Parallel-vs-sequential is indicative only.** True disjointness / dependency-wave reasoning belongs to the deferred engine, not this stub.
- **Function-named command.** Name + args read as "manager, implement these epics" per [`../../knowledge/command-naming.md`](../../knowledge/command-naming.md); the bare form does a useful read-only thing.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link/quote, never restated.

---

`/manager:implement [epics]` — manual invocation.
