# Feature: Show actual changes inline (LSA / Core / Helper)

> Source: `.lsa/roadmap.md:128-132` §"2026-05-22 backlog detail" #5.
> Status: backlog (partial — `lsa-reconcile` already meets the bar; see `lsa/skills/lsa-reconcile/SKILL.md:35`).
> Priority: **Must** (per `.lsa/roadmap.md:37`).

## Summary

Every marketplace skill that writes, edits, or marks anything must follow the order **write → show → comment**: the change is written to disk, the actual content is quoted back inline (or shown as a compact diff for multi-line / batch changes), and only then does commentary follow. Bare prose like *"I added X to file Y"* or *"Observable result: file is edited"* is no longer acceptable. The landing surface is a sixth rule in `core/skills/output/SKILL.md` that subsumes this principle, plus a skill-body sweep across `lsa/skills/`, `core/skills/`, and `helper/agents/` to bring every existing write step up to the new bar.

Reference exemplar — the user-endorsed gold standard — is the 8-element drift block in `lsa/skills/lsa-reconcile/SKILL.md:35`: *"DRIFT verdict + module name + file/line counts + classification (a or b) + verbatim spec quote with path:line + verbatim artifact quote with path:line + proposed one-line spec update + decision"*. User on that exemplar (2026-05-22): *"Good! Love it!"* (cited in `.lsa/roadmap.md:131`).

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | The agent shall, after every single-file write or edit performed by a marketplace skill, quote the actual content of the change inline (the new line(s) verbatim, with file path and line range), before any commentary about why the change matters. | Must |
| F2 | When a change replaces existing content (class-(a) edit per `lsa/skills/lsa-reconcile/SKILL.md:38`), the agent shall show both the previous content (quoted, with path:line) and the new content (quoted, with path:line), in that order. | Must |
| F3 | When a change is purely additive (class-(b) append per `lsa/skills/lsa-reconcile/SKILL.md:39`), the agent shall quote the added content (with path:line) and label it as added. | Must |
| F4 | When a step marks state (e.g., *"marked OQ5 as resolved"*, *"bumped SHA"*, *"archived feature"*), the agent shall quote the actual line(s) that changed in the state file (e.g., the new `.lsa-sync-state.json` entry, the new `[resolved]` line in `requirements.md`) — *"marked"* without quoted content is forbidden. | Must |
| F5 | When a batch of changes is too large to quote in full (more than ~10 lines of new content across files, or more than ~5 files touched), the agent shall render a **compressed inspection table** in lieu of full quoting: one row per change, columns `file:line | type (add/edit/replace) | summary (≤8 words) | pointer`. The table must be followed by file:line pointers the human can open, and shall never be replaced by a bare *"go check the file"* line. | Must |
| F6 | Where feature `Where` the write produces a structured artifact (a `.json`, a YAML block), the agent shall quote the new fragment as a fenced code block of the matching language (json / yaml), not as prose. | Must |
| F7 | Every `Observable result:` line in a skill's `## Steps` block that names a file write, edit, append, or mark shall name *what is quoted back to the human*, not only that the file changed. The phrase *"diff shown"* alone is not sufficient — the format of the diff (full quote vs. compressed table) must be named. | Must |
| F8 | If the agent fails to ground a quoted change (e.g., the file write itself failed), the agent shall surface *"write failed — no content to quote"* rather than fabricate the content. Per `core/skills/ground-rules/SKILL.md` Rule 2 (fact-grounding). | Must |

EARS-form mapping for the eight functional requirements:

- **F1, F4** — *Ubiquitous* (`shall always` after a write).
- **F2** — *Event* (*"When X replaces existing content… shall"*).
- **F3** — *Event* (*"When X is purely additive… shall"*).
- **F5** — *Event* (*"When the batch exceeds the threshold… shall"*).
- **F6** — *Where* (*"Where the artifact is structured… shall"*).
- **F7** — *Ubiquitous* (every `Observable result:` that names a write).
- **F8** — *Unwanted* (*"If the write fails, then… shall"*).

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | The new `core/output` rule shall stay under 50 lines of rendered markdown (the single-change template, the batch template, and three worked examples), so it fits the `core/output` 1–1.5-screen budget (per `core/skills/output/SKILL.md:20`). |
| NF2 | The rule shall be copy-paste-ready into `core/skills/output/SKILL.md` by the implementor — no further restructuring required. |
| NF3 | Skill-body sweeps shall be a mechanical edit per skill (replace one `Observable result:` line at a time); no skill's `## Goal` / `## Constraints` / `## Output` sections shall be touched unless the touch is required by a new write step. |
| NF4 | The rule shall cite the `lsa-reconcile` 8-element format as the exemplar (per `lsa/skills/lsa-reconcile/SKILL.md:35`) — the rule is a generalization of an existing in-repo pattern, not a new invention. |
| NF5 | The rule shall not duplicate any text already in `core/output`'s five existing rules. Where it overlaps with Rule 4 (*Sourced* — quoted evidence) or Rule 5 (*Concrete*), it shall cite the existing rule by markdown link. |

## Inputs & Outputs

**Inputs.**
- `.lsa/roadmap.md:128-132` — the user's verbatim Problem / Example / Expected Output text.
- `lsa/skills/lsa-reconcile/SKILL.md:35-44` — the reference 8-element format (the gold standard the user endorsed).
- `core/skills/output/SKILL.md` — the current five-rule canonical file the new rule lands in.
- The full skill inventory under `lsa/skills/`, `core/skills/`, and `helper/agents/` for the sweep.

**Outputs.**
- A new Rule 6 in `core/skills/output/SKILL.md` (likely titled *"Show changes inline — write, show, comment"*).
- Per-skill updates to every `Observable result:` line that currently names a file write without naming what is quoted back. Surface: `lsa/skills/lsa-sync/SKILL.md`, `lsa/skills/lsa-specify/SKILL.md`, `lsa/skills/lsa-init/SKILL.md`, `lsa/skills/lsa-plan/SKILL.md`, `lsa/skills/lsa-revise-constitution/SKILL.md`, `lsa/skills/lsa-verify/SKILL.md` (metrics write only), and `helper/agents/helper.md` (no current writes — agent stays read-only, but Helper's response-shape constraint inherits Rule 6 by reference).
- Updated `core/CLAUDE.md` operational-checkpoint block (an addition naming Rule 6 alongside the existing three checkpoints).
- Per-plugin `CHANGELOG.md` entries + SemVer bumps per `CLAUDE.md` *"Per-plugin SemVer + CHANGELOG"* discipline.

## Constraints

- **Do not edit `lsa-reconcile`.** It is the exemplar; the rule reads against it. Touching it risks circular drift.
- **No new file types, no new conventions, no new state files.** This row is a behavioral discipline, not a tooling addition.
- **The rule must not break Rule 2 (Minimal).** A full quote of a 200-line patch is a Rule 2 violation; that is exactly why F5 (the batch / compressed-inspection-table path) exists.
- **Sweep is mechanical.** No skill's behavior changes — only what the skill prints back. Per the explicit framing in `.lsa/roadmap.md:132`.
- **Per-plugin SemVer + CHANGELOG.** Each plugin updated bumps its own version and entry per `CLAUDE.md` *"Discipline (sourced)"*.

## Out of Scope

- Refactoring `lsa-reconcile` itself — it sets the bar.
- Adding lints / harness checks that auto-detect missing inline content. (Deferred to the Self-eval harness row in `.lsa/roadmap.md:28`.)
- Helper's full assistant refactor (separate row #1 in the backlog).
- LSA verb-headline what-and-why preambles (row #4 — see "Interaction with #4" in `design.md`).
- Backfilling archive specs under `.lsa/archive/`. Archive files don't rewrite per the rule cited in `.lsa/roadmap.md:48`.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per .lsa/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per .lsa/VISION.md:204 — one of Ubiquitous / Event / State / Optional / Unwanted. -->

- **AC1** — *Event*. When a marketplace skill writes a single line to a file, the human shall, without opening any other file, see the file path with line range, the new line quoted verbatim, and then the commentary — in that order, in the same response turn. *Observable*: response contains a quoted block citing `path:line` of the new content before any "this means" sentence.
- **AC2** — *Event*. When a marketplace skill replaces existing content, the human shall, without opening any other file, see both the previous content (quoted, with path:line) and the new content (quoted, with path:line) in the same response turn. *Observable*: response contains both quoted blocks; ordering is previous-then-new.
- **AC3** — *Event*. When a marketplace skill performs more than ~5 file changes in a single turn, the human shall see a compressed inspection table (one row per change) with at least the columns `file:line | type | summary | pointer`, followed by file:line pointers. *Observable*: the table is rendered; no row says only *"see file"*.
- **AC4** — *Event*. When a marketplace skill *marks* state (e.g., resolves an OQ row, bumps a SHA, archives a feature dir), the human shall see the actual line(s) that changed in the state file, quoted, with path:line. *Observable*: no response of the form *"marked X resolved"* without a quoted block.
- **AC5** — *Ubiquitous*. Every skill body under `lsa/skills/`, `core/skills/`, and `helper/agents/` whose `## Steps` block names a file write, edit, append, or mark shall name `core/output` Rule 6 (by markdown link to `core/skills/output/SKILL.md`) at the relevant step, and its `Observable result:` shall name what is quoted back to the human. *Observable*: a grep across the three skill trees for `Observable result:.*written\|edited\|appended\|marked` returns zero rows where the result names only the file mutation without naming the quoted echo.
- **AC6** — *Unwanted*. If a write fails, the response shall name the failure (*"write failed — no content to quote"*) rather than render a quoted block of pre-write speculation. *Observable*: failure paths contain the failure phrase; no fake quote is rendered.
- **AC7** — *Ubiquitous*. The new Rule 6 in `core/skills/output/SKILL.md` shall include the single-change template, the batch (compressed-inspection-table) template, and at least three worked examples covering: (a) single-file edit, (b) multi-file batched write, (c) state-marking ("marked X resolved"). *Observable*: a Read of the file shows all three template forms in the body.
