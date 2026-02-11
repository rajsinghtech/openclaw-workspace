---
name: Session Review
description: Analyze agent sessions for tool failures, retry patterns, knowledge gaps, context limits, and config drift. Covers sessions_list/sessions_history tool call syntax and error categorization.
requires: []
---

# Session Review

## Gathering Sessions

Use the built-in `sessions_list` and `sessions_history` tools (OpenClaw tool calls, NOT bash commands).

### List recent sessions

```json
{ "tool": "sessions_list", "params": { "activeMinutes": 720, "limit": 100, "messageLimit": 5 } }
```

- `activeMinutes: 720` = last 12 hours
- `messageLimit: 5` = include last 5 messages per session for quick triage
- Use `kinds` to filter: `["main", "group", "cron", "hook"]`

### Get full session transcript

```json
{ "tool": "sessions_history", "params": { "sessionKey": "<key>", "limit": 200, "includeTools": true } }
```

- Set `includeTools: true` to see tool call results (where errors appear)
- Increase `limit` for long sessions

### Agents to review

Check sessions for ALL agents: **main**, **morty**, **dyson**, **leon**.

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
| Agent | `main` / `morty` / `dyson` / `leon` |
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
- main: W sessions
- morty: X sessions
- dyson: Y sessions
- leon: Z sessions

Findings:
1. [breaking] Container name mismatch — AGENTS.md says "main", should be "openclaw" (sessions: abc123, def456)
2. [misleading] Model list outdated — missing nvidia provider in TOOLS.md (session: ghi789)

Proposed PRs:
1. fix: correct container name in main workspace docs
2. docs: add nvidia provider to TOOLS.md quick reference
```
