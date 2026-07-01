# Core

Five domain-neutral discipline skills that make output trustworthy and any actor (skill / slash command / workflow) follow a single, observable shape. For the "why" behind this package, see [`../.lsa/VISION.md`](../.lsa/VISION.md).

## What's here

- **`ground-rules`** — Apply on every substantive task. Enforces 8 content rules — see [`core/CLAUDE.md`](./CLAUDE.md) for the canonical list. **Since v0.14.0,** Rule 7 *Done is a gate-proven, cited predicate* — an agent may report a completion state (`tests green`, `migration applied`, `merged @ <sha>`, `deployed`) only when a deterministic, agent-inaccessible gate proved it and the report cites the gate artifact; anything unproven is reported `attempted`/`unknown` with evidence attached. The structural answer to the S7 "Inaccurate Self-Reporting" failure mode; the safety-core ground rule the parallel-agent-delivery pitch rests on.
- **`output`** — Apply to every human-facing output. **One hard rule + six pieces of guidance** — see [`core/CLAUDE.md`](./CLAUDE.md). The hard rule is *Sourced* (Rule 4): fact-grounding plus its file-load trace and citation format, non-negotiable on every output. The other six (structured, minimal, formatted, concrete, what-and-why preamble, show-changes-inline) are guidance — outcomes to aim for when they serve the answer, not a checklist every response must satisfy; a one-sentence factual reply needs a source, not a template. Each component picks its own format; some skills cite a specific guidance rule as load-bearing for their own output. The seven rules are split into this hard-vs-guidance posture (only Rule 4 / Sourced stays hard); the rule numbering is preserved so existing cites resolve unchanged, and the show-changes-inline discipline (Rule 7) is held at the skill level independently of `core/output`'s posture. **Since v0.13.0,** Rule 7 carries the **gate-delivery contract**: an *Authorization boundary* (write → show → comment applies to already-authorized changes; approval-gated artifacts invert to **show → approve → write** — nothing lands on disk before its gate, nothing on reject) and a *Delivery test* (content counts as "shown" only via a turn-final text message or inside an `AskUserQuestion` gate — subagent transcripts and same-turn pre-tool-call text do not count); Rule 5 gains the matching *Self-contained gates* bullet (a picker only asks about content already delivered or carried by the picker itself). **Since v0.8.0,** Rule 7 *Show changes inline — write, show, comment* requires every write/edit/mark performed by an agent to be echoed back inline (single-change block or compressed inspection table) before commentary; generalizes the 8-element drift block from `lsa-reconcile`. New operational checkpoint #4 in `core/CLAUDE.md`. Rule 7 carries a *How this gets enforced* sub-section naming the per-skill cites plus the author-time regression check `prompt-engineer:prompt-review` (warning-only, scans prompt sources); a previously-documented PR-time check in `lsa:verify` was removed in v0.13.0 as never implemented. **Since v0.7.0,** Rule 6 *What-and-why preamble — verdicts carry a one-sentence frame* requires every verdict label drawn from [`core/knowledge/output-vocabulary.md`](./knowledge/output-vocabulary.md) §"Verdicts" to be preceded by a one-sentence preamble naming (a) the action in the user's frame and (b) the concrete consequence if the human does not act. **Since v0.5.5,** declared the **single marketplace-wide source-of-truth** for output discipline — other plugins cite this file by markdown link, never restate the count or rule names (re-grounded summaries permitted only when they cite canonical at the top, per `helper/knowledge/output-discipline.md` precedent). Enforced by `core/tests/repo-anchored.md` D2. **Since v0.5.4,** *sourced* requires a one-line trace directive at the top of every marketplace instructional file; on load the agent prints `=============== [<file>] [<plugin>] ===============` verbatim, one line per loaded file, in load order, before the response body. Replaces the v0.5.3 single-line `[plugin:skill]` marker.
- **`actor-template`** — Apply when authoring or editing a Skill, slash command, or workflow. Enforces the Goal / Input / Steps / Output / Constraints shape and demands every Step produce an observable result.
- **`flow-selector`** — Apply before any non-trivial task. Classifies the work as Quick / Standard / Extended by chain-of-thought reasoning over Vision §4 boundary signals, then waits for human confirmation before any LSA ceremony fires. Renamed from `tier-selector` (T1 / T2 / T3) in `core` v0.5.2.
- **`reuse-first`** — Apply on any coding task before writing code. Walks a 7-rung reuse ladder — understand the real flow → YAGNI → existing in-codebase helper (grep first) → stdlib/builtin → native platform feature → already-installed dependency → shortest working diff — and stops at the first rung that holds, so the change reuses over rewrites and adds only the minimum. Carries the root-cause-not-symptom bug rule (fix once in the shared path, not per-symptom). Silent on prose/analysis tasks that author no code. **New in v0.15.0.**

## Knowledge

- **[`knowledge/output-vocabulary.md`](./knowledge/output-vocabulary.md)** — The canonical marketplace verdict labels (PROPOSED, DRIFT, APPLIED, PASS, FAIL, etc.) cited by `core/output`.
- **[`knowledge/fast-path-source-of-truth.md`](./knowledge/fast-path-source-of-truth.md)** — The shared single-source-of-truth navigation fast-path contract: a navigation-class question ("what's next", "how do I get started") maps to one source-of-truth file at a known path → direct `Read` + cited `file:line` quote-back, no sub-agent / `context7` / multi-round `Grep`. Exact-phrase detection (not semantic similarity); any failure falls through to the deep-research path unchanged. Cited by `manager:next`, the `project-manager` agent, and Helper's onboarding catalog.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/reload-plugins
```

Invoke directly via `/core:ground-rules`, `/core:output`, `/core:actor-template`, `/core:flow-selector` (renamed from `/core:tier-selector` in `core` v0.5.2), or `/core:reuse-first`, or let Claude trigger them automatically by description match. Run `/reload-plugins` after editing skill files to pick up changes without restart.

### Merge the CLAUDE.md fragment

Copy the content of [`core/CLAUDE.md`](./CLAUDE.md) into your project's `/CLAUDE.md` (or whichever path your `.lsa.yaml` configures as the constitution). The fragment declares four always-on rules: `ground-rules` application, `output` discipline, `flow-selector` invocation before non-trivial tasks, and `reuse-first` on coding tasks.

## Install on Claude.ai

Each skill uploads separately (Claude.ai's native model). From the repo root:

```bash
cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/
```

Then in Claude.ai → **Settings → Features → Custom Skills**, upload `ground-rules.zip` and `actor-template.zip` separately.

Per Anthropic docs (`platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`): *"Custom Skills do not sync across surfaces. Skills uploaded to one surface are not automatically available on others."* The upload is one-time, per user; there is no organization-wide distribution path on Claude.ai today.
