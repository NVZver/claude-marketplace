# Test Suites: Diagonal Cross-Artifact Analysis

## Journey 1: Gate 2 fires with all artifacts internally consistent (happy)

**Goal:** A spec author finishes Gate 1 with consistent artifacts; the new diagonal check confirms consistency without blocking.
**Covers:** AC1, AC2, AC5

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — contract present, all 4 rows pass | Author approves Gate 1 (contract-trigger = yes) → `lsa-specify` proceeds to Gate 2 → renders 4-row coverage table with every row `✓` → each row cites two `file:line` pointers → human approves → Gate 3 |

**Expected outcome:**
- A 4-row markdown table appears in the Gate 2 presentation, with rows ordered: AC→Journey, Journey→Design, Design→Contract, Contract→test-suites.
- Every row has status `✓` and a citation column showing `<file>:<line> ↔ <file>:<line>`.
- The Gate 2 decision block (`[a] approve / [b] approve with corrections / [c] reject`) renders unchanged below the coverage table.

## Journey 2: Gate 2 fires with `contract.yaml` skipped

**Goal:** A spec author writes a feature with no contract trigger; the diagonal check renders contract-touching rows as `N/A` rather than failing.
**Covers:** AC4

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Happy — contract skipped, rows 1–2 pass, rows 3–4 N/A | Author approves Gate 1 (contract-trigger = no) → `lsa-specify` proceeds to Gate 2 → renders 4-row table → rows 1 (AC→Journey) and 2 (Journey→Design) show `✓` → rows 3 (Design→Contract) and 4 (Contract→test-suites) show `N/A — contract skipped` → human approves |

**Expected outcome:**
- Rows 3 and 4 never show `✗` when contract is skipped — they show `N/A — contract skipped` with no citation column required.
- The human is never asked to resolve a contract-row failure when the contract was deliberately skipped.

## Journey 3: Gate 2 surfaces a cross-artifact contradiction (error)

**Goal:** A spec author has an internal contradiction between two artifacts; the diagonal check blocks approval until the human picks a resolution.
**Covers:** AC3

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Single failure — Contract↔test-suites mismatch | Author writes `contract.yaml` with `POST /foo` but `test-suites.md` Journey 1 says `PUT /foo` → Gate 2 renders 4-row table → row 4 shows `✗` with both cited lines → a single Rule 6 decision block appears: `[a] revise contract (POST→PUT) / [b] revise test-suites (PUT→POST) / [c] custom` → approval is blocked until human picks → human picks `[a]` → file is edited → Gate 2 re-fires |
| 2 | Two failures batched — Design↔Contract + Contract↔test-suites both mismatch | Author has design.md describing a `DELETE` endpoint but contract.yaml only has `POST` + test-suites.md tests `POST` → Gate 2 renders table with rows 3 AND 4 as `✗` → two Rule 6 decision blocks appear together in a single multi-question `AskUserQuestion` call → human picks per row → both edits applied → Gate 2 re-fires |
| 3 | Reject custom — escape to Gate 1 | Author hits an `✗` row but neither `[a]` nor `[b]` is acceptable → picks `[c] custom` → enters free-form text → the gate logs the custom note and returns to Gate 1 for a deeper revision |

**Expected outcome:**
- Every `✗` row produces exactly one Rule 6 decision block.
- When multiple rows fail, all decision blocks surface together in a single `AskUserQuestion` (NF2: batched).
- Approval cannot proceed until every `✗` row is resolved (`[a]`, `[b]`, or `[c]`).
- `[c] custom` is always available as the escape hatch — the gate never forces a binary choice.

## AC coverage check (mandatory before Gate 2 presentation)

| AC | Covered by |
|---|---|
| AC1 — 4-row table renders | Journey 1, Path 1 |
| AC2 — Citations in `file:line` | Journey 1, Path 1 |
| AC3 — Failing row → Rule 6 block, blocks approval | Journey 3, Paths 1–3 |
| AC4 — `N/A` when contract skipped | Journey 2, Path 1 |
| AC5 — Docs in SKILL.md + module spec | Journey 1, Path 1 (verifiable post-implementation by reading the docs) |

**All 5 ACs covered by at least one journey.** ✓
