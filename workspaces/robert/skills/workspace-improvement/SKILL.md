---
name: Workspace Improvement
description: Cross-reference workspace docs against live deployment and open PRs for fixes
requires: [gh, git, kubectl, jq, yq]
---

# Workspace Improvement

## Cross-Reference Checks

Compare what workspace docs say against what's actually deployed.

### Container Names

```bash
# Live state
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq -r '.items[0].spec.containers[].name'

# Compare against docs
grep -r "container" workspaces/*/AGENTS.md workspaces/*/TOOLS.md | grep -i "name\|exec\|-c "
```

### Volume Mounts

```bash
# Live mounts
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq '.items[0].spec.containers[0].volumeMounts[] | {name, mountPath}'

# Compare against documented paths in workspace files
grep -rn "/home/node\|/opt/workspace\|/opt/config" workspaces/
```

### Model Providers

```bash
# Live config providers
kubectl exec deployment/openclaw -c openclaw -n openclaw -- \
  cat /home/node/.openclaw/clawdbot.json | jq '.models.providers | keys'

# Repo config providers
jq '.models.providers | keys' kustomization/openclaw.json

# Compare against what AGENTS.md documents
grep -A2 "Provider" workspaces/main/AGENTS.md
```

### Agent List

```bash
# Live agents
kubectl exec deployment/openclaw -c openclaw -n openclaw -- \
  cat /home/node/.openclaw/clawdbot.json | jq '.agents.list[].id'

# Repo agents
jq '.agents.list[].id' kustomization/openclaw.json
```

### Skills vs Skill Directories

```bash
# Skill directories that exist
ls workspaces/main/skills/ workspaces/morty/skills/ workspaces/robert/skills/

# Skills referenced in AGENTS.md
grep -n "skill" workspaces/*/AGENTS.md
```

## Staleness Detection

Check if workspace content references outdated values:

```bash
# Image tags in docs vs deployment
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq -r '.items[0].spec.containers[].image'
grep -rn "ghcr.io\|oci.killinit.cc" workspaces/

# Tailscale version
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq -r '.items[0].spec.containers[] | select(.name=="tailscale") | .image'
grep -n "tailscale" workspaces/*/AGENTS.md
```

## PR Creation Workflow

### 1. Check for Duplicates

```bash
gh pr list --repo rajsinghtech/openclaw-workspace --author rajsinghtechbot --state open
```

Skip if an open PR already addresses the same issue.

### 2. Clone and Branch

```bash
git clone https://github.com/rajsinghtech/openclaw-workspace.git /tmp/robert-review
cd /tmp/robert-review
git checkout -b robert/<topic>-$(date +%Y-%m-%d)
```

### 3. Make Changes

Edit only the files that need fixing. Prefer minimal, targeted changes.

### 4. Validate

```bash
# If you touched JSON
jq . kustomization/openclaw.json > /dev/null

# If you touched YAML
yq . <file.yaml> > /dev/null

# If you touched kustomization resources
kustomize build kustomization/ > /dev/null
```

### 5. Commit and PR

```bash
git add <specific-files>
git commit -m "<type>: <description>"
git push origin robert/<topic>-$(date +%Y-%m-%d)

gh pr create \
  --title "<type>: <description>" \
  --body "## Findings
<evidence>

## Changes
<what and why>

## Sessions Referenced
<session IDs>"
```

### Commit Types

- `fix:` — corrects incorrect information
- `docs:` — updates stale or missing documentation
- `feat:` — adds new skill or capability
- `chore:` — cleanup, formatting, no behavior change
