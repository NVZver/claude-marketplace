Shaped by: Nikita Zverev
Date: 2026-07-19
Status: approved
Role lens: developer-tooling product manager (dependency-management / staleness lens)
Gate decisions:
- Fork 1 (dogfood target): pin the **Claude Code platform surface** (`plugin.json` schema, `hooks.json`, `AskUserQuestion`, the `Agent`/`Skill` tools) as the one dogfood spec — a genuine versioned external dependency this repo consumes constantly and hallucinates about, and one that exercises the staleness path honestly.
- Fork 2 (config surface): a new `libs:` block in `.lsa.yaml` (`spec` + `manifest`), not a misuse of `modules:` / `artifact_paths`.
- Fork 3 (staleness detection): a `gate:` script only, so `lsa:verify` blocks GROUNDED on a stale pin. Smallest surface, hardest enforcement.
- Fork 4 (authoring surface): no new skill — authoring is a documented human-driven act using the existing library-documentation protocol plus a knowledge file for the format.
Posture: this item is net-new capability and sits OUTSIDE the consolidation posture set
2026-07-16. The owner explicitly approved shaping it on 2026-07-19, reopening expansion **for
this item only**. Consolidation remains in force for everything else.
Why now: the 2026-07-19 competitive pulse check flagged this as the one shrank-on-purpose item a
direct competitor (Tessl) has already shipped at scale — and it is the mature part of their
product while their generation framework is still closed beta.

# Pinned library specs for the top 3-5 dependencies

Write a version-pinned spec once for a repo's 3-5 most-used external libraries, make agents
read it before reaching for external docs, and make the system notice out loud when the
dependency moves off the pin — so a frozen spec cannot silently rot.

## Problem

LSA's handling of external libraries is entirely reactive today, and thinner than
`.lsa/VISION.md` §6 describes. VISION's before/after example claims discovery "records in a
Library Docs table" — **no such table exists in any skill**; the phrase appears nowhere else in
the repo. The real implementation is a four-step lookup protocol in
`lsa/knowledge/conventions.md` §"Library documentation protocol": check for `resolve-library-id`
(context7 MCP) → read the manifest for a version → `query-docs` → cite
`lib:<name>:<api> via context7`, with a `WebSearch` fallback and a "state it, never guess"
terminal case. There is no cache of any kind, per-session or otherwise. The work is redone every
feature.

Two failure modes follow. First, **repeated work**: the same Stripe or React lookup is re-fetched
every feature, paying latency the fast-path work
(`.lsa/pitches/fast-path-navigation-questions.md`) was specifically built to eliminate elsewhere.
Second, and worse, **the protocol's entry condition is the agent's own uncertainty** — it fires
"when any LSA skill needs to call a library API it is unsure about." Confident wrongness (a
hallucinated signature, an API that existed two majors ago) does not trigger the unsure-path and
can ship unchallenged. That is a direct hit on the system's stated product: "Trust is the product.
A fast wrong answer is a defect" (`.lsa/VISION.md` §2 principle 1). (Noted for accuracy: the same
section does say discovery skills "do this proactively", so the gap is narrower than pure
on-demand lookup — but there is still no cache, and no mechanism that challenges a confident
answer.)

`.lsa/VISION.md` §6 Adjust item 2 already analyzed this and reached a verdict: "do NOT build a
10,000-spec registry — that's their product. But write a pinned spec once for your 3-5 most-used
libraries. It's a module spec pointed at an external dep. Everything else stays reactive." The
roadmap row `library-spec-cache-for-top-3-5-libraries` has sat at `priority: Could,
status: backlog` with no pitch file since 2026-05-20. This pitch implements that verdict; it does
not reopen it.

Current workaround: every feature that touches a library re-runs the protocol from zero, and
confident-but-wrong API usage is caught only downstream — by `lsa:reconcile` if a scenario happens
to exercise it, by the implementer's own test run, or by the human in review. Often by none of
them.

Definition of success:
1. Between 3 and 5 pinned library specs exist in a repo, each stating the exact version it
   describes and covering only the symbols that repo actually calls.
2. An agent working on a feature that touches a pinned library reads the pinned spec and makes
   zero external fetches for symbols the spec covers.
3. When the dependency's pinned version no longer matches what the repo resolves, the system emits
   a finding **within one session** — a stale pin is loud, never silent.
4. On a stale pin, the agent falls back to the existing reactive protocol rather than trusting the
   stale file.

## Appetite

**Small batch, and the ceiling is fixed by the VISION verdict, not by this pitch:** 3-5
libraries, pinned once, authored by a human. That is the ceiling, not a starting point — no phase
two that grows the count. The tight appetite is a direct consequence of the posture exception
recorded in the header: this is a deliberate, bounded exception, so it must not become a
bridgehead.

In appetite: a file-format convention for a pinned library spec; a config surface that registers
pinned specs; a staleness check wired into machinery that already exists; one edit to the read
protocol so agents reach the pinned spec first; documentation of the authoring act.

Out of appetite: any registry, any crawler, any pre-validation pipeline, any auto-refresh, any
support for more than one version of a library at a time, and any change to how non-pinned
libraries are handled.

## Solution sketch

- **Key user interactions:**
  1. **Author (one-off, human-driven).** The human names a library they use constantly. The agent
     runs the existing library-documentation protocol once, at authoring time, and drafts a pinned
     spec scoped to the symbols this repo actually calls. The human reviews and commits it. The
     fetched content becomes a trusted in-repo document only by passing through that human review
     — it enters as untrusted data (`SECURITY.md`) and is promoted by a person, not by the agent.
  2. **Read (every feature, zero cost).** A feature touches a pinned library. The agent reads the
     local pinned spec — no fetch, no MCP call, no network.
  3. **Notice (the part that answers the rot problem).** The dependency is upgraded. The resolved
     version no longer matches the spec's pin. The system says so, names the library and both
     versions, and the pinned spec **demotes itself**: for the duration of the mismatch it is no
     longer authoritative, and the reactive protocol resumes. The human re-pins when they choose.

- **Main components:**
  - A pinned-spec file format and location under `${specs_root}` — a module-spec shape pointed at
    an external dep, per the VISION verdict. It carries a mandatory version assertion and a
    mandatory pointer to the manifest/lockfile entry that assertion is checked against.
  - A `libs:` registration block in `.lsa.yaml` (`spec` + `manifest`), per gate decision Fork 2.
  - A staleness check. This is the cheap part, because the drift machinery already exists and is
    deterministic: `.lsa.yaml`'s `gate:` block runs local bash with zero model calls,
    `lsa:verify` blocks a GROUNDED verdict on any non-zero gate exit, and a SessionStart hook
    already diffs each module against its spec's last-commit SHA and prints a one-line notice
    (`lsa/ARCHITECTURE.md` §3). A pinned library spec is the same pattern with a different watched
    artifact: not source globs, but the manifest line. Per `.lsa/VISION.md` §2 principle 10 this
    comparison is deterministic and belongs in a script the model cites.
  - One edit to `lsa/knowledge/conventions.md`: pinned specs slot into the read protocol ahead of
    the external-fetch step, conditional on a fresh pin.

- **Critical path:** human names a library → agent drafts the pinned spec from one authoring-time
  fetch → human reviews and commits → next feature reads local, fetches nothing → dependency
  upgrades → staleness script exits non-zero → verify blocks and the session hook announces it →
  pinned spec demotes, reactive protocol resumes → human re-pins. **The load-bearing link is the
  second half.** A pinned spec with no staleness check is worse than no pinned spec, because it
  converts an occasional wrong fetch into a permanent wrong local answer.

## Rabbit holes

1. **The read-order inversion — this is the sharpest risk.** `.lsa/VISION.md` §2 principle 6
   orders truth as in-repo config → in-repo docs → the code itself → external sources → ask the
   human. A pinned library spec is an in-repo doc that *represents* an external source, so it jumps
   the queue by construction. If it is stale, principle 6 now actively prefers a wrong answer over
   a fetchable right one — the pitch would have made the system worse at exactly the failure it set
   out to fix. Mitigation: the pinned spec's precedence is **conditional, not positional**. It
   ranks as an in-repo doc only while its version assertion verifies; on mismatch it drops below
   external sources and the reactive protocol resumes. Freshness is the price of precedence.

2. **Scope creep toward a registry.** "3-5" has no natural stopping point once the format exists.
   Mitigation: a hard cap enforced by a lint check in the C-series (`scripts/lint.sh`), failing
   above 5 pinned specs. Raising the cap then requires a deliberate, visible edit rather than
   drift.

3. **The pinned spec becomes a doc dump.** A full API surface is thousands of tokens loaded on
   every feature — a direct violation of `.lsa/VISION.md` §2 principle 5 (the map is not the
   territory) and a self-inflicted context-budget wound. Mitigation: the spec covers only the
   symbols the repo actually calls, capped at roughly one screen. It is a map, and anything off the
   map falls through to the reactive protocol.

4. **Version-range false negatives.** A manifest saying `^4.0.0` lets the installed version drift
   inside the range while the check reads green. Mitigation: check against the lockfile where one
   exists; where none exists, the check reports `[cannot verify]` rather than passing — an honest
   unknown, never a green light.

5. **Untrusted content becoming trusted instructions.** The spec's content originates from fetched
   external docs; `SECURITY.md` treats such content as data to report, never instructions to obey.
   A committed in-repo `.md` under `${specs_root}` is otherwise trusted instruction surface.
   Mitigation: the human-review-before-commit gate is the promotion boundary, and it is mandatory.
   No agent may author a pinned spec into the repo unreviewed.

6. **No conventional dogfood target in this repo.** Verified: the repo contains zero
   `package.json` files, and `mode: docs` means there is no `/src/`. There is no npm or pip
   dependency here to pin, and `.lsa/VISION.md` §1 makes dogfooding non-negotiable DNA. Resolved
   at gate: pin the **Claude Code platform surface** instead — a genuine versioned external
   dependency this repo consumes constantly (`plugin.json` schema, `hooks.json`,
   `AskUserQuestion`, the `Agent`/`Skill` tools), and one where a version mismatch is a real,
   observable failure mode. Note this makes the manifest pointer unconventional (there is no
   lockfile line to read), so rabbit hole 4's `[cannot verify]` path is the expected default for
   this first pin — the check must report that honestly rather than inventing a version source.

## No-gos

1. This pitch does NOT build a spec registry of any size beyond the 3-5 cap — that is Tessl's
   product, and `.lsa/VISION.md` §6 Adjust item 2 already ruled it out.
2. This pitch does NOT introduce any new external service or runtime network dependency. Fetching
   is an authoring-time act performed by the existing library-documentation protocol; reading a
   pinned spec is a local file read. Per `SECURITY.md`.
3. This pitch does NOT auto-refresh or auto-rewrite a stale pinned spec. Detection only; the human
   re-pins. Auto-rewriting the spec from a newly fetched doc would let the system silently decide
   on the human's behalf, against `.lsa/VISION.md` §2 sub-principle 1a (ownership over automation)
   and against Level 2.5's absorb-don't-automate posture.
4. This pitch does NOT replace the reactive protocol. `lsa/knowledge/conventions.md` remains the
   path for every non-pinned library and for every symbol a pinned spec does not cover — exactly as
   the VISION verdict specifies ("Everything else stays reactive").
5. This pitch does NOT support multiple versions of one library, or a version matrix. One library,
   one pin, one version.
6. This pitch does NOT re-litigate the `.lsa/VISION.md` §6 item-2 verdict, and it does NOT reopen
   the 2026-07-16 consolidation posture for anything other than this item.
