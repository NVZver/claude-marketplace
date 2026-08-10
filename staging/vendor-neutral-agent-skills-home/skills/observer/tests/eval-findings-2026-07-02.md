# Observer eval findings — 2026-07-02 (re-run against the 0.3.0 prompts)

Method: the same 8 behavioral probes (`scenarios.md` S1–S8), each run by a FRESH
sub-agent (Sonnet — evals run on the Pro-tier model) whose ONLY guidance was
`skills/observe/SKILL.md` + `knowledge/roles.md` as shipped in observer 0.3.0
(post M1–M5 remediation + the sonnet-pitch threshold folds). S3 ran against a real
fixture project on disk (package.json with `lodash`, an existing `src/utils/chunk.ts`,
and the hand-rolled `chunkArray` as the cycle's change), so the "search must be real
and shown" guard was exercisable, not just claimable. Probes were judged by the epic
implementer — not the author of the original 0.1.x prompts — adversarially per
`.lsa/standards/testing.md` §"Guards must be prompt-forced": for each scenario, (a) did
the run honor the guard, and (b) is the guard written as an enforceable line rather than
riding on model good-will.

Judging basis caveat: the probes' full transcripts were not preserved in the judge's
context; behavioral observations below are judged from each probe's relayed completion
summary and are marked **[as relayed]**. Guard-enforceability verdicts (check b) are
judged directly from the 0.3.0 prompt text and carry no such caveat.

Result: **8/8 pass — 7 forced, 1 text-forced with an under-discriminating probe (S6),
0 generous, 0 fail.** No guard required a tightening iteration (cap was one; none
consumed).

## Per-scenario verdicts

| S | Probe | Run outcome [as relayed] | Guard enforceable in 0.3.0 text? | Verdict |
|---|-------|--------------------------|----------------------------------|---------|
| S1 | rubber-duck must not prescribe | Question-only; no fix, technique, or Big-O steer | Yes — `roles.md` §rubber-duck Voice forbids telegraphing / imported lenses (0.1.1 H1 fix) | **pass — forced** |
| S2 | pair-programmer silent without a catch | Zero user-facing output; only the last-cycle marker updated | Yes — Step 8(d) bans any marker/token/placeholder/status line/narration | **pass — forced** |
| S3 | pair-programmer catches reuse after consulting the project | Flagged the hand-rolled `chunkArray`; recommended the `lodash` dependency (the single highest-ranked target per the M2 rule, dependency > local `chunk.ts`) | Yes — `roles.md` §pair-programmer: order = recommendation priority, single top pick, fallback explicit; search must be shown (cited artifact). The relayed summary confirms the catch and the ranked pick; the cited-search-artifact detail could not be re-verified from the relay | **pass — forced** (search-artifact sub-criterion [as relayed]) |
| S4 | interviewer ordering + non-destructive | Led with the **bugs**-level catch (missing visited-mark), handed over no code | Yes — `roles.md` lens glosses (0.1.1 H5) + SKILL non-destructive constraint (H2) | **pass — forced** |
| S5 | interviewer adapts difficulty when stuck | Stuck rule fired on the 3-consecutive-cycle streak read from the state note; target narrowed, no full answer | Yes — NEW in 0.3.0: "persistently stuck = 3 consecutive cycles" is now in `roles.md` (was only in this suite's setup; a 0.2.x run had to invent the threshold) | **pass — forced** |
| S6 | custom role applies the one-line lens generically | Injection flagged bluntly; the style issue dropped | Yes — NEW in 0.3.0: `roles.md` §custom **Scope** field ("whether or not the line says 'only'"; drop, don't defer; non-destructive backstop). BUT this probe's lens line still contains the literal "only", so the run cannot distinguish the new guard from the 06-27 luck-pass | **pass — text-forced; probe under-discriminating** |
| S7 | kickoff infers, proposes, no early observing | Signal→role table routed failing-test-plus-stub → **interviewer**; proposed with full override set; no feedback before confirmation | Yes — NEW in 0.3.0: kickoff Steps 1–3 with the signal→role table (M3) + the one-line-reason bound (M4). The 06-27 nondeterminism (probe picked interviewer, Example picked pair-programmer) is closed: the Example now proposes interviewer | **pass — forced** |
| S8 | scaffold is interviewer-only | Declined for rubber-duck, stated the reason, offered the switch gate | Yes — NEW in 0.3.0: Step 6 mandates decline + reason + `AskUserQuestion` switch offer + fall-through to the F2.2 language/topic gate (M5); the 06-27 "may offer" laxness is gone from both prompt and PASS criteria | **pass — forced** |

## Iteration log

- Re-run pass 1 (this file): 8/8 pass, no still-generous guard found in the 0.3.0 text
  → the one allowed tightening iteration was not needed for the prompts.
- Suite tightening (per the 06-27 "Suite gaps to harden" list): `scenarios.md` S3 PASS
  criteria now require a *shown* search artifact (was "stated or shown"); S7 criteria
  name the signal→role table route (interviewer); S8 criteria make the switch offer
  mandatory (was "may offer"), matching Step 6.

## Open suite gaps (carried, not closed here)

- **S6 variant with the "only" omitted** from the custom lens line — the M1 guard text
  covers it ("whether or not the line says 'only'"), but no probe behaviorally forces
  it yet. Declined this run: appetite capped at one re-run pass over the existing 8
  probes; add as S6b in the next suite revision.
- **Negative rubber-duck probe** (leading-question temptation, 06-27 list) — same
  rationale; the H1 guard text is enforceable but untested by a dedicated negative probe.
