Epic: marketplace-mcp-server/tool-name-rephrase
Reconcile date: 2026-08-25
Diff state: **uncommitted** (working tree at `git rev-parse HEAD` = `4ff883466bd1a561f08a8d411e88b6b7ed894073`)

## Requirement ↔ hunk coverage

R1 = reword each of the 26 identified lines to exact after-text. R2 = no alteration to frontmatter `tools:`, code fences, links, or any line beyond the specified set. R3 = the 3 already-compliant citation lines untouched. R4 = grep-based check reports zero unconditioned matches, does not flag the citation pattern. R5 = `bash scripts/gate.sh` still exits 0 after the rewrite. (Full EARS text: `requirements.md` §Requirements.)

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | All 11 rewrite-target files (see full line-by-line audit table below) | Manual line-by-line audit, all 29 physical line-edits (24 single-row entries + 4 sub-lines of entry 25 + entry 26) read and diffed against `requirements.md`'s Rewrite table after-text — 26/26 table entries (29/29 physical lines) match exactly | ✅ |
| R2 | `git diff` on all 11 files, hunk-by-hunk | Counted changed lines per file against expected entry count per file: `core/skills/output/SKILL.md` 1, `lsa/agents/orchestrator.md` 4, `lsa/skills/delegate/SKILL.md` 3, `lsa/skills/verify/SKILL.md` 1, `manager/agents/product-manager.md` 1, `manager/agents/project-manager.md` 4, `manager/skills/check/SKILL.md` 2, `manager/skills/decompose/SKILL.md` 2, `manager/skills/implement/SKILL.md` 2, `manager/skills/next/SKILL.md` 2, `manager/skills/shape/SKILL.md` 7 — total 29, exactly matching the 29 physical rewrite-table lines. No frontmatter, code-fence, or link line touched | ✅ |
| R3 | `git status --short core/skills/flow-selector/SKILL.md core/skills/ground-rules/SKILL.md` (both absent from status); `git diff` on both (empty, exit 0) | Both files show zero uncommitted changes; lines 46 (`flow-selector`) and 24/71 (`ground-rules`) read directly and still carry the original "in Claude Code" citation text | ✅ |
| R4 | New file `scripts/check-tool-name-citations.sh` | (1) Read the script source — confirmed it strips frontmatter via an awk pass on the first two `---` lines, flags backtick-wrapped tool names from an 18-name list in body prose only, and skips any line containing the substring "Claude Code" anywhere on that line. (2) Ran the script: `Scanned 21 files. PASS — zero unconditioned tool-name matches.` exit 0. (3) Independent from-scratch grep pass (not reusing the script) over the same 21 first-slice files, using the 8-name list from `requirements.md`'s grounding facts (`Read`/`Write`/`Edit`/`Grep`/`Agent`/`Skill`/`AskUserQuestion`/`SendMessage`), same frontmatter-strip + same-line "Claude Code" exclusion logic, written independently: zero matches found — script and independent cross-check agree | ✅ |
| R5 | N/A (regression gate, not a specific hunk) | `bash scripts/gate.sh` run against the current (rewritten) tree — all 6 checks (docs-invariants, citations, links, project-map, tests, lib-pins) PASS, gate exit 0 | ✅ |

## Full line-by-line audit (26 table entries / 29 physical lines)

Current line numbers below are post-rewrite (re-located by content, since the table's captured line numbers drifted during earlier edits in the same file).

| # | File | Current line | Match |
|---|---|---|---|
| 1 | `core/skills/output/SKILL.md` | 86 | ✅ `- **inside an interactive confirmation gate** (question text, option descriptions, or option \`preview\` — \`AskUserQuestion\` in Claude Code).` |
| 2 | `lsa/agents/orchestrator.md` | 30 | ✅ "...invoke each stage's skill directly (`Skill` in Claude Code), write its artifact..." |
| 3 | `lsa/agents/orchestrator.md` | 35 | ✅ "...Hand the grounded spec + `.feature` files to the external implementer by dispatching it as a sub-agent (`Agent` in Claude Code, or the developer's own tool)..." |
| 4 | `lsa/agents/orchestrator.md` | 36 | ✅ "...Grade the diff by dispatching it as a sub-agent (`Agent` in Claude Code) in a context that is..." |
| 5 | `lsa/agents/orchestrator.md` | 48 | ✅ "...When this agent runs as a subagent, an interactive confirmation gate (`AskUserQuestion` in Claude Code) is unavailable..." |
| 6 | `lsa/skills/delegate/SKILL.md` | 47 | ✅ "- **Agent-dispatched implementer** (delegate dispatches it as a sub-agent — `Agent` in Claude Code): inject..." |
| 7 | `lsa/skills/delegate/SKILL.md` | 53 | ✅ "- **Non-agent implementer** (human / Cursor / Copilot — not dispatched as a sub-agent) (G10):..." |
| 8 | `lsa/skills/delegate/SKILL.md` | 56 | ✅ "...(as a sub-agent — `Agent` in Claude Code) to grade that one signalled increment... pass it as the sub-agent dispatch's `model` parameter (absent ⇒ `inherit`)..." |
| 9 | `lsa/skills/verify/SKILL.md` | 30 | ✅ "...as the reference map — instead of multiple manual searches. Resolving each symbol..." |
| 10 | `manager/agents/product-manager.md` | 58 | ✅ "- **Gates belong to the dispatcher.** An interactive confirmation gate (`AskUserQuestion` in Claude Code) is unavailable in subagent context;..." |
| 11 | `manager/agents/project-manager.md` | 24 | ✅ "...(a non-zero script exit is the only fallback to a full file read)." |
| 12 | `manager/agents/project-manager.md` | 37 | ✅ "...Only if a query script exits non-zero fall through to a model-side read of the ledger...." |
| 13 | `manager/agents/project-manager.md` | 71 | ✅ "...Do not invoke `lsa:discover`; the dispatching skill invokes it directly with this seed (`Skill` in Claude Code)...." |
| 14 | `manager/agents/project-manager.md` | 110 | ✅ "- **Gates belong to the dispatcher.** An interactive confirmation gate and direct skill invocation (`AskUserQuestion` and `Skill` in Claude Code) are unavailable in subagent context;..." |
| 15 | `manager/skills/check/SKILL.md` | 27 | ✅ "...each quoted with `file:line` — via an interactive confirmation gate (`AskUserQuestion` in Claude Code) (approve / reject)...." |
| 16 | `manager/skills/decompose/SKILL.md` | 24 | ✅ "...This skill delivers the list and presents the gate via an interactive confirmation gate (`AskUserQuestion` in Claude Code); on reject/adjust..." |
| 17 | `manager/skills/decompose/SKILL.md` | 26 | ✅ "...On epic approval, invoke `lsa:discover` directly (`Skill` in Claude Code) with the agent's staged seed text verbatim..." |
| 18 | `manager/skills/implement/SKILL.md` | 30 | ✅ "...fall through to a model-side read of the ledger...." |
| 19 | `manager/skills/implement/SKILL.md` | 34 | ✅ "...the plan rides in the message or interactive confirmation gate (`AskUserQuestion` in Claude Code) the user sees, never only in a sub-agent payload..." |
| 20 | `manager/skills/next/SKILL.md` | 24 | ✅ "...do you fall through to a model-side read of `${specs_root}/roadmap.yaml`...." |
| 21 | `manager/skills/next/SKILL.md` | 26 | ✅ "...this skill presents it via an interactive confirmation gate (`AskUserQuestion` in Claude Code). No `lsa:discover` handoff..." |
| 22 | `manager/skills/shape/SKILL.md` | 11 | ✅ "...runs the agent's returned human gates via an interactive confirmation gate (`AskUserQuestion` in Claude Code), then hands off..." |
| 23 | `manager/skills/shape/SKILL.md` | 26 | ✅ "...Invoke the `product-manager` agent by dispatching it as a sub-agent (`Agent` in Claude Code) with the problem description...." |
| 24 | `manager/skills/shape/SKILL.md` | 28 | ✅ "...Then present each pending gate via an interactive confirmation gate (`AskUserQuestion` in Claude Code) (Rule 5 *Self-contained gates*)..." |
| 25a | `manager/skills/shape/SKILL.md` | 29 | ✅ "- **Approve:** write the pitch to `${specs_root}/pitches/<slug>.md` with `Status: approved`..." |
| 25b | `manager/skills/shape/SKILL.md` | 30 | ✅ "- **Reshape:** re-dispatch the agent with the user's feedback (a continuation message — `SendMessage` in Claude Code — or a new dispatch if the agent has exited)..." |
| 25c | `manager/skills/shape/SKILL.md` | 35 | ✅ "...On approve, invoke `manager:decompose` directly (`Skill` in Claude Code) with the approved pitch slug...." |
| 25d | `manager/skills/shape/SKILL.md` | 61 | ✅ "- **No silent handoff.** ... an interactive confirmation gate, `AskUserQuestion` in Claude Code, is unavailable in subagent context): every pending gate the agent returns is presented via an interactive confirmation gate before any downstream step." |
| 26 | `manager/skills/check/SKILL.md` | 23 | ✅ "...Only if it exits non-zero fall through to a model-side read of `${specs_root}/roadmap.yaml`. Observable result:..." |

All 26 table entries (29 physical line-edits) confirmed byte-exact against the requirements.md after-text. No other content changed on any of these lines beyond the specified after-text.

## Orphan hunks

Coverage-skeleton (`bash scripts/coverage-skeleton.sh .lsa/features/marketplace-mcp-server/tool-name-rephrase`) enumerated candidate hunks across the full `git status` (repo-wide), which includes two unrelated concurrent in-flight uncommitted workstreams: `.lsa/.rag-index/` (many binary index files) and `scripts/opencode-dist-deploy.sh` / `scripts/opencode-dist-generate.sh`. Per this epic's own scope (task instructions, consistent with prior epics' reconcile passes — see `core-server` and `agent-prompts` rows in `.lsa/metrics.md`), these are excluded as pre-existing, unrelated items, not part of this diff.

Within this epic's actual scope — the 11 rewrite-target files + the new `scripts/check-tool-name-citations.sh` verification script — every changed/new file traces to a requirement:

- 11 rewrite-target files → R1/R2/R3 (line-by-line audit above)
- `scripts/check-tool-name-citations.sh` (new) → R4 (Flow 2's own requirement for a verification check; legitimate supporting infrastructure, not an orphan)

Orphan hunks: none.

## Gate results

`bash scripts/gate.sh` (2026-08-25, post-rewrite, uncommitted tree):

```
=== .lsa.yaml gate: block ===
  PASS  docs-invariants  bash scripts/lint.sh → exit 0
  PASS  citations        bash scripts/check-citations.sh → exit 0
  PASS  links            bash scripts/check-links.sh → exit 0
  PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests            bash scripts/run-tests.sh → exit 0
  PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0

gate: PASS — every configured check exited 0
```
Exit code: 0.

## Verdict

reconcile: PASS @ uncommitted (tree HEAD = `4ff883466bd1a561f08a8d411e88b6b7ed894073`)
