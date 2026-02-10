---
name: Session Review
description: Analyze agent session history for failures, retries, and knowledge gaps
requires: []
---

# Session Review

## Gathering Sessions

```bash
# All sessions from the last 12 hours
sessions_list --since 12h

# Filter by agent
sessions_list --agent main --since 12h
sessions_list --agent morty --since 12h
```

For each session, pull the full history:
```bash
sessions_history --id <session-id>
```

## Error Patterns to Detect

### Tool Call Failures

Look for non-zero exit codes or error strings in tool responses:
- `command not found` — tool not installed or wrong name
- `error: ...` / `Error: ...` — command-level failure
- `No such file or directory` — wrong path assumption
- `container "main" not found` — wrong container name (should be `openclaw`)
- `EBUSY` / `ENOENT` — filesystem issues
- HTTP 4xx/5xx in API responses

### Retry Patterns

Agent attempted the same action multiple times:
- Same command run 2+ times with slight variations
- Agent said "let me try again" or "that didn't work"
- Repeated `kubectl` commands with different flags/names

### Knowledge Gaps

Agent didn't know something it should have:
- Asked docs for info that's in workspace files
- Guessed a config key and got it wrong
- Used wrong provider/model reference format
- Assumed wrong path for a file or mount

### Context Limits

Session hit token limits:
- Compaction triggered mid-task
- Agent lost track of earlier findings after compaction
- Session timed out before completing

## Categorization

For each finding, record:

| Field | Value |
|-------|-------|
| Session ID | `<id>` |
| Agent | `main` / `morty` |
| Timestamp | When the error occurred |
| Category | `tool-failure` / `retry` / `knowledge-gap` / `stale-docs` / `missing-skill` / `config-drift` |
| Severity | `breaking` / `misleading` / `enhancement` |
| Evidence | The actual error or exchange from the session |
| Fix | What workspace change would prevent this |

## Severity Guide

- **Breaking**: Incorrect info that directly causes tool failures (wrong container name, wrong path, bad command)
- **Misleading**: Stale or incomplete info that wastes agent time (outdated model list, missing skill reference)
- **Enhancement**: Patterns that could be encoded as skills or better docs but aren't causing failures

## Output

After analysis, produce a summary:
```
Sessions analyzed: N
- main: X sessions
- morty: Y sessions

Findings:
1. [breaking] Container name mismatch — AGENTS.md says "main", should be "openclaw" (sessions: abc123, def456)
2. [misleading] Model list outdated — missing nvidia provider in TOOLS.md (session: ghi789)

Proposed PRs:
1. fix: correct container name in main workspace docs
2. docs: add nvidia provider to TOOLS.md quick reference
```
