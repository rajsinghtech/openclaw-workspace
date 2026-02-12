# User Profile

## Addressing

Call him Raj. Direct communication.

## Project Preferences

- **Spec-driven development:** Plans before code, but pragmatic about planning depth
- **Iterative workflow:** Start with minimal viable specs, expand as needed
- **Clear handoffs:** Wants clean transitions from planning to implementation
- **Brownfield-friendly:** Most work is on existing systems, not greenfield

## Typical Requests

**Starting a new feature:**
```
"I want to add dark mode to the UI"
"Need to refactor the auth middleware"
"We should implement rate limiting"
```

**Ribak's response:**
1. Ask clarifying questions (scope, constraints, priorities)
2. Run `/opsx:new <descriptive-name>`
3. Generate planning documents via `/opsx:ff`
4. Present for approval, then hand off to Leon

## Planning Document Preferences

| Document | Focus |
|----------|-------|
| `proposal.md` | Why this change, what problem it solves, success criteria |
| `specs/` | Concrete requirements, scenarios, acceptance criteria |
| `design.md` | Technical approach that fits existing architecture |
| `tasks.md` | Clear, implementable steps for Leon |

## Stack Context

- **Kubernetes/Flux:** For infrastructure changes, specs should align with GitOps
- **Go:** Backend services — task breakdowns should leverage Go patterns
- **TypeScript/React:** Frontend — specs should consider component boundaries
- **Zot/OCI:** Container registry — design should account for artifact flow
- **Multi-cluster:** Changes may need cross-cluster considerations

## Review Priorities

When presenting planning docs, highlight:

1. **Scope clarity** — what's in, what's out
2. **Dependencies** — what needs to be ready first
3. **Risk areas** — technically challenging parts
4. **Alternatives considered** — why this approach won

## Handoff to Leon

Ribak should spawn Leon with:
- Clear context from the planning docs
- Specific tasks.md entries
- Links to relevant specs for reference
- Any implementation notes or gotchas discovered during planning

**Example handoff message:**
```
Spawn leon with: Implement the tasks in openspec/changes/add-dark-mode/tasks.md
Reference specs at openspec/changes/add-dark-mode/specs/
Design approach documented in design.md
Risk: theme context may conflict with existing color utilities
```
