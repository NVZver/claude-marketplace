# Epic 0 — Parallel-Agent-Delivery Prior-Art Spike

## Summary
Research spike (doc-mode, no code). Produce `.lsa/research/parallel-agent-delivery-prior-art.md`
consolidating prior art for each of the 6 components in the parallel-agent-delivery pitch, with a
build / borrow / hybrid verdict per component. Informs (does not block) Epics 1–4.
Source: `.lsa/roadmap.md:58` · pitch `.lsa/pitches/parallel-agent-delivery.md:31`

## Deliverable contract (required sections of the research doc)
1. **Header** — title, date, source pitch link, one-line purpose, doc-mode note.
2. **Method** — what was searched, how sources were rated (primary vendor docs > blog > inferred).
3. **Per-component findings** — one block per component (template below), 6 blocks total.
4. **Verdict roll-up table** — component | verdict | borrowed primitive | net new to build | Epic.
5. **Open questions / risks** — anything the research could not resolve, tagged for the relevant Epic.

## Per-component verdict template (fixed shape, applied to all 6)
- **Component N — <name>**
  - **Verdict:** Build | Borrow | Hybrid
  - **Prior art:** 2–4 sources, each `Source — "searchable quote"` (URL or file:line)
  - **Borrowed primitive:** the existing thing we integrate (or "none")
  - **Net-new to build:** the thin part we still author ourselves
  - **Reason:** one line
  - **Informs:** Epic 1 | 2 | 3 | 4 (which build epic consumes this)

## Functional requirements (doc-mode — about the artifact, not runtime behavior)
- R1. The doc SHALL contain exactly one findings block per pitch component (6 total), each following
  the verdict template. (pitch `:31`)
- R2. Each component block SHALL carry a Build/Borrow/Hybrid verdict and ≥2 cited sources with a
  searchable quote per source. (constitution §1 fact-grounding; `.lsa/VISION.md:37`)
- R3. No verdict SHALL rest on a vague claim ("looks mature", "widely used") without a cited quote.
- R4. The doc SHALL include the roll-up table mapping each component → verdict → Epic.
- R5. Components 1, 3, 5 SHALL explicitly assess the GitHub-native / lsa-stage-reports primitives the
  pitch already names (merge queue `merge_group`, branch-protection required checks,
  lsa-stage-reports contract). (pitch `:31,36,42`)
- R6. The doc SHALL live at `.lsa/research/parallel-agent-delivery-prior-art.md` (new dir).

## Out of scope
- No plugin/module code change (this is a research artifact; not in any `.lsa.yaml` module).
- No decision to build any Epic — the spike informs, does not commit (roadmap `:58`).
- No new report-contract invention — defer to lsa-stage-reports for shape (pitch rabbit-hole 7).
