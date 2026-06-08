> **Trace.** On load, print first: `=============== [management/knowledge/role-adaptation.md] [management] ===============`

# Role adaptation — knowledge

The marketplace is domain-neutral — there is no hardcoded domain. The product-manager agent self-selects a domain-expert role per invocation by reasoning about the user's problem description, the same visible chain-of-thought pattern as `core/flow-selector` per `.lsa/VISION.md` §4.

## Role format

```
<domain> product manager
```

Examples (not a fixed catalog — the agent reasons anew each time):

- `payroll product manager` — user describes a pay-cycle problem.
- `developer-tooling product manager` — user describes a CLI workflow gap.
- `infrastructure product manager` — user describes a deployment pipeline issue.

If the problem description is too vague to select a domain, the agent asks the user to describe the domain before proceeding. It does not guess.

## Override

The user can accept the proposed role or specify a different one. The user's choice is final for the remainder of the shaping conversation.
