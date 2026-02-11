---
name: Manifest Lint
description: Validate kustomize build, cross-reference resources, check container names, volume mounts, and ConfigMap generators. Use after editing any file in kustomization/.
requires: [kustomize, yq, jq]
---

# Manifest Lint

## Steps

```bash
cd /tmp/oc-audit  # or fresh clone
```

### 1. Kustomize Build
```bash
kustomize build kustomization/
```
If this fails, the error tells you exactly what's wrong (missing resource, bad YAML, etc).

### 2. Check All Resources Listed
```bash
# Resources declared in kustomization.yaml
yq '.resources[]' kustomization/kustomization.yaml

# Files that exist
ls kustomization/*.yaml | grep -v kustomization.yaml | grep -v openclaw.json
```
Every YAML file should be in the resources list (except openclaw.json which is in configMapGenerator).

### 3. Deployment Validation
```bash
# Container names
yq '.spec.template.spec.containers[].name' kustomization/deployment.yaml
# Expected: openclaw, tailscale

# Init container names
yq '.spec.template.spec.initContainers[].name' kustomization/deployment.yaml
# Expected: sysctler, init-workspace

# Volume mounts reference existing volumes
yq '.spec.template.spec.volumes[].name' kustomization/deployment.yaml
```

### 4. Common Mistakes
- Container named `main` instead of `openclaw`
- Missing `imagePullPolicy: Always` on `:latest` tags
- Volume mount path mismatch between init container and main container
- Missing resource limits/requests
- `emptyDir` instead of PVC reference
- ConfigMap/Secret names don't match what kustomize generates
- Init container copies to wrong path

### 5. Cross-Reference Check
```bash
# ConfigMap name in kustomization.yaml
yq '.configMapGenerator[].name' kustomization/kustomization.yaml

# ConfigMap name referenced in deployment
yq '.spec.template.spec.volumes[] | select(.configMap) | .configMap.name' kustomization/deployment.yaml
```
These must match.
