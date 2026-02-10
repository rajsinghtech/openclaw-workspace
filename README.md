# OpenClaw Workspace

Kubernetes deployment and workspace content for an OpenClaw agent running on a Talos cluster with Flux GitOps.

## What's in this repo

| Directory | Purpose |
|-----------|---------|
| `kustomization/` | Kubernetes manifests (Deployment, Services, Secrets, ConfigMap, RBAC) |
| `workspace/` | Agent workspace content — skills, tools reference, identity, persona |
| `.github/workflows/` | CI pipelines for building and pushing OCI images |

## Images

**`oci.killinit.cc/openclaw/openclaw`** — Custom OpenClaw image with CLI tools (kubectl, flux, helm, kustomize, yq, sops, jq) baked into `ghcr.io/openclaw/openclaw:2026.2.6`. Multi-arch (amd64 + arm64).

**`oci.killinit.cc/openclaw/workspace`** — Scratch image containing only the `workspace/` directory. Delivered to the pod via Kubernetes ImageVolume.

## Architecture

```
Pod (openclaw namespace)
├── init: sysctler          — IP forwarding for Tailscale
├── init: init-workspace    — copies workspace + config to PVC
├── openclaw                — OpenClaw server on port 18789
└── tailscale               — mesh networking sidecar
```

- **Storage:** 5Gi Ceph RBD PVC at `/home/node/.openclaw/` — persists agent state across restarts
- **Workspace:** refreshed from OCI image on every start, skills at `workspace/skills/`
- **Config:** `openclaw.json` via ConfigMap, copied to PVC by init container
- **Kubeconfig:** multi-cluster access (ottawa, robbinsdale, stpetersburg) via Tailscale k8s-operator endpoints
- **Networking:** Tailscale sidecar, HTTPRoute via Gateway API

## Models

| Provider | Model | Role |
|----------|-------|------|
| `nvidia` | `moonshotai/kimi-k2.5` | Default (131k ctx, reasoning) |
| `anthropic` | `claude-opus-4-6` | Fallback (200k ctx, multimodal) |
| `llama-cpp` | `Qwen3-Coder-Next` | Local via Tailscale egress |

## Skills

Workspace skills at `workspace/skills/*/SKILL.md`:

- **flux-debugging** — Flux reconciliation troubleshooting
- **pod-troubleshooting** — Container failure diagnosis
- **gitops-deploy** — End-to-end deployment workflow
- **zot-registry** — OCI registry operations
- **memory-management** — Session and context management

## GitOps Flow

```
git push → GitHub Actions builds images → Flux reconciles manifests → pod restarts with fresh images
```

1. Push to `main`
2. CI builds and pushes via `skopeo copy docker-archive:` (Zot rejects `docker push`)
3. Flux fetches from GitRepository source, applies `./kustomization`
4. Flux substitutes variables from cluster ConfigMaps/Secrets, decrypts SOPS secrets
5. `kubectl rollout restart` to pick up new `:latest` images

## Secrets

All secrets are SOPS-encrypted with PGP key `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`. Flux decrypts at apply time.

## Registry

Uses Zot at `oci.killinit.cc`. Push **must** use skopeo — `docker push` and `crane push` produce manifests Zot rejects. Multi-arch via `crane index append`.
