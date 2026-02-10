# OpenClaw Workspace

## Architecture

This repo contains two independently built artifacts plus Kubernetes manifests:

### Images
- **`oci.killinit.cc/openclaw/openclaw`** — Custom OpenClaw image with CLI tools baked in
  - Base: `ghcr.io/openclaw/openclaw:2026.2.6` (already multi-arch amd64+arm64)
  - Tools: kubectl, flux, helm, kustomize, yq, sops, jq, gh (versions pinned as Dockerfile ARGs)
  - Multi-stage Dockerfile: `debian:bookworm-slim` downloads tools, then COPY into upstream
  - Workflow: `.github/workflows/build-openclaw.yaml`
  - Triggers on: `Dockerfile.openclaw` or workflow changes
  - Uses official Docker Actions + GHA layer cache

- **`oci.killinit.cc/openclaw/workspace`** — Workspace content (markdown, skills)
  - Pure content image (`FROM scratch`)
  - Built from `Dockerfile.workspace`
  - Workflow: `.github/workflows/build-workspace.yaml`
  - Triggers on: `workspaces/**`, `Dockerfile.workspace`, or workflow changes

### Kubernetes (`kustomization/`)
- Raw manifests managed by Flux via GitRepository source
- Flux watches `rajsinghtech/openclaw-workspace` repo, path `./kustomization`
- Variable substitution from `common-secrets`, `common-settings`, `cluster-settings`, `cluster-secrets`
- SOPS encryption with PGP key: `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`
- Config uses `configMapGenerator` with raw `openclaw.json` (not inline YAML)

## Registry: Zot (`oci.killinit.cc`)

**Critical**: Zot rejects manifests pushed by `docker push`, `crane push`, and buildx `--push`.
Always use `skopeo copy docker-archive:<file>.tar docker://<registry>/<image>:<tag>` to push.
Multi-arch manifests work via `crane index append` after per-arch images are pushed.

## Build Pattern

Tools are downloaded **inside the Dockerfile** via multi-stage build. Each tool is a separate
`RUN` layer, so Docker caches them individually. GHA cache (`cache-from`/`cache-to`) persists
layers between CI runs.

```
docker/build-push-action (amd64) → output tar → skopeo push
docker/build-push-action (arm64) → output tar → skopeo push
crane index append → multi-arch manifest
```

## Key Paths

| Path | Purpose |
|------|---------|
| `/home/node/.openclaw/` | Runtime state dir (5Gi Ceph PVC, persists across restarts) |
| `/home/node/.openclaw/workspaces/main/` | Main agent workspace (refreshed from OCI image on start) |
| `/home/node/.openclaw/workspaces/morty/` | Morty ops agent workspace (refreshed from OCI image on start) |
| `/home/node/.openclaw/clawdbot.json` | Config (copied from ConfigMap by init container, writable) |
| `/usr/local/bin/` | CLI tools (baked into openclaw image) |

## Deployment

- Tailscale sidecar with ephemeral auth, POD_NAME as hostname
- Workspace content delivered via Kubernetes ImageVolume (`pullPolicy: Always`)
- Config copied to PVC by init container (must be writable for OpenClaw auto-config)
- 5Gi Ceph RBD PVC for persistent agent state
- Two agents: main (OpenClaw) and morty (ops sub-agent)
- Single replica, Recreate strategy
