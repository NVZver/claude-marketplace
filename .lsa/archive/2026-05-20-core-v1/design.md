# Core v1 — Design

**Date:** 2026-05-20
**Status:** Approved (in brainstorm); pending written-spec review
**Parent vision:** `.lsa/VISION.md` v0.4
**Scope:** First shippable version of the domain-neutral Core, installable on both Claude Code and Claude.ai.

---

## 1. Goal

Ship the smallest Core that proves VISION's spine in real daily use: two portable Skills — `ground-rules` and `actor-template` — installable natively on Claude Code (via plugin marketplace) and Claude.ai (via Skills upload), with zero custom build steps and zero per-surface generators.

The success test: after install on a fresh session of either surface, an ungrounded factual claim triggers `ground-rules`, and a request to author a new skill/command/workflow triggers `actor-template`.

## 2. Decisions locked (and what they ruled out)

| Decision | Locked | Ruled out |
| --- | --- | --- |
| Cross-surface scope | Portable Skill on both Claude Code and Claude.ai | CLAUDE.md-only always-on; dual packaging |
| Contents | `ground-rules` + `actor-template` only | tier-selector and registry deferred |
| Actor scope | Skill-as-actor (SKILL.md frontmatter + body = Goal/Input/Steps/Output/Constraints) | All-three-forms; separate Knowledge/Actor templates |
| Approach | Lean Knowledge — pure-knowledge skills, no embedded checklists, no scaffold command | Embedded self-check; single combined skill |
| Plugin name | `core` (also the Claude Code namespace prefix) | — |
| Marketplace name | `nz-vision` | `vision`, `vision-wip` |
| Versioning | SemVer; first release `0.1.0`; bump on every meaningful change | Git-SHA implicit versioning |
| Spec location | `.lsa/YYYY-MM-DD-*.md` | repo-root `docs/superpowers/specs/…` |

## 3. Architecture and layout

New files in **bold**; existing in plain.

```
claude-marketplace/                       (repo root)
├── .claude-plugin/
│   └── marketplace.json                  ← NEW
├── core/                                  ← NEW (the v1 deliverable)
│   ├── .claude-plugin/
│   │   └── plugin.json                    ← NEW
│   ├── skills/
│   │   ├── ground-rules/
│   │   │   └── SKILL.md                   ← migrated/tightened from vision/SKILL.md
│   │   └── actor-template/
│   │       └── SKILL.md                   ← NEW
│   ├── README.md                          ← NEW (install paths for both surfaces)
│   └── VERIFICATION.md                    ← NEW (manual smoke checks)
├── lsa/                                   (migrated to plugin layout post-v1 — see lsa/CHANGELOG.md)
└── vision/
    ├── VISION.md                          (source of truth for "why")
    ├── SKILL.md                           (kept as the design draft of ground-rules)
    └── specs/
        └── 2026-05-20-core-v1-design.md   ← THIS FILE
```

**Why this shape.** Same on-disk folder is the unit you ship as a Claude Code plugin AND zip for Claude.ai upload — one source of truth, two native installs. `core/` is a self-contained plugin so future packs (`tech`, `writing`, …) sit beside it without restructuring. `vision/` stays the "why" folder; `core/` is the "what gets installed" folder.

**Verified Claude-native — sources:**
- Plugin layout: `code.claude.com/docs/en/plugins` — *"Don't put `commands/`, `agents/`, `skills/`, or `hooks/` inside the `.claude-plugin/` directory. Only `plugin.json` goes inside."*
- Marketplace: `code.claude.com/docs/en/plugin-marketplaces` — *"Create `.claude-plugin/marketplace.json` in your repository root. Each plugin entry needs at minimum a `name` and `source`."*
- Skill format: `agentskills.io` — *"a folder containing a `SKILL.md` file. This file includes metadata (`name` and `description`, at minimum)."* Open standard, identical file across Claude Code, Claude.ai, and other adopters.
- Claude.ai install: `platform.claude.com/.../agent-skills/overview` — *"Upload your own Skills as zip files through Settings > Features."*

## 4. The two files in detail

### 4.1 `core/skills/ground-rules/SKILL.md`

**Origin.** Migrated from `vision/SKILL.md` (already well-formed). Two changes only.

**Frontmatter (final shape):**

```yaml
---
name: ground-rules
description: Apply on every substantive task — answering questions, drafting, research, analysis, planning, coding, reviewing — whenever the response contains any factual claim or could pad/overreach. Enforces four rules: fact-grounding (sources + quotes), no fake-confidence hedging, read the real source before answering, deliver only what was asked.
---
```

Tightened from the original draft so the trigger keywords ("factual claim", "pad", "fact-grounding", "hedging", "scope") appear early — per `code.claude.com/docs/en/skills`: *"Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing to reduce context usage."*

**Body.** Four numbered sections verbatim from current draft:
1. Fact-grounding — every factual claim carries a source.
2. No fake confidence, no disguised facts.
3. Read the real source before answering.
4. Deliver only what was asked — no scope creep.

Plus the existing examples and the closing "What this skill never does" list.

**Add one footer line:** *"Writing or editing an actor (Skill, slash command, workflow)? See `actor-template`."* — plain prose, no file path, so it travels across surfaces.

### 4.2 `core/skills/actor-template/SKILL.md`

**Frontmatter (proposed final):**

```yaml
---
name: actor-template
description: Use when authoring or editing an actor — a Skill, slash command, or workflow that prescribes how to act (not just what is true). Enforces the Goal/Input/Steps/Output/Constraints shape, separates Knowledge from Actor, and demands every step produce an observable result.
---
```

**Body sections (≤ 80 lines total):**

1. **What is an Actor.** Two-sentence definition contrasting Actor (how to act) vs. Knowledge (what is true). One-line pointer to `ground-rules` for the truth half.
2. **The five required sections.** Goal · Input · Steps · Output · Constraints. One sentence each, naming the failure mode if the section is skipped.
3. **The rules.** Every Step has an observable result. No Knowledge bleed (rules/patterns/reference go in a Knowledge skill instead). No section combined or renamed.
4. **One worked example.** A short Actor (e.g., "Summarize a pull request") shown end-to-end so the shape is obvious from one read. The example **must demonstrate at least one Step that produces an observable result** — otherwise it quietly violates the rule from §4.2 #3. One example — not three — because per `code.claude.com/docs/en/skills` § "Skill content lifecycle": *"When you or Claude invoke a skill, the rendered `SKILL.md` content enters the conversation as a single message and stays there for the rest of the session."*
5. **Copy-paste template.** A literal SKILL.md skeleton — frontmatter + the five headed sections — for the user to paste when starting a new actor.
6. **What this skill never does.** Mirror of `ground-rules`' tail; kept to 3–5 bullets.

**Footer line:** *"Every output an actor produces must still obey `ground-rules`."*

## 5. Manifests

### 5.1 `core/.claude-plugin/plugin.json`

```json
{
  "name": "core",
  "description": "Domain-neutral discipline for trustworthy output: fact-grounding (sources + quotes), no fake-confidence hedging, read-before-write, only-required-output, and the Goal/Input/Steps/Output/Constraints shape for any actor (skill, slash command, or workflow).",
  "version": "0.1.0",
  "author": { "name": "Nikita Zverev" }
}
```

### 5.2 `.claude-plugin/marketplace.json` (repo root)

```json
{
  "name": "nz-vision",
  "owner": { "name": "Nikita Zverev" },
  "description": "Vision — a personal, model-agnostic agentic engineering system. Domain-neutral core, on-demand packs.",
  "plugins": [
    {
      "name": "core",
      "source": "./core",
      "description": "Domain-neutral discipline: ground-rules + actor-template."
    }
  ]
}
```

`nz-vision` is checked against the docs' reserved-names list (`claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `anthropic-agent-skills`, `knowledge-work-plugins`, `life-sciences`) — not reserved.

## 6. Install paths

### Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
```

Skills auto-discover under `core/skills/`. Invoke directly via `/core:ground-rules` and `/core:actor-template`, or let Claude trigger by description. `/reload-plugins` picks up edits without restart.

### Claude.ai

```bash
cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/
```

Upload each zip in Settings > Features. Per `platform.claude.com` docs: *"Custom Skills do not sync across surfaces. Skills uploaded to one surface are not automatically available on others."* — so the upload is one-time, per surface, per user.

## 7. Cross-references between the two skills

Plain-prose footer lines only (see §4.1 and §4.2). No file paths, no absolute links — both surfaces resolve skill identity differently (`/core:ground-rules` in Code, `ground-rules` on Claude.ai), and prose pointers travel across both cleanly.

## 8. `core/README.md` contents

≤ 60 lines, three sections:

1. **What's here.** Two skills, one sentence each. Pointer to `.lsa/VISION.md` for the "why".
2. **Install on Claude Code.** The two `/plugin` commands + `/reload-plugins` note.
3. **Install on Claude.ai.** The `zip -r` one-liner + Settings > Features path + the one-line note about per-user, no-sync.

## 9. Verification (v1 — manual, no harness)

Captured verbatim in `core/VERIFICATION.md` so the checks are repeatable.

**V1. Installs cleanly on both surfaces.**
- Claude Code: `/plugin install core@nz-vision` succeeds; `/help` lists both skills under the `core:` namespace.
- Claude.ai: both zips upload via Settings > Features; both appear in the Skills list with their full descriptions.

**V2. Description-match triggering fires when it should.**
- Drop an ungrounded claim into a fresh session ("Library X handles retries automatically") — `ground-rules` activates and forces sourcing or `[cannot verify]`.
- Ask "help me create a new skill for X" — `actor-template` activates.
- Both probes run on both surfaces.

**V3. Behavior change is observable.**
- Run the same small task twice — once with `core` installed, once without. Compare: presence/absence of source-and-quote on factual claims; presence/absence of the 5-section actor shape; scope-creep on a narrow ask.
- Eyeball the three VISION §5 metrics in pre-eval form: *accuracy to task*, *proven facts with sources*, *only-required-changes*.

Statistical eval, Elo, and Wilson CIs are explicitly deferred — VISION §6 adjust #3.

**Falsifiable threshold for the riskiest assumption (description-match reliability).** VISION v0.4 originally put `ground-rules` in `CLAUDE.md` precisely to guarantee always-on activation; v1 trades that for App portability. To keep the trade-off honest: across two weeks of regular use, log every session where `ground-rules` *should* have fired (any factual claim was made or any output overreached). If it fired on fewer than **~90% of intended tasks**, treat that as a v1 failure mode, not a wording tweak — and revisit the `CLAUDE.md` fragment option from VISION §3.

**Run V1 first, not last.** Both install paths are claimed Claude-native but untested. The implementation plan must run V1 (cleanly installs on both surfaces) before writing any skill body content — otherwise we discover broken install at the end of the work, not the start.

## 10. Out of scope for v1 (explicit, with reason)

| Deferred | Reason |
| --- | --- |
| `tier-selector` skill (T1/T2/T3 chain-of-thought) | Useful but tech-flavored examples; let the minimal spine bake first. |
| `registry` skill (map-not-territory loader) | VISION §6: principle holds; the bespoke mechanism matters less now Claude Code reports per-component cost natively. |
| Tech pack (TDD loop, verifier, spec lifecycle, reconcile) | Heaviest pack; comes after the spine is proven (VISION §3). |
| Statistical eval harness, Elo, Wilson CI | VISION §6 adjust #3 — defer until pass/fail isn't enough. |
| EARS-block tightening of acceptance criteria | VISION §6 adjust #1 — belongs in the tech pack's spec format. |
| Self-check checklists embedded in skills | Rejected as premature ceremony (Approach 2 in brainstorm). |
| Subagent variant of `actor-template` | Code-only surface; revisit when tech pack starts. |
| `CLAUDE.md` always-on fragment of `ground-rules` | Trades off against App portability locked in §2. Reconsider only if description-match fires unreliably in real use. |

## 11. Open follow-ups (post-v1)

- After two weeks of real use, review the three VISION §5 metrics on personal log of sessions. If `ground-rules` under-fires on Claude.ai, revisit description wording before reaching for a CLAUDE.md fragment.
- If actor-template fires too rarely, consider adding `when_to_use` with trigger phrases (note the 1,536-char combined cap with `description` per `code.claude.com` docs).
- When `tier-selector` graduates to a real skill, this design's footer line in `actor-template` may need to mention it.
