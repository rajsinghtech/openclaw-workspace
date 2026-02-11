---
name: Debug Troubleshooting
description: Systematic debugging — reproduce, isolate, trace root cause, verify fix. Covers code path tracing, log analysis, binary search for regressions, and hypothesis-driven debugging.
requires: [gh, git]
---

# Debug Troubleshooting

## Approach

1. **Reproduce** — Understand what's failing and under what conditions
2. **Isolate** — Narrow down to the specific component, file, or line
3. **Root cause** — Find the actual bug, not just the symptom
4. **Fix** — Propose a minimal, targeted fix
5. **Verify** — Explain how to confirm the fix works

## Code Debugging

### Read the error

```bash
# Get error from logs
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=100

# Get error from CI
gh run view <id> --repo rajsinghtech/<repo> --log-failed
```

### Trace the code path

```bash
# Clone and search
git clone https://github.com/rajsinghtech/<repo>.git /tmp/debug
cd /tmp/debug

# Find where the error originates
grep -rn "error message text" .
grep -rn "function_name" .
```

### Common patterns

| Symptom | Likely Cause |
|---------|-------------|
| `container "main" not found` | Wrong container name — use `openclaw` |
| `EBUSY: resource busy` | Atomic write on ConfigMap subPath mount |
| `manifest invalid` | Pushed via `docker push` instead of `skopeo` |
| `${VAR}` not resolved | Missing `$${}` escaping for Flux postBuild |
| `command not found` | Tool not in Dockerfile or wrong PATH |

## Infrastructure Debugging

Follow the chain: **Flux source → Kustomization → Deployment → Pod → Container**

```bash
# Flux source
flux get source git -A | grep openclaw

# Kustomization
flux get kustomization -A | grep openclaw

# Pod
kubectl get pods -n openclaw -o wide
kubectl describe pod -l app.kubernetes.io/name=openclaw -n openclaw

# Container logs
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=50
```
