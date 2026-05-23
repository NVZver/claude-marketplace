# Design: `/lint` command

## Modules Affected

| Module | Change Type |
|--------|-------------|
| Repo root (`.claude/commands/`) | new — adds `.claude/commands/lint.md` |
| `core` | read-only |
| `lsa` | read-only |
| `helper` | read-only |
| `vision/` | read-only |

`/lint` is repo-level tooling — outside all three plugin modules per `.lsa.yaml`. It reads from every module but writes to none.

## Technical Approach

**Form: LLM-driven slash command** at `.claude/commands/lint.md`. Per Constraint *"LLM-driven, not regex"* in `requirements.md` — the principles are qualitative (KISS = "short, scannable"; SRP = "one purpose per file"; DRY = "cite, don't restate" requires understanding of canonical-vs-citation context). Regex cannot judge these; the agent reasoning over file contents can.

**File shape** (the slash-command body):
1. **Frontmatter** — `description:` that triggers on `/lint`, `audit`, `discipline check`. `argument-hint: [--mode=full-scan|changes-only]`. Tools: `Read`, `Grep`, `Glob`, `Bash` (for `git diff --name-only` in changes-only mode), `AskUserQuestion`.
2. **Goal** — one sentence per `core/actor-template`.
3. **Input** — the optional `--mode=` flag; default `full-scan`.
4. **Steps:**
   - Step 1: Read `CONTRIBUTING.md:7-9` (the three principles) + `:138-146` (the 7 anti-patterns). These are the rules.
   - Step 2: Enumerate scope. `full-scan` → `find . -name '*.md' -not -path './node_modules/*' -not -path './.git/*' | grep -v CHANGELOG | grep -v 'vision/specs/archive/' | grep -v 'vision/plans/'`. `changes-only` → `git diff --name-only main` filtered to the same patterns.
   - Step 3: For each in-scope file, check against KISS / DRY / SRP. Apply the 7 anti-patterns as supporting evidence. Severity calibration per `requirements.md` AC5 + the PR #17 playbook (High = principle broken visibly on first read; Medium = real violation in lower-traffic content; Low = nits).
   - Step 4: Compose report — severity-grouped, sorted High → Medium → Low, then `file:line` asc. Per-finding shape: `file:line` + ≤1-line verbatim quote + 1-sentence principle citation. No cap on count.
   - Step 5: If 0 findings → return `✅ clean`. Otherwise render every finding.
   - Step 6: If the auditor noticed a same-family violation outside the seed pattern → emit "Honesty flags — audit gaps caught mid-run" section.
5. **Output** — Markdown report on stdout. No file writes.
6. **Constraints** — read-only tools only, concise per finding (≤3 lines each), subject-voice picker prompts, cite-by-section for canonical refs (`lsa/knowledge/conventions.md` § Read protocol).

**Verification approach.** No automated test infrastructure exists for slash commands in this repo. The feature is verified by execution — run `/lint` on this repo, compare findings to PR #17's ground truth (9 findings, the audit-gap honesty flag, the contract-trigger inspection). Revisit when the Self-eval harness lands per `vision/specs/roadmap.md`.

## Data Model Changes

None.

## API / Interface Changes

None — contract trigger = NO at User Verification 1.

## Cross-Module Contracts

None. `/lint` is repo-level tooling that READS from each plugin but does not modify or expose anything cross-module.

## Open Questions

None. All open questions resolved at User Verification 2 (2026-05-22):

- **OQ1 → RESOLVED:** `changes-only` scopes to modified files entirely (not git-diff line ranges).
- **OQ2 → DROPPED:** the cap on findings was removed — sort question is moot.
- **OQ3 → MOVED to Technical Approach §"Verification approach"** — it was a fact statement, not a decision.
