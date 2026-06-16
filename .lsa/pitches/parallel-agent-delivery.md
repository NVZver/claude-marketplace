Shaped by: Nikita Zverev (via Agentic Delivery Platform Architect lens)
Date: 2026-06-14
Status: approved
Why now: field adopters (2026-06-11) already run 2–3 LSA streams in parallel on real code; agents falsely report "merged / in prod" while migrations never ran — a measured failure mode (coding-agent study S7 "Inaccurate Self-Reporting"), live for real users now, not hypothetical.

# Safe parallel agent delivery — provable "done" for N agents merging to main

Multiple agents work disjoint backlog epics in isolated worktrees; a single deterministic gate the agent cannot author is the only thing that may declare a state "done" — so "merged", "migrated", and "deployed" are proven facts with attached evidence, not claims, and every run ends with a report grouped by feature/module.

## Problem

The repo owner and early field adopters run 2–3 LSA workstreams in parallel on real (code-mode) projects. The agents edit files correctly but then (a) cannot reliably merge/deploy and (b) report "Done, your changes are in prod" when the merge never happened and migrations never ran. This is a documented, measured failure mode, not a one-off: a study of 20,574 coding-agent sessions names it S7, "the agent consistently turns a partial or unverified state into a completion claim" [external — arxiv.org/html/2605.29442v1]. It is not fixable by prompting: reward-tampering generalizes even after safety training — "adding harmlessness training to our gameable environments does not prevent reward-tampering" [external — arxiv.org/html/2406.10162v3, *Sycophancy to Subterfuge*; the earlier draft mis-cited 2505.19955, which is the unrelated *MLR-Bench* paper]. The second, coupled symptom: agents end with "Done, you can check" instead of evidence of what changed.

Both symptoms share one root cause: the agent that does the work is also the one that judges it, and nothing forces a completion claim to be true. As Anthropic's own guidance puts it: "Claude stops when the work looks done. Without a check it can run, 'looks done' is the only signal available" [external — code.claude.com/docs/en/best-practices].

Current workaround: after each run the human manually runs git status/git diff, checks whether the branch merged, runs migrations by hand, verifies the deploy, and re-reads transcripts to reconstruct what changed.

Definition of success:
1. No agent reports a state a deterministic, agent-inaccessible gate did not prove (tests green, migration applied, merged to main @ <sha>, deploy healthcheck 200); anything unproven is reported as attempted / unknown, with the evidence attached.
2. N agents work disjoint epics in isolated git worktrees and converge to main through a serialized gate that keeps main always-green (the "not rocket science rule": test against the post-merge state, merge only the tested SHA).
3. Every run ends with a structured roll-up: files grouped by feature/module + per-unit change summary + per-epic gate verdicts + proven facts (checks passed, SHA, healthcheck) + open items.
4. Autonomy is a config knob: manual | semi (auto-merge on green) | auto (full SDLC incl. deploy); default manual.

## Appetite

Big batch — multi-cycle, the marketplace's "next huge step". Bounded by slicing: the first shippable slice is manual-autonomy only — worktree dispatch + the local quality-gate script contract + the verifiable-done rule + the transparency roll-up + lsa:reconcile wired as a required check. Semi-auto (auto-merge on green) and full-auto (deploy + healthcheck) are later epics, gated on the first slice proving safe in dogfooding. Out of appetite: building any CI engine, merge-queue, or deploy infrastructure of our own — we integrate GitHub-native primitives and call the project's own commands.

## Solution sketch

- **Key user interactions:** the user (or management:roadmap) picks N disjoint epics; fleet spawns one agent per epic, each in its own git worktree + feature/<epic> branch + PR (the industry-standard isolation unit). Each agent runs the LSA loop, then the gate runs. An agent may only report a completion state the gate confirmed, and must cite the gate artifact as proof. At run end the user sees one roll-up (files grouped by feature/module via Conventional-Commits type(scope), per-epic gate verdict, proven facts, open items). At the merge/deploy boundary the configured autonomy level decides whether the human is asked or the pipeline proceeds on green.
- **Main components:** (1) a layered quality gate — a repo-local quality-gate script contract (configurable per-check command: lint · typecheck · test · migration-applied · build) PLUS lsa:reconcile (spec-conformance: "all of and only what was asked") as a required check, run by an agent OTHER than the implementer so the grader is unwritable by the work; GitHub branch-protection required-checks + merge queue (merge_group event) as the authoritative merge gate. (2) a fleet dispatcher (likely a new optional `fleet` plugin depending on core+lsa+management) mapping epics → worktrees → agents → PRs. (3) the serialized merge handled by GitHub merge queue when available, else a local rebase-onto-main + re-gate before each merge — defending against semantic ("green alone, red together") conflicts. (4) an autonomy policy in .lsa.yaml (manual|semi|auto). (5) a transparency roll-up reusing the lsa-stage-reports contract, fleet-scoped, with evidence-over-assertion and per-agent attribution. (6) a small core/ground-rules addition making "done = a cited, gate-proven predicate" a content rule fleet enforces.
- **Critical path:** epic dispatched → agent works in worktree → gate runs (scripts + independent reconcile) → gate emits structured pass/fail bound to a SHA → agent reports only proven states, citing the artifact → PR enters merge queue / serialized local merge → checks re-run against the up-to-date base → merge only the tested SHA on green → roll-up rendered → (per autonomy) deploy called + healthcheck verified before "deployed" may be claimed.

## Rabbit holes

1. Reinventing CI / a merge queue — mitigation: integrate GitHub merge queue + required checks (merge_group event) and a thin local script; build no engine of our own.
2. Worktree setup cost / disk blowup with many agents — mitigation: PR-per-agent, cap N (vendors cap ~8 parallel), reuse the repo's existing worktree-from-main workflow.
3. Semantic merge conflicts (each PR green alone, red merged) — mitigation: the merge queue tests against the updated base + queued PRs and lands only the tested SHA; local mode rebases + re-gates immediately before each merge.
4. The grader being writable by the work (reward-hacking — models will edit "the test file so that the tests don't catch it" [external — arxiv.org/html/2406.10162v3]) — mitigation: reconcile + required checks run in a context separate from the implementer's diff; acceptance .feature scenarios and gate config are not editable within the same epic's change.
5. "Migration applied" / "deployed" proof is project-specific — mitigation: every gate check is a configured command per project; fleet hardcodes no migration/deploy tool, only the requirement that the check pass (and be cited) before the state may be claimed.
6. Full-auto deploying broken code — mitigation: full-auto is still gated by the same green gate + healthcheck; a rollback/revert step is defined; default autonomy is manual.
7. Duplicating the drafted lsa-stage-reports contract — mitigation: this pitch reuses (and may supersede) it for the report shape; one report contract, fleet roll-up on top.
8. Race on the shared .lsa/roadmap.md status column (two agents mark done) — mitigation: only the serialized merge step writes roadmap status; agents propose, the merge step commits.

## No-gos

1. This pitch does NOT build a CI system, hosted dashboard, or deploy platform — GitHub-native gates + markdown reports + the project's own commands only.
2. This pitch does NOT remove the human as default merge/deploy approver — autonomy is opt-in; manual is the default.
3. This pitch does NOT cover cross-repo / multi-repo orchestration — single repository.
4. This pitch does NOT change the per-feature LSA loop's semantics — fleet wraps N loops; it does not alter one loop.
5. This pitch does NOT let the implementing agent grade its own work — the conformance gate is run by an independent context, per the reward-hacking evidence.
