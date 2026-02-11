---
name: CI Diagnosis
description: Diagnose GitHub Actions workflow failures — build errors, skopeo push failures, crane manifest issues, workspace build problems. Use when CI runs fail or images aren't updating.
requires: [gh]
---

# CI Diagnosis

## Steps

### 1. Check Recent Runs
```bash
gh run list --repo rajsinghtech/openclaw-workspace --limit 10
```

### 2. Inspect a Failed Run
```bash
gh run view <run-id> --repo rajsinghtech/openclaw-workspace
gh run view <run-id> --repo rajsinghtech/openclaw-workspace --log-failed
```

### 3. Common Failures

**Build failure (Dockerfile.openclaw):**
- Tool download URL changed or version doesn't exist
- QEMU emulation issue on arm64 build
- Base image `ghcr.io/openclaw/openclaw:2026.2.9` unavailable

**Push failure (skopeo):**
- Zot registry unreachable from GHA runner
- Bad credentials (`ZOT_USERNAME`/`ZOT_PASSWORD` secrets)
- `skopeo copy` format wrong — must be `docker-archive:<file>.tar`

**Manifest failure (crane):**
- `crane index append` fails if per-arch images weren't pushed
- Tag format mismatch

**Workspace build failure:**
- Dockerfile.workspace syntax error
- Missing files referenced in COPY

### 4. Fix Pattern
```bash
# Clone, fix the issue
git clone https://github.com/rajsinghtech/openclaw-workspace.git /tmp/oc-fix
cd /tmp/oc-fix
# edit the file...
git add <file> && git commit -m "fix: ..." && git push

# Watch the new run
gh run list --repo rajsinghtech/openclaw-workspace --limit 1
gh run watch <new-run-id> --repo rajsinghtech/openclaw-workspace
```
