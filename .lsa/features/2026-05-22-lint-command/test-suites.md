# Test Suites: `/lint` command

## Journey 1: Audit the whole repo for KISS/DRY/SRP violations

**Goal:** The maintainer wants to see every principle violation across the marketplace repo before a release, PR, or as a periodic discipline pass.
**Covers:** AC1, AC4, AC5, AC6

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | maintainer invokes `/lint` (no args) → command reads CONTRIBUTING.md + enumerates scope (`core/`, `lsa/`, `helper/`, `.lsa/`, root `*.md`) → produces severity-grouped Markdown report (sorted High → Medium → Low, then `file:line` asc) → maintainer triages findings. Report length scales with finding count; no cap. |
| 2 | Boundary — clean repo | maintainer invokes `/lint` → no violations found → command returns single `✅ clean` verdict line |
| 3 | Honesty — audit gap caught mid-run | during execution, the LLM auditor identifies a violation that's the same family as a confirmed finding but outside its initial seed pattern (e.g., the M2 helper.md:48-49 case in PR #17) → command renders the finding under "Honesty flags — audit gaps caught mid-run", labelled separately from the seed-pattern findings |

**Expected outcome:** Maintainer reads a severity-grouped report with every finding citing `file:line` + a verbatim quote + the principle violated. Clean repo returns one line. Honesty flags are visible as a separate section, not silently folded into the main list.

## Journey 2: Lint a pre-commit / pre-PR diff

**Goal:** The maintainer wants to catch new principle violations introduced by the current branch before pushing — without re-reading the entire repo.
**Covers:** AC2, AC4, AC5, AC6

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | maintainer (on a feature branch) invokes `/lint --mode=changes-only` → command runs `git diff --name-only main` → enumerates the changed instruction-bearing `.md` files → audits only those → produces the same report shape as Journey 1, scoped to the diff |
| 2 | Boundary — diff has no instruction files | maintainer invokes `/lint --mode=changes-only` on a branch that only modified CHANGELOG / JSON / shell scripts → command returns `✅ no instruction-bearing changes in diff — nothing to audit` |
| 3 | Boundary — clean diff | diff includes instruction files but they have no violations → command returns `✅ clean (changes-only mode, N files audited)` |

**Expected outcome:** Maintainer sees a report scoped to recent work. Same finding shape as Journey 1. The mode flag is the only difference in user-visible behavior. Empty/clean cases return one-line verdicts, not empty reports.
