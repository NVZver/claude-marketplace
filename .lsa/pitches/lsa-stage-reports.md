Shaped by: Nikita Zverev (via manager:product-manager, developer-tooling lens)
Date: 2026-06-12
Status: draft
Why now: first external adopters are running LSA without the author's context (field reports 2026-06-11) — opaque stage transitions now cost real users, not just the owner.

# Per-stage LSA reports — what changed, outcome, next step

After every LSA stage, the human and the agent see one uniform, compact report: exact files changed (grouped by logical unit), the stage outcome, and the next step.

## Problem

The repo owner (primary LSA user) and the lsa:orchestrator agent itself cannot quickly see, during or after an LSA run, what a stage actually did. Evidence: each skill's `## Output` is a different shape — `discover` returns "Intent + cited codebase facts" (`lsa/skills/discover/SKILL.md:35`), `specify` returns file paths (`lsa/skills/specify/SKILL.md:35`), `verify` returns "**GROUNDED** or **NOT-GROUNDED** with `grounding.md`" (`lsa/skills/verify/SKILL.md:35`), `delegate` returns "The implementer's diff" (`lsa/skills/delegate/SKILL.md:36`), `reconcile` returns "`conformance.md` … + **PASS**, or a drift report" (`lsa/skills/reconcile/SKILL.md:38`). The orchestrator just "collect[s] its `## Output`" (`lsa/agents/orchestrator.md:34`) — no shared contract for files-touched, outcome, or next step. A stage-*entry* convention exists ("print a one-line read-summary per source", `lsa/knowledge/conventions.md:30`); there is no stage-*exit* counterpart.

Current workaround: scroll the transcript, run `git status`/`git diff`, and re-read the artifacts each stage produced to reconstruct what happened.

Definition of success: at the end of every LSA stage, a report of a fixed shape appears inline — exact file paths with change type, changes grouped by logical unit, the stage outcome, and the next step — readable in under 15 lines by both the human and the next agent in the loop.

## Appetite

Small batch. One new LSA knowledge file (the report contract) plus a one-line citation directive in each LSA skill and the orchestrator. No new agents, no hooks, no `.lsa.yaml` schema change, no persisted per-run files. Out of appetite: any run-history store, dashboards, or machine-readable (JSON) telemetry.

## Solution sketch

- **Key user interactions:** the user runs the LSA loop as today; after each stage a uniform stage-exit report appears inline — `Stage · Outcome · Files changed (table, grouped by logical unit) · Next step`. On `reconcile` PASS, the orchestrator emits a final roll-up of all stage reports for the run. Read-only stages (e.g. `discover`, `verify`) report "no files changed" plus the artifacts they produced.
- **Main components:** new `lsa/knowledge/stage-report.md` defining the report shape — reusing the `core/output` Rule 7 compressed inspection table (`| # | file:line | type | summary |`, `core/skills/output/SKILL.md:88-95`) for the files section; one citation line added to each of the 7 skills under `lsa/skills/` and to `lsa/agents/orchestrator.md` Step 5; per-plugin CHANGELOG + SemVer bump.
- **Critical path:** stage completes → skill emits stage-exit report per the knowledge contract → orchestrator carries it forward and names the next stage → at reconcile PASS the roll-up shows every stage's files + outcomes in one screen.

## Rabbit holes

1. Inventing a second change-table format competing with `core/output` Rule 7 — mitigation: the knowledge file mandates Rule 7's compressed inspection table verbatim as the files section; no new table schema.
2. Transcript bloat — five stages × a verbose report breaks the 1–1.5-screen budget (`core/skills/output/SKILL.md:40`) — mitigation: hard cap ~15 lines per report; grouping by logical unit is the compression mechanism, not extra prose.
3. "Logical unit" is subjective — mitigation: the knowledge file fixes the grouping precedence: module (per `.lsa.yaml` `artifact_paths`) → requirement ID (F1…) → directory.
4. Re-bloating skills that just passed a minimality review (commit `5df6391`) — mitigation: content lives only in the knowledge file; each skill carries a single citation line, matching the existing "cite, never restate" convention (`lsa/knowledge/conventions.md:57`).

## No-gos

1. This pitch does NOT cover a persisted per-run log file (e.g. `${specs_root}/features/<name>/run-log.md`) — inline transcript reports only; cross-session recall is a separate pitch if field use proves the need.
2. This pitch does NOT change loop order, gates, or any skill's behavior — it is a reporting surface only.
3. This pitch does NOT cover machine-readable output (JSON), dashboards, or hooks-based automation — markdown in the transcript, per docs-mode discipline.
