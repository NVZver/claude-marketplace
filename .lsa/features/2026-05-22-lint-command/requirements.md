# Feature: `/lint` — KISS/DRY/SRP repo audit slash command

## Summary

A maintainer-only slash command at `.claude/commands/lint.md` that audits the marketplace repo against the three principles in `CONTRIBUTING.md:7-9` (KISS · DRY · SRP), using the seven anti-patterns at `CONTRIBUTING.md:138-146` as supporting evidence. Codifies the methodology that surfaced 9 findings manually in PR #17. Two modes: `full-scan` (every instruction-bearing `.md`) and `changes-only` (diff vs `main`). Output: severity-grouped Markdown report. Read-only — no edits, no commits, no version bumps.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | Lives at `.claude/commands/lint.md` at repo root (maintainer-only; NOT a marketplace plugin surface). | Must |
| F2 | Supports two modes: `full-scan` (default — every `.md` under `core/`, `lsa/`, `helper/`, `.lsa/`, root) and `changes-only` (diff vs `main`). Selected via `--mode=` flag. | Must |
| F3 | Output is a Markdown report grouped by severity (High / Medium / Low) with `file:line` + verbatim quote + 1-sentence principle/anti-pattern citation per finding. | Must |
| F4 | Checks KISS · DRY · SRP per `CONTRIBUTING.md:7-9`; uses the 7 anti-patterns at `CONTRIBUTING.md:138-146` as supporting evidence. Anti-patterns that don't map to KISS/DRY/SRP (e.g., *"version without CHANGELOG entry"*) are out of scope. | Must |
| F5 | Renders findings sorted by severity desc (High → Medium → Low), then by `file:line` ascending — most-impactful first. No cap on count (per User Verification 2 decision 2026-05-22). | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Read-only — no edits, no commits, no version bumps. Findings only. |
| NF2 | Concise per finding — each finding is ≤3 lines (`file:line` header + ≤1-line verbatim quote + ≤1-line principle citation). Total length scales with finding count; no preamble, no recap, no padding. Per `core/output` Rule 2 (Minimal). |

## Inputs & Outputs

- **Input:** optional `--mode=full-scan|changes-only` flag (default `full-scan`).
- **Output:** stdout Markdown report — severity-grouped with `file:line` + verbatim quote + principle citation per finding; or a single `✅ clean` verdict line if no violations.
- **Side effects:** none. Reads files from disk; does not write.

## Constraints

- **Read-only.** No `Edit`, `Write`, or side-effect `Bash` allowed. Findings only.
- **Subject-voice picker prompts** per `core/output` Rule 5 — any follow-up `AskUserQuestion` (e.g., *"Show the 7 skipped findings?"*) uses plain-English question text, never picker IDs or jargon.
- **Cite the violation by `file:line`; cite canonical references by `file:section`** per `lsa/knowledge/conventions.md` § Read protocol. Line numbers drift; section names survive.
- **No silent scope expansion.** Same-family violations caught mid-run surface under "Honesty flags", never silently extending the finding list (per `CONTRIBUTING.md:145` anti-pattern *"Expand scope silently"*).
- **LLM-driven, not regex.** The rules are qualitative (KISS = "short, scannable"; SRP = "one purpose per file") — no regex implementation.

## Out of Scope

- Applying fixes, version bumps, CHANGELOG entries, PR creation. Lint surfaces; human decides.
- Stale-name detection (e.g., `tier-selector` → `flow-selector` drift) — that's a Factual-grounding concern.
- Banned-hedge-word lint — deferred to the Self-eval harness row in `.lsa/roadmap.md`.
- The *"version without CHANGELOG entry"* anti-pattern check — procedural, separate from KISS/DRY/SRP.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per .lsa/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per .lsa/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->
- [ ] **AC1.** When the user invokes `/lint` with no args, the system shall produce a severity-grouped report of all KISS/DRY/SRP findings across the scoped files.
- [ ] **AC2.** When the user invokes `/lint --mode=changes-only`, the system shall scope the audit to files changed vs `main` and produce the same report shape.
- [ ] **AC4.** When the audit finds no violations, the system shall return a single `✅ clean` verdict line.
- [ ] **AC5.** When a finding is rendered, the system shall include `file:line` + a verbatim quote of the offending text + a 1-sentence citation of the principle violated (KISS / DRY / SRP) plus the supporting anti-pattern when applicable.
- [ ] **AC6.** When the auditor identifies a same-family violation that wasn't in the initial seed pattern, the system shall surface it under an "Honesty flags — audit gaps caught mid-run" section rather than silently extending the finding list.
