---
name: OpenClaw Docs Lookup
description: Look up OpenClaw documentation on demand via web_fetch
requires: []
---

# OpenClaw Docs Lookup

You have access to the full OpenClaw documentation at `docs.openclaw.ai`. Use `web_fetch` to look up answers before guessing.

## How to Look Things Up

### 1. Master Index
Fetch `https://docs.openclaw.ai/llms.txt` to get the full doc index with every page URL. Use this when you're not sure which page has the answer.

### 2. Direct Page Access
If you know the topic, go straight to the page:

| Topic | URL |
|-------|-----|
| **Config reference** | `https://docs.openclaw.ai/gateway/configuration` |
| **Agent runtime** | `https://docs.openclaw.ai/concepts/agent-runtime` |
| **Multi-agent routing** | `https://docs.openclaw.ai/concepts/multi-agent` |
| **Memory system** | `https://docs.openclaw.ai/concepts/memory` |
| **Sessions** | `https://docs.openclaw.ai/concepts/sessions` |
| **Model failover** | `https://docs.openclaw.ai/concepts/model-failover` |
| **Skills** | `https://docs.openclaw.ai/tools/skills` |
| **Sub-agents** | `https://docs.openclaw.ai/tools/agents` |
| **Exec / shell tools** | `https://docs.openclaw.ai/tools/exec` |
| **Web tools** | `https://docs.openclaw.ai/tools/web` |
| **Cron jobs** | `https://docs.openclaw.ai/automation/cron` |
| **Hooks** | `https://docs.openclaw.ai/automation/hooks` |
| **Heartbeat** | `https://docs.openclaw.ai/gateway/heartbeat` |
| **Health checks** | `https://docs.openclaw.ai/gateway/health` |
| **Sandboxing** | `https://docs.openclaw.ai/gateway/sandbox` |
| **Discord channel** | `https://docs.openclaw.ai/channels/discord` |
| **Environment vars** | `https://docs.openclaw.ai/help/env` |
| **Troubleshooting** | `https://docs.openclaw.ai/help/debugging` |
| **FAQ** | `https://docs.openclaw.ai/help/faq` |
| **Docker install** | `https://docs.openclaw.ai/installation/docker` |
| **Model providers** | `https://docs.openclaw.ai/providers/overview` |
| **Custom providers** | `https://docs.openclaw.ai/providers/custom` |
| **CLI reference** | `https://docs.openclaw.ai/cli/overview` |
| **ClawHub (skills marketplace)** | `https://docs.openclaw.ai/tools/clawhub` |

### 3. When to Look Things Up

**Always check docs before:**
- Changing config keys you're unsure about (wrong keys crash the agent)
- Adding new providers or models
- Modifying agent routing, session, or memory settings
- Debugging startup failures or unexpected behavior
- Setting up cron jobs, hooks, or automation

**Use the index (`llms.txt`) when:**
- You don't know which page covers a topic
- The user asks about a feature you haven't seen before
- You need to verify if a config key exists

### 4. Config Schema Quick Reference

OpenClaw config (`clawdbot.json`) top-level keys:
```
gateway        — port, auth, controlUi
models         — providers, mode
agents         — defaults, list
session        — scope, idleMinutes
tools          — profile, web, exec
skills         — entries, load
channels       — discord, telegram, whatsapp, etc.
logging        — level, consoleStyle
commands       — parsing settings
messages       — prefixes, reactions
```

Agent-level keys (under `agents.defaults` or per-agent in `agents.list`):
```
model          — primary, thinking, failover
workspace      — path to workspace dir
identity       — name, emoji
heartbeat      — every, model, target, activeHours
subagents      — allowAgents, model, maxConcurrent
compaction     — memoryFlush settings
memorySearch   — enabled, sources, experimental
timeoutSeconds — max turn duration
maxConcurrent  — concurrent session limit
```

**Common mistake:** putting agent-level keys at root level. They MUST go under `agents.defaults` or a specific agent in `agents.list`.

### 5. ClawHub — Community Skills

Search and install community skills:
```bash
clawhub search "kubernetes"
clawhub install <skill-slug>
clawhub update --all
```

Notable ops skills: `kubernetes`, `docker-essentials`, `git-essentials`, `gitflow`
