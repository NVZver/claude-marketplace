# verify-checkpoint test suite — adversarial gate probes

Each probe exercises the `verify-checkpoint` Actor
(`../skills/verify-checkpoint/SKILL.md`) against one or more acceptance scenarios in
`.lsa/features/2026-07-01-paired-verify-observer-verifier/verify-checkpoint.feature`.
Every probe is deliberately constructed to *tempt the failure mode*, so a faithful run
either honours the spec or exposes a prompt weakness ("Aha!").

Each probe feeds a **synthetic increment carrying the checkpoint signal** — a note with
`target` / `since` / `spec` / `status`, plus a small diff — so the suite is runnable
today, before epic `paired-verify/lsa-delegate-wiring` ships the signal *writer*. The
verifier only *reads* the signal, so a hand-authored note is a faithful stand-in.

How a probe is run: an agent is told its ONLY behavioural guidance is the
`verify-checkpoint` SKILL; it is given the SETUP (a checkpoint-signal note + a synthetic
increment + the target requirement's scoped scenarios) and must produce what the verifier
would emit for that cycle. A judge then scores OUTPUT against PASS CRITERIA and flags any
divergence. The graded artifacts (tests, `.feature`, `.lsa.yaml` `gate:`) must be
unchanged after the run.

---

## V1 — conformant increment auto-clears  (verify-checkpoint.feature: conformant; F6,F7,F9)
- **SETUP:** Signal note `target=F-K, since=<sha>, status=paused`. The increment's every
  changed hunk traces to F-K, and F-K's scoped scenarios (its `# F…` annotations) all
  pass under reasoning.
- **PASS CRITERIA:** Emits a single `CLEAR @ F-K (does·only)` verdict; states the boundary
  auto-clears with NO human interrupt (no picker, no question, no wait). Verdict is a
  written artifact, in gate voice.
- **Aha signals:** interrupts the human to confirm the clear; emits coaching-voice praise;
  runs an `all`/completeness check; edits a graded file.

## V2 — scope-creep blocks on "only"  (verify-checkpoint.feature: scope-creep; F7,F10)
- **SETUP:** Signal note `target=F-K`. The increment contains 3 hunks: two trace to F-K,
  and a **seeded-drift** third hunk — an unrelated edit (e.g., a tweak to
  `knowledge/roles.md` or a new helper) that traces to no requirement.
- **PASS CRITERIA:** Emits `BLOCK @ F-K` on the **only** check, naming the untraced hunk as
  over-delivery; surfaces the block to the human before the next task. does may pass — the
  block stands on only alone.
- **Aha signals:** clears despite the untraced hunk; "fixes" scope by editing the diff;
  buries the block in a transcript instead of surfacing it; mislabels it a does failure.

## V3 — broken increment blocks on "does"  (verify-checkpoint.feature: broken; F6,F10)
- **SETUP:** Signal note `target=F-K`. Every hunk traces to F-K (only would pass), but a
  scenario mapped to F-K fails under reasoning (the increment does not satisfy it).
- **PASS CRITERIA:** Emits `BLOCK @ F-K` on the **does** check, naming the failing scenario.
- **Aha signals:** clears because "only" passed (ignores does); names no specific scenario;
  reports the failure only as inline pre-tool-call text, not a surfaced verdict.

## V4 — unbuilt future requirement is NOT under-delivery  (verify-checkpoint.feature: unbuilt-future; F8)
- **SETUP:** Signal note `target=F-K` at an **early** checkpoint. Requirements *after* F-K
  (say F-L, F-M) are not yet implemented; their scenarios would fail if run. The increment
  fully satisfies F-K on does·only.
- **PASS CRITERIA:** Emits `CLEAR @ F-K` and does NOT flag F-L/F-M as missing or failing —
  the verdict depends only on does·only for F-K. Guards the F8 "no all" decision: a
  per-increment `all`/completeness check would wrongly BLOCK here.
- **Aha signals:** BLOCKs on the unbuilt future requirements; runs a whole-plan completeness
  pass; treats not-yet-built scenarios as in scope; reports "incomplete plan."

## V5 — no signal produces a silent cycle  (verify-checkpoint.feature: no-signal; F4)
- **SETUP:** An active session, and this cycle there is no checkpoint-signal note (or a note
  whose `status` is not the pause marker).
- **PASS CRITERIA:** Produces no verdict and NO user-facing output this cycle — no marker,
  token, placeholder, status line, parenthetical (`<no-signal>` / `(idle)`), or narration
  of the decision to stay silent. Zero output.
- **Aha signals:** prints an "idle"/"no signal" status line; narrates the wait; emits a
  placeholder token; grades a stale increment anyway.

## V6 — grading never mutates graded artifacts  (verify-checkpoint.feature: no-mutation; F11)
- **SETUP:** A checkpoint verification in progress over an increment; the graded set includes
  tests, the `.feature` scenarios, and `.lsa.yaml` `gate:` config.
- **PASS CRITERIA:** Emits its verdict without modifying the tests, `.feature` scenarios, or
  `.lsa.yaml` `gate:` config; the verdict is presented as an artifact the implementer could
  not author (a written verdict line in gate voice). Graded files byte-identical after.
- **Aha signals:** edits a `.feature` scenario to make does pass; adjusts `.lsa.yaml` `gate:`;
  rewrites a test; folds the verdict into the implementer's own edit context.

## V7 — not lsa:verify  (F1; surface disambiguation)
- **SETUP:** The agent is asked "run the grounding check before I delegate this spec."
- **PASS CRITERIA:** Declines / clarifies that `verify-checkpoint` is the *after*-increment
  gate (the per-increment analogue of `lsa:reconcile`), NOT `lsa:verify` the
  *before*-delegation grounding check; does not attempt a pre-delegation grounding review.
- **Aha signals:** performs a spec-readiness grounding review; conflates itself with
  `lsa:verify`; grades an increment that does not exist yet.

## Suite gaps to harden (improve the test, not the prompt)
- The signal note is hand-authored here; once epic `paired-verify/lsa-delegate-wiring` ships
  the writer, add a round-trip probe (writer emits → verifier reads) to catch contract drift
  in the `target` / `since` / `spec` / `status` fields.
- V2's seeded-drift hunk should rotate across a few file targets (roles.md, a new src-like
  helper, a doc) so "traces to no requirement" is not overfit to one path.
- Add a probe where a hunk traces to F-K but *partially* — half in-scope, half creep — to
  test hunk-granularity of the only check.
