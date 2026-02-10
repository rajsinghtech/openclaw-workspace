# Tools

All tools at `/usr/local/bin/`. Authenticated as `rajsinghtechbot` via GITHUB_TOKEN.

## gh

```bash
# Clone repos
gh repo clone rajsinghtech/openclaw-workspace -- /tmp/oc-audit

# Check CI status
gh run list --repo rajsinghtech/openclaw-workspace --limit 5
gh run view <id> --repo rajsinghtech/openclaw-workspace

# Create PRs (for non-trivial changes)
gh pr create --title "fix: ..." --body "..."
```

## git

```bash
git clone https://github.com/rajsinghtech/openclaw-workspace.git /tmp/oc-audit
git add <files> && git commit -m "fix: ..." && git push
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

## Cluster

```bash
kubectl get pods -n openclaw -o wide
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=50
flux get kustomization -A | grep openclaw
```
