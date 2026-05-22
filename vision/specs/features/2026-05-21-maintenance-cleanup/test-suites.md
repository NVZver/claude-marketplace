# Test Suites: /maintenance:cleanup

## Journey: Run cleanup on a clean feature branch and apply the diff

**Goal:** Reduce ship-cost on a feature branch without breaking any invariant.
**Covers:** AC1, AC2, AC3, AC4, AC7, AC8

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | `git checkout feature/<name>` (clean) → `/maintenance:cleanup` → human sees staged diff (includes a relocation patch per AC7) + `vision/reports/cleanup-<date>.md` (with skipped-patch categories per AC3 + AC8) → human reviews → `/commit-commands:commit` |
| 2 | Pending review (state) | `/maintenance:cleanup` → staged diff appears → human steps away for an hour → returns: no files have changed, no commit has fired (AC4) → can resume review |
| 3 | All patches skipped | `/maintenance:cleanup` on a tree where every candidate patch would violate an invariant → staged diff is empty; report lists every skip with `file:line` + category from AC8's 10-item enum → human sees nothing to apply |

**Expected outcome:** Happy + pending-review paths leave a staged diff + report; human owns the commit. All-skipped path produces an empty diff but a fully-populated report so the human understands why nothing was proposed.

---

## Journey: Re-run cleanup the next day

**Goal:** Confirm cleanup has converged; capture any drift introduced since.
**Covers:** AC1, AC6, AC10

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy (next day, converged) | Yesterday's diff was applied + committed → today: `/maintenance:cleanup` → empty diff (AC6); fresh `vision/reports/cleanup-<today>.md` confirms 0 hunks proposed |
| 2 | Happy (next day, new drift) | Yesterday's diff was applied; human added new content since → today: `/maintenance:cleanup` → non-empty diff covering only the new content → report shows what changed since yesterday |
| 3 | Error (same-day re-invocation) | `/maintenance:cleanup` runs at 10am; human invokes again at 2pm same day → second invocation aborts with a clear error message (`report file vision/reports/cleanup-<date>.md already exists; rename or delete before re-running`); working tree unchanged (AC10) |

**Expected outcome:** Re-run on unchanged content shows convergence (empty diff). Re-run on drifted content shows only the delta. Same-day re-invocation refuses cleanly rather than overwriting.

---

## Journey: Verification fails mid-run

**Goal:** Confirm safety on inputs that pass classification but fail verification.
**Covers:** AC1, AC5

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Error (broken plugin.json) | `/maintenance:cleanup` proceeds through inventory + classify + stage → F5 check 4 (plugin.json parses) FAILs because a patch broke valid JSON → skill runs `git restore` on every staged file → report ends with `FAIL: plugin.json parse error at <file>:<line>` |
| 2 | Error (skill description drift) | Same as above but check 2 (skill description byte-identical) FAILs — a prose-trim patch accidentally touched a `description:` line → reset + report names the offending file + line |
| 3 | Error (broken link target) | Same flow, check 11 FAILs because a relocation patch updated the wrong path → reset + report cites both the citation and the missing target |

**Expected outcome:** Every verification-fail path produces a clean working tree (as if cleanup never ran) + a report explaining the failure with `file:line`. Human can then fix the underlying issue and re-run.

---

## Journey: Precondition refusal

**Goal:** Prevent unsafe invocation.
**Covers:** AC9

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Error (on main branch) | Human on `main` types `/maintenance:cleanup` → skill prints *"Refusing to run on `main`. Switch to a feature branch first (`git checkout -b feature/<name>`)."* → no other side effects |
| 2 | Error (dirty working tree) | Human on a feature branch with uncommitted changes → skill prints *"Refusing to run with uncommitted changes. Commit or stash first (`git status` shows N modified files)."* → no other side effects |

**Expected outcome:** Each refusal path prints the failing precondition + the concrete next action; no inventory runs, no diff stages, no report written. Working tree untouched.
