> **Trace.** On load, print first: `=============== [vision/specs/features/2026-05-22-helper-onboarding-fast-path/tasks.md] [vision] ===============`

# Tasks: Helper fast-path for onboarding questions

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #2. Requirements: `./requirements.md`. Design: `./design.md`. Tests: `./test-suites.md`.

Sequenced executable steps for **one PR**, single branch. Each task names a deliverable + the AC / NFR / requirement it covers. The PR title and branch slug: `feat(helper): onboarding fast-path (v0.3.0)`.

## Task 0 — Branch + worktree

- **Deliverable.** Create feature branch `feat/helper-onboarding-fast-path` from `main`.
- **Covers.** Workflow convention (`lsa/ARCHITECTURE.md` branch management).
- **Verify.** `git status` on the new branch is clean.

## Task 1 — Create the catalog Knowledge file

- **Deliverable.** New file `helper/knowledge/onboarding-fast-path.md` with the structure specified in `design.md` §"New Knowledge file content":
  1. Trace directive header.
  2. Purpose statement (1-2 sentences).
  3. Catalog table — 6 rows per `design.md` §"README excerpt mapping table".
  4. Matching rules (3-5 bullets).
  5. Negative examples (4-6 bullets).
  6. Fall-through rules.
- **Covers.** F1 (classification rule lives in Knowledge), F6 (catalog is data), NF5 (Knowledge vs Actor separation), `design.md` §"New Knowledge file content".
- **Verify.** Manual read-through; confirm every catalog row's `file:line-range` resolves to the expected content in the live README at HEAD; confirm headings cited in the table exist verbatim in the source files.

## Task 2 — Wire Step 1.5 into the Helper agent

- **Deliverable.** Edit `helper/agents/helper.md`:
  - Insert new Step 1.5 with the exact wording in `design.md` §"Step 1.5 — exact wording".
  - **Insertion-style: do NOT renumber existing Steps 2-5.** Steps 2 / 3 / 4 / 5 keep their numbers and bodies. Per `design.md` §"Landing surface" and §"Three-stage flow" *Numbering convention*.
  - Add one bullet to Constraints (`helper/agents/helper.md:46-58`): the *"Fast-path-first for onboarding subjects"* bullet from `design.md` §"Landing surface".
- **Covers.** F1, F2, F3, F4, F5, F7, AC1-AC8.
- **Verify.** Diff inspection — exactly one new Step (1.5) inserted; existing Steps' numbers and bodies unchanged; the *"skip to Step 5"* note at `helper/agents/helper.md:34` stays valid (no renumber required).

## Task 3 — Plugin manifest + CHANGELOG bump

- **Deliverable.**
  - `helper/.claude-plugin/plugin.json`: bump `version` `0.2.1` → `0.3.0`.
  - `helper/CHANGELOG.md`: prepend the v0.3.0 entry per `design.md` §"Landing surface" row (Keep a Changelog format).
- **Covers.** NF4 (Per-plugin SemVer + CHANGELOG); `vision/specs/main.spec.md:30` NFR3; `CLAUDE.md` *"Bump version in the same commit as the changelog entry"* rule.
- **Verify.** `cat helper/.claude-plugin/plugin.json | jq '.version'` returns `0.3.0`; `head -10 helper/CHANGELOG.md` shows the v0.3.0 entry first.

## Task 4 — Update `helper/README.md`

- **Deliverable.** Add the one-line note under the Status header per `design.md` §"Landing surface": *"v0.3.0 adds onboarding fast-path — README-cited answer in seconds for install / start / what-is questions; deep-research path unchanged for everything else."*
- **Covers.** `CLAUDE.md` *"READMEs are living documents"* rule; NF6 (no regressions surfaced to user).
- **Verify.** Diff inspection — exactly one line added; no other content changed.

## Task 5 — Correct the roadmap row

- **Deliverable.** Edit `vision/specs/roadmap.md:114`:
  - Replace *"Pattern classifier lives in `helper/skills/helper/SKILL.md`."* with *"Pattern classifier lives in `helper/knowledge/onboarding-fast-path.md`; Step 1.5 in `helper/agents/helper.md` invokes it."*
  - Move the row from `## Feature Backlog` to `## Recently merged` with date `2026-05-23` and status `shipped — helper v0.3.0`.
- **Covers.** Surface-divergence note in `requirements.md` §Summary; living-spec discipline.
- **Verify.** Diff inspection.

## Task 6 — Probe Journey 1 (golden test)

- **Deliverable.** Run `test-suites.md` Journey 1 (golden — *"how do I get started with LSA"*) in a fresh Claude Code session post-build. Capture: (a) wall-clock from invocation to response, (b) tool-call trace, (c) response body excerpt + citation.
- **Covers.** AC1, NF1, F1, F2, F4.
- **Verify.** Latency ≤5s; no `Grep` / `Glob` / `context7` calls; quoted excerpt matches `README.md:73-83` content.

## Task 7 — Probe Journeys 2 through 10

- **Deliverable.** Run remaining Journeys from `test-suites.md`:
  - Journey 2 (install).
  - Journey 3 (what-is triple).
  - Journey 4 (multi-trigger first-match-wins).
  - Journey 5 (fall-through deep-research).
  - Journey 6 (excerpt missing → fall-through).
  - Journey 7 (cannot-verify backstop).
  - Journey 8 (cooldown precedes fast-path).
  - Journey 9 (signal-a auto-engage unaffected).
  - Journey 10 (catalog drift probe — informational; ACK drift behavior, not a pass/fail).
- **Covers.** AC2-AC8, F3, F5, F7, NF6; Journey 10 → `design.md` OQ2 (catalog drift acknowledgement, no AC binding).
- **Verify.** Per Journey expected-outcomes. Record probe results inline in the PR description. For Journey 10, record observed drift behavior; non-blocking for merge.

## Task 8 — Commit + push + open PR

- **Deliverable.**
  - One commit on `feat/helper-onboarding-fast-path` with files from Tasks 1-5.
  - Commit message body: title `feat(helper): onboarding fast-path (v0.3.0)`, footer cites `vision/specs/features/2026-05-22-helper-onboarding-fast-path/`.
  - Push under `NVZver` account per `CLAUDE.md` §"GitHub account".
  - PR description: paste probe results from Task 6 + Task 7.
- **Covers.** Workflow convention.
- **Verify.** `gh pr view` shows the PR open against `main`; probe results visible in description.

## Task 9 — Post-merge: `lsa-sync`

- **Deliverable.** Run `/lsa:sync` post-merge per `CLAUDE.md` *"Spec-grounding + Fact-grounding"* discipline; archive `vision/specs/features/2026-05-22-helper-onboarding-fast-path/`; update `vision/specs/modules/helper/spec.md` (or equivalent) with the new fast-path behavior.
- **Covers.** `lsa/ARCHITECTURE.md` sync discipline.
- **Verify.** `lsa-sync` exits with PASS; feature dir moved under `vision/specs/archive/`.

## Task 10 — On-merge: roadmap status update

- **Deliverable.** On merge, edit `vision/specs/roadmap.md` row *"Helper fast-path for onboarding questions"* (currently `vision/specs/roadmap.md:110`) — move from *Feature Backlog* to *Recently merged*. (If row already addressed by row #1 bundling, mark as covered by the joint Helper v0.3.0 PR.)
- **Covers.** Living-spec discipline; bundled v0.3.0 decision (`design.md` §"Modules Affected" *Cross-row Helper v0.3.0 bundling*).
- **Verify.** Diff inspection — row removed from *Feature Backlog* and present under *Recently merged* with date `2026-05-23` and reference to the joint Helper v0.3.0 PR.

---

## Pre-merge checklist

- [ ] Task 1: `helper/knowledge/onboarding-fast-path.md` exists with 6 catalog rows.
- [ ] Task 2: Step 1.5 inserted; Steps NOT renumbered (insertion-style); Constraints bullet added.
- [ ] Task 3: `helper` plugin bumped to v0.3.0 with matching CHANGELOG entry.
- [ ] Task 4: `helper/README.md` Status note added.
- [ ] Task 5: `vision/specs/roadmap.md` row #2 corrected and moved to *Recently merged*.
- [ ] Task 6: Journey 1 passes — ≤5s, no deep-grep / no `context7`.
- [ ] Task 7: Journeys 2-9 pass per expected outcomes; Journey 10 drift behavior recorded (informational).
- [ ] Task 8: PR opened against `main` with probe results in description.
- [ ] Task 9: `lsa-sync` queued for post-merge.

## Open Questions

- **OQ1.** **Catalog drift hook (design.md OQ2) — separate PR or this one?** Adding a drift check at `lsa-reconcile` SessionStart would expand scope significantly. **Tentative resolution: separate follow-up. Land this PR with manual catalog re-pin; open a backlog row if drift bites.**
- **OQ2.** **Should the trace directive on the new Knowledge file follow the standard or get a custom format?** Per `core` v0.5.4 / `lsa` v0.6.4 / `helper` v0.2.1 every marketplace instructional file carries `=============== [<file>] [<plugin>] ===============` on load (`vision/specs/roadmap.md:16`). **Tentative resolution: standard format, no custom — consistent with the other three files in `helper/knowledge/`.**
- **OQ3.** **`lsa-verify` of this feature PR.** Per `vision/specs/main.spec.md` and the verify discipline, every code change must trace to a requirement. **Tentative resolution: enumerate the trace in PR description: catalog rows ↔ AC1-AC3, Step 1.5 wording ↔ F1/F2/F4, CHANGELOG entry ↔ NF4. Run `/lsa:verify` before merge.**
