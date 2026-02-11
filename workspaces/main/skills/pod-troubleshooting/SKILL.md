---
name: Pod Troubleshooting
description: Debug pod crashes, CrashLoopBackOff, ImagePullBackOff, OOMKilled, init container errors, and EBUSY config failures. Use when pods are not Running or containers are restarting.
requires: [kubectl]
---

# Pod Troubleshooting

## Diagnostic Chain

```bash
# 1. Pod status overview
kubectl get pods -n openclaw -o wide

# 2. Detailed state for failing pods
kubectl describe pod -l app.kubernetes.io/name=openclaw -n openclaw

# 3. Namespace events
kubectl get events -n openclaw --sort-by='.lastTimestamp' | tail -20
```

## Container Names

Always specify `-c <name>` for logs/exec:

| Container | Role |
|-----------|------|
| `openclaw` | Main OpenClaw server |
| `tailscale` | Tailscale mesh sidecar |
| `init-workspace` | Copies workspace + config to emptyDir |
| `sysctler` | Enables IP forwarding (init) |

## Decision Tree

| Symptom | Likely Cause | Action |
|---------|-------------|--------|
| `ImagePullBackOff` | Registry auth or missing tag | See `failures.md` → ImagePullBackOff |
| `CrashLoopBackOff` | Container exits repeatedly | See `failures.md` → CrashLoopBackOff |
| `Init:Error` | Init container failed | See `failures.md` → Init:Error |
| `OOMKilled` | Memory limit exceeded | See `failures.md` → OOMKilled |
| `EBUSY` in logs | Config mounted as subPath | See `failures.md` → EBUSY |
| Running but not working | Check container logs | `kubectl logs -c openclaw --tail=100` |

## Quick Actions

```bash
# Container logs
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=100

# Previous crash logs
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --previous --tail=100

# Exec into running container
kubectl exec -it deployment/openclaw -c openclaw -n openclaw -- /bin/sh

# Restart deployment
kubectl rollout restart deployment openclaw -n openclaw
kubectl rollout status deployment openclaw -n openclaw
```

For detailed failure diagnosis steps, read `failures.md` in this skill directory.
