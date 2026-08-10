---
name: doctor
description: Run when the user asks for a health check of their skills install — "doctor", "health check", "verify install", "is my install wired", "something's broken", a skill that should have triggered didn't, or right after installing or updating packs. Runs four fixed read-only diagnostic checks — required packs discoverable (core + lsa), the always-on card present in the project's AGENTS.md, installed skill content consistent with the source repo, and the repo's own gate scripts passing — and reports a per-check PASS/WARN/FAIL/SKIP table with the evidence found and a one-line fix per failure. Never edits anything. Not for free-form questions ("what is X?", "how do I Y?") — the doctor only runs its fixed checks.
---

> **Trace.** On load, print first: `=============== [core/skills/doctor/SKILL.md] [core] ===============`


# Doctor

A user-runnable self-check for the skills install: four fixed, read-only diagnostic checks, each reporting PASS / WARN / FAIL / SKIP with the evidence it actually observed and a one-line fix when it fails — so a broken or half-wired install reports itself instead of failing silently (per `.lsa/pitches/onboarding-diagnostics.md` in the source repo). Free-form cited Q&A ("what is X?", "how do I Y?") is out of scope; the doctor never answers open questions — it only runs the checks below.

## Goal

Produce a four-row diagnostic table — required packs, AGENTS.md always-on card, content consistency, gate scripts — where every verdict is backed by evidence actually observed (never a bare "OK"), and every non-PASS row carries a one-line fix.

## Input

- No required arguments. An optional user symptom ("skills don't trigger", "lint is red") is echoed above the report — the four checks themselves are fixed and always all run.
- The current project's files (read-only): its `AGENTS.md`, its skills directory (`.agents/skills/`, or a host-specific path such as `.claude/skills/`), and — when present — a `skills-lock.json` recording what was installed from where.

## Steps

1. **Detect the environment.** Look for a root `skills/<pack>/<name>/SKILL.md` catalog tree. If found, the doctor is running inside this repo (the skills *source*); otherwise inside a consumer project that *installed* skills from it. This picks the content source-of-truth in Step 4 and run-vs-SKIP in Step 5. Observable result: the environment named (`source-repo` / `consumer`) with the evidence quoted (the catalog tree found, or "no root `skills/` catalog tree").

2. **Check 1 — required packs discoverable (`core` + `lsa`).** Discoverability is only heuristically observable from inside a project, so gather evidence in order: (a) the session's own context — do `core/*` and `lsa/*` skills appear in the available-skills list? (b) the project's skills directory — do subdirectories matching `core-*` / `lsa-*` (or a pack-prefixed equivalent, per the installing host's naming) exist? (c) a `skills-lock.json`, if present — does it record `core` and `lsa` pack skills? Both packs evidenced → PASS. Either missing from every readable source → FAIL for the missing one (fix: `npx skills add <org>/<repo> --skill core/... --skill lsa/...`, or copy the pack's skill directories manually — see CONTRIBUTING.md). No evidence source readable in this environment → WARN "not determinable", naming what was looked for. Never infer "installed" from the pack's source directories being present in a clone of the source repo — source on disk is not an install. Observable result: the verdict plus the exact evidence found (skill names seen, directories found, or lock entries), or the not-determinable reason.

3. **Check 2 — always-on card present in the project's `AGENTS.md`.** Grep the project's `AGENTS.md` for the four always-on rule anchors the card declares: `ground-rules`, `core/output` (or `output`), `flow-selector`, `reuse-first`. All four found → PASS. Some found → WARN — partial merge (users adapt the card; report per-anchor, name each missing one). None found, or no `AGENTS.md` at all → FAIL (fix: add the always-on card content to the project's `AGENTS.md`, per this repo's own `AGENTS.md`). Observable result: a per-anchor found/missing list, each hit cited as `AGENTS.md:<line>`.

4. **Check 3 — installed skill content vs source repo.** For each pack evidenced discoverable in Step 2: if a `skills-lock.json` is present, read its recorded content hash for each skill and compare against the current hash of that skill's directory in the source repo (or the source repo's own tree, when running inside it). All match → PASS. Any mismatch → WARN, listing each `<pack>/<skill>: local hash ≠ source hash` (fix: `npx skills update`, or re-copy the skill directory manually). No lockfile and not running inside the source repo → WARN "not determinable" (`npx skills`' lockfile is the only drift signal available; it tracks content hashes, not semantic versions — see CONTRIBUTING.md). Observable result: per-skill hash-match pairs, or the not-determinable reason.

5. **Check 4 — gate scripts pass.** Inside this repo (the skills source) only: run `bash scripts/lint.sh`, `bash scripts/check-links.sh`, `bash scripts/check-citations.sh`. All exit 0 → PASS. Any nonzero → FAIL, quoting the script's own failing line as the fix pointer. In a consumer project → SKIP ("gate scripts are internal to the skills source repo — nothing to run here"). Observable result: the script exit codes, or the SKIP reason.

6. **Render the report.** One table, one row per check: `# | Check | Verdict | Evidence | Fix` — Verdict ∈ PASS / WARN / FAIL / SKIP; Evidence is what was observed (a quoted key, a `file:line`, an exit code); Fix is one line (`—` on PASS/SKIP). Close with a one-line overall verdict — `PASS` (all rows PASS), `PASS WITH WARNINGS` (any WARN or SKIP, no FAIL), `FAIL` (any FAIL) — labels per [`../knowledge/output-vocabulary.md`](../knowledge/output-vocabulary.md). Observable result: the environment line + table + overall verdict delivered as the turn-final message.

## Output

The environment line, a four-row per-check table (`# | Check | Verdict | Evidence | Fix`), and a one-line overall verdict (`PASS` / `PASS WITH WARNINGS` / `FAIL`). Human-readable, delivered turn-final; every Evidence cell holds something the reader can re-check (a `file:line`, a JSON key, an exit code) — never a bare assertion.

## Constraints

- **Read-only.** Never create, edit, or delete any user file; never install, update, or remove a skill; never fetch the network. The doctor reports and instructs — the human fixes (the Step 5 scripts are the repo's own detect-and-report-only checks; auto-repair is a pitch no-go).
- **No new shipped executable.** Every check runs through the agent's existing tools (Read / Grep / read-only Bash) and the repo's already-existing `scripts/*.sh`; this skill ships no script or hook of its own — the trust boundary stays pure Markdown.
- **Honest verdicts only.** A check whose evidence is not observable in the current environment reports WARN or SKIP with the reason — never a guessed PASS, never a fabricated FAIL. Per [`ground-rules` Rule 7 *Done is a gate-proven, cited predicate*](../ground-rules/SKILL.md).
- **Fixed procedure, not Q&A.** The doctor runs exactly the checks above — it never answers open questions.
- Outputs follow [`../output/SKILL.md`](../output/SKILL.md) — citation by link, never restated.

---

Every output this skill produces still obeys `core/ground-rules` (content) and `core/output` (format).
