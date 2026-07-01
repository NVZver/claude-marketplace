> **Trace.** On load, print first: `=============== [.lsa/standards/code.md] [vision] ===============`

# Code Standards — claude-marketplace

What follows are the standards every artifact in this repo follows. Distilled from `/CLAUDE.md` "Discipline" and `.lsa/VISION.md` §1 *"Distribution + versioning"* and `.lsa/archive/2026-05-20-core-v1/design.md` §3 *"Plugin layout"*.

## Markdown-only

This repo ships **markdown skills + plugin manifests + hook scripts** — no `/src/`, no language compiler, no test runner. Concretely:

- Skills are `SKILL.md` files with YAML frontmatter (`name`, `description`).
- Plugin manifests are `.claude-plugin/plugin.json` (small JSON object: `name`, `description`, `version`, `author`).
- Hooks (introduced by `lsa` v0.2.0) are declared in `lsa/hooks/hooks.json` (single-file plugin convention per `code.claude.com/docs/en/hooks`) and invoke a sibling shell script via `${CLAUDE_PLUGIN_ROOT}`.
- The marketplace catalog is `.claude-plugin/marketplace.json`.

Because there's no `/src/`, LSA runs in **doc-mode** here (`mode: docs` in `/.lsa.yaml`) — verification diffs `artifact_paths` rather than `/src/`. See `lsa/ARCHITECTURE.md` §4.10 and §5 (Phase 5 — Verify).

## Per-plugin SemVer + CHANGELOG

- Every plugin maintains its own `<plugin>/CHANGELOG.md` (Keep a Changelog format).
- Every plugin's authoritative version lives in `<plugin>/.claude-plugin/plugin.json`'s `version` field.
- **Bump the version in the same commit as the changelog entry.** No exceptions. Source: `/CLAUDE.md` "Discipline".

Two plugins evolve independently. There is no repo-level VERSION file — the marketplace ships whatever is currently on `main`.

## Plugin layout

Each plugin lives at the repo root in its own directory:

```
<plugin>/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── CHANGELOG.md
└── skills/
    └── <skill-name>/
        └── SKILL.md
```

Additional top-level directories (`hooks/`, `commands/`, `tests/`, `ARCHITECTURE.md`, `VERIFICATION.md`) are added as needed. Source: `.lsa/archive/2026-05-20-core-v1/design.md` §3.

## `${CLAUDE_PLUGIN_ROOT}` convention

Hook scripts (and any other plugin-internal command paths) reference their plugin directory via `${CLAUDE_PLUGIN_ROOT}` — never a hardcoded absolute path. Example: `lsa/hooks/hooks.json` invokes `${CLAUDE_PLUGIN_ROOT}/hooks/session-start-drift-check.sh`. Source: `code.claude.com/docs/en/hooks`.

## Model policy — Pro-safe by default, Opus-opportunistic

The marketplace must run 100% on the **Claude Pro** plan (Sonnet 5, no Opus) and exploit **Opus** when the session has it (Max). Three rules make that automatic:

1. **Default to `inherit` — omit `model:` in shipped frontmatter.** An omitted `model:` field resolves to `inherit` (the main session's model), so Pro sessions run every agent/skill on Sonnet 5 and Max sessions run them on Opus 4.8 — no per-artifact decision needed. Source: `code.claude.com/docs/en/sub-agents` §"Choose a model" (*"Omitted: defaults to inherit"*); `code.claude.com/docs/en/model-config` (Pro defaults to Sonnet 5, Max to Opus 4.8).
2. **Never hardcode `opus`, `haiku`, or `fable`.** A hardcoded model a plan lacks is a **hard error, not a fallback** — `model: opus` on a Pro session fails with *"Claude Opus is not available with the Claude Pro plan"* and blocks the agent until the user runs `/model`. Source: `code.claude.com/docs/en/errors`. The same risk applies to any tier that lacks the pinned model.
3. **`sonnet` is the only safe explicit value** — present on every relevant plan (Pro/Team/Enterprise default it; Max includes it). Pin `model: sonnet` **only** on purely-mechanical sub-agents (file-reading discovery, grounding checks, prompt scans, cited lookups) so a Max session spends Opus on reasoning, not grunt work; Pro is unaffected (already Sonnet). Do not pin `sonnet` on stages whose quality lifts materially on Opus (adversarial grading, deep decomposition) — let those `inherit`.

Net effect: "works natively on Sonnet, excels on Opus" is a property of the default (`inherit`), and no shipped artifact ever forces a model a plan lacks.

## Dispatch efficiency — inline unless isolation is load-bearing

A sub-agent dispatch starts a **fresh context** that reloads the `CLAUDE.md` hierarchy + memory and re-reads files it needs (it inherits none of the parent's reads or history). That cost multiplies across a multi-stage flow and is the dominant token drain for Pro users under usage caps. So an orchestrating actor **runs a stage inline in its own context** — carrying facts forward and reusing them — **unless a fresh or independent context is load-bearing.** Isolation is load-bearing only for:

1. **The external implementer** — LSA writes no production code; the coding agent is outside the boundary (`lsa:delegate`).
2. **An independent grader** — must have no write access to what it grades, so it cannot run in the context that authored the tests/spec (`lsa:reconcile`, *Independence must be observable*).
3. **Parallel work that would collide in one tree** — worktree-isolated fan-out (`manager:implement`).

Everything else — spec authoring, shaping, decomposition, recommendation, review, cited lookup — runs inline. Applied: `lsa:orchestrator` runs `discover → specify → verify` inline (lsa v0.21.0). Per-plugin application to the remaining dispatchers (`manager` shape/decompose/next/check; `helper` lookups) is tracked on the roadmap. Source: 2026-07-01 token/model assessment; grounds `lsa/agents/orchestrator.md`.

## Artifact hand-off — pointer + summary, not full payload

When an agent produces a sizeable artifact for another agent (a spec, a conformance report, a generated schema, a research dump), it **writes the artifact to a file and returns a pointer + a decision-relevant summary + any pending gates** — it does not round-trip the full payload back through context. The pointer is the file path; the summary is the few sentences the dispatcher needs to route the next step; the pending gates are the human decisions still owed. This is the inter-agent generalization of [`core/output`](../../core/skills/output/SKILL.md) Rule 2 *"Pull, don't push"* — that rule surfaces to a human only what they must act on next; this standard applies the same discipline to data crossing an agent boundary.

Concretely:

- **Intermediate-only data stays in the file.** Data that no human ever reads — scratch computations, full source excerpts, the un-summarized artifact body — lives in the file and never enters the dispatcher's context. Context carries the pointer and the summary, nothing more.
- **Fact-grounding citations are preserved in the file, never summarized away.** The artifact keeps its full source + verbatim quote per [`core/ground-rules`](../../core/skills/ground-rules/SKILL.md) Rule 1. The summary may cite fewer of them, but the file remains the complete, grounded record — a summary must never be the only surviving copy of a citation.
- **Human-facing content is the carve-out.** Anything the human must read or decide on is *not* left behind a pointer. Per [`core/output`](../../core/skills/output/SKILL.md) Rule 7 *Delivery test*, content counts as shown only through a channel the harness renders — a turn-final message or an `AskUserQuestion` gate; a file path or a subagent transcript does **not** count. So the dispatcher **reads the file and re-renders the human-facing content itself** before any gate. Never gate a human decision behind *"go read the file"*. This carve-out never relaxes; the file-pointer optimization applies to inter-agent data, not to the human channel.

The live precedent this generalizes is [`lsa/skills/reconcile/SKILL.md`](../../lsa/skills/reconcile/SKILL.md): reconcile writes its full requirement-by-requirement mapping to `conformance.md` and returns a compact verdict line (`reconcile: PASS|FAIL @ <graded-sha>`) — the pointer + summary shape already in production. This standard promotes that pattern from one skill to a repo-wide default.

This section is the complement of **Dispatch efficiency**: that section governs *when* to spawn a fresh context; this one governs *how* data crosses the boundary once a context is spawned. Per-agent rewiring to this standard (e.g. the `manager` shaping/roadmap agents that today return full content through context) is deliberate follow-on, not part of this standard's authoring.

Source: [`core/skills/output/SKILL.md:42`](../../core/skills/output/SKILL.md) Rule 2 *"Pull, don't push"* + [`core/skills/output/SKILL.md:79-86`](../../core/skills/output/SKILL.md) Rule 7 *Delivery test*; precedent [`lsa/skills/reconcile/SKILL.md:37-39`](../../lsa/skills/reconcile/SKILL.md) (`conformance.md` + verdict line).

## Constitution = `.lsa/VISION.md`

The configured constitution for this repo (per `/.lsa.yaml: constitution`) is `.lsa/VISION.md`, not `/CLAUDE.md`. `/CLAUDE.md` is the slimmed Claude Code entry point — it points at the constitution but is not the constitution.
