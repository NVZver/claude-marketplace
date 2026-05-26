Shaped by: Nikita Zverev
Date: 2026-05-26
Status: approved
Why now: the product-manager just shipped (management v0.1.0) — pitches land as files but the roadmap stays a hand-maintained table with no agent to decompose pitches into buildable work items; the gap between "shaped idea" and "LSA build cycle" is uncoordinated

# Project-manager agent for the management plugin

A roadmap steward that converts approved pitches into scoped work items, keeps the roadmap tidy and reliable, and hands focused epics to LSA for technical refinement and implementation.

## Problem

The marketplace has a strong shaping phase (product-manager → pitch) and a strong build phase (LSA: discover → plan → implement → verify), but nothing in between. Once a pitch is approved, the user must manually:

1. Add a backlog entry to the roadmap (`vision/specs/roadmap.md`) — currently a hand-maintained Markdown table.
2. Decide what to work on next by scanning the roadmap, mentally weighing dependencies and priority.
3. Decompose the chosen pitch into focused epics/tickets small enough for LSA to take one at a time.
4. Keep the roadmap up to date as work progresses (status changes, new items, completed items).

Evidence: `vision/specs/roadmap.md:9-43` — a 35-row static table maintained by hand. Status updates happen only when the user remembers to edit the table. `lsa:next` (`lsa/skills/next/SKILL.md:11-12`) does a simple priority-sorted pop from the backlog — no dependency reasoning, no pitch reading, no decomposition.

**What principal-level project managers do differently** [sourced from industry practice]:

1. **Roadmap stewardship.** The roadmap is not a static list — it is a living document that reflects current reality. A principal PM keeps it accurate, flags stale items, and ensures every entry has enough context for someone to pick it up. Source: the distinction between "backlog grooming" (junior) and "roadmap stewardship" (principal) is that the latter reasons about the whole, not individual items [unverified — cited from training knowledge about TPM career ladders].

2. **Pitch-to-epic decomposition.** A pitch describes the shaped problem and solution boundary. Epics are the buildable slices. A principal PM decomposes with discipline: each epic is independently shippable, has a clear definition of done, and is small enough for one build cycle. Source: the Shape Up concept of "scopes" — horizontal slices of work that can be completed independently within the appetite boundary [unverified — cited from training knowledge of Basecamp Shape Up methodology].

3. **Dependency-aware sequencing.** Given N backlog items, the PM does not just sort by priority. They factor in: (a) which items must ship first to unblock others, (b) technical risk (uncertain items earlier to fail fast), (c) value delivery (what gets user-facing impact soonest). Source: WSJF-adjacent reasoning used in mature engineering organizations [unverified — Weighted Shortest Job First from SAFe framework, adapted].

Current workaround: the user manually does all four steps above. This works at 3-5 features; it breaks at 10+.

Definition of success: approved pitches flow into the roadmap as structured backlog entries. The user invokes one skill, the project-manager reads the roadmap, helps pick the next item, decomposes the linked pitch into focused epics, and hands each epic to LSA. The roadmap stays accurate and up to date.

## Appetite

Medium batch. Deliverables follow the product-manager pattern (one agent + one orchestrator skill + knowledge files):

- `management/agents/project-manager.md` — the agent prompt
- `management/skills/roadmap/SKILL.md` — single entry point (the roadmap)
- `management/knowledge/epic-decomposition.md` — rules for breaking pitches into epics
- `management/knowledge/sequencing-heuristics.md` — three-factor model (dependency, risk, value)

The agent is **read-write on the roadmap only** — it reads pitches, specs, branches, and git state, but the only file it proposes modifications to is `vision/specs/roadmap.md` (with user approval). All other modifications remain the responsibility of other skills.

**Also modifies the product-manager output.** The product-manager currently produces only a pitch file. After this feature ships, `management:start-feature` also produces a roadmap backlog entry (title, short description, priority, link to pitch file) — so the handoff from shaping to project management is structured, not manual.

Out of appetite:
- Automated status updates from git/LSA state (the PM recommends changes; the user approves edits to the roadmap).
- Gantt chart / timeline visualization (text-based is sufficient for a solo workflow).
- Sprint/iteration planning — the system uses appetite-based shaping, not sprint cycles.
- External tool integration (Jira, Linear) — the roadmap file is the source of truth.

## Solution sketch

- **Key user interactions:**
  1. After a pitch is approved, `management:start-feature` adds a backlog entry to the roadmap (new behavior — currently only writes the pitch file).
  2. User invokes `management:roadmap` (the single entry point).
  3. Agent reads the roadmap, identifies candidate items, and recommends what to take next — citing dependencies, risk, and value from the linked pitch files.
  4. User confirms the pick.
  5. Agent reads the selected pitch and decomposes it into focused epics (independently shippable, clear definition of done, scoped to one LSA build cycle each).
  6. User approves the epics.
  7. Agent hands the first epic to LSA (via `lsa:discover` or `lsa:new`) for technical refinement and implementation.

- **Main components:**
  - `management/agents/project-manager.md` — read-only on everything except roadmap; proposes roadmap edits via `AskUserQuestion` approval. Follows Goal/Input/Steps/Output/Constraints actor template (`vision/VISION.md:42`).
  - `management/skills/roadmap/SKILL.md` — orchestrator skill that dispatches the project-manager agent. Mirrors the start-feature → product-manager pattern.
  - `management/knowledge/epic-decomposition.md` — rules for decomposing a pitch into epics: each epic must be independently shippable, have a one-sentence scope, and map to a clear boundary in the pitch's solution sketch. Knowledge file (what is true), not actor.
  - `management/knowledge/sequencing-heuristics.md` — the three-factor sequencing model grounded in what data the agent can actually read from this repo. Knowledge file.

- **Critical path:** user invokes `management:roadmap` → agent reads roadmap → recommends next item with rationale → user confirms → agent reads linked pitch → decomposes into epics → user approves epics → agent hands first epic to LSA.

- **`lsa:next` relationship.** `lsa:next` currently does a simple priority-sorted pop from the roadmap. When the management plugin is installed, `lsa:next` becomes redundant — the project-manager provides the same "what to work on next" capability but with dependency reasoning and pitch-grounded decomposition. Resolution: `lsa:next` stays as a fallback for users who do not install the management plugin; when management is installed, the recommended flow is `management:roadmap` instead. No hard dependency added to `lsa`.

## Rabbit holes

1. **Roadmap format stability.** The agent parses the roadmap's Markdown table. If the table format changes (columns renamed, structure altered), the agent breaks silently. Mitigation: define the expected roadmap table format in a knowledge file; the agent validates on read and reports parse failures clearly rather than guessing.

2. **Epic granularity.** "Small and focused" is subjective — the agent might produce epics that are still too large for one LSA build cycle, or too small to be independently meaningful. Mitigation: the knowledge file defines concrete heuristics (e.g., "each epic should touch one module boundary" or "each epic should be completable in one `lsa:discover` → `lsa:verify` cycle"). The user approves every epic list before handoff.

3. **Stale roadmap entries.** The agent might recommend items whose linked pitch is outdated or whose context has shifted since shaping. Mitigation: the agent reads the pitch file and checks the "Why now" metadata and "Date" field, flagging items shaped more than N weeks ago for user re-evaluation before decomposition.

4. **Product-manager output change.** Adding a roadmap entry to the product-manager's output changes the existing `management:start-feature` → product-manager flow. Mitigation: the change is additive (one additional step after pitch approval) and guarded by an `AskUserQuestion` — the user confirms the backlog entry content before it is written. The pitch-only flow still works if the user skips the roadmap step.

5. **Handoff format to LSA.** The project-manager produces epics; LSA expects a task description for `lsa:discover`. The epic format must be rich enough for LSA to run discovery without losing context, but not so prescriptive that it duplicates LSA's own spec authoring. Mitigation: each epic is a one-paragraph description with a link to the parent pitch — enough to seed `lsa:discover`, not a requirements document.

## No-gos

1. This pitch does NOT cover automated roadmap status updates from git/LSA state — the project-manager recommends; the user approves changes to the roadmap. Adding automatic status tracking is a separate appetite decision.

2. This pitch does NOT cover sprint/iteration planning — the marketplace uses appetite-based shaping per `management/knowledge/pitch-structure.md`, not fixed-length sprints.

3. This pitch does NOT cover multi-contributor coordination — the marketplace is a personal system (`vision/VISION.md:7`). Resource allocation and team communication are not in scope.

4. This pitch does NOT cover the internal structure of LSA's discovery or planning — the project-manager hands epics to LSA; what LSA does with them is LSA's concern.

5. This pitch does NOT cover external tool integration (Jira, Linear, GitHub Issues) — the roadmap file is the source of truth.
