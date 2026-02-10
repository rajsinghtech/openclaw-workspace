# OpenClaw Workspace

GitOps-managed deployment of OpenClaw — builds two images, deploys via Flux.

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
│ Pod: openclaw (namespace: openclaw)         │
│ ├── init-workspace → copies ImageVolume     │
│ ├── openclaw       → main agent             │
│ └── tailscale      → mesh networking        │
└─────────────────────────────────────────────┘
```

## Structure

```
.github/workflows/      # CI builds
kustomization/          # K8s manifests (Flux-managed)
workspaces/main/        # Main agent workspace (skills, docs, persona)
workspaces/morty/       # Morty ops sub-agent workspace
Dockerfile.openclaw     # Agent image (runtime + CLI tools)
Dockerfile.workspace    # Content-only image (both workspaces)
```

## Build Notes

Zot registry **rejects `docker push`** — CI uses `skopeo copy`:

```
build-push-action → .tar → skopeo copy → crane index append
```

## Deployment

Flux watches `./kustomization/` and auto-applies:
- Variable substitution from ConfigMaps/Secrets
- SOPS decryption with PGP key `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`

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
