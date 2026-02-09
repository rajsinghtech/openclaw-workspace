# OpenClaw Workspace

## Architecture

This repo contains two independently built artifacts plus Kubernetes manifests:

### Images
- **`oci.killinit.cc/openclaw/openclaw`** — Custom OpenClaw image with CLI tools baked in
  - Base: `ghcr.io/openclaw/openclaw:2026.2.6`
  - Tools: kubectl, flux, helm, kustomize, yq, sops, jq
  - Built from `Dockerfile.openclaw`
  - Workflow: `.github/workflows/build-openclaw.yaml`
  - Triggers on: `Dockerfile.openclaw` or workflow changes

- **`oci.killinit.cc/openclaw/workspace`** — Workspace content (markdown, skills)
  - Pure content image (`FROM scratch`)
  - Built from `Dockerfile.workspace`
  - Workflow: `.github/workflows/build-workspace.yaml`
  - Triggers on: `workspace/**`, `Dockerfile.workspace`, or workflow changes

### Kubernetes (`kustomization/`)
- Raw manifests managed by Flux via GitRepository source
- Flux watches `rajsinghtech/openclaw-workspace` repo, path `./kustomization`
- Variable substitution from `common-secrets`, `common-settings`, `cluster-settings`, `cluster-secrets`
- SOPS encryption with PGP key: `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`

## Registry: Zot (`oci.killinit.cc`)

**Critical**: Zot rejects manifests pushed by `docker push`, `crane push`, and buildx `--push`.
Always use `skopeo copy docker-archive:<file>.tar docker://<registry>/<image>:<tag>` to push.
Multi-arch manifests work via `crane index append` after per-arch images are pushed.

## Build Pattern

Tools are downloaded **natively on the CI runner** (not inside Docker/QEMU) for both architectures,
then COPY'd into the image. This avoids slow QEMU-emulated downloads and flaky CDN issues.

```
Runner (amd64) → download tools/amd64/* and tools/arm64/*
                → docker build (amd64, native) → docker save → skopeo push
                → buildx build (arm64, QEMU, just COPY) → save tar → skopeo push
                → crane index append (multi-arch manifest)
```

## Key Paths

| Path | Purpose |
|------|---------|
| `/home/node/.openclaw/` | Runtime state dir (emptyDir, fresh each restart) |
| `/home/node/.openclaw/workspace/` | Workspace content (copied from OCI ImageVolume) |
| `/home/node/.openclaw/clawdbot.json` | Config (mounted from ConfigMap) |
| `/usr/local/bin/` | CLI tools (baked into openclaw image) |

## Deployment

- Tailscale sidecar with ephemeral auth, POD_NAME as hostname
- Workspace content delivered via Kubernetes ImageVolume (`pullPolicy: Always`)
- Config delivered via ConfigMap
- Single replica, Recreate strategy
