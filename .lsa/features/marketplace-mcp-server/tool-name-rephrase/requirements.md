Parent: [Marketplace-as-MCP-server](../../../pitches/marketplace-mcp-server.md)
Epic: marketplace-mcp-server/tool-name-rephrase
Date: 2026-08-25
Status: draft

# Tool-name rephrase — client-neutral instruction prose

Reword every unconditioned literal Claude-Code-tool-name mention in the
first-slice (`core`, `lsa`, `manager`) skill and agent instruction prose into
a generic action description, keeping the tool name only as a parenthetical
citation — matching the pattern `VISION.md` §2 principle 9 ("Substrate-native
first") already establishes ("In Claude Code: `AskUserQuestion` for
decisions, `Read`/`Edit`/`Write` for files..."). Frontmatter `tools:`
declarations are untouched — still required for Claude Code's native plugin
path. This is prose surgery: meaning must be exactly preserved.

Rewrite policy confirmed this session: **"Generic action + Claude Code
citation"** (not "fully tool-name-free prose"). Rationale: a fully
tool-name-free rewrite would also force rewording the 3 lines that already
follow `VISION.md`'s own established idiom, which would contradict the
constitution rather than comply with it. The chosen policy satisfies the
epic's actual intent (a non-Claude-Code client's own model understands the
generic action) while staying consistent with the repo's existing citation
pattern.

**Amendment (post-implementation, pre-reconcile):** the implementer's
verification pass found a 26th unconditioned mention that the original
25-entry table omitted — `manager/skills/check/SKILL.md:23`'s "a model-side
`Read` of `${specs_root}/roadmap.yaml`" was present in the discover-time
grep dump but dropped when the table was hand-assembled. It follows the
identical "model-side Read" pattern already reworded at entries 12, 18, 20.
Added below as entry 26, same policy, same reviewer (the orchestrator).

## User flows

### Flow 1 — Reword unconditioned tool-name prose across the first-slice tree

- **Flow:** The implementer applies an exact before/after rewrite to 25
  flagged lines across 11 files (see Rewrite table below).
- **Success:** Each line matches its specified after-text exactly; no other
  line in any of the 11 files changes.
- **I/O:** Input = the 11 files at current content; Output = same files with
  only the 25 specified lines changed.
- **Test:** Diff each file; only the 25 specified lines changed, each
  matching its after-text.

### Flow 2 — Verification finds zero unconditioned tool-name matches

- **Flow:** A grep-based check scans first-slice body prose (excluding
  frontmatter `tools:` lines).
- **Success:** Zero unconditioned literal Claude-Code-tool-name matches
  remain; the 3 already-compliant citation lines are correctly recognized as
  compliant, not flagged.
- **I/O:** Input = the reworded tree; Output = check pass/fail.
- **Test:** Check script exits 0.

### Flow 3 — Existing structural invariants unregressed

- **Flow:** `bash scripts/gate.sh` runs after the rewrite.
- **Success:** Gate stays green — trace directives (C4), `tools:`
  frontmatter (C5), description/body-length invariants (C7/C9), links,
  citations all still hold.
- **I/O:** Input = the reworded tree; Output = gate PASS.
- **Test:** `bash scripts/gate.sh` exits 0.

## Requirements (EARS)

1. **The system shall** reword each of the 25 identified lines to its exact
   specified after-text (Rewrite table below).
2. **The system shall not** alter frontmatter `tools:` declarations, code
   fences, links, or any line beyond the 25 specified.
3. **The system shall not** alter the 3 already-compliant citation lines
   (`core/skills/flow-selector/SKILL.md:46`;
   `core/skills/ground-rules/SKILL.md:24,71`).
4. **While** verifying, **when** the grep-based check scans body prose
   (frontmatter `tools:` excluded), **the system shall** report zero
   unconditioned literal Claude-Code-tool-name matches, and **shall not**
   flag the `(<ToolName> in Claude Code)` citation pattern.
5. **While** verifying, **the system shall** confirm `bash scripts/gate.sh`
   still exits 0 after the rewrite.

## Rewrite table (25 entries — exact before/after)

| # | Location | After-text (replaces the flagged sentence/clause; all other text on the line and every other line in the file stays byte-identical) |
|---|---|---|
| 1 | `core/skills/output/SKILL.md:80` | `- **inside an interactive confirmation gate** (question text, option descriptions, or option \`preview\` — \`AskUserQuestion\` in Claude Code).` |
| 2 | `lsa/agents/orchestrator.md:25` | "...invoke each stage's skill directly (`Skill` in Claude Code), write its artifact..." |
| 3 | `lsa/agents/orchestrator.md:30` | "...Hand the grounded spec + `.feature` files to the external implementer by dispatching it as a sub-agent (`Agent` in Claude Code, or the developer's own tool)..." |
| 4 | `lsa/agents/orchestrator.md:31` | "...Grade the diff by dispatching it as a sub-agent (`Agent` in Claude Code) in a context that is..." |
| 5 | `lsa/agents/orchestrator.md:43` | "...When this agent runs as a subagent, an interactive confirmation gate (`AskUserQuestion` in Claude Code) is unavailable..." |
| 6 | `lsa/skills/delegate/SKILL.md:42` | "- **Agent-dispatched implementer** (delegate dispatches it as a sub-agent — `Agent` in Claude Code): inject..." |
| 7 | `lsa/skills/delegate/SKILL.md:48` | "- **Non-agent implementer** (human / Cursor / Copilot — not dispatched as a sub-agent) (G10):..." |
| 8 | `lsa/skills/delegate/SKILL.md:51` | "...(as a sub-agent — `Agent` in Claude Code) to grade that one signalled increment... pass it as the sub-agent dispatch's `model` parameter (absent ⇒ `inherit`)..." |
| 9 | `lsa/skills/verify/SKILL.md:26` | "...as the reference map — instead of multiple manual searches. Resolving each symbol..." |
| 10 | `manager/agents/product-manager.md:53` | "- **Gates belong to the dispatcher.** An interactive confirmation gate (`AskUserQuestion` in Claude Code) is unavailable in subagent context;..." |
| 11 | `manager/agents/project-manager.md:19` | "...(a non-zero script exit is the only fallback to a full file read)." |
| 12 | `manager/agents/project-manager.md:32` | "...Only if a query script exits non-zero fall through to a model-side read of the ledger...." |
| 13 | `manager/agents/project-manager.md:66` | "...Do not invoke `lsa:discover`; the dispatching skill invokes it directly with this seed (`Skill` in Claude Code)...." |
| 14 | `manager/agents/project-manager.md:105` | "- **Gates belong to the dispatcher.** An interactive confirmation gate and direct skill invocation (`AskUserQuestion` and `Skill` in Claude Code) are unavailable in subagent context;..." |
| 15 | `manager/skills/check/SKILL.md:23` | "...each quoted with `file:line` — via an interactive confirmation gate (`AskUserQuestion` in Claude Code) (approve / reject)...." |
| 16 | `manager/skills/decompose/SKILL.md:20` | "...This skill delivers the list and presents the gate via an interactive confirmation gate (`AskUserQuestion` in Claude Code); on reject/adjust..." |
| 17 | `manager/skills/decompose/SKILL.md:22` | "...On epic approval, invoke `lsa:discover` directly (`Skill` in Claude Code) with the agent's staged seed text verbatim..." |
| 18 | `manager/skills/implement/SKILL.md:26` | "...fall through to a model-side read of the ledger...." |
| 19 | `manager/skills/implement/SKILL.md:30` | "...the plan rides in the message or interactive confirmation gate (`AskUserQuestion` in Claude Code) the user sees, never only in a sub-agent payload..." |
| 20 | `manager/skills/next/SKILL.md:20` | "...do you fall through to a model-side read of `${specs_root}/roadmap.yaml`...." |
| 21 | `manager/skills/next/SKILL.md:22` | "...this skill presents it via an interactive confirmation gate (`AskUserQuestion` in Claude Code). No `lsa:discover` handoff..." |
| 22 | `manager/skills/shape/SKILL.md:7` | "...runs the agent's returned human gates via an interactive confirmation gate (`AskUserQuestion` in Claude Code), then hands off..." |
| 23 | `manager/skills/shape/SKILL.md:22` | "...Invoke the `product-manager` agent by dispatching it as a sub-agent (`Agent` in Claude Code) with the problem description...." |
| 24 | `manager/skills/shape/SKILL.md:24` | "...Then present each pending gate via an interactive confirmation gate (`AskUserQuestion` in Claude Code) (Rule 5 *Self-contained gates*)..." |
| 25a | `manager/skills/shape/SKILL.md:25` | "- **Approve:** write the pitch to `${specs_root}/pitches/<slug>.md` with `Status: approved`..." |
| 25b | `manager/skills/shape/SKILL.md:26` | "- **Reshape:** re-dispatch the agent with the user's feedback (a continuation message — `SendMessage` in Claude Code — or a new dispatch if the agent has exited)..." |
| 25c | `manager/skills/shape/SKILL.md:31` | "...On approve, invoke `manager:decompose` directly (`Skill` in Claude Code) with the approved pitch slug...." |
| 25d | `manager/skills/shape/SKILL.md:57` | "- **No silent handoff.** The human gates live in THIS skill (the agent cannot ask — an interactive confirmation gate, `AskUserQuestion` in Claude Code, is unavailable in subagent context): every pending gate the agent returns is presented via an interactive confirmation gate before any downstream step." |
| 26 | `manager/skills/check/SKILL.md:23` | "...Only if it exits non-zero fall through to a model-side read of `${specs_root}/roadmap.yaml`. Observable result:..." |

## Facts this spec is grounded on (from discover)

- 25 lines across 11 files carry an unconditioned literal tool-name mention
  (backtick-wrapped `Read`/`Write`/`Edit`/`Grep`/`Agent`/`Skill`/
  `AskUserQuestion`/`SendMessage`) with no "in Claude Code" framing — full
  list above (Rewrite table).
- 3 lines already use the compliant "In Claude Code: X" citation pattern
  and are explicitly OUT of scope for this epic:
  `core/skills/flow-selector/SKILL.md:46` ("`AskUserQuestion` in Claude
  Code"), `core/skills/ground-rules/SKILL.md:24` ("In Claude Code, the
  substrate-native primitive for this is `AskUserQuestion`"),
  `core/skills/ground-rules/SKILL.md:71` ("In Claude Code, prefer the
  substrate's native file primitives (`Read` / `Edit` / `Write`)").
- Existing repo-internal gate (`bash scripts/lint.sh`, wired as `.lsa.yaml`
  `gate: docs-invariants`) already enforces C4 (trace directive present in
  every `SKILL.md`/`agents/*.md`), C5 (every `agents/*.md` declares
  `tools:` in frontmatter), C7 (description length + name-matches-directory),
  C9 (body ≤500 lines) — these run unchanged after this epic's edits and are
  regression protection against accidentally breaking file structure while
  rewording prose.
- `VISION.md` §2 principle 9 ("Substrate-native first"): "In Claude Code:
  `AskUserQuestion` for decisions, `Read`/`Edit`/`Write` for files,
  `TaskCreate`/`TaskUpdate` for task tracking, `Skill` for skill invocation"
  — the citation-pattern precedent this epic's rewrite policy follows.
