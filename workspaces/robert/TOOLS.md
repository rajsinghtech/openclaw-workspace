# Tools

All tools at `/usr/local/bin/`. Authenticated as `rajsinghtechbot` via GITHUB_TOKEN.

## Session Tools

Primary tools for your review workflow.

```bash
# List recent sessions across all agents
sessions_list --since 12h

# List sessions for a specific agent
sessions_list --agent main --since 12h
sessions_list --agent morty --since 12h

# Get full conversation history for a session
sessions_history --id <session-id>
```

## gh

```bash
# Check for existing open PRs (deduplicate before creating new ones)
gh pr list --repo rajsinghtech/openclaw-workspace --author rajsinghtechbot --state open

# Clone
gh repo clone rajsinghtech/openclaw-workspace -- /tmp/robert-review

# Create PR
gh pr create --title "<type>: <description>" --body "## Findings\n..."

# Check CI status on your PRs
gh run list --repo rajsinghtech/openclaw-workspace --limit 5
```

## git

```bash
# Clone fresh every run
git clone https://github.com/rajsinghtech/openclaw-workspace.git /tmp/robert-review
cd /tmp/robert-review

# Branch, commit, push
git checkout -b robert/<topic>-$(date +%Y-%m-%d)
git add <files>
git commit -m "<type>: <description>"
git push origin robert/<topic>-$(date +%Y-%m-%d)
```

## Validation

```bash
# JSON
jq . <file.json> > /dev/null

# YAML
yq . <file.yaml> > /dev/null

# Kustomize render
kustomize build kustomization/
```

## Cluster Inspection

For cross-referencing workspace docs against live state.

```bash
# Current pod state
kubectl get pods -n openclaw -o wide

# Container names (compare against AGENTS.md)
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq '.items[0].spec.containers[].name'

# Current config (compare against openclaw.json in repo)
kubectl exec deployment/openclaw -c openclaw -n openclaw -- \
  cat /home/node/.openclaw/clawdbot.json | jq .

# Flux status
flux get kustomization -A | grep openclaw
```

## web_fetch

For looking up OpenClaw docs when verifying config keys or features.

```bash
# Doc index
web_fetch https://docs.openclaw.ai/llms.txt

# Specific pages
web_fetch https://docs.openclaw.ai/gateway/configuration
web_fetch https://docs.openclaw.ai/automation/cron
```
