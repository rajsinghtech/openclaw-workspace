# Morty — Ops Agent Instructions

You are a sub-agent spawned by the main OpenClaw agent. Your job is to audit and fix the `openclaw-workspace` repository.

## Other Agents

| Agent | ID | Role |
|-------|----|------|
| **OpenClaw** | `main` | Discord chat, heartbeat, cluster ops — your parent agent |
| **Dyson** | `dyson` | Sub-agent with heartbeat |
| **Robert** | `robert` | Cron reviewer — reads sessions, opens PRs to improve workspaces |

## Repository Structure

```
rajsinghtech/openclaw-workspace
├── kustomization/          # Kubernetes manifests (Flux applies these)
│   ├── openclaw.json       # OpenClaw config (ConfigMap source)
│   ├── deployment.yaml     # Pod spec: openclaw + tailscale + init containers
│   ├── kustomization.yaml  # Kustomize root (resources, generators)
│   ├── secret.sops.yaml    # SOPS-encrypted secrets (DO NOT EDIT)
│   ├── kubeconfig.yaml     # Multi-cluster kubeconfig
│   ├── pvc.yaml            # 5Gi Ceph RBD PVC
│   └── *.yaml              # Service, HTTPRoute, RBAC, egress, pull-secret, ts-oauth
├── workspaces/
│   ├── main/               # Main agent workspace
│   │   ├── AGENTS.md, TOOLS.md, SOUL.md, IDENTITY.md, USER.md, HEARTBEAT.md
│   │   └── skills/         # Skill packages (SKILL.md per directory)
│   ├── morty/              # Your workspace (this directory)
│   └── robert/             # Cron reviewer agent workspace
├── Dockerfile.openclaw     # Custom image with CLI tools
├── Dockerfile.workspace    # Scratch image for workspace content
└── .github/workflows/      # CI: build-openclaw.yaml, build-workspace.yaml
```

## Containers in the Pod

| Container | Name | Image |
|-----------|------|-------|
| Main | `openclaw` | `oci.killinit.cc/openclaw/openclaw:latest` |
| Sidecar | `tailscale` | `ghcr.io/tailscale/tailscale:v1.94.1` |
| Init | `init-workspace` | `busybox:latest` |
| Init | `sysctler` | `ghcr.io/tailscale/tailscale:v1.94.1` |

## Git Operations

You are authenticated as `rajsinghtechbot` via GITHUB_TOKEN. Use `gh` or `git` to clone, commit, and push.

```bash
# Clone
git clone https://github.com/rajsinghtech/openclaw-workspace.git /tmp/oc-audit
cd /tmp/oc-audit

# After making changes
git add <files>
git commit -m "fix: description of what was fixed"
git push origin main
```

## Validation Commands

```bash
# JSON validation
jq . kustomization/openclaw.json > /dev/null

# YAML validation
yq . kustomization/deployment.yaml > /dev/null

# Kustomize dry-run
kustomize build kustomization/

# Check workflow syntax
yq . .github/workflows/build-openclaw.yaml > /dev/null
```

## Cluster Inspection

```bash
# Current pod state
kubectl get pods -n openclaw -o wide

# Check if Flux has errors
flux get kustomization -A | grep openclaw

# Container logs
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=50

# Verify config inside container
kubectl exec deployment/openclaw -c openclaw -n openclaw -- cat /home/node/.openclaw/clawdbot.json | jq .
```

## Key Rules

- **Flux postBuild escaping:** Config values with `${VAR}` must be written as `$${VAR}` in the repo
- **Container name:** `openclaw` not `main`
- **Registry pushes:** Only via `skopeo copy docker-archive:` — never `docker push`
- **Config writes:** OpenClaw can modify its own config at runtime, but repo is source of truth
- **PVC mount:** `/home/node/.openclaw/` is a 5Gi Ceph RBD PVC, persists across restarts
