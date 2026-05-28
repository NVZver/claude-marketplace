# Design: Diagonal Cross-Artifact Analysis

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `lsa` | modify — edits to `lsa/skills/lsa-specify/SKILL.md` Step 5 (Gate 2) and `.lsa/modules/lsa/spec.md` Invariants section |
| `core` | read-only — no edits; `core/ground-rules` Rule 6 is referenced (no change) |

## Technical Approach

Prose-level addition to the Step 5 body of `lsa/skills/lsa-specify/SKILL.md`. Insertion point: after the existing AC-coverage check (`lsa/skills/lsa-specify/SKILL.md:154`), before the rendered presentation of `test-suites.md`.

The addition reads four artifacts (`requirements.md`, `test-suites.md`, `design.md`, optional `contract.yaml`) and renders a 4-row markdown coverage table inside the Gate 2 presentation. The check logic is described in the SKILL body (not in executable code) because `lsa` invariant at `.lsa/modules/lsa/spec.md:30` is *"markdown + small JSON / YAML / bash surface. No `/src/`."*

### Coverage table rows

| # | Pair | Compares | When contract skipped |
|---|------|----------|----------------------|
| 1 | AC→Journey | Each AC in `requirements.md` § Acceptance Criteria has at least one Journey in `test-suites.md` with that AC in its `**Covers:**` line. | Always evaluated. |
| 2 | Journey→Design | Every Journey in `test-suites.md` is grounded in a section of `design.md` (module, contract, or technical approach reference). | Always evaluated. |
| 3 | Design→Contract | Every endpoint or schema named in `design.md` § API / Interface Changes appears in `contract.yaml`. | `N/A — contract skipped` |
| 4 | Contract→test-suites | Every endpoint/schema in `contract.yaml` is exercised by at least one Journey path in `test-suites.md`. | `N/A — contract skipped` |

### Citation format

Each row's citation column is rendered as `<file>:<line> ↔ <file>:<line>`. Example for row 1: `requirements.md:48 ↔ test-suites.md:7` — where line 48 is the `- [ ] AC1: ...` line and line 7 is the `**Covers:** AC1, AC2` line.

When a row fails, the citation column shows the two specific lines that failed to reconcile (e.g., the AC line that no Journey covers, and the closest near-miss Journey heading).

### Rule 6 decision block on failure

When a row's status is `✗`, the SKILL renders a Rule 6 decision block per failing row:

```
✗ Row N (<pair>):  <file>:<lineA> ↔ <file>:<lineB>
   <lineA-content>
   <lineB-content>

   Resolution:
   [a] revise <fileA> — <suggested-edit-A>
   [b] revise <fileB> — <suggested-edit-B>
   [c] custom — free-form text
```

When multiple rows fail (per NF2), all decision blocks render together in a single multi-question `AskUserQuestion` call. Approval is blocked until every `✗` row has a resolution. `[c] custom` escapes to Gate 1 for deeper revision.

## Data Model Changes

none

## API / Interface Changes

none (no HTTP/REST surface; the change is a markdown render inside one skill's Step body)

## Cross-Module Contracts

none

The Gate 2 output is consumed by humans (the spec author) only. `lsa-plan` and `lsa-verify` read the approved artifact files (`requirements.md`, `test-suites.md`, `contract.yaml`, `design.md`) — not the Gate 2 render itself. So no downstream module's behavior depends on the table shape.

## Open Questions

| ID | Question | Default |
|---|---|---|
| OQ1 | When an AC spans multiple lines, which line does the citation point to? | Line of the `- [ ] ACn:` opener. |
| OQ2 | How is a Journey cited when it has both a heading and a path table? | Line of the `## Journey: ...` heading. |
| OQ3 | What happens if `design.md` § API / Interface Changes says "none" but `contract.yaml` defines endpoints? | Row 3 = `✗` (the design lies about the contract). Caught by Design→Contract. |
| OQ4 | What about the inverse — design names an endpoint but contract is skipped (Gate 1 trigger = no)? | The design narrative may use endpoint-like language without triggering Gate 1; rows 3–4 render `N/A`. If this becomes a real source of bugs, escalate Gate 1's trigger sensitivity in a follow-up feature. |
| OQ5 | Where is the new behavior documented in addition to the SKILL.md Step 5 body? | Add one Invariant line in `.lsa/modules/lsa/spec.md` § Invariants. |

All defaults captured; no human input blocked. Open Questions are surfaced to Gate 2 for confirmation.
