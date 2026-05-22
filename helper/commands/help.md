---
description: "Ask Helper a question or request a walkthrough. STUB until step 3 of vision/specs/features/2026-05-21-helper-agent/tasks.md lands; currently responds with a pointer to the spec."
---

# `/help` — stub (step 1)

The `/help` command body lands in **step 3** of [`vision/specs/features/2026-05-21-helper-agent/tasks.md`](../../vision/specs/features/2026-05-21-helper-agent/tasks.md). Until then, this command is a stub.

When invoked, respond to the user with exactly this text (no fabrication, no extra commentary):

> `/help` is being built. The Helper plugin is at **step 1 of 4** (scaffold-only). The `/help` command body lands in step 3; the Helper agent body lands in step 2. Until those land, please read [`helper/README.md`](../helper/README.md) or the feature spec at [`vision/specs/features/2026-05-21-helper-agent/`](../vision/specs/features/2026-05-21-helper-agent/) directly.

Do not attempt to answer the user's question. Do not invoke other skills. Hand control back to the human.
