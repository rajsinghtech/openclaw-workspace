---
name: Cluster Context
description: OpenClaw pod architecture, volumes, networking, secrets, and provider configuration. Use when debugging container, mount, networking, or credential issues.
requires: [kubectl]
---

# Cluster Context

## Pod Architecture

Single-replica Deployment in `openclaw` namespace:

```
Pod: openclaw
  initContainers:
    sysctler        -> enables IP forwarding for Tailscale
    init-workspace  -> copies workspace content from OCI ImageVolume to data PVC
  containers:
    openclaw        -> OpenClaw server (oci.killinit.cc/openclaw/openclaw:latest)
    tailscale       -> Tailscale sidecar for mesh networking
```

## Model Providers

| Provider | Model | Use Case |
|----------|-------|----------|
| `nvidia` | `moonshotai/kimi-k2.5` | Default — strong reasoning, 131k context |
| `anthropic` | `claude-opus-4-6` | Fallback — 200k context, multimodal |
| `llama-cpp` | `Qwen3-Coder-Next` | Local model via Tailscale egress |

## Volumes

| Volume | Type | Mount Path | Purpose |
|--------|------|------------|---------|
| `data` | PVC (openclaw-data, 5Gi Ceph RBD) | `/home/node/.openclaw/` | Persistent agent state |
| `workspace` | ImageVolume (oci.killinit.cc/openclaw/workspace:latest) | `/opt/workspace` | Read-only workspace content |
| `config` | ConfigMap (openclaw-config) | `/opt/config` | Config files, copied by init container |

## Networking

- Service `openclaw-main` on port 18789
- HTTPRoute through Gateway API (`ts` gateway in `home` namespace)
- Hostname: `openclaw.${CLUSTER_DOMAIN}` (Flux-substituted)
- LLM backend: `stpetersburg-llama-cpp` ExternalName service → Tailscale egress proxy

## Secrets

| Secret | Keys |
|--------|------|
| `openclaw-secrets` (SOPS) | DISCORD_BOT_TOKEN, OPENCLAW_GATEWAY_TOKEN, OPENAI_API_KEY, OPENAI_BASE_URL, ANTHROPIC_API_KEY, NVIDIA_API_KEY |
| `ts-oauth` | Tailscale OAuth credentials (ephemeral + preauthorized) |
| `zot-pull-secret` | Registry credentials for `oci.killinit.cc` |

## Inspection Commands

```bash
# Container images running
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq -r '.items[0].spec.containers[].image'

# Volume mounts
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | \
  jq '.items[0].spec.containers[0].volumeMounts[] | {name, mountPath}'

# Provider config
kubectl exec deployment/openclaw -c openclaw -n openclaw -- \
  jq '.models.providers | keys' /home/node/.openclaw/clawdbot.json

# Env vars (for API key resolution)
kubectl exec deployment/openclaw -c openclaw -n openclaw -- env | sort

# Pull secret verification
kubectl get secret zot-pull-secret -n openclaw -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```
