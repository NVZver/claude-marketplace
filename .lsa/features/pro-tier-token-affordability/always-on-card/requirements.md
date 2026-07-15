# Epic pro-tier-token-affordability/always-on-card — Requirements

Parent: ../../../pitches/pro-tier-token-affordability.md (WS1) · Status: approved · Date: 2026-07-15
Modules: core (card), lsa (read protocol). Grounding: lsa:discover 2026-07-15.

## Functional requirements (EARS)

- **F1** (Ubiquitous) The core plugin shall ship ONE always-on card of ≤45 lines carrying:
  the eight ground-rule names each with a one-line essence; the hard output rule (Sourced —
  source + quote — plus the file-load trace directive) stated in full; the three flow labels
  with the five boundary signals; a reuse-first ladder pointer; the cite-without-loading
  convention; and `reconcile.runs` guidance — every section citing its full skill by
  markdown link (licensed by `core/skills/output/SKILL.md:8` re-grounded-summary clause).
- **F2** (Event) When a substantive task begins in a session with the card merged, the
  system shall apply content and output discipline from the card alone, without loading
  the ground-rules / output / flow-selector SKILL.md files.
- **F3** (Event) When a task matches a card-listed escalation trigger (authoring or editing
  a marketplace instructional file; adjudicating a disputed rule; prompt review), the
  system shall load only the full skill that trigger names.
- **F4** (State) While an LSA skill runs its read protocol, the system shall satisfy the
  mandatory constitution read with the digest (≤35 lines), loading the full constitution
  only for constitutional tasks (lsa:init, lsa:revise-constitution, explicit user request).
- **F5** (Unwanted) If the constitution changes and the digest is not regenerated, then
  `bash scripts/lint.sh` shall exit non-zero naming the stale digest.
- **F6** (Ubiquitous) The digest shall be deterministically derived from the constitution
  by a repo-internal script (zero model tokens, same input → same output), never hand-edited.
- **F7** (Ubiquitous) The card and digest shall preserve rule content — packaging only:
  no rule added, removed, weakened, or renumbered; canon stays the linked SKILL.md files.
- **F8** (Event) When the card or digest is loaded, the system shall print its file-load
  trace line (both files carry the trace directive).

## Acceptance criteria (journey-shaped)

- **AC1** (F1, F2) Fresh session, substantive question → response is sourced + traced with
  discipline text ≤ card size (~45 lines) loaded, not ~493.
- **AC2** (F4, F8) Any LSA skill invocation → read-summary cites the digest read; skill
  output unchanged in shape and rigor.
- **AC3** (F5, F6) Edit VISION.md, run lint → non-zero with staleness message; run the
  regeneration script, lint → 0.
- **AC4** (F7) Side-by-side review of card + digest vs canon shows zero semantic rule
  change; probe D2 and lint C6 stay green.

## Design decisions (resolved at the 2026-07-15 spec gate)

- **D1** Digest path: `.lsa/VISION-digest.md`, adjacent to the constitution `[ASSUMPTION]`.
- **D2** `lsa/knowledge/conventions.md` Read protocol step 2 names the digest as the
  mandatory read + lists the full-read triggers.
- **D3** `core/skills/reuse-first/SKILL.md` untouched; the card compresses its ladder to
  one pointer line.

## Non-functional

- Card ≤45 lines, digest ≤35 lines (`wc -l`); no behavior profile forks (pitch No-go 5).
