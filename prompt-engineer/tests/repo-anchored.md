# Repo-anchored self-tests

Dogfood probes — run the `prompt-engineer` plugin against the prompt files it ships with (plus one scratch sample), where the source of truth for every expected answer is a file in this repo. Complement to [`../VERIFICATION.md`](../VERIFICATION.md) (which keeps the portable probes). These probes drift as the plugin changes; that is the point — they pin behavior to *current* repo state, not to a frozen prompt.

Run each probe in a fresh Claude Code session at this repo root, with `prompt-engineer@NVZver` installed. Record PASS/FAIL inline or in a session log.

---

## Set A — `prompt-engineer` agent (self-consistency)

The agent enforces Separation of Concerns ([`knowledge/separation-of-concerns.md`](../knowledge/separation-of-concerns.md)); these probes hold it to its own doctrine.

### A1 — Agent references knowledge, never inlines rules

**Prompt.** *"Does the `prompt-engineer` agent contain its rule definitions, or does it reference knowledge files?"*

**Source of truth.** [`agents/prompt-engineer.md:35-43`](../agents/prompt-engineer.md) — every Step links out to `knowledge/*.md`; rules are not restated in the agent. Confirmed by [`CHANGELOG.md:19`](../CHANGELOG.md) (agent `161 → 58` lines, six rule categories extracted to `knowledge/`).

**PASS.** States the agent references knowledge files (cites a Step line in `agents/prompt-engineer.md`); may note the 58-line agent and the v0.2.0 extraction.

**FAIL.** Claims the agent inlines its rule lists, invents a section, or answers without citing a file.

### A2 — Ground-rules list is defined once (grep invariant)

**Prompt / recipe.** Run from repo root:
```sh
grep -rn "Declare: Goal, Input, Steps, Output" prompt-engineer/ --exclude-dir=tests
```
(`--exclude-dir=tests` skips this file, whose recipe line above would otherwise self-match.)

**Source of truth.** The actor ground-rules list lives only in [`knowledge/actor-ground-rules.md:12`](../knowledge/actor-ground-rules.md). An `agents/` or `commands/` hit is a boundary violation (HIGH) per [`knowledge/separation-of-concerns.md:38`](../knowledge/separation-of-concerns.md) ("Actor restates a rule from a knowledge file").

**PASS.** Exactly one hit: `prompt-engineer/knowledge/actor-ground-rules.md:12`.

**FAIL.** Any hit under `agents/` or `commands/` — the rule list has leaked back into an actor.

### A3 — Agent passes its own review

**Prompt.** *"Run `prompt-review` on `prompt-engineer/agents/prompt-engineer.md`."*

**Source of truth.** The agent carries every required actor section — Role [`:22`](../agents/prompt-engineer.md), Goal `:24`, Input `:26`, Constraints `:28-31`, Steps `:33-43`, Output `:45-48`, Example Output `:50-58`.

**PASS.** Zero HIGH findings. Any finding is LOW wording at most.

**FAIL.** A HIGH finding (missing section / boundary violation) — the plugin fails its own bar.

---

## Set B — `prompt-review`

### B1 — Every finding cites a rule number

**Prompt.** *"Review `prompt-engineer/commands/prompt-optimize.md` and show the findings table."*

**Source of truth.** Constraint [`commands/prompt-review.md:18`](../commands/prompt-review.md) — *"Do NOT report issues without citing the violated rule number"*; the Example Output table carries a `Rule` column ([`:51`](../commands/prompt-review.md)).

**PASS.** Output is a table where every row has a rule citation in the `Rule` column (or states "0 issues").

**FAIL.** Any finding with no rule number, or prose instead of a table.

### B2 — Show-changes-inline check is present (v0.3.0)

**Prompt.** *"Does `prompt-review` check for show-changes-inline violations? What severity?"*

**Source of truth.** [`commands/prompt-review.md:39`](../commands/prompt-review.md) — Step 3 item `l`, **WARNING-ONLY**, author-time half of `core/output` Rule 7; example WARNING row at [`:57`](../commands/prompt-review.md).

**PASS.** Confirms the check exists, names it warning-only / author-time, cites `:39`.

**FAIL.** Says no such check, calls it a HIGH/MEDIUM gate, or misattributes it to `lsa:verify`.

### B3 — Review catches planted violations (behavioral)

**Prompt.** Save this block to a scratch file outside the repo (`/tmp/deploy.md`), then: *"Run `prompt-review` on `/tmp/deploy.md`."*
```markdown
---
name: deploy
description: Deploy the service
allowed-tools: Read, Write, Bash
---
# Deploy
Goal: Ship the service to production.
Input: $ARGUMENTS (environment name)
Constraints:
- Do NOT deploy on Fridays
## Steps
1. Read the manifest carefully → manifest loaded
2. Handle the deployment
## Output
Format: Summary line.
Length: 1 line.
```

**Source of truth.** This command sample plants one finding per severity (an `## Output` spec is present, so the missing `## Example Output` is the only HIGH):
| Expected finding | Severity | Rule | Anchored in |
|---|---|---|---|
| No Example Output section | HIGH | 10 | [`actor-ground-rules.md:21`](../knowledge/actor-ground-rules.md) |
| Step 2 vague: "Handle the deployment" (no observable result) | MEDIUM | 5 | [`actor-ground-rules.md:16`](../knowledge/actor-ground-rules.md) |
| Adverb "carefully" in step 1 | LOW | 9 | [`actor-ground-rules.md:20`](../knowledge/actor-ground-rules.md) |

**PASS.** Each listed finding surfaces, cited to its rule. The HIGH (missing Example Output) is the non-negotiable catch.

**FAIL.** The HIGH is missed, or any finding lands with no rule citation.

### B4 — Review fires the show-changes-inline WARNING (behavioral, v0.3.0)

**Prompt.** Save this block to `/tmp/SKILL.md` (check `l` keys off the `**/SKILL.md` path), then: *"Run `prompt-review` on `/tmp/SKILL.md`."*
```markdown
---
name: sync
description: Sync local records to the remote store
---
# Sync
Goal: Push new and changed local records to the configured remote.
Input: $ARGUMENTS (source path)
Constraints:
- Do NOT sync partial batches
## Steps
1. Read the source → records loaded
2. Write the merged result to output.json → output.json written
## Output
Format: Summary line.
Length: 1 line.
## Example Output
Synced 12 records to output.json.
```

**Source of truth.** [`commands/prompt-review.md:39`](../commands/prompt-review.md) — check `l` flags a write step in a `**/SKILL.md` or `**/agents/*.md` source carrying no show-changes directive. Step 2 writes `output.json` with no such directive; the sample is otherwise compliant (Goal ≠ description, every step has a result, Output + Example Output present), so the WARNING is the only finding.

**PASS.** One WARNING on step 2, cited `3l`. No HIGH or MEDIUM (the check is warning-only, not a gate).

**FAIL.** No WARNING (the marquee v0.3.0 check is dead), or it fires as a HIGH/MEDIUM.

---

## Set C — `prompt-optimize`

### C1 — Fixes are quoted inline before the verdict (v0.3.0)

**Prompt.** Reuse `/tmp/deploy.md` from B3: *"Run `prompt-optimize` on `/tmp/deploy.md`."*

**Source of truth.** [`commands/prompt-optimize.md:31`](../commands/prompt-optimize.md) — Step 5.5: *"Quote each applied fix inline before the verdict … Never report 'fixed N issues' without the changed content."*

**PASS.** Each fix shows changed content (before/after or quoted insertion) *before* the summary table.

**FAIL.** Reports "fixed N issues" / a count-only table with no changed content shown.

### C2 — Re-review confirms resolution

**Prompt.** Continue C1: *"Re-run `prompt-review` on the optimized `/tmp/deploy.md`."*

**Source of truth.** [`commands/prompt-optimize.md:32-33`](../commands/prompt-optimize.md) — Step 6 re-runs review; Step 7 repeats until clean or an issue recurs.

**PASS.** The B3 HIGH and MEDIUM are gone from the re-review.

**FAIL.** A previously reported HIGH/MEDIUM persists with no "same issue recurs" note.

---

## Set D — `prompt-create`

### D1 — Scaffold has all sections, quoted inline before the verdict

**Prompt.** *"Run `prompt-create` for a command named `lint-config`."* (Answer its questions: Command; Goal "validate a config file"; one constraint.)

**Source of truth.** [`commands/prompt-create.md:33-34`](../commands/prompt-create.md) — a Command gets Goal/Input/Constraints/Steps/Output/Example Output; [`:35`](../commands/prompt-create.md) — quote the generated content inline before any verdict.

**PASS.** Generated file shows all required sections, quoted inline, *before* the "Created:" line; then runs review on it.

**FAIL.** A required section is missing, or only a path is reported with no content shown.

### D2 — Missing input → asks, never guesses

**Prompt.** *"Create a prompt."* (no type, no name)

**Source of truth.** [`commands/prompt-create.md:22-23`](../commands/prompt-create.md) — Step 1 asks "(A) Agent, (B) Command", Step 2 asks for a kebab-case name; grounded in [`actor-ground-rules.md:17`](../knowledge/actor-ground-rules.md) rule 6 ("ask one question with 2-4 suggested answers. Never guess").

**PASS.** Asks for component type (with options) and name before writing anything.

**FAIL.** Guesses a type/name and scaffolds a file without asking.

---

## Running the set

1. `/plugin install prompt-engineer@NVZver` (or `/plugin enable prompt-engineer@NVZver` if already installed).
2. `/reload-plugins` after any file edit.
3. Open a fresh session for each probe — state from a prior probe contaminates the next.
4. Sets B/C use **scratch files outside the repo** (`/tmp/deploy.md`, `/tmp/SKILL.md`) so repo-wide scans stay clean; delete them after.

Record outcomes against [`../VERIFICATION.md`](../VERIFICATION.md)'s falsifiable threshold.
