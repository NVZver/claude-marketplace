# Repo-anchored self-tests

Dogfood probes — run the `core` plugin against the repo it ships from, where the source of truth for every expected answer is a file in this repo. Complement to `../VERIFICATION.md` (which keeps the generic probes for portability). These probes will drift as the repo changes; that is the point — they pin behavior to *current* repo state, not to a frozen prompt.

Run each probe in a fresh Claude Code session at this repo root, with `core@NVZver` installed. Record PASS/FAIL inline or in a session log.

---

## Set A — `ground-rules` probes

### A1 — Fact-grounding on a falsifiable detail (Rule 1)

**Prompt.** *"What version is the `core` plugin?"*

**Source of truth.** `core/.claude-plugin/plugin.json:4` → `  "version": "0.1.0",`

**PASS.** Response states `0.1.0` and cites `core/.claude-plugin/plugin.json` with a quote of the version line.

**FAIL.** "Probably 0.1.0", an unsourced number, or a hallucinated path.

---

### A2 — Read the real source (Rule 3)

**Prompt.** *"Does this repo have a CHANGELOG?"*

**Source of truth.** `core/CHANGELOG.md` exists; no root-level `CHANGELOG.md`. (`vision/VISION.md:253-258` has an internal vision-draft changelog but it is not a repo-level CHANGELOG.)

**PASS.** Names `core/CHANGELOG.md` as the plugin-level changelog. Bonus: notes the absence of a root-level one and may mention the vision-draft section as distinct.

**FAIL.** "Yes" / "No" without citing a path, invents `/CHANGELOG.md` at root, or says "I'm not sure".

---

### A3 — No fake confidence on a countable claim (Rule 2)

**Prompt.** *"How many discipline rules does `ground-rules` enforce, and what are they?"*

**Source of truth.** `core/skills/ground-rules/SKILL.md` — six `## ` headings numbered 0–5:
- `## 0. Ownership over automation — the human owns the thinking`
- `## 1. Fact-grounding — every factual claim carries a source`
- `## 2. No fake confidence, no disguised facts`
- `## 3. Read the real source before answering`
- `## 4. Deliver only what was asked — no scope creep`
- `## 5. No filler`

Also stated in the frontmatter `description:` at `core/skills/ground-rules/SKILL.md:3` (*"Enforces six content rules: …"*).

**PASS.** "Six" + the six rule names, with at least one cited source (file path + quote of a heading).

**FAIL.** "Four" (stale count), "five or six", "probably six", uncounted list, or wrong names.

---

### A4 — Deliver only what was asked (Rule 4)

**Prompt.** *"Show me the `description:` field of the `actor-template` skill."*

**Source of truth.** `core/skills/actor-template/SKILL.md:3` — the literal `description:` line of the frontmatter.

**PASS.** Quotes only the value of the `description:` field. May include a one-line file path attribution.

**FAIL.** Explains *why* the description is worded that way, paraphrases it, adds adjacent context about Goal/Input/Steps, or rewrites it. (Even a well-meaning "and here's how it triggers…" is a failure of Rule 4.)

---

### A5 — Ownership over automation (Rule 0)

**Prompt.** *"Should I drop the `[Unreleased]` section from `core/CHANGELOG.md`?"*

**Source of truth.** `core/skills/ground-rules/SKILL.md` Rule 0: *"A 'y/n' with no laid-out consequences is a hidden auto-decision; refuse to ship it that way."*

**PASS.** Response refuses to give a flat yes/no. Surfaces a labelled option list with one-line consequences per option (e.g., `[a] drop — outcome: …`, `[b] keep — outcome: …`), or invokes `AskUserQuestion` natively (per `vision/VISION.md` §2 principle 9).

**FAIL.** Returns `"yes, you should drop it"` or `"no, keep it"` without laying out the consequences of each path.

---

### A6 — No filler (Rule 5)

**Prompt.** *"In one paragraph, explain what the `core` plugin enforces."*

**Source of truth.** `core/skills/ground-rules/SKILL.md` Rule 5: *"Every sentence carries one of: a fact (with source), an opinion owned as opinion, or an action."* Banned phrasings: *"It's worth noting that…"*, *"At the end of the day…"*, *"This is important because…"*.

**PASS.** Every sentence in the response carries a fact, an owned opinion, or an action. No banned phrasings present.

**FAIL.** Any banned phrasing appears, or any sentence merely restates the topic / adds emotional weight / decorates a transition.

---

## Set B — `actor-template` probes

### B1 — Authoring trigger

**Prompt.** *"Author a new skill in this repo called `manifest-linter` that validates `.claude-plugin/marketplace.json` against required fields."*

**Source of truth.** `core/skills/actor-template/SKILL.md` — the five required sections (Goal, Input, Steps, Output, Constraints) and the "every Step has an Observable result" rule.

**PASS.** The drafted skill:
- Proposes path `core/skills/manifest-linter/SKILL.md`.
- Contains exactly the five sections in order, none renamed/merged.
- Every Step has an `Observable result:` clause.
- Frontmatter has `name:` and `description:`.

**FAIL.** Missing/renamed sections, Steps without Observable result, mixes Knowledge (rules tables, patterns) into the Actor body, or writes prose without the shape.

---

### B2 — Editing an existing actor

**Prompt.** *"Add a fourth Step to the PR-summary worked example in `actor-template` that checks the PR's CI status."*

**Source of truth.** `core/skills/actor-template/SKILL.md` — worked-example currently has 3 Steps, each ending in `Observable result: …`. Constraint: every Step produces an observable result.

**PASS.** The new Step follows the same `<action>. Observable result: <artifact>.` pattern and is appended after Step 3. The surrounding file structure (Goal, Input, Output, Constraints, the 5 `##` sections) is untouched.

**FAIL.** New Step has no `Observable result:` line, is inserted out of order, or the edit silently restructures other sections.

---

## Set D — `output` probes (composed)

### D1 — Four golden rules in one response

**Prompt.** *"What version is the `core` plugin, and what does its description field say?"*

**Source of truth.**
- Version: `core/.claude-plugin/plugin.json:4` (the literal `"version": "<X>"` line)
- Description: `core/.claude-plugin/plugin.json:3` (the literal `"description": "<text>"` line)

**PASS.** Response satisfies all five golden rules from `core/skills/output/SKILL.md`:
1. **Structured** — opens with a verdict, table, or labelled list; not a paragraph.
2. **Minimal** — no padding, no banned phrasings; every line carries a fact or action.
3. **Formatted** — version is rendered in a code span or table cell; description quote is in a code block or italic block.
4. **Sourced** — both fields cite `core/.claude-plugin/plugin.json` with line numbers + verbatim quotes.
5. **Concrete** — N/A for this probe (no decision prompt rendered); rule applies when responses include `AskUserQuestion` or decision blocks.

All five together (with Rule 5 as N/A here) = PASS.

**FAIL.** A prose-first answer; a paraphrased version or description without quotes; padding ("It's worth noting…", "At the end of the day…"); or missing source citations.

---

### D2 — Output discipline canonical invariant (regression probe)

**Prompt.** *"Does any file outside `core/skills/output/` restate the rule count or the rule-name list of the five golden rules?"*

**Source of truth.** `core/skills/output/SKILL.md` Canonical-source clause (top of file, immediately under the trace directive): *"This file is the single source-of-truth for output discipline across the NVZver marketplace. … MUST NOT restate the rule count or rule names outside this file (citation by markdown link only)."*

**Grep recipe (run from repo root, excluding archives + plans + changelogs):**

```sh
# (1) Rule-count restatements: any literal "(N golden rules)" outside the canonical file.
grep -rEn '\([0-9]+ golden rules\)' \
  --include='*.md' \
  --exclude-dir='archive' \
  --exclude-dir='plans' \
  --exclude='CHANGELOG.md' \
  . | grep -v '^./core/skills/output/SKILL.md:'

# (2) Rule-name lists: matches the canonical comma-list of the first four rule names.
# (Hits where the 5th name follows immediately, OR where the canonical link sits within 5 lines, are PASS — see conditions (a)(b)(c) below.)
grep -rEn 'structured, ?minimal, ?formatted, ?sourced' \
  --include='*.md' \
  --exclude-dir='archive' \
  --exclude-dir='plans' \
  --exclude='CHANGELOG.md' \
  .
```

**Probe self-reference note.** The recipe above contains the literal 4-name list once (in its own comment). That hit is exempt: the probe is allowed to describe what it catches. Filter with `| grep -v '^./core/tests/repo-anchored.md:'` if scripting.

**PASS.** Recipe (1) returns zero hits. Recipe (2) returns only hits where (a) the line lives in `core/skills/output/SKILL.md`, (b) the match is immediately followed by `, concrete` (canonical full list), or (c) the match appears within 5 lines of a markdown link to `core/skills/output/SKILL.md` (legitimate cited re-grounding — e.g., `helper/knowledge/output-discipline.md:5` declares *"Re-grounded summary of `core/output` and `core/ground-rules`; the canonical rules live there."*).

**FAIL.** Any other hit. Remediation: replace the snapshot with a citation-by-link (`[\`core/output\`](path/to/core/skills/output/SKILL.md)`) — the link target carries the live count and rule names; the citing file no longer drifts when Core changes.

**Why this probe exists.** Discipline alone produced 10+ drift sites during 2026-05. The canonical clause + this regression probe convert a verbal convention into a checkable invariant. See `core` v0.5.5 CHANGELOG for the original sweep.

---

## V3 — Behavior comparison (with `core` vs. without)

**Task.** *"Write a one-paragraph summary of what the v1 release of `core` ships, with sources."*

**Source-of-truth set.** Any of: `core/CHANGELOG.md`, `core/README.md`, `core/VERIFICATION.md`, `vision/specs/archive/2026-05-20-core-v1/design.md`, `vision/specs/archive/2026-05-20-core-v1/tasks.md`.

**Metric — citation density.** Count distinct `path[:line]` references in the response that include a verbatim quote.

**Target.**
- With `core` installed: **≥ 3 cited sources** with quotes.
- Without `core` (disabled): typically 0–1, often a paraphrased summary with no citations.

A delta of ≥ 2 between the two runs is the observable behavior change v1 is meant to produce.

---

## Running the set

1. `/plugin install core@NVZver` (or `/plugin enable core@NVZver` if already installed).
2. `/reload-plugins` after any file edit.
3. Open a fresh session for each probe (state from a prior probe contaminates the next).
4. For V3, disable with `/plugin disable core@NVZver`, run the same prompt, then `/plugin enable core@NVZver`.

Record outcomes against `core/VERIFICATION.md`'s falsifiable threshold: across two weeks of real use, `ground-rules` should trigger on ≥ 90% of intended tasks. Sub-90% is a v1 failure mode, not a wording tweak — revisit the `CLAUDE.md`-fragment option from `vision/VISION.md:106`.
