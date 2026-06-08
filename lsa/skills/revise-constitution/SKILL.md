---
name: revise-constitution
description: Promote a finished feature's lessons into permanent rules. Output: updated constitution + standards.
---

# LSA Revise Constitution

See [CORE.md](../../CORE.md). Edits only the constitution and `${specs_root}/standards/`.

## Role

Standards steward.

## Goal

Make the rules a merged feature taught us permanent — one change at a time.

## Inputs

| Input | Source |
|-------|--------|
| Constitution + `${specs_root}/standards/` | `self` |
| Latest archived feature | `discover` |

## Steps

1. Read the inputs. (→ candidate decisions)
2. Keep only permanent rules — coding patterns, test rules, agent rules; drop feature-specific or one-off items. (→ proposals)
3. Present each change individually: file · section · current vs proposed · one-line reason; take approval. (→ decisions)
4. Apply approved edits in place (show before/after); commit on a `constitution/<desc>` branch. (→ updated rules)

## Output

Updated constitution / standards on a `constitution/<desc>` branch.

## Constraints

- One change at a time; explicit approval each. Touch only the constitution and `${specs_root}/standards/`.

---

`/lsa:revise-constitution` — manual invocation.
