---
name: check
description: "Check roadmap hygiene and apply approved fixes. Input: none. Output: proposed row diffs (stale/inconsistent entries — missing pitch, status vs branch mismatch, merged-but-not-shipped) delivered and gated one by one via AskUserQuestion; only approved rows are written, each quoted inline. Runs inline — no agent dispatch. Reads ${specs_root}/roadmap.yaml on demand via scripts/roadmap-query.sh hygiene (whole-file read is fallback only)."
---

> **Trace.** On load, print first: `=============== [manager/skills/check/SKILL.md] [manager] ===============`


# Check

Check the roadmap for hygiene issues — stale rows, missing pitches, status/branch mismatches — and apply the fixes the user approves. **Runs inline in the invoking context; no agent dispatch.** The five hint classes are derived deterministically by `scripts/roadmap-query.sh hygiene`, so the only model work is judgment over the script's hints — which does not need a fresh context ([`../../../.lsa/standards/code.md`](../../../.lsa/standards/code.md) §*Dispatch efficiency*: *"Everything else — spec authoring, shaping, decomposition, recommendation, review, cited lookup — runs inline."*). The scan conditions themselves stay canon in [`../../agents/project-manager.md`](../../agents/project-manager.md) Steps 6-7, which still run there when hygiene rides along with Mode 1 sequencing.

## Goal

Keep the roadmap honest — flag rows whose observable state contradicts their status and apply the corrections the user approves — without the user manually auditing the roadmap, and without paying a fresh agent context to read a script's output.

## Input

- None required. The roadmap is the entry point; ambient state (roadmap, pitches, branches, specs) is read on demand.

## Steps

1. **Get the deterministic hints.** Run `bash scripts/roadmap-query.sh hygiene` — it emits all five hint classes (missing-pitch, backlog-but-branch, stale-in-progress, merged-not-shipped, no-artifacts) from the ledger + git with zero model tokens and no whole-file read. Only if it exits non-zero fall through to a model-side `Read` of `${specs_root}/roadmap.yaml`. Observable result: the script's hint list quoted, or an observable fall-through note.

2. **Confirm each hint before proposing it.** The hints are input, not verdicts ([`../../agents/project-manager.md`](../../agents/project-manager.md) Step 6). Confirm each against what the roadmap row and any linked pitch actually say; drop hints the context explains away; respect the **recency boundary** — a class-5 hint means *"nothing was ever created for this slug"*, never *"this item went stale"*. Observable result: a confirmed finding list, or the explicit statement that the roadmap is clean.

3. **Gate each row diff one by one.** For each confirmed finding, present previous row + proposed row — each quoted with `file:line` — via `AskUserQuestion` (approve / reject). Deliver the diff *inside the gate* so the user sees it ([`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7 *Delivery test*). Observable result: every proposed diff individually gated.

4. **Apply only approved rows, then show them.** Write approved rows to `${specs_root}/roadmap.yaml`; discard rejected ones. Quote each written row inline after writing — never *"roadmap updated"* without the row (Rule 7 *write → show → comment*). Observable result: each approved row written and re-quoted inline; rejected diffs discarded with nothing written.

## Output

Each proposed hygiene row diff is gated one by one; approved rows are written and quoted inline; rejected diffs are discarded. If the roadmap is clean, that is stated with the script output backing it. No handoff, no agent dispatch.

### Example Output

[illustrative]

```
=============== [manager/skills/check/SKILL.md] [manager] ===============

$ bash scripts/roadmap-query.sh hygiene
  class 2 (backlog-but-branch)  .lsa/roadmap.yaml:21  onboarding-checklist

1 hint; confirmed against the row + pitch (branch feature/onboarding-checklist is live).

Gate — .lsa/roadmap.yaml:21 onboarding-checklist (status backlog → in_progress): approve / reject
> approve
  Applied — .lsa/roadmap.yaml:21 onboarding-checklist | Onboarding checklist | Should | in_progress
```

## Constraints

- **Inline, not dispatched.** Hygiene is script-derived enumeration plus bounded judgment — neither is load-bearing isolation ([`../../../.lsa/standards/code.md`](../../../.lsa/standards/code.md) §*Dispatch efficiency*). Do not dispatch `project-manager` from this skill.
- **Script first.** The five hint classes come from `scripts/roadmap-query.sh hygiene`, never from a model-side scan of the ledger — per [`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) §2 principle 10.
- **Gate before write.** The roadmap is an approval-gated artifact: show → approve → write. Nothing is written before its gate; on reject, nothing is written.
- **Show changes inline.** Quote every row written — never "roadmap updated" without the row. Per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/manager:check` — manual invocation.
