# Grounding — always-on-card (verify, before-check, 2026-07-15)

Verdict: **GROUNDED**

## Reference map

| Spec reference | Status |
|---|---|
| Always-on fragment (card's predecessor) | exists @ `core/CLAUDE.md:1-37` (opt-in fragment, `:5`) |
| Four always-on mandates the card replaces | exist @ `core/CLAUDE.md:11` (ground-rules), `:15` (output), `:26` (flow-selector), `:37` (reuse-first) |
| Eight ground rules (F1 card content) | exist @ `core/skills/ground-rules/SKILL.md:13` ("Eight content rules, numbered 0–7") |
| Hard output rule + file-load trace (F1, F8) | exist @ `core/skills/output/SKILL.md:23-26` |
| Re-grounded-summary licence (F1 legality) | exists @ `core/skills/output/SKILL.md:8` — "Re-grounded summaries … permitted only when they cite this file by link" |
| Probe D2 (AC4) | exists @ `core/tests/repo-anchored.md` (named by `output/SKILL.md:8`) |
| Flow labels + five boundary signals (F1) | exist @ `core/skills/flow-selector/SKILL.md:13-17,30`; `core/CLAUDE.md:28` |
| Reuse ladder pointer (F1, D3) | exists @ `core/CLAUDE.md:37`; skill 54 lines untouched per D3 |
| Read protocol to amend (F4, D2) | exists @ `lsa/knowledge/conventions.md:29-39` ("(mandatory)" @ `:34`) |
| Constitution (digest source, F6) | exists @ `.lsa/VISION.md` (278 lines; `wc -l` 2026-07-15) |
| `reconcile.runs` guidance source (F1) | exists @ `.lsa.yaml:20-24` (comment block documents default 3 + escape hatch) |
| Gate block (F5 harness) | exists @ `.lsa.yaml:15-18`; `scripts/lint.sh` present with C1-C11 |
| The card itself | **new** — replaces `core/CLAUDE.md` fragment content, ≤45 lines |
| `.lsa/VISION-digest.md` | **new** — path is `[ASSUMPTION D1]` per requirements.md |
| Digest-generation script + lint staleness check | **new** — deterministic derivation constraint: structural extraction only (headings + tagged lines), else determinism (F6) breaks |
| Cite-without-loading convention text | **new** — card section, no existing source to collide with |

## Feasibility

- Flow 1 (card-only discipline): buildable — current fragment is already 37 lines; compressing 8 rule one-liners + hard rule + flows + 3 pointers into ≤45 is tight but feasible.
- Flow 2 (escalation): buildable — trigger list is card text; no mechanism needed.
- Flow 3 (digest read): buildable — one-line amendment in `conventions.md` step 2.
- Flow 4 (staleness): buildable — lint.sh already owns C1-C11 pattern; one added check.

## Gate results (quality-gate-contract; command + exit code)

- `bash scripts/lint.sh` → exit 0 (C1-C11 all PASS)
- `bash scripts/check-citations.sh` → exit 0 (72 citations resolve)
- `bash scripts/check-links.sh` → exit 0 (449 links resolve)

## Blockers

None. One visible `[ASSUMPTION]`: D1 digest path (`.lsa/VISION-digest.md`) — confirmed at the spec gate, revisit only if the implementer surfaces a conflict.
