Shaped by: Nikita Zverev
Date: 2026-05-28
Status: draft
Why now: end-of-project user feedback flagged perf as "Terrible" — a 3-minute response to "what's next" is the dominant friction across daily marketplace use, and the same root cause already shipped a partial fix for Helper (`feedback_helper_latency.md`); generalizing it before more skills are added is cheaper than retrofitting later.

# Fast path for simple-navigation questions

Make `lsa:next`, `management:roadmap` "what's next", and Helper onboarding questions answer in seconds via direct read + cited quote — not deep grep, context7, or sub-agent dispatch.

## Problem

Every user of the marketplace hits this within the first hour. Asking "what's next" or "how do I get started" routes through a deep research loop (sub-agent dispatch, multi-round grep, context7 lookups) when the authoritative answer lives in a single file at a known path — `roadmap.md`, `README.md`, or `lsa/README.md`. The latency turns navigation into a multi-minute pause.

Evidence (user, 2026-05-28, verbatim): *"Performance - Terrible, sometimes a simple question like 'what's next' took 3 min to answer."*

Same root cause as the already-shipped Helper fast-path (`feedback_helper_latency.md`, `helper` v0.3.0): the agent treats every question as a research task even when the question maps deterministically to one source-of-truth file with one canonical answer. Helper got a 6-row catalog in `helper/knowledge/onboarding-fast-path.md`. `lsa:next` and `management:roadmap` got none.

Confirmed trace for `management:roadmap`: `management/skills/roadmap/SKILL.md:23` reads verbatim *"Invoke the `project-manager` agent via the `Agent` tool with no additional context — the agent reads ambient state itself"*. The skill unconditionally dispatches the full agent — there is no fast-path branch ahead of dispatch. The fix surface therefore covers BOTH the skill (add a fast-path branch *before* dispatch) AND `management/agents/project-manager.md` (add an early-exit fast-path inside, in case the user invokes the agent directly without the skill wrapper).

Current workaround: the user either waits 1-3 minutes per navigation question, or learns to manually open the roadmap file and skim it themselves — defeating the point of the skill.

Definition of success: a navigation-class question ("what's next", "what's the status of X", "how do I get started", "what is LSA") returns a cited answer in under 5 seconds of wall-clock time, with the same quote-back format Helper already uses. Deep research kicks in only when the source-of-truth file does not answer the question.

## Appetite

Small batch. Scope is *adding a fast-path branch* to three existing skills, not rebuilding them. The pattern already exists (`helper/knowledge/onboarding-fast-path.md`, `helper/agents/helper.md` Step 1.5) — this pitch replicates it for `lsa:next` and `management:roadmap`, and audits Helper's catalog for gaps surfaced by this feedback.

Out of appetite:
- Caching layer or persistent index over the roadmap.
- Re-architecting the sub-agent dispatch model.
- Performance work on the deep-research path itself (only the fast-path bypass is in scope).
- Adding fast-paths to skills outside the three named (lsa:next, management:roadmap, Helper).

## Solution sketch

- **Key user interactions:**
  - User runs `lsa:next` -> within ~5 seconds, sees the next backlog item quoted from `.lsa/roadmap.md` with a `file:line` citation. No sub-agent spawned, no context7 lookup, no multi-round grep.
  - User runs `management:roadmap` with "what's next" intent -> same shape, same latency.
  - User asks Helper "how do I get started" or "what is LSA" -> answer routes through the existing `helper/knowledge/onboarding-fast-path.md` catalog (already shipped); this pitch audits the catalog for missing rows surfaced by the new feedback.

- **Main components:**
  - **NEW shared knowledge file: `core/knowledge/fast-path-source-of-truth.md`** — single source of truth for the fast-path pattern. Documents: (a) the pattern shape (single-source-of-truth question → direct read + cited quote → no deep grep / no context7 / no sub-agent dispatch); (b) the question-shape detection discipline (exact-phrase match first, not semantic similarity); (c) the fall-through rule (any failure → existing deep-research path with no regression); (d) the citation format expectation (`file:line` quote-back). All three callers below cite this file as the shared contract.
  - `lsa/skills/next/SKILL.md` — new Step 0 (or equivalent) that reads `.lsa/roadmap.md` directly, finds the first `backlog` or `not started` row in the Feature Backlog table, and quotes it back with `file:line`. Cites `core/knowledge/fast-path-source-of-truth.md`. Falls through to existing logic only if the roadmap is missing, empty, or the question shape doesn't match.
  - `management/skills/roadmap/SKILL.md` — new fast-path branch inserted *before* the unconditional agent dispatch at line 23. For "what's next" question shape, return the cited roadmap row directly and exit; reserve the agent dispatch (and its richer dependency/risk/value reasoning) for explicit "recommend an order" / "what should I pick" questions. Cites `core/knowledge/fast-path-source-of-truth.md`.
  - `management/agents/project-manager.md` — add an early-exit fast-path inside the agent itself, so users who invoke the agent directly (bypassing the skill wrapper) also get the cited-quote shortcut for the "what's next" shape. Cites `core/knowledge/fast-path-source-of-truth.md`.
  - `helper/knowledge/onboarding-fast-path.md` — review the 6-row catalog for missing patterns surfaced by the latest feedback; add rows if gaps exist. Add a back-cite to `core/knowledge/fast-path-source-of-truth.md` for the pattern's general statement.

- **Tasks (ordered):**
  1. Write `core/knowledge/fast-path-source-of-truth.md` (the shared pattern doc) FIRST — all subsequent edits cite it.
  2. Update `lsa/skills/next/SKILL.md` — add Step 0 fast-path; cite the shared knowledge file.
  3. Update `management/skills/roadmap/SKILL.md` — insert fast-path branch before the line-23 unconditional dispatch; cite the shared knowledge file.
  4. Update `management/agents/project-manager.md` — add early-exit fast-path inside the agent; cite the shared knowledge file.
  5. Update `helper/knowledge/onboarding-fast-path.md` — audit catalog, add missing rows, back-cite the shared knowledge file.

- **Critical path:** write shared knowledge doc -> detect navigation-class question shape -> resolve to source-of-truth file -> direct Read + quote -> return with `file:line` citation. If any step fails, fall through to the existing path (no regression).

## Rabbit holes

1. **Question-shape classification.** Misclassifying a deep-research question as fast-path returns a stale or wrong answer cheaply, which is worse than the slow correct answer. Mitigation: pattern match on exact phrases first ("what's next", "what should I work on next", "how do I get started"), not semantic similarity. Unknown phrasing falls through to the existing path. The Helper fast-path catalog uses this discipline already; the new shared knowledge doc encodes it.

2. **Roadmap format drift.** `lsa:next` parsing `.lsa/roadmap.md` directly couples the skill to the roadmap's markdown table format. If the format changes (column rename, table-to-list migration), the fast-path breaks silently. Mitigation: cite the exact heading anchor (`## Feature Backlog`) and column position; if either is missing, fall through to existing logic with an observable warning. Tie the format to the roadmap structure documented in `management/knowledge/`.

3. **Latency target verification.** "Under 5 seconds" is the user-visible goal but is not measurable without instrumentation. Mitigation: rely on observed wall-clock at the verify gate (the user noted ~3 min baseline and ~5s for Helper's existing fast-path — the same shape should yield the same ballpark). Defer formal metrics to the Self-eval harness backlog row.

## No-gos

1. This pitch does NOT cover adding fast-paths to skills outside `lsa:next`, `management:roadmap`, and Helper — other skills can adopt the pattern in their own pitches once the shared knowledge doc exists.
2. This pitch does NOT cover caching, indexing, or any persistent state — the fast-path is a direct file read on every call.
3. This pitch does NOT cover the deep-research path performance (sub-agent dispatch, context7, multi-round grep) — those remain unchanged for genuine research questions.
4. This pitch does NOT cover Helper's command-router refactor (already shipped, `helper` v0.3.0) — this pitch consumes that pattern rather than re-doing it.

## Open questions

1. For Helper's existing 6-row catalog: are there rows missing that would have answered the user's "what's next" question if asked of Helper instead of `lsa:next`? (i.e., is the catalog incomplete for navigation-class questions?) — resolve during the catalog audit task.
