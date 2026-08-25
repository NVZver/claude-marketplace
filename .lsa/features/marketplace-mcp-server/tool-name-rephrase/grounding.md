Epic: marketplace-mcp-server/tool-name-rephrase
Verdict: GROUNDED
Date: 2026-08-25

## Reference map (`bash scripts/resolve-refs.sh`, representative sample)

All 25 rewrite-table locations and all 3 already-compliant citation lines
were spot-checked by symbol; every one resolves to an existing `file:line`.
A representative sample (one per file, plus both already-compliant files):

| Symbol | Resolution |
|---|---|
| `core/skills/output/SKILL.md:80` | exists |
| `lsa/agents/orchestrator.md:25` | exists |
| `lsa/skills/delegate/SKILL.md:42` | exists |
| `lsa/skills/verify/SKILL.md:26` | exists |
| `manager/agents/product-manager.md:53` | exists |
| `manager/agents/project-manager.md:19` | exists |
| `manager/skills/check/SKILL.md:23` | exists |
| `manager/skills/decompose/SKILL.md:20` | exists |
| `manager/skills/implement/SKILL.md:26` | exists |
| `manager/skills/next/SKILL.md:20` | exists |
| `manager/skills/shape/SKILL.md:7` | exists |
| `core/skills/flow-selector/SKILL.md:46` | exists (already-compliant, not touched) |
| `core/skills/ground-rules/SKILL.md:24` | exists (already-compliant, not touched) |

## Feasibility (per user flow)

- **Flow 1 (rewrite applied):** buildable — every line number was located
  via the discover-time grep dump and confirmed present; the after-text for
  all 25 entries is fully specified in `requirements.md`'s Rewrite table,
  leaving the implementer no discretion over wording.
- **Flow 2 (verification check):** buildable — a grep-based check
  distinguishing "unconditioned tool-name mention" from "`(<ToolName> in
  Claude Code)` citation" is a straightforward pattern-exclusion script,
  same technique already used by `scripts/lint.sh`'s existing checks.
- **Flow 3 (gate unregressed):** buildable — `bash scripts/gate.sh` already
  exists and runs today with the current (unmodified) tree; re-running it
  after the rewrite is a direct repeat of the same command.

No flow is infeasible on what exists.

## Assumptions

None beyond the rewrite-policy decision already recorded in
`requirements.md`'s header (confirmed this session, not carried as an open
`[ASSUMPTION]`).

## Gate (`.lsa.yaml` `gate:` block, docs-mode repo)

`bash scripts/gate.sh` (2026-08-25, pre-delegation, current tree):

```
PASS  docs-invariants  bash scripts/lint.sh → exit 0
PASS  citations        bash scripts/check-citations.sh → exit 0
PASS  links            bash scripts/check-links.sh → exit 0
PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
PASS  tests            bash scripts/run-tests.sh → exit 0
PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0
gate: PASS — every configured check exited 0
```

## Verdict

**GROUNDED.** Every cited reference resolves, all three flows are buildable,
and the gate block exits 0 on the pre-rewrite tree (the baseline the
implementer's diff will be compared against). Cleared for `lsa:delegate`.
