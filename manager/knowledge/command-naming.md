> **Trace.** On load, print first: `=============== [manager/knowledge/command-naming.md] [manager] ===============`

# Command naming — knowledge

Commands are **functions you call**, not nouns you browse. A command name plus its arguments must tell a new reader what the command *does* — without opening the file. Zero metaphor: reject abstract or evocative names (`swarm`, `orchestra`, `armada`) that name a *thing* instead of an *action*.

## The convention

```
<object|actor>:<action>-<modifier> arg1, arg2
```

- **`<object|actor>`** — the namespace: the thing acted on, or the agent doing the acting (`manager`, `roadmap`, `pitch`).
- **`<action>`** — a verb. The command *does* this (`next`, `decompose`, `check`, `start`).
- **`-<modifier>`** — optional refinement of the action (`check-hygiene`, `decompose-pitch`); express as a `-suffix` or a flag.
- **`arg1, arg2`** — the inputs the verb operates on.

**Test.** Read the name and args aloud as a sentence. `manager:decompose <pitch>` reads as "manager, decompose this pitch" — passes. `manager:roadmap` reads as "manager roadmap" — a noun phrase, no verb, fails.

## Worked example: the noun that hid verbs (now resolved)

`manager:roadmap` *was* a noun. Its description bundled **three distinct verbs** into one entry point — "recommend what to work on next, decompose pitches into epics, and tidy roadmap hygiene". A reader could not tell from the name `roadmap` which of the three would run, or what to pass it. As of `manager` v0.9.0 the noun is split into three verb skills, each dispatching the same `project-manager` agent with a distinct intent. The before→after:

```
# Before — one noun, three hidden actions
manager:roadmap            # recommend? decompose? tidy? unclear

# After (live) — one verb each, args explicit
manager:next               # recommend the next backlog item
manager:decompose <pitch>  # decompose a pitch into epics
manager:check              # check roadmap hygiene
```

Each verb now has a name that states its action and an argument list that states its input. Nothing is hidden. The shared dispatch → gate → re-render logic lives once at [`./roadmap-orchestration.md`](./roadmap-orchestration.md); the verb skills cite it rather than restating it.

## How to apply

When authoring a new command:

1. **Pick the verb first.** What single action does this command perform? That verb is the `<action>`. If you cannot name one verb, the command does too much — split it.
2. **Namespace by the object or actor.** Put the thing acted on, or the agent acting, before the colon (`manager:`, `pitch:`).
3. **Modifiers as `-suffix` or flags.** Refinements attach to the action (`check-hygiene`), not the namespace.
4. **Arguments after the name.** The verb's inputs follow as positional args (`decompose <pitch>`).
5. **The no-arg form does something useful.** Calling the command bare (no args) should default to a useful, read-only action — `manager:next` recommends; `manager:check` reports. Never error on empty input when a sensible read-only default exists.
