# AGENTS.md canonical — one discipline file, gated against duplication

## Summary

Move this repo's own always-on agent instructions from `/CLAUDE.md` to `/AGENTS.md`
(the vendor-neutral standard, https://agents.md/), reduce `/CLAUDE.md` to an
`@AGENTS.md` import plus genuinely Claude-Code-specific lines, and make install
step 2 name a tool-conditional *destination* while the shipped fragment *path*
(`core/CLAUDE.md`) stays byte-identical in name. A new `scripts/lint.sh` check
**C16** fails the gate if the discipline text ever appears in a second file.

- Source: `.lsa/pitches/standards-conformance-agents-md.md` (approved 2026-07-19) — Fork A, Fork B, rabbit holes 1–4.
- Applies: pitch success criteria 1 and 2; rabbit hole 1's non-negotiable — *"if the chosen wiring cannot be gated by a script, it is the wrong wiring."*
- Target surface: `/AGENTS.md` (new), `/CLAUDE.md` (rewired), `core/CLAUDE.md` (prose only), `core/README.md`, `README.md`, `scripts/lint.sh`.
- Style precedent: `scripts/lint.sh` C6 (`scripts/lint.sh:152-165`) and C15 (`scripts/lint.sh:455-475`) — banner comment, single-purpose presence guard, `pass_line` / `fail_line`.

## User Flows

1. **A non-Claude-Code agent opens the repo.** Cursor / Codex / Zed / Copilot
   reads `/AGENTS.md` at repo root and receives the full always-on discipline —
   the eight `core/ground-rules` one-liners, the hard `core/output` rule, the
   `core/flow-selector` classification requirement, and the pointers to
   `.lsa/VISION.md` and `CONTRIBUTING.md`.
2. **Claude Code opens the repo.** Claude Code reads `/CLAUDE.md`, which is an
   `@AGENTS.md` import plus Claude-Code-specific lines. Claude Code does **not**
   read `AGENTS.md` natively (anthropics/claude-code#6235, open as of
   2026-07-19), so both files must coexist and the import is explicit.
3. **A user installs the marketplace.** README install step 2 tells them to merge
   the `core/CLAUDE.md` fragment into `CLAUDE.md` if they use Claude Code, or into
   `AGENTS.md` otherwise. Same bytes, different destination.
4. **A maintainer accidentally copies the discipline into a second file.**
   `bash scripts/lint.sh` exits non-zero and prints a `FAIL` line naming **C16**
   and both offending paths. Deleting the copy makes lint exit 0 again.

## Functional requirements (EARS)

- R1. A new file `/AGENTS.md` SHALL exist at repo root and SHALL hold the current
  content of `/CLAUDE.md` verbatim, including its `# CLAUDE.md` heading retitled
  to `# AGENTS.md` and every existing relative link left unchanged (`./.lsa/VISION.md`,
  `./.lsa.yaml`, `./core/CLAUDE.md`, `./README.md`, `./CONTRIBUTING.md`,
  `./lsa/README.md`, `./core/README.md`, `./lsa/ARCHITECTURE.md`,
  `./.lsa/main.spec.md`). Both files sit at repo root, so no relative path
  requires rewriting. `/AGENTS.md` SHALL contain the literal string
  `The always-on card lives at` exactly once.

- R2. `/CLAUDE.md` SHALL be reduced to (a) a single `# CLAUDE.md` heading, (b) a
  line containing exactly `@AGENTS.md` and nothing else, (c) one sentence stating
  that `AGENTS.md` is canonical and this file exists because Claude Code does not
  read `AGENTS.md` natively (citing `anthropics/claude-code#6235`), and (d) a
  `## Claude Code specifics` section holding only content meaningless outside
  Claude Code: the `/plugin marketplace add` / `/plugin install` / `/reload-plugins`
  install block and the `/core:doctor` pointer. `/CLAUDE.md` SHALL be **≤ 20 lines**
  (`wc -l < CLAUDE.md` returns a value ≤ 20) and SHALL NOT contain the literal
  string `The always-on card lives at`.

- R3. `core/CLAUDE.md` SHALL keep its exact path `core/CLAUDE.md`. It SHALL NOT be
  renamed, moved, or deleted — the path is pinned by `.lsa.yaml` `core.artifact_paths`
  and by lint C15's `DW_CARD="core/CLAUDE.md"` (`scripts/lint.sh:465`). It SHALL
  continue to contain the literal marker `Deterministic work is scripted` so C15's
  second sub-check keeps passing.

- R4. The self-describing destination prose inside `core/CLAUDE.md` SHALL name a
  tool-conditional destination — merge into your project's `CLAUDE.md` (Claude Code)
  or `AGENTS.md` (any other agent tool). No rule text inside the card changes; this
  is a destination sentence edit only.

- R5. `README.md` install step 2 (currently `README.md:71`, reading *"Merge the
  `core/CLAUDE.md` fragment into your project's `CLAUDE.md`. This is the step that
  activates the always-on rules — skip it and the discipline layer silently never
  engages."*) SHALL be rewritten so that: the source fragment link stays exactly
  `[`core/CLAUDE.md`](./core/CLAUDE.md)`; the destination names `CLAUDE.md` for
  Claude Code and `AGENTS.md` for every other agent tool; and the existing
  activation warning sentence is preserved verbatim.

- R6. The `README.md` troubleshooting bullet *"Always-on rules not applying"*
  (currently `README.md:92`) SHALL name the same tool-conditional destination and
  SHALL keep referring to install step 2.

- R7. `core/README.md`'s merge-instruction paragraph (currently `core/README.md:33`,
  beginning *"Copy the content of ..."*) SHALL name the same tool-conditional
  destination and SHALL keep the `core/CLAUDE.md` source path unchanged.

- R8. `scripts/lint.sh` SHALL gain a new check numbered **C16** — C15 is the highest
  existing check, so C16 is the next free number. It SHALL be implemented in the C6 /
  C15 presence-guard style (banner comment, `pass_line` on success, `fail_line` on
  failure) with these literal constants:
  - `DISCIPLINE_MARKER='The always-on card lives at'`
  - `DISCIPLINE_HOME='AGENTS.md'`
  It SHALL collect the sorted list of files containing `DISCIPLINE_MARKER` as a
  fixed string, over tracked **and** untracked-non-ignored files, excluding exactly
  three surfaces: `.lsa/**` (spec/pitch prose quotes the marker by design),
  `scripts/lint.sh` (defines the marker), and `**/CHANGELOG.md` (frozen history).
  The reference implementation is:
  `git grep -lIF --untracked "${DISCIPLINE_MARKER}" -- ':(exclude).lsa/**' ':(exclude)scripts/lint.sh' ':(exclude)**/CHANGELOG.md'`
  It SHALL `pass_line` if and only if that list is exactly the single entry
  `AGENTS.md`. If the list is empty it SHALL `fail_line` stating the discipline
  marker is missing from `AGENTS.md`. If the list has two or more entries it SHALL
  `fail_line` stating the discipline text is duplicated and SHALL print every
  offending path, indented, one per line. Both `fail_line` strings SHALL begin with
  the literal token `C16`.

- R9. C16 SHALL be proven by **falsification**, not by observing a green run. The
  implementer SHALL execute this negative control and record its output:
  1. Create `scratch-c16-probe.md` at repo root containing the line
     `The always-on card lives at [core/CLAUDE.md](./core/CLAUDE.md).`
  2. Run `bash scripts/lint.sh`. It SHALL exit **1**, and its output SHALL contain
     a `FAIL` line whose text includes `C16` and includes both `AGENTS.md` and
     `scratch-c16-probe.md`.
  3. Delete `scratch-c16-probe.md`.
  4. Run `bash scripts/lint.sh` again. It SHALL exit **0**.
  A C16 that cannot be made to fail in step 2 is a failed requirement, not a passing
  one. `scratch-c16-probe.md` SHALL NOT be committed.

- R10. `/core:doctor` Check 2 (`core/skills/doctor/SKILL.md:28`) SHALL continue to
  pass unchanged: it greps the *project's* `CLAUDE.md` for the four anchors
  `ground-rules`, `core/output`, `flow-selector`, `reuse-first`. Because those
  anchors live in the shipped `core/CLAUDE.md` fragment (unchanged by R3/R4) and
  are checked against a *consumer's* `CLAUDE.md`, no doctor logic changes. This
  requirement is a regression guard: `core/skills/doctor/SKILL.md` SHALL NOT be
  edited by this epic.

- R11. Lint C15 SHALL continue to pass both sub-checks after the change — the
  `.lsa/VISION.md` presence check and the `core/CLAUDE.md` (`DW_CARD`) presence
  check. `scripts/lint.sh` C15's code SHALL NOT be modified.

- R12. `core` SHALL bump SemVer **0.20.0 → 0.21.0** (MINOR — user-facing install
  instruction changes) in `core/.claude-plugin/plugin.json`, with a matching
  `core/CHANGELOG.md` entry under a new `## [0.21.0]` heading in the same commit.
  `core/CLAUDE.md` and `core/README.md` are both in `core`'s `artifact_paths`
  (`.lsa.yaml`), which is what drives this bump. `/CLAUDE.md`, `/AGENTS.md`,
  `/README.md`, `.lsa/VISION.md` and `scripts/lint.sh` are in **no** plugin's
  `artifact_paths`, so this epic costs exactly **one** SemVer bump — `core` — and
  no other plugin version or CHANGELOG SHALL be touched.

- R13. `project-map.yaml` SHALL be regenerated with
  `bash lsa/scripts/project-map-build.sh` and committed, because this epic adds the
  new directory `.lsa/features/standards-conformance-agents-md/` at depth 3.

- R14. After the change, `bash scripts/lint.sh`, `bash scripts/check-citations.sh`,
  `bash scripts/check-links.sh`, `bash lsa/scripts/project-map-check.sh`,
  `bash scripts/run-tests.sh`, and `bash scripts/check-version-changelog.sh` SHALL
  each exit **0**.

## Out of Scope

- Renaming `core/CLAUDE.md` (rabbit hole 4 — breaks `.lsa.yaml` and C15).
- Any change to skill *content*, name, or directory.
- `scripts/generate-for-cursor.sh` or any `cursor-equal-support` epic.
- The `skills-ref` / agentskills.io citation work — that is epic
  `standards-conformance-agents-md/standards-claim`.
- Widening `scripts/check-links.sh` to cover `.lsa/` (named in rabbit hole 5, not taken).
