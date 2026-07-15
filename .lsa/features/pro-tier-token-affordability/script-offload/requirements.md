# Epic pro-tier-token-affordability/script-offload — Requirements

Parent: ../../../pitches/pro-tier-token-affordability.md (WS3) · Status: approved · Date: 2026-07-15
Modules: lsa (verify + reconcile gate-run wiring), manager (next fast-path wiring). Repo-internal infra: `scripts/gate.sh`, `scripts/roadmap-row.sh`. Grounding: lsa:discover 2026-07-15.

## Functional requirements (EARS)

- **F1** (Ubiquitous) A repo-internal `scripts/gate.sh` shall run the `.lsa.yaml` `gate:` block as ONE
  deterministic pass — executing each configured check in order, printing `name → command → exit N`
  per check plus an aggregate line, exiting non-zero iff any check failed — with zero model calls.
  This is the *verify pre-pass* offload: verify/reconcile run one command instead of orchestrating
  each gate command model-side (pitch driver 4, WS3).
- **F2** (Ubiquitous) A repo-internal `scripts/roadmap-row.sh` shall print the first
  `backlog` / `not started` row of `${specs_root}/roadmap.md`'s `## Feature Backlog` table with its
  `path:line` citation, deterministically — the *roadmap-row extractor* offload of `manager:next`
  Step 0's model-side scan.
- **F3** (Ubiquitous) `scripts/gate.sh` shall read the check list from the `.lsa.yaml` `gate:` block
  (the single source of truth) — it shall **not** hardcode / duplicate the command list, so adding a
  gate check is a one-file `.lsa.yaml` edit (DRY; no drift). `gate.sh` is the runner, never a member
  of the block.
- **F4** (Event) When `lsa:verify` (Step 4) or `lsa:reconcile` (Step 1) runs the `gate:` block, it
  shall run it via the aggregate runner where the repo provides one (this repo: `bash scripts/gate.sh`)
  and cite its consolidated per-check command + exit; absent a runner it shall run each configured
  command (byte-for-byte today's behavior). The cited artifact is the per-check command + exit either way.
- **F5** (Event) When `manager:next` answers a plain "what's next" (Step 0 fast-path), it shall use the
  roadmap-row extractor where the repo provides one (this repo: `bash scripts/roadmap-row.sh`) to get
  the first backlog row + line, and quote its output; absent an extractor it shall locate the row
  model-side (`Read` roadmap.md) — today's behavior.
- **F6** (Ubiquitous) Both scripts shall be repo-internal (in `scripts/`, outside every plugin's
  `artifact_paths`) — Pro-safe local bash, zero model tokens — and therefore trigger **no plugin
  version bump** (same class as `scripts/lint.sh`); only the shipped-skill wiring bumps a plugin.
- **F7** (Unwanted) If `.lsa.yaml` has no `gate:` block, `gate.sh` shall report `NOT-RUNNABLE`
  (matching reconcile's contract) rather than crash; if the roadmap / `## Feature Backlog` anchor is
  missing or holds no backlog row, `roadmap-row.sh` shall exit non-zero so the skill falls through to
  its model-side path — never a hard error in either skill (`core/skills/ground-rules/SKILL.md` Rule 3).

## Acceptance criteria (journey-shaped)

- **AC1** (F1, F3) `bash scripts/gate.sh` ⇒ runs `docs-invariants` / `citations` / `links` from the
  `.lsa.yaml` block, prints each command + exit, and exits 0 when all pass; adding a `gate:` key makes
  it run that check too with no edit to `gate.sh`.
- **AC2** (F2) `bash scripts/roadmap-row.sh` ⇒ prints `.lsa/roadmap.md:13 — | Library-spec cache … |
  Could | backlog | … |` and exits 0.
- **AC3** (F5) `manager:next` Step 0 names the roadmap-row extractor and the model-side fallback.
- **AC4** (F4) `lsa:verify` Step 4 and `lsa:reconcile` Step 1 name the aggregate gate runner and the
  per-command fallback; the cited artifact stays per-check command + exit.
- **AC5** (F7) With no backlog row, `roadmap-row.sh` exits non-zero (fall-through); with no `gate:`
  block, `gate.sh` reports `NOT-RUNNABLE`.

## Design decisions (resolved at the 2026-07-15 spec gate)

- **D1** `gate.sh` parses the `gate:` block from `.lsa.yaml` (fixed 2-space-indent `name: command`
  lines under `gate:`), so the block stays the one source of truth (F3). No YAML library — the format
  is fixed and repo-owned.
- **D2** Convention-over-config wiring: the shipped skills reference the scripts by conventional path
  with a graceful model-side fallback — **no new `.lsa.yaml` schema key** — so a consumer without the
  scripts keeps today's behavior and no schema churn ships (backward-compatible).
- **D3** Owner plugins: `lsa` (verify + reconcile gate-run wiring) and `manager` (next fast-path
  wiring); each bumps SemVer + CHANGELOG + README in the same commit (`.lsa/standards/code.md:18-22`).
  The scripts carry no bump (F6).
- **D4** These are the two offloads the pitch names; no other pass is moved this epic (No scope creep —
  `core/skills/ground-rules/SKILL.md` Rule 4). Model-side spec-reference resolution (verify Step 1)
  stays model-judgment and is out of scope.

## Non-functional

- Zero model tokens on both scripts; deterministic; Pro-safe local bash (pitch WS3 "same Pro-safe
  pattern as the existing gate block", `.lsa.yaml:9-14`).
- Backward-compatible: absent scripts ⇒ both skills run their existing model-side paths unchanged.
- Reward-hacking safe: the epic does not alter any `.lsa.yaml` `gate:` command or `.feature` scenario
  that grades it — `gate.sh` only *runs* the unchanged block (`lsa/knowledge/quality-gate-contract.md`
  §"Independence rule").
