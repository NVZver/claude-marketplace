Shaped by: Nikita Zverev
Date: 2026-07-02
Status: approved
Role lens: release-engineering / CI-enforcement product manager
Decisions:
- Fork A (500-line body cap): hard-fail at 500 in CI — nothing shipped is near it (~190 max); a warn-that-never-fails is itself tech debt.
- Fork B (model-pin check scope): frontmatter-only — C5-style awk scan between `---` fences over `artifact_paths` files; a repo-wide grep would false-trip on `.lsa/standards/code.md:52` (documents the ban) and CHANGELOG history.
- Fork C (commit-discipline in CI): yes, hook + CI — the local hook never fires on a GitHub-UI merge; CI mirroring is the only way the same-commit discipline holds for merged PRs.
- Fork D (description-length + name↔dir coverage): skills + agents — the 1,024-char limit applies to any triggering surface.
Why now: manager:implement already ships a 1,041-char description that exceeds Anthropic's
1,024-char skill-description limit (measured 2026-07-02), so a "hard" rule is being violated
on a reviewer-facing surface right now — and the 2026-07-02 competitive analysis put this gap
at the top of the reliability delta vs wshobson/agents and spec-kit.

# Make every "hard" rule deterministically enforced, not advisory

The marketplace calls several invariants "hard" / "no exceptions" in its constitution and
standards, but only one of three declared gate scripts actually runs in CI and none of the
three frontmatter limits is checked anywhere — so the rules hold by discipline, not by
machine. Close the gap: wire the missing gates into CI, add the missing frontmatter checks,
and harden the local commit hook.

(Gloss: "gate" = a deterministic pass/fail script named in `.lsa.yaml`. "Invariant" = a rule
the constitution says always holds. "Frontmatter" = the YAML block at the top of a SKILL.md /
agent file. "Fact-grounding" = the repo's #1 rule that every claim carries a source + quote.)

## Problem

Anthropic's own guidance draws the line this pitch is built on: *"Unlike CLAUDE.md
instructions which are advisory, hooks are deterministic… Use hooks for actions that must
happen every time with zero exceptions"* (code.claude.com/docs/en/best-practices, cited in the
2026-07-02 competitive analysis). The marketplace states rules as "hard" but leaves them
advisory in practice. Concretely, four gaps, all verified 2026-07-02 against the live repo:

1. **Two of three declared gates never run in CI.** `.lsa.yaml:16-18` declares three gate
   scripts — `docs-invariants: bash scripts/lint.sh`, `citations: bash scripts/check-citations.sh`,
   `links: bash scripts/check-links.sh`. But `.github/workflows/lint.yml:14` runs only
   `bash scripts/lint.sh`. Fact-grounding is the constitution's first spine invariant —
   *"No claim without Statement + Source + searchable quote"* (`.lsa/VISION.md:37`) — so its
   mechanical checker being CI-dark is the sharpest instance.

2. **No frontmatter-limit check exists anywhere.** `manager/skills/implement/SKILL.md:3` ships a
   description measured at 1,041 characters, over Anthropic's documented 1,024-char hard limit
   (platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) — a truncation
   risk on the exact surface that decides whether the skill triggers. Nothing in
   `scripts/lint.sh` (checks C1–C6) catches it.

3. **The model-pin rule is prose-only.** `.lsa/standards/code.md:52` calls a hardcoded model
   *"a hard error, not a fallback"* and says *"Never hardcode `opus`, `haiku`, or `fable`"* — a
   Pro-plan-breaking pin. Currently compliant (zero pins), but no check greps for it.

4. **The local commit hook is soft in four ways.** `.claude/hooks/commit-discipline-check.sh` is
   repo-internal and never ships (SECURITY.md:252-263) — a PR merged via the GitHub UI bypasses
   it entirely. It fails open on an unparseable payload (line 58 `|| exit 0`). It false-positives
   merge commits (no merge detection; `version_bumped` lines 85-89 only sees the staged diff).
   Its CHANGELOG check requires merely ≥1 added line (`changelog_added`, lines 92-97), not that
   the top CHANGELOG heading match `plugin.json`'s version.

Who has it: the repo owner (and any future contributor). The surface is reviewer-facing
(JetBrains application visibility), so a shipped violation is a credibility cost.

Current workaround: rules honored by hand and memory. The 1,041-char description shows the
workaround already failed once, silently.

Definition of success: every rule the constitution or standards label "hard" / "no exceptions"
either passes a deterministic CI check or is blocked by a hook — zero currently-shipped
violations remaining (manager:implement description trimmed under 1,024 in the same batch),
and a red CI run for any reintroduction. Measured by: a CI job that fails on a synthetic
over-length description, a synthetic `model: opus` pin, and a dangling citation/link.

## Appetite

Medium batch. All markdown + bash against the existing gate-script pattern — no new machinery,
no new plugin, no model calls. Extends `scripts/lint.sh` (home of C1–C6), adds two lines to CI,
hardens one hook, trims one description. Touches repo-internal infrastructure only (`.github/`,
`scripts/`, `.claude/hooks/`, `SECURITY.md`) — outside every plugin's `artifact_paths`, so the
bulk triggers no plugin SemVer bump. Exception: the manager:implement description trim carries
the manager CHANGELOG + `plugin.json` bump + README-delta discipline in the same commit.

Out of appetite: verbatim quote-match for citations (check-citations.sh is mechanical-only by
design, header lines 10-13); any change to the Level-2.5 advisory posture of spec-grounding /
reconcile (`.lsa/VISION.md:247`); auto-fixing (every check reports and blocks, never edits).

## Solution sketch

- **Key user interactions:** none in normal use — value is invisible until someone tries to ship
  a violation; then CI goes red (or the local commit is blocked) with an actionable message.
- **Main components:**
  1. Wire the two dark gates into CI: add `bash scripts/check-citations.sh` and
     `bash scripts/check-links.sh` steps to `.github/workflows/lint.yml`.
  2. Add three frontmatter invariants to `scripts/lint.sh` (C7–C9, reusing the C5 awk
     frontmatter-scan so a body line can't mask a frontmatter value):
     - C7 — every shipped SKILL.md / agents/*.md `description:` ≤ 1,024 chars; skill `name:`
       matches its directory. (Coverage: skills + agents, per Fork D.)
     - C8 — fail on `^model:\s*(opus|haiku|fable)` inside frontmatter of shipped skill/agent
       files (frontmatter-scoped so prose/CHANGELOG lines don't false-trip, per Fork B).
     - C9 — 500-line body cap on shipped skill/agent bodies (hard-fail, per Fork A; latent —
       largest today ~190).
  3. Trim `manager/skills/implement/SKILL.md:3` below 1,024 (currently 1,041) with manager
     CHANGELOG + SemVer + README delta in the same commit.
  4. Harden `.claude/hooks/commit-discipline-check.sh`: skip merge commits (detect
     `$GIT_DIR/MERGE_HEAD`); replace ≥1-added-line CHANGELOG check with "top `## [x.y.z]`
     heading == plugin.json version"; sharpen SECURITY.md's note to name the fail-open tradeoff.
     Per Fork C, mirror the version↔CHANGELOG discipline as a CI check so GitHub-UI merges are
     covered too.
- **Critical path:** extend lint.sh with C7–C9 → prove each fails on a synthetic violation and
  passes clean → wire the two gates + the CI discipline mirror into lint.yml → trim the
  manager description → harden the hook → CI green on main, red on each planted violation.

## Rabbit holes

1. False positives on the new checks — scope C7–C9 to frontmatter of files under artifact_paths,
   reuse the C5 awk between-`---`-fences scan (lint.sh:129-144) + existing exemptions.
2. Merge-commit detection in a PreToolUse context — test `$GIT_DIR/MERGE_HEAD`; if set, skip the
   version/CHANGELOG discipline (the bump landed on the branch).
3. CHANGELOG-heading parsing — parse the first real-SemVer `## [x.y.z]` heading, skipping
   `[Unreleased]`, compare to plugin.json.
4. The GitHub-UI-merge bypass is only half-closed by hook hardening — truly closed only by the
   CI mirror (Fork C, decided yes).
5. The 500-line cap is a guideline, not a constitution rule — hard-fail defensible because
   nothing is near it; keep threshold generous, revisit if a real body approaches (Fork A,
   decided hard-fail).

## No-gos

1. This pitch does NOT add verbatim quote-match to the citation gate (mechanical-only by design).
2. This pitch does NOT change the Level-2.5 advisory posture of spec-grounding or lsa:reconcile.
3. This pitch does NOT add auto-fix to any check — report and block, never edit.
4. This pitch does NOT extend enforcement to the .lsa/ spec tree, tests/, or CHANGELOG history.
