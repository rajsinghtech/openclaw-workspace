---
name: Zot Registry
description: OCI registry operations with Zot (oci.killinit.cc)
requires: [kubectl]
---

# Zot Registry

Registry: `oci.killinit.cc`

## Critical: Push Method

Zot rejects manifests from `docker push`, `crane push`, and buildx `--push`. The **only** working push method is:

```bash
skopeo copy docker-archive:<file>.tar docker://oci.killinit.cc/<repo>/<image>:<tag>
```

This is handled automatically by CI workflows. Never change the push method.

## Image Inspection

```bash
# Check if an image exists and view its manifest
crane manifest oci.killinit.cc/openclaw/openclaw:latest | jq .
crane manifest oci.killinit.cc/openclaw/workspace:latest | jq .

# Get the digest
crane digest oci.killinit.cc/openclaw/openclaw:latest
crane digest oci.killinit.cc/openclaw/workspace:latest

# List tags
crane ls oci.killinit.cc/openclaw/openclaw
crane ls oci.killinit.cc/openclaw/workspace

# Full inspect (config + layers)
skopeo inspect docker://oci.killinit.cc/openclaw/openclaw:latest
```

## Multi-Arch Manifests

Per-arch images are pushed individually, then combined:

```bash
# After pushing amd64 and arm64 images separately via skopeo:
crane index append \
  --manifest oci.killinit.cc/openclaw/openclaw:<sha>-amd64 \
  --manifest oci.killinit.cc/openclaw/openclaw:<sha>-arm64 \
  --tag oci.killinit.cc/openclaw/openclaw:<sha> \
  --tag oci.killinit.cc/openclaw/openclaw:latest
```

## Authentication

```bash
# Login (credentials from Zot secrets)
crane auth login oci.killinit.cc -u <username> -p <password>

# Skopeo uses --creds or --authfile
skopeo inspect docker://oci.killinit.cc/openclaw/openclaw:latest --creds user:pass
```

In-cluster, pull credentials come from the `zot-pull-secret` imagePullSecret:

```bash
# Verify pull secret
kubectl get secret zot-pull-secret -n openclaw -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

## Troubleshooting

### "manifest invalid" on Push
You're using `docker push` or `crane push`. Switch to `skopeo copy docker-archive:`.

### ImagePullBackOff in Cluster
```bash
# Check pod events
kubectl describe pod -l app.kubernetes.io/name=openclaw -n openclaw | grep -A3 "Failed"

# Verify the image tag exists
crane ls oci.killinit.cc/openclaw/openclaw

# Verify pull secret is correct
kubectl get secret zot-pull-secret -n openclaw -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq '.auths'
```

### Stale Image After CI
Kubernetes caches `:latest` tags. Force a re-pull:

```bash
kubectl rollout restart deployment openclaw -n openclaw
```

The workspace ImageVolume uses `pullPolicy: Always`, so it re-pulls on every pod start.
