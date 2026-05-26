# Feature: Management Plugin — Product Manager Agent

## Summary

The marketplace has strong *build* discipline (`lsa:discover` → `lsa:plan` → `lsa:implement` → `lsa:verify`) but no *what to build* discipline. Today, the user carries the entire shaping burden mentally before typing a feature description into `lsa:discover`. This feature adds a `product-manager` agent inside a new `management` plugin that drives an interactive shaping conversation — extracting information from the user, clarifying requirements, and producing a structured pitch from initially vague input. The agent dynamically adapts its domain-expert role per invocation since the marketplace is domain-neutral.

Source: `vision/specs/roadmap.md:179-191` — *"The marketplace has a strong build discipline but no what to build discipline."*

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | `management:start-feature` skill accepts a vague problem/opportunity (argument or interactive prompt) and dispatches the `product-manager` agent, which drives an interactive shaping conversation — not a one-shot analysis. | Must |
| F2 | As the first step, the agent reasons about which domain-expert role best serves the user's problem (e.g., "payroll product manager", "developer-tooling product manager") and adopts that role to narrow focus, ask domain-relevant questions, and surface domain-specific risks. The role selection is visible to the user and overridable. | Must |
| F3 | The user is the primary source of truth. The agent asks targeted questions to extract missing information: who has the problem, what evidence exists, what the appetite is, what are known risks, what is explicitly excluded. Codebase reading (roadmap, specs, code) is secondary — it grounds and enriches the user's answers, never contradicts the user's stated intent. | Must |
| F4 | The agent progressively builds the pitch through conversation — shaping vague input into structured sections incrementally, confirming understanding as it goes, rather than waiting until all questions are answered. | Should |
| F5 | The agent produces a structured pitch markdown file with five sections: Problem (who has it, evidence), Appetite (scope/time boundary), Solution sketch (directional but loose), Rabbit holes (known complexities to call out), No-gos (what the pitch explicitly excludes). Stored at `vision/specs/pitches/<slug>.md`. | Must |
| F6 | The pitch is presented to the user for approval via `AskUserQuestion` — approve, reshape, or reject. No downstream work fires until explicit approval. | Must |
| F7 | On approval, the skill hands off to `lsa:new` (which handles branch creation + flow-selector + discovery). The pitch context seeds the discovery phase. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Plugin follows marketplace conventions: `plugin.json` with SemVer, `CHANGELOG.md` (Keep a Changelog), `README.md`, `dependencies: ["core"]`. Per `vision/VISION.md:46` *"Distribution + versioning."* |
| NF2 | Agent inherits `core/ground-rules` (6 content rules) and `core/output` (7 format rules). Pitch content is fact-grounded per Rule 1; decisions use `AskUserQuestion` per Rule 5. |
| NF3 | Pitch artifact format must be parseable by the future `project-manager` agent (roadmap item #2) for roadmap population — structured markdown with predictable headings. |

## Inputs & Outputs

- **Input:** A vague problem or opportunity description from the user (text argument to `management:start-feature`, or interactive prompt if no argument given).
- **Output:** An approved pitch file at `vision/specs/pitches/<slug>.md` with five sections. On approval, control passes to `lsa:new`.
- **Side effects:** The `management` plugin directory is created with agent, skill, knowledge, and manifest files. Module entry added to `.lsa.yaml` and `main.spec.md`.

## Constraints

- The agent is domain-neutral by default — it self-selects a domain role per invocation, not at install time. Per `vision/VISION.md:7` *"the core is domain-neutral."*
- The agent does not populate the roadmap, track dependencies, or manage sequencing — that is the future project-manager's job. Per roadmap:193-205.
- The `lsa:new` overlap (roadmap:191 *"lsa:new should either be removed or redirect to management:start-feature"*) is noted but deferred — resolve when the full management plugin (both agents) ships.
- Knowledge vs Actor separation per `vision/VISION.md:42`. The agent file is an Actor; pitch methodology and domain-role selection logic are Knowledge files.

## Out of Scope

- Project-manager agent and `management:task-status` skill (roadmap item #2, separate feature branch).
- Roadmap population, dependency tracking, sequencing recommendations.
- `lsa:new` removal or redirect.
- Shape Up methodology adoption beyond the pitch structure (no betting table, no cool-down cycle).

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->
- [ ] AC1: When a user invokes `management:start-feature` with a vague problem description, the system shall ask clarifying questions to extract missing pitch sections before producing the structured pitch.
- [ ] AC2: When the agent begins a shaping conversation, it shall reason about and visibly adopt a domain-expert role, and the user shall be able to override the selected role.
- [ ] AC3: When the user provides information, the system shall treat it as authoritative and use codebase sources only to ground or enrich — never to contradict the user's stated intent; however, when pitch sections conflict (e.g., appetite vs. solution complexity), the system shall flag the inconsistency as an observation for the user to resolve.
- [ ] AC4: When the shaping conversation completes, the system shall produce a pitch file containing all five sections (Problem with current workaround + definition of success, Appetite, Solution sketch with key interactions + components + critical path, Rabbit holes, No-gos) plus "Why now" metadata at `vision/specs/pitches/<slug>.md`.
- [ ] AC5: When the pitch is presented for approval, the system shall wait for explicit human confirmation via `AskUserQuestion` before any downstream skill fires.
- [ ] AC6: When the user approves the pitch, the system shall hand off to `lsa:new` with the pitch as discovery context.
- [ ] AC7: Where the management plugin is installed, its `plugin.json` shall declare `"dependencies": ["core"]`.
