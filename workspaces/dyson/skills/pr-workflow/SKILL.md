---
name: PR Workflow
description: Clone kubernetes-manifests, branch, fix, validate, and open a PR
requires: []
---

# PR Workflow

Standard procedure for making changes to the `rajsinghtech/kubernetes-manifests` repo via pull request.

## Setup

```bash
# Clone fresh
git clone https://github.com/rajsinghtech/kubernetes-manifests.git /tmp/k8s-manifests
cd /tmp/k8s-manifests
```

## Branch Naming

Use conventional branch names:
- `fix/ottawa-<description>` — bug fix for Ottawa cluster
- `fix/robbinsdale-<description>` — bug fix for Robbinsdale
- `fix/stpetersburg-<description>` — bug fix for StPetersburg
- `fix/infra-<description>` — shared infrastructure fix
- `feat/<description>` — new feature or addition
- `chore/<description>` — maintenance, cleanup

```bash
git checkout -b fix/ottawa-coredns-memory-limit
```

## Common Fix Patterns

### Resource Limits
```yaml
# Increase memory limit for a crashing pod
resources:
  limits:
    memory: "512Mi"  # was 256Mi, OOMKilled
  requests:
    memory: "256Mi"
```

### Flux Kustomization Config
```yaml
# Fix dependency or path issues
spec:
  dependsOn:
    - name: infrastructure
  path: ./apps/media
  sourceRef:
    kind: GitRepository
    name: flux-system
```

### HelmRelease Version Bump
```yaml
spec:
  chart:
    spec:
      version: ">=1.2.3"  # bump from 1.2.2
```

### HelmRelease Values Fix
```yaml
spec:
  values:
    persistence:
      enabled: true
      storageClass: "ceph-block"  # was wrong class
```

### Namespace Label/Annotation
```yaml
metadata:
  labels:
    istio-injection: enabled  # add missing mesh label
```

## Validate Before Committing

```bash
# Validate YAML syntax
yq . <changed-file.yaml> > /dev/null

# Kustomize build (if applicable)
kustomize build <path-to-kustomization-dir>/ > /dev/null

# Check for common mistakes
grep -rn '<<<' /tmp/k8s-manifests/  # merge conflicts
grep -rn 'TODO\|FIXME\|HACK' <changed-files>  # leftover markers
```

## Commit and Push

```bash
git add <specific-files>
git commit -m "fix(ottawa): increase coredns memory limit to prevent OOM"
git push origin fix/ottawa-coredns-memory-limit
```

Commit message conventions:
- `fix(<scope>)`: bug fix
- `feat(<scope>)`: new feature
- `chore(<scope>)`: maintenance
- Scope: cluster name (`ottawa`, `robbinsdale`, `stpetersburg`) or `infra` for shared

## Create PR

```bash
gh pr create --repo rajsinghtech/kubernetes-manifests \
  --title "fix(ottawa): increase coredns memory limit to prevent OOM" \
  --body "$(cat <<'EOF'
## Problem
CoreDNS pods on Ottawa are OOMKilled with current 256Mi limit.

## Fix
Increased memory limit to 512Mi, request to 256Mi.

## Affected
- Cluster: talos-ottawa
- Namespace: kube-system
- Resource: deployment/coredns
EOF
)"
```

## Report Back

After creating the PR, report:
```
[ottawa] PR opened: fix(ottawa): increase coredns memory limit
URL: https://github.com/rajsinghtech/kubernetes-manifests/pull/123
Files changed: apps/kube-system/coredns/deployment.yaml
```

## Rules

- **Never push to main** — always branch and PR
- **Never skip validation** — kustomize build must pass
- **One concern per PR** — don't mix unrelated fixes
- **Include context** — PR body must explain the problem, fix, and affected resources
