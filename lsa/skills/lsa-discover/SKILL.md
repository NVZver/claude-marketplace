---
name: lsa-discover
description: Light discovery phase used at the start of every T2 and T3 task. Asks the minimal clarifying questions needed to identify the affected module spec, the change's intent, and the acceptance criterion. Writes nothing to disk for T2 (oral output only); hands the captured context to lsa-specify for T3. Use this before any code or spec change when the tier is T2 or T3.
---

# LSA Discover

The light discovery phase between `core/tier-selector` and either implementation (T2) or `lsa-specify` (T3). Cheap by design: three questions, no spec writes for T2, a small scratch handoff for T3.

## Goal

Establish minimum-viable context — which module the change touches, what the change is in one sentence, and the acceptance criterion in one sentence — and hand off to the next phase appropriate to the tier.

## Input

- The task description from `core/tier-selector`'s confirmed handoff, including the confirmed tier (T2 or T3).
- `.lsa.yaml` at repo root (or LSA defaults: `constitution: /CLAUDE.md`, `specs_root: /specs/`, `mode: code`, `modules: {}`) for the list of candidate module names.

## Steps

1. **Read `.lsa.yaml` and list candidate module names.** Read `modules.*` keys; if `.lsa.yaml` is absent, list module directories under `${specs_root}/modules/` instead. Observable result: the candidate-module list printed back to the human (so the answer to question (a) below is constrained, not invented).

2. **Ask the three-question discovery probe.** Ask, exactly three questions, in this order:
   - (a) **Which module(s) does this touch?** (Pick from the list printed in Step 1, or say "new module: <name>" if none fit.)
   - (b) **What's the change in one sentence?**
   - (c) **What's the acceptance criterion in one sentence?** (How will we know the change is done?)

   Observable result: three short answers captured in the working scratch.

3. **For T2 only** — write a single-paragraph context summary (one paragraph, 2–4 sentences) naming the chosen module(s), the change, and the AC. **Stop** there. The agent then writes a failing test, implements the change, and runs `/lsa:verify`. Observable result: the context paragraph printed back to the human; no files written to `${specs_root}/`.

4. **For T3 only** — write a draft `discovery.md` block under the working feature directory (a scratch file, not yet committed; `lsa-specify` consumes and expands it into the formal feature spec):

   ```markdown
   # Discovery — <feature-name>

   - **Module(s):** <answer (a)>
   - **Change:** <answer (b)>
   - **Acceptance:** <answer (c)>
   ```

   Then hand off to `lsa-specify` with a one-line message naming the chosen module(s) and feature name. Observable result: `discovery.md` exists; the handoff is invoked.

## Output

- **T2** — short context paragraph (oral only; no file).
- **T3** — `discovery.md` scratch file at the working feature path, plus a one-line handoff message naming the chosen module(s) and the feature name.

## Constraints

- **Three questions, no more.** If deeper context is needed, escalate back to `tier-selector` for a tier-bump rather than asking question four.
- **Do not write to the configured `specs_root`.** That is `lsa-specify`'s responsibility. The T3 `discovery.md` is a working scratch file, not a spec write.
- **Do not invent module names** not present in `.lsa.yaml` (or under `${specs_root}/modules/` when `.lsa.yaml` is absent). If the chosen module does not exist, capture it explicitly as `new module: <name>` so downstream phases know to create it.

---

`/lsa:discover` — manual invocation. On T3 completion, downstream is `lsa-specify`.
