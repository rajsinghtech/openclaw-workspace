---
name: Memory Management
description: Session memory and context management best practices
requires: []
---

# Memory Management

## Context Hygiene

### Before Starting a New Task
Run `/compact` to clear stale context before switching topics. This prevents hallucination from prior task context bleeding into the new one.

### After Configuring Something
Commit important details to memory immediately. Verify by repeating the key facts back. Don't rely on session context surviving — compaction or restarts will lose it.

### When Context Seems Incomplete
Search session memory before asking the user to repeat themselves:
- Check recent conversation for relevant details
- Review workspace files that may contain the answer
- Only ask after confirming the info isn't available

## Sub-Agents for Long Tasks

Spawn sub-agents for tasks that may exceed session timeout (60 min idle):
- Scheduled/cron monitoring tasks
- Long-running build watches
- Periodic health checks

Sub-agents run independently and won't be killed by the parent session timing out.

```
Main agent → spawns sub-agent for monitoring
Main agent session can idle/timeout
Sub-agent continues running
```

## Memory Flush Before Compaction

When context is getting large and compaction is imminent, flush important state to persistent storage:
- Write key findings to workspace files
- Update any tracking documents
- Log decisions and their rationale

This ensures nothing critical is lost when the context window compresses.

## Daily Operations Pattern

1. **Start of session:** Review workspace files for context, run health checks
2. **During work:** Commit decisions and findings to memory as you go
3. **Before idle:** Flush any uncommitted knowledge to workspace files
4. **On return:** Check workspace files and events since last active

## Memory Search

When looking for prior context:
1. Check workspace files first (persistent across restarts)
2. Search session memory for recent interactions
3. Check pod logs for operational history: `kubectl logs -c openclaw --tail=200`
4. Review Kubernetes events: `kubectl get events -n openclaw --sort-by='.lastTimestamp'`
