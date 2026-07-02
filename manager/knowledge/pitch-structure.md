> **Trace.** On load, print first: `=============== [manager/knowledge/pitch-structure.md] [manager] ===============`

# Pitch structure — knowledge

The canonical format for a shaped pitch. An approved pitch lives at `${specs_root}/pitches/<slug>.md` (where `specs_root` is resolved from `.lsa.yaml` — see [`../../lsa/knowledge/conventions.md`](../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults"). Inspiration: Basecamp Shape Up shaping phase [unverified -- cited from training knowledge].

**Contents:** [Metadata header](#metadata-header) · [Five sections](#five-sections) · [Markdown template](#markdown-template) · [Worked example](#worked-example-illustrative)

## Metadata header

```
Shaped by: <name>
Date: <YYYY-MM-DD>
Status: draft | approved
Why now: <one sentence — what makes this timely; "no urgency — backlog candidate" if none>
```

**Status lifecycle (since management v0.6.0, per `core/output` Rule 7 *Authorization boundary*):** `draft` exists only in the product-manager agent's return payload — never on disk. `manager:shape` writes the file with `Status: approved` only after its approve gate. A rejected pitch is never written; its rationale stays in the conversation.

## Five sections

Fixed H2 headings, fixed order. Downstream agents (project-manager, `lsa:discover`) parse by name — do not rename, reorder, or nest.

- **Problem** — who has it, evidence, current workaround, definition of success.
- **Appetite** — scope/time constraint (not estimate). What is out of appetite.
- **Solution sketch** — key user interactions, main components involved, critical path.
- **Rabbit holes** — numbered risks with mitigations. "None identified" if empty.
- **No-gos** — numbered exclusions. "This pitch does NOT cover X because Y."

## Markdown template

```markdown
Shaped by: <name>
Date: <YYYY-MM-DD>
Status: draft
Why now: <one sentence>

# <Pitch title>

One-sentence summary.

## Problem

<who has it, evidence>

Current workaround: <how users cope today>

Definition of success: <how we will know this is solved>

## Appetite

<size, boundary, what is out>

## Solution sketch

- **Key user interactions:** <what the user does differently>
- **Main components:** <which parts of the system are touched>
- **Critical path:** <the one sequence that must work>

## Rabbit holes

1. <risk> — <mitigation>

## No-gos

1. <exclusion> — <rationale>
```

## Worked example [illustrative]

```markdown
Shaped by: Nikita Zverev
Date: 2026-05-26
Status: draft
Why now: third plugin just shipped (manager) — pattern is repeating, cost of mistakes compounds

# Onboarding checklist for new marketplace plugins

New plugin authors repeat the same setup mistakes — missing CHANGELOG, wrong plugin.json
shape, no module spec entry. A guided checklist would catch these before the first PR.

## Problem

Plugin authors (currently just the repo owner, but the pattern should hold for contributors)
forget steps when scaffolding a new plugin. Evidence: the helper plugin's first PR needed
three follow-up commits to add the missing .lsa.yaml entry and module spec
[assumption: reconstructed from CHANGELOG pattern, not from a specific bug report].

Current workaround: the author manually cross-references existing plugins (helper, lsa) and
hopes they remember every file. Each new plugin repeats this from scratch.

Definition of success: a new plugin scaffold passes `lsa:verify` on the first commit — no
follow-up fix commits for missing structural files.

## Appetite

Small batch. The checklist is a static knowledge file — no agent logic, no automation.
Out of appetite: a scaffolding command that auto-generates files (that is a separate pitch).

## Solution sketch

- **Key user interaction:** author reads the checklist before their first commit; each item
  is a yes/no checkpoint with a file path to create.
- **Main components:** one new knowledge file at `core/knowledge/new-plugin-checklist.md`;
  no changes to existing plugins or skills.
- **Critical path:** author opens checklist → walks items top to bottom → creates each file →
  runs `lsa:verify` → passes on first attempt.

## Rabbit holes

1. Checklist drift — the checklist could fall out of sync with actual plugin structure.
   Mitigation: `lsa:verify` traces checklist items to real file paths; missing file = finding.

## No-gos

1. This pitch does NOT cover auto-scaffolding (a `/plugin new` command) — that requires
   agent logic and a separate appetite decision.
2. This pitch does NOT cover external contributor onboarding (CoC, PR templates) — out of
   scope for the manager plugin.
```
