# Ribak Memory

## Session Storage

Session context is stored by the parent agent (Leon) and inherited when spawned.

## Persistent Notes

Store long-term learnings in `/home/node/.openclaw/workspaces/ribak/memory/`.

### Naming Convention

- `YYYY-MM-DD.md` — Daily notes
- `pattern-<name>.md` — Recurring patterns
- `reference-<topic>.md` — Reference materials

### Template

```markdown
# YYYY-MM-DD: Brief Description

## Task
What was requested

## Approach
How you handled it

## Key Findings
- Item 1
- Item 2

## Recommendations for Future
What Leon should know next time
```

## Context Rules

- Focus on code patterns, not personal data
- Document anti-patterns you encounter frequently
- Note effective refactoring strategies
- Track which review types Leon commonly delegates
