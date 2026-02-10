---
name: GitOps Deploy
description: End-to-end deployment workflow for OpenClaw via Flux
requires: [kubectl, flux, sops]
---

# GitOps Deploy

## Full Deployment Flow

```
git commit → git push → CI builds images → Flux reconciles → pod restarts
```

### 1. Push Changes

Commit and push to `main`. Two CI pipelines may trigger depending on what changed:

- `build-openclaw.yaml` — Dockerfile.openclaw or workflow changes
- `build-workspace.yaml` — workspace/** or Dockerfile.workspace changes

### 2. Monitor CI

```bash
# List recent workflow runs
gh run list --repo rajsinghtech/openclaw-workspace --limit 5

# Watch a specific run
gh run watch <run-id> --repo rajsinghtech/openclaw-workspace

# Check if the run succeeded
gh run view <run-id> --repo rajsinghtech/openclaw-workspace
```

### 3. Reconcile Flux

After CI completes and images are pushed, tell Flux to pick up the new git state:

```bash
# Reconcile source + kustomization in one shot
flux reconcile kustomization openclaw-workspace --with-source

# Wait for it
flux get kustomization openclaw-workspace
```

### 4. Force Image Pull

The deployment uses `:latest` tags. Kubernetes won't re-pull unless the pod restarts:

```bash
kubectl rollout restart deployment openclaw -n openclaw
kubectl rollout status deployment openclaw -n openclaw
```

### 5. Verify

```bash
kubectl get pods -n openclaw -o wide
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=20
```

## ConfigMap Changes

Config lives in `kustomization/openclaw.json`, delivered via kustomize configMapGenerator.

Key rules:
- Generator uses `disableNameSuffixHash: true` — the ConfigMap name is always `openclaw-config`
- Init container copies config from ConfigMap to emptyDir (writable)
- Config changes require a pod restart to take effect (init container runs on startup)

### Flux PostBuild Escaping

Flux performs `${VAR}` substitution on all manifests. If your config contains literal `${VAR}` references (for OpenClaw's own env var substitution), you must escape them:

```
Config value:      ${NVIDIA_API_KEY}
In the file:       $${NVIDIA_API_KEY}
After Flux sub:    ${NVIDIA_API_KEY}   ← OpenClaw resolves this at runtime
```

Double-dollar `$${}` tells Flux to emit a literal `${}` without substituting.

## SOPS Secret Management

Secrets are encrypted with SOPS using PGP key `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`.

```bash
# Decrypt and view
sops -d kustomization/secret.sops.yaml

# Edit (opens in $EDITOR, re-encrypts on save)
sops kustomization/secret.sops.yaml

# Set a single value
sops --set '["stringData"]["NEW_KEY"] "value"' kustomization/secret.sops.yaml

# Verify the change
sops -d kustomization/secret.sops.yaml | yq '.stringData.NEW_KEY'
```

After modifying secrets:
1. Commit and push the encrypted file
2. Flux decrypts during reconciliation using its SOPS provider
3. Restart the pod if the secret is consumed via `envFrom`

## Quick Deploy Checklist

1. Make changes to config/manifests/workspace
2. `git add && git commit && git push`
3. Wait for CI (if image changes): `gh run watch`
4. `flux reconcile kustomization openclaw-workspace --with-source`
5. `kubectl rollout restart deployment openclaw -n openclaw` (if images changed)
6. `kubectl get pods -n openclaw` — verify Running
7. `kubectl logs ... -c openclaw --tail=20` — verify startup
