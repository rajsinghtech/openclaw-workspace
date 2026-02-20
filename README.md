# OpenClaw Workspace

GitOps-managed deployment of OpenClaw — builds two images, deploys via Flux.

> **Quick Config Reference**: See [`kustomization/CONFIG.md`](kustomization/CONFIG.md) for Kubernetes-specific configuration details including Flux escaping, cron jobs, and agent setup.

## Images

| Image | Purpose |
|-------|---------|
| `oci.killinit.cc/openclaw/openclaw` | Agent runtime with CLI tools (kubectl, flux, helm, etc.) |
| `oci.killinit.cc/openclaw/workspace` | Static content (skills, docs, config) |

## Architecture

```
GitHub Actions ──► Zot Registry ──► Flux ──► Kubernetes
                                         │
               ┌─────────────────────────────────────────────┐
               │ Pod: openclaw (namespace: openclaw)       │
               │ ├── init-workspace → copies ImageVolume     │
               │ ├── openclaw → main agent                   │
               │ └── tailscale → mesh networking             │
               └─────────────────────────────────────────────┘
```

## Structure

```
.github/workflows/       # CI builds
kustomization/           # K8s manifests (Flux-managed)
  ├── CONFIG.md        # Kubernetes-specific configuration guide
  ├── openclaw.json    # OpenClaw config (see CONFIG.md for Flux escaping)
  └── cron-jobs.json   # Cron job definitions
workspaces/main/         # Main agent workspace (skills, docs, persona)
workspaces/morty/        # Morty ops sub-agent workspace
workspaces/leon/         # Leon coding expert workspace
workspaces/dyson/        # Dyson multi-cluster monitor workspace
workspaces/robert/       # Robert cron reviewer workspace
Dockerfile.openclaw      # Agent image (runtime + CLI tools)
Dockerfile.workspace     # Content-only image (all workspaces)
```

## Flux Variable Escaping

When using Flux CD, environment variable references like `${API_KEY}` must be escaped as `$${API_KEY}` in `openclaw.json`. Flux leaves `$${VAR}` as `${VAR}` at runtime, which OpenClaw then substitutes from environment variables.

See [`kustomization/CONFIG.md`](kustomization/CONFIG.md) for full details.

## Build Notes

Zot registry **rejects `docker push`** — CI uses `skopeo copy`:

```
build-push-action → .tar → skopeo copy → crane index append
```

## Deployment

Flux watches `./kustomization/` and auto-applies:
- Variable substitution from ConfigMaps/Secrets
- SOPS decryption with PGP key `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`

## Agents

| Agent | ID | Role | Model | Workspace |
|-------|----|----|------|-----------|
| Main | `main` | Discord chat, heartbeat, cluster ops | MiniMax M2.5 | `workspaces/main/` |
| Morty | `morty` | Ops agent — config audit, manifest fixes | MiniMax M2.5 | `workspaces/morty/` |
| Dyson | `dyson` | Multi-cluster monitor — heartbeat every 30m | MiniMax M2.5 | `workspaces/dyson/` |
| Robert | `robert` | Cron reviewer — daily session analysis, PRs | MiniMax M2.5 | `workspaces/robert/` |
| Leon | `leon` | Coding expert — code review, debugging, architecture, OpenSpec | MiniMax M2.5 | `workspaces/leon/` |

## Skills

| Skill | Use case |
|-------|----------|
| `flux-debugging` | Reconcile failures, SOPS errors |
| `pod-troubleshooting` | CrashLoopBackOff, OOM |
| `gitops-deploy` | Full deploy pipeline |
| `zot-registry` | Registry issues |

## Commands

```bash
# Force sync
flux reconcile kustomization openclaw --with-source

# Check status
kubectl get pods -n openclaw
kubectl logs -l app=openclaw -n openclaw
```
test Fri Feb 20 05:37:52 UTC 2026
