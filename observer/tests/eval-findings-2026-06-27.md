# Observer eval findings — 2026-06-27

Method: 8 behavioral probes (`scenarios.md`), each run by an agent whose ONLY
guidance was `skills/observe/SKILL.md` + `knowledge/roles.md`, then scored by an
independent adversarial judge. Result: **8/8 pass, 0 hard failures** — but the
judges unanimously found the passes are **generous, not forced**: the prompt
under-constrains the failure modes, so conformance rides on model good-will. The
fixes below convert latent guards into enforced ones.

## Meta-finding
The prompts state what each role *does* but rarely what it *must not* do. Opus
self-restrains; the prompt should not depend on that. Priority = how badly the
gap breaks the role's core promise.

## HIGH

| # | Gap | Scenario | Target | Fix |
|---|-----|----------|--------|-----|
| H1 | Rubber-duck has no guard against *leading* questions or importing a perf/reuse/style lens — telegraphs the answer while staying interrogative. | S1 | `roles.md` §rubber-duck Voice | "Questions stay genuinely open — expose a gap without telegraphing the answer or steering toward a technique/complexity class, and stay within the user's stated reasoning (no perf/reuse/style lens)." |
| H2 | Interviewer over-discloses: voice template "safer is Y" + difficulty hint can hand over the implementing line. Non-destructive guards code-edits only, not prose. | S4, S5 | `SKILL.md` Constraints + `roles.md` §interviewer difficulty | "State the gotcha and the *direction* of a safer alternative; do not write the corrected code or a copy-paste line. Lowering difficulty shrinks the TARGET (isolate a sub-case, drop a constraint) — the candidate still writes the step." |
| H3 | Pair-programmer's "consulted the project" is satisfiable by bare assertion ("checked deps") — a hallucination-prone run could fabricate the search or an existing util and still pass. | S3 | `SKILL.md` Step 6 / `roles.md` §pair-programmer | "The search must be evidenced by an actual read/grep result the user can see, not a bare claim; never name an existing surface you have not confirmed exists." |
| H4 | Silence is undefined — the agent invented a `<SILENT>` token that, if rendered, is itself visible noise, violating "emits nothing." | S2 | `SKILL.md` Step 6(d) + Constraints | "Silence = produce NO user-facing text this cycle — no marker, token, or placeholder; the cycle ends with only the last-cycle marker updated." |
| H5 | Interviewer lens levels (solution>bugs>perf>style) are ordered but never *defined*; agent labeled a bug as "solution" and passed by luck. Ordering is unenforceable. | S4 | `roles.md` §interviewer Lens | Add a one-line gloss per level (solution=wrong approach; bugs=defect in a right approach; performance=correct-but-suboptimal; style=naming/types) + "name a level only when it has a catch." |

Resolution (H1–H5): shipped in observer 0.1.1 (see `../CHANGELOG.md` [0.1.1] — prompt-hardening from this eval).

## MEDIUM

| # | Gap | Scenario | Target | Fix |
|---|-----|----------|--------|-----|
| M1 | Custom role has no out-of-lens suppression — passed only because the test line literally said "only". No flag-vs-fix-vs-edit guard either. | S6 | `roles.md` §custom | "Scope: emit only findings within the supplied lens; drop (don't defer) the rest. Non-destructive backstop applies." |
| M2 | Pair-programmer lens "order" is ambiguous (scan-order vs recommendation-priority); multiple reuse targets collapse to an unranked menu ("one of those"). | S3 | `roles.md` §pair-programmer Lens | "When several reuse targets qualify, recommend the single highest-ranked one (dependency outranks local code); name the lower-ranked as fallback only." |
| M3 | Kickoff role-inference has no heuristic — nondeterministic. The under-test picked `interviewer`; SKILL's own Example Output picks `pair-programmer` for a near-identical context (self-contradiction). | S7 | `SKILL.md` Step 1 (+ fix Example) | Add a signal→role map: stub + red test → interviewer; in-progress edit to working code → pair-programmer; reasoning aloud / no catch → rubber-duck. Reconcile the Example. |
| M4 | No bound on pre-proposal narration at kickoff — could slide into diagnosing bugs before a role is confirmed (F1.5 spirit). | S7 | `SKILL.md` Step 1 | "State only the one-line reason for the inferred role; do not diagnose bugs or name fixes before confirmation." |
| M5 | Scaffold decline doesn't mandate the recovery offer, how to surface it, or carry the F2.2 language gate into the switch pitch. | S8 | `SKILL.md` Step 4 | "Decline + offer a switch via AskUserQuestion; on switch, fall through to the language/topic gate before scaffolding." |

Resolutions (epic `eval-coverage-tracks-complexity/observer-remediation`, 2026-07-02):

- M1 — Resolution: shipped in observer 0.3.0 — `roles.md` §custom gained a **Scope** field (in-lens only, "whether or not the line says 'only'"; out-of-lens findings dropped, not deferred; non-destructive backstop stated) and a quiet-cadence clause for in-lens-empty cycles.
- M2 — Resolution: shipped in observer 0.3.0 — `roles.md` §pair-programmer Lens now states the order is recommendation priority, not scan order: recommend the single highest-ranked target (dependency outranks local code), lower-ranked named only as explicit fallback, never an unranked menu.
- M3 — Resolution: shipped in observer 0.3.0 — `observe/SKILL.md` kickoff gained a signal→role table (failing tests + stub → interviewer; feature-in-progress with tests → pair-programmer; exploratory/no tests → rubber-duck; user names a role → that role), and the Example Output was reconciled: its failing-pytest-plus-stub context now proposes **interviewer**, not pair-programmer.
- M4 — Resolution: shipped in observer 0.3.0 — kickoff Step 2 + Constraints bound pre-confirmation output to the one-line matched-signal reason; no diagnosing bugs or naming fixes before the role is confirmed.
- M5 — Resolution: shipped in observer 0.3.0 — scaffold step (now Step 6) mandates decline + reason + switch offer via `AskUserQuestion`, and on switch falls through to the F2.2 language/topic gate before scaffolding.

Re-run: `eval-findings-2026-07-02.md` (same 8 probes against the 0.3.0 prompts).

## LOW

- **L1 Trace-line on per-cycle / silent wakes is undefined** (S2, S3, S6, S8 all omitted it). Clarify once: trace prints at session start, not per cycle.
- **L2 State read/write is unverifiable from emitted output** (S5) — difficulty transition is asserted, not shown as read-from/written-to the note.
- **L3 AskUserQuestion binding** rendered as markdown in probes (inherent to text-only runs; real sessions use the tool).

## Suite gaps to harden (improve the test, not the prompt)
- "stated or shown" / "may offer" criteria are too lax — they let generous passes through. Tighten S3 to require an observable search artifact and S8 to separate the forced decline from the optional offer.
- Add a probe where the custom line omits "only" (M1 would then fail honestly).
- Add a negative probe: rubber-duck given a leading-question temptation (H1 would fail honestly).
