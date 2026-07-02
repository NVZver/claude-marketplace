---
name: doctor
description: Run when the user asks for a health check of their NVZver marketplace install — "doctor", "health check", "verify install", "is my install wired", "something's broken", a skill that should have triggered didn't, or right after installing or updating plugins. Runs four fixed read-only diagnostic checks — required plugins installed (core + lsa), the core/CLAUDE.md always-on fragment merged into the project CLAUDE.md, installed plugin versions consistent with their source manifests, and the marketplace gate scripts passing — and reports a per-check PASS/WARN/FAIL/SKIP table with the evidence found and a one-line fix per failure. Never edits anything. Not for free-form questions ("what is X?", "how do I Y?") — those belong to helper's /help; the doctor only runs its fixed checks.
---

> **Trace.** On load, print first: `=============== [core/skills/doctor/SKILL.md] [core] ===============`


# Doctor

A user-runnable self-check for the marketplace install: four fixed, read-only diagnostic checks, each reporting PASS / WARN / FAIL / SKIP with the evidence it actually observed and a one-line fix when it fails — so a broken or half-wired install reports itself instead of failing silently (per [`.lsa/pitches/onboarding-diagnostics.md`](../../../.lsa/pitches/onboarding-diagnostics.md)). Free-form cited Q&A ("what is X?", "how do I Y?") is [`helper`](../../../helper/README.md)'s job (`/help`); the doctor never answers open questions — it only runs the checks below.

## Goal

Produce a four-row diagnostic table — required plugins, CLAUDE.md fragment, version consistency, gate scripts — where every verdict is backed by evidence actually observed (never a bare "OK"), and every non-PASS row carries a one-line fix.

## Input

- No required arguments. An optional user symptom ("skills don't trigger", "lint is red") is echoed above the report — the four checks themselves are fixed and always all run.
- The current project's files (read-only), and — when readable — Claude Code's plugin state under `~/.claude/plugins/` (`installed_plugins.json`, the `marketplaces/NVZver/` clone).

## Steps

1. **Detect the environment.** Read `.claude-plugin/marketplace.json` at the project root. If it exists with `"name": "NVZver"`, the doctor is running inside the marketplace source repo; otherwise inside a consumer project. This picks the version source-of-truth in Step 4 and run-vs-SKIP in Step 5. Observable result: the environment named (`marketplace-source` / `consumer`) with the evidence quoted (the `"name"` line, or "no `.claude-plugin/marketplace.json`").

2. **Check 1 — required plugins installed (`core` + `lsa`).** Installation is only heuristically observable from inside a project, so gather evidence in order: (a) the session's own context — do `core:*` and `lsa:*` skills appear in the available-skills list? (b) `~/.claude/plugins/installed_plugins.json` — do the keys `core@NVZver` and `lsa@NVZver` exist? Both plugins evidenced → PASS. Either missing from every readable source → FAIL for the missing one (fix: `/plugin install <name>@NVZver`, then `/reload-plugins`). No evidence source readable in this environment → WARN "not determinable", naming what was looked for. Never infer "installed" from the plugin source directories being present in the repo — source on disk is not an install. Observable result: the verdict plus the exact evidence found (skill names seen, or the JSON keys), or the not-determinable reason.

3. **Check 2 — `core/CLAUDE.md` fragment present in the project `CLAUDE.md`.** Grep the project's `CLAUDE.md` for the four always-on rule anchors the fragment declares ([`core/CLAUDE.md`](../../CLAUDE.md)): `ground-rules`, `core/output`, `flow-selector`, `reuse-first`. All four found → PASS. Some found → WARN — partial merge (users adapt the fragment; report per-anchor, name each missing one). None found, or no `CLAUDE.md` at all → FAIL (fix: merge [`core/CLAUDE.md`](../../CLAUDE.md) into the project `CLAUDE.md`, per [`core/README.md`](../../README.md) § "Merge the CLAUDE.md fragment"). Observable result: a per-anchor found/missing list, each hit cited as `CLAUDE.md:<line>`.

4. **Check 3 — installed plugin versions vs source manifests.** For each NVZver plugin evidenced installed in Step 2, read the installed version (the `version` field in `installed_plugins.json`, or the versioned cache path) and compare it to the source manifest `<plugin>/.claude-plugin/plugin.json` — the repo's own manifest when inside the marketplace source repo, else the synced clone under `~/.claude/plugins/marketplaces/NVZver/`. All equal → PASS. Any mismatch → WARN, listing each `<plugin>: installed X ≠ source Y` (fix: update the NVZver marketplace and the stale plugins via `/plugin`, then `/reload-plugins`). Neither installed state nor a source manifest readable → WARN "not determinable". Observable result: per-plugin `installed → source` version pairs.

5. **Check 4 — gate scripts pass.** Inside the marketplace source repo only: run `bash scripts/lint.sh`, `bash scripts/check-links.sh`, `bash scripts/check-citations.sh`, `bash scripts/check-version-changelog.sh`. All exit 0 → PASS. Any nonzero → FAIL, quoting the script's own failing line as the fix pointer. In a consumer project → SKIP ("gate scripts are repo-internal to the marketplace source repo — nothing to run here"). Observable result: the four script exit codes, or the SKIP reason.

6. **Render the report.** One table, one row per check: `# | Check | Verdict | Evidence | Fix` — Verdict ∈ PASS / WARN / FAIL / SKIP; Evidence is what was observed (a quoted key, a `file:line`, an exit code); Fix is one line (`—` on PASS/SKIP). Close with a one-line overall verdict — `PASS` (all rows PASS), `PASS WITH WARNINGS` (any WARN or SKIP, no FAIL), `FAIL` (any FAIL) — labels per [`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md). Observable result: the environment line + table + overall verdict delivered as the turn-final message.

## Output

The environment line, a four-row per-check table (`# | Check | Verdict | Evidence | Fix`), and a one-line overall verdict (`PASS` / `PASS WITH WARNINGS` / `FAIL`). Human-readable, delivered turn-final; every Evidence cell holds something the reader can re-check (a `file:line`, a JSON key, an exit code) — never a bare assertion.

## Constraints

- **Read-only.** Never create, edit, or delete any user file; never install, update, or remove a plugin; never fetch the network. The doctor reports and instructs — the human fixes (the Step 5 scripts are the repo's own detect-and-report-only checks; auto-repair is a pitch no-go).
- **No new shipped executable.** Every check runs through the agent's existing tools (Read / Grep / read-only Bash) and the repo's already-existing `scripts/*.sh`; this skill ships no script or hook of its own — the trust boundary stays pure Markdown.
- **Honest verdicts only.** A check whose evidence is not observable in the current environment reports WARN or SKIP with the reason — never a guessed PASS, never a fabricated FAIL. Per [`ground-rules` Rule 7 *Done is a gate-proven, cited predicate*](../ground-rules/SKILL.md).
- **Fixed procedure, not Q&A.** The doctor runs exactly the checks above — it never answers open questions. Free-form cited Q&A is [`helper`](../../../helper/README.md)'s `/help`; helper never runs an install check. The boundary is stated in both READMEs.
- Outputs follow [`../output/SKILL.md`](../output/SKILL.md) — citation by link, never restated.

---

Every output this skill produces still obeys `core/ground-rules` (content) and `core/output` (format).
