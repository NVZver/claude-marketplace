Shaped by: Nikita Zverev
Date: 2026-07-19
Status: approved
Role lens: developer-tooling product manager (open-standards / interoperability lens)
Gate decisions:
- Fork A (CLAUDE.md ↔ AGENTS.md wiring): `/AGENTS.md` is canonical; `/CLAUDE.md` becomes an `@AGENTS.md` import plus anything genuinely Claude-Code-specific. Explicit, greppable by lint, survives `git clone` on any OS, visible to a human reader.
- Fork B (shipped `core/` fragment): one `core/CLAUDE.md`; install step 2 gains a tool-conditional destination. Zero duplication; path stays pinned for `.lsa.yaml:61` and lint C15.
- Fork C (SchemaStore / `.lsa.yaml` JSON Schema): **out of scope**, separate pitch — net-new capability for third-party editors, outside the consolidation posture that findings A and B sit inside.
- Fork D (proving conformance): one-off manual `skills-ref validate` run, output cited as evidence in `core/VERIFICATION.md`; the `.lsa.yaml` `gate:` block stays free of npm. Both optional fields left unset — see the revision below.
- Fork D sub-item **REVISED at decomposition (2026-07-19)**: the optional per-skill `license` field is **DROPPED**, not set. It is optional in the spec, absent from all four success criteria, and does not affect `skills-ref validate` (20/20 passes without it). Decisive reason: the license is already stated once at repo root, so writing it into 20 files copies a single fact into twenty independently-driftable places — the exact failure mode rabbit hole 1 builds C16 to prevent. Shipping the anti-duplication gate and the duplication in the same cycle would be incoherent. Cost avoided: four SemVer bumps + four CHANGELOG entries + four module-spec updates, since `*/skills/**/SKILL.md` sits in `artifact_paths` for `core`, `lsa`, `manager`, and `observer`. `metadata` stays unset for the same reason it always was. Recorded as one greppable line in `core/VERIFICATION.md` so it is not re-litigated.
- Fork E (sequencing): this pitch runs FIRST and triggers a re-shape of `cursor-equal-support` before any of its epics start.
Why now: the industry standardized the exact distribution layer our tool-agnosticism claim is
unproven at, and `cursor-equal-support` is still `status: backlog` — re-aiming it now is free,
after it starts it is rework.

# Make tool-agnosticism true and independently verifiable

Adopt `AGENTS.md` as the single source for this repo's agent instructions, claim the Agent
Skills open standard we already silently comply with, and re-aim `cursor-equal-support` around
both — without duplicating one line of discipline content.

## Problem

`README.md` §"Status + substrate" claims: *"the discipline (specs, sourcing, flow gating) isn't
Claude-specific and the skills are plain Markdown — porting to another agentic IDE is a routing
exercise, not a rewrite."* Our own competitive review calls that claim half-earned: *"LSA's
tool-agnosticism is real at the format layer (EARS + Gherkin are genuinely portable) but unproven
at the distribution layer"* (`.lsa/observations/2026-07-19-sdd-competitive-pulse-check.md` §5.1).
The same section notes *"every claim in §3 above is currently unverified by anyone outside this
repo."*

Two verified findings make the gap concrete and cheap to close:

**A — we ship no `AGENTS.md`.** A vendor-neutral agent-instruction standard, per
https://agents.md/ : *"AGENTS.md is now stewarded by the Agentic AI Foundation under the Linux
Foundation"*, *"used by over 60k open-source projects"*, with Cursor, Copilot, Codex, Devin,
Zed, Jules, Junie, Aider, goose, RooCode, VS Code and Warp listed as consumers. Confirmed by
glob: no `AGENTS.md`, no `.cursorrules`, no `.cursor/` in this repo. A foreign agent opening
this repo finds only `CLAUDE.md` and gets nothing.

**B — we already conform to the Agent Skills spec and never say so.** The `SKILL.md` format is
published at https://agentskills.io/specification with a reference validator
(`skills-ref validate ./my-skill`) and 40+ compatible clients. Its normative requirements —
`name` ≤64 chars, lowercase-alphanumeric-plus-hyphens, **matching the parent directory**;
`description` non-empty and ≤1024; body recommended under 500 lines — are already enforced
against all 20 of our shipped skills by `scripts/lint.sh` C7 and C9. Verified 2026-07-19:
name↔directory matches 20/20; longest body is 192 lines. We converged on the spec's own
constraints without having read it. But C7's comment cites *"Anthropic's documented hard limit …
platform.claude.com"* and C9 cites an internal pitch fork — vendor doc and internal artifact, not
the open standard. We meet a public interoperability spec and cite a vendor for permission to do
so.

Who has the problem: (1) the maintainer, whose README makes a claim he cannot presently prove;
(2) any future evaluator, for whom "tool-agnostic" is currently an assertion with no artifact
behind it.

Current workaround: none. The claim is carried unverified, and the only planned remedy
(`cursor-equal-support`, `priority: Must`, `status: backlog`) is a bespoke
`scripts/generate-for-cursor.sh` emitting a Cursor-shaped tree — a one-vendor answer designed
before either standard was on our radar.

Definition of success — all four independently checkable by someone who does not use Claude Code:

1. A reader with no Claude Code install opens `/AGENTS.md` at repo root and receives the full
   always-on discipline.
2. The discipline text exists in exactly **one** file on disk; a lint check fails if a second
   copy appears.
3. `skills-ref validate` passes on all 20 shipped skills, and its output is cited as a gate
   artifact — external tooling, not our own script, confirming conformance.
4. `README.md` §"Status + substrate" names both standards, so the claim carries a source rather
   than an adjective.

## Appetite

One cycle, docs-only (`mode: docs`). The budget is: one new root file, one rewiring of an
existing root file, one lint check, one README/VISION paragraph, one comment re-citation in
`lint.sh`, and one re-shape trigger on `cursor-equal-support`.

Out of appetite: writing `scripts/generate-for-cursor.sh` (that stays `cursor-equal-support`'s
work); actually running an LSA cycle inside another tool; any change to skill *content*;
publishing or promoting anything externally.

**Posture check.** Repo posture is consolidation (2026-07-16): optimize/solidify, no net-new
capability. Findings A and B sit inside it — both make an existing claim true and provable and
add zero capability. That reading does **not** extend to the SchemaStore idea: publishing a JSON
Schema for `.lsa.yaml` and registering it for third-party editor autocomplete is net-new
capability for users we do not have. Excluded at gate (Fork C).

## Solution sketch

- **Key user interactions:** a non-Claude-Code user clones the repo and reads `AGENTS.md` instead
  of finding nothing. An installing user's step 2 becomes tool-conditional — *merge the
  `core/CLAUDE.md` fragment into your project's `CLAUDE.md` (Claude Code) or `AGENTS.md` (every
  other listed tool)*. Same bytes, different destination. This is literally the "routing exercise"
  the README promises, made real.

- **Main components:**
  - `/AGENTS.md` (new) — this repo's own project instructions, moved here verbatim.
  - `/CLAUDE.md` (rewired) — reduced to an `@AGENTS.md` import plus anything genuinely
    Claude-Code-specific. Necessary because Claude Code does **not** read `AGENTS.md` natively
    (anthropics/claude-code#6235, open); both files must coexist.
  - `core/CLAUDE.md` — **path unchanged.** It is pinned by `.lsa.yaml:61` (`core`
    `artifact_paths`) and by lint C15, which greps this exact path (`DW_CARD="core/CLAUDE.md"`).
    Only its self-describing prose changes ("merge into your project's `CLAUDE.md`" → the
    tool-conditional wording).
  - `scripts/lint.sh` — new check C16 asserting the discipline text lives in one file only
    (anti-duplication); C7/C9 comments re-cited to agentskills.io alongside the existing refs.
  - `README.md` §"Status + substrate" and `.lsa/VISION.md` — the claim, sourced to both standards.
  - `.lsa/roadmap.yaml` `cursor-equal-support` — notes updated to record that its locked approach
    is superseded in part and must be re-shaped.

- **Critical path:** move discipline text to `AGENTS.md` → `CLAUDE.md` imports it → C16 proves no
  second copy exists → `skills-ref validate` passes on 20/20 skills → README claim cites both
  standards → `cursor-equal-support` re-scoped before it starts.

**Position on `cursor-equal-support`.** AGENTS.md makes that pitch's *prose-translation* half
largely redundant and its *skill-routing* half the real remaining work. Cursor is a listed
AGENTS.md consumer and a listed Agent Skills client, so one root `AGENTS.md` plus
already-conformant `SKILL.md` files covers Cursor — and Copilot, Codex, Zed, Junie, Aider, goose
— without generating a `.cursor/` tree of restated discipline. What a generator still buys us is
placement/routing of the 20 skills into each client's expected location, which no standard
settles. So: **the generator survives, its scope narrows, and its epics
(`generate-and-copy-docs`, `vision-second-surface`) must be re-shaped, not started.** That is the
sharpest reason to run this pitch first — the item is `status: backlog`, so re-aiming costs
nothing today and becomes rework the moment `generate-script` begins.

## Rabbit holes

1. **Duplicating the discipline into two files that then drift** — the self-inflicted version of
   exactly the spec/code drift this system exists to prevent. Mitigation: `CLAUDE.md` holds an
   `@AGENTS.md` import, never a copy, and lint C16 fails the gate if the discipline text appears
   in two files. Non-negotiable: **if the chosen wiring cannot be gated by a script, it is the
   wrong wiring.**

2. **Assuming native AGENTS.md support.** Claude Code does not read it (issue #6235, open,
   unimplemented as of July 2026). Any design where `AGENTS.md` alone activates the discipline on
   our primary substrate is broken on arrival. Mitigation: Fork A resolved to the explicit
   `@AGENTS.md` import, and `/core:doctor`'s "fragment merged" check must still pass afterward.

3. **Breaking install step 2.** The README states: *"Merge the `core/CLAUDE.md` fragment into your
   project's `CLAUDE.md`. This is the step that activates the always-on rules — skip it and the
   discipline layer silently never engages."* `CLAUDE.md` here is a distribution surface, not just
   repo config. Mitigation: the shipped fragment path never changes; only the destination sentence
   gains a second branch. Existing Claude Code users' instructions read identically.

4. **Renaming `core/CLAUDE.md`.** Tempting for symmetry, and it breaks two things: `.lsa.yaml:61`
   lists it in `core`'s `artifact_paths`, and lint C15 greps the literal path. Mitigation:
   explicitly out of scope; the file keeps its name.

5. **`cursor-equal-support`'s pitch file is missing.** `.lsa/roadmap.yaml` links to
   `pitches/cursor-equal-support.md`, which **does not exist** — verified 2026-07-19. No gate
   catches it because `scripts/check-links.sh` excludes `^\.lsa/` from the files it checks, so the
   entire specs tree is a link-checking blind spot. That item's locked approach survives only as
   roadmap `notes` prose. Mitigation: treat it as needing reconstruction anyway; this pitch's
   re-scope note is the trigger. Widening `check-links.sh` to cover `.lsa/` is adjacent work,
   named here, not taken.

6. **The reference validator is an npm dependency in a repo that advertises a tiny trust
   boundary** — *"five pure-Markdown plugins plus one transparent SessionStart shell hook"*
   (`README.md` §Security). Wiring `skills-ref` into `.lsa.yaml`'s `gate:` block would put
   third-party Node code on the critical path and weaken a security claim to strengthen an
   interoperability one. Resolved at gate (Fork D): a one-off manual run whose output is cited as
   evidence; the gate block is untouched.

## No-gos

1. This pitch does NOT write `scripts/generate-for-cursor.sh` or implement any
   `cursor-equal-support` epic — it re-aims that item and stops.
2. This pitch does NOT publish a JSON Schema for `.lsa.yaml` or register it with SchemaStore
   (Fork C) — net-new capability for third parties, outside the consolidation posture that
   findings A and B sit inside.
3. This pitch does NOT run an LSA cycle in another tool. It makes the claim verifiable; proving it
   end-to-end in Cursor is `cursor-equal-support`'s job, post-re-shape.
4. This pitch does NOT change any skill's content, name, or directory — all 20 already conform
   (name↔dir 20/20, longest body 192 lines vs. the spec's recommended 500). Only what we *cite*
   about them changes.
5. This pitch does NOT seek external users or publish comparison content. `README.md`
   "Personal-use first" is unchanged; the observation file's §6 item 6 still holds.
