# Workspace Tools

All tools are installed at `/usr/local/bin/` and on `$PATH`. The workspace has a ServiceAccount (`tailscale`) with RBAC configured for in-cluster access to the `openclaw` namespace.

## Skills

Skills are higher-level knowledge packages that build on the CLI tools below. Check `workspace/skills/` for structured guides on:
- **flux-debugging** — Flux reconciliation troubleshooting chain
- **pod-troubleshooting** — Container failure diagnosis
- **gitops-deploy** — End-to-end deployment workflow
- **zot-registry** — OCI registry operations
- **memory-management** — Session and context management

Use skills first for common tasks — they encode tested diagnostic sequences and known gotchas.

## kubectl

Kubernetes cluster management. In-cluster config is automatic.

```bash
# Pod status
kubectl get pods -n openclaw
kubectl get pods -n openclaw -o wide
kubectl describe pod -l app.kubernetes.io/name=openclaw -n openclaw

# Container logs
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=100
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c tailscale --tail=50
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c init-workspace

# Deployment status
kubectl get deployment openclaw -n openclaw
kubectl rollout status deployment openclaw -n openclaw
kubectl rollout restart deployment openclaw -n openclaw

# Config inspection
kubectl get configmap openclaw-config -n openclaw -o yaml
kubectl get secret openclaw-secrets -n openclaw -o yaml

# Events (sorted by time)
kubectl get events -n openclaw --sort-by='.lastTimestamp'

# Resources in the namespace
kubectl get all -n openclaw

# Check ImageVolume reference
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o jsonpath='{.items[0].spec.volumes[?(@.name=="workspace")].image}'

# Check pull secret
kubectl get secret zot-pull-secret -n openclaw -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .

# Exec into the main container
kubectl exec -it deployment/openclaw -c openclaw -n openclaw -- /bin/sh

# Check DNS resolution for LLM backend
kubectl exec deployment/openclaw -c openclaw -n openclaw -- nslookup stpetersburg-llama-cpp
```

## flux

Flux CD GitOps toolkit. Used to inspect and manage the GitOps reconciliation.

```bash
# Overall status of Flux kustomizations
flux get kustomization -A

# Git source status
flux get source git -A

# OCI source status (if any)
flux get source oci -A

# Force reconciliation (pulls latest from git + reapplies)
flux reconcile kustomization <name> --with-source

# Suspend/resume reconciliation (useful during debugging)
flux suspend kustomization <name>
flux resume kustomization <name>

# Check Flux controller logs
kubectl logs -n flux-system deployment/kustomize-controller --tail=50
kubectl logs -n flux-system deployment/source-controller --tail=50

# Flux events
flux events -A --for Kustomization/<name>
```

## helm

Kubernetes package manager. Available for inspecting Helm releases in the cluster.

```bash
# List releases across namespaces
helm list -A

# Check release status
helm status <release> -n <namespace>

# Show values of a release
helm get values <release> -n <namespace>
```

## kustomize

Preview what Flux will apply from the repo's kustomization directory.

```bash
# Build and preview the full rendered output
# NOTE: this requires the repo to be cloned. The workspace content doesn't include kustomization/
# but you can use it to validate kustomize overlays if files are available.
kustomize build <path>

# With variable substitution preview (manual)
kustomize build <path> | yq
```

## sops

Secrets encryption and decryption. The SOPS config (`.sops.yaml`) uses PGP key `FAC8E7C3A2BC7DEE58A01C5928E1AB8AF0CF07A5`.

```bash
# Decrypt a SOPS-encrypted file (requires the PGP private key)
sops -d secret.sops.yaml

# Encrypt a plaintext YAML file
sops -e secret.yaml > secret.sops.yaml

# Edit an encrypted file in-place (opens in $EDITOR)
sops secret.sops.yaml

# Rotate encryption keys
sops --rotate -i secret.sops.yaml

# Show metadata without decrypting
sops filestatus secret.sops.yaml
```

Note: Decryption requires the PGP private key to be available in the GPG keyring. In the cluster, Flux handles decryption via its SOPS provider. You likely cannot decrypt secrets interactively from inside this pod unless the key is imported.

## yq

YAML processor. Useful for inspecting and transforming Kubernetes manifests.

```bash
# Pretty-print YAML
yq . file.yaml

# Extract a specific field
kubectl get deployment openclaw -n openclaw -o yaml | yq '.spec.template.spec.containers[].image'

# List all container images in a pod
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o yaml | yq '.items[0].spec.containers[].image'

# Check init container images
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o yaml | yq '.items[0].spec.initContainers[].image'
```

## jq

JSON processor. Useful for working with kubectl JSON output and API responses.

```bash
# Pretty-print JSON
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | jq '.items[0].status.phase'

# Get container statuses
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | jq '.items[0].status.containerStatuses[] | {name, ready, restartCount, state}'

# Get init container statuses
kubectl get pod -l app.kubernetes.io/name=openclaw -n openclaw -o json | jq '.items[0].status.initContainerStatuses[] | {name, ready, state}'

# Parse events
kubectl get events -n openclaw -o json | jq '.items | sort_by(.lastTimestamp) | .[-10:] | .[] | {type, reason, message, lastTimestamp}'
```

## Quick Health Check

Run these in sequence to get a full picture of the deployment:

```bash
kubectl get pods -n openclaw -o wide
kubectl get deployment openclaw -n openclaw
kubectl get events -n openclaw --sort-by='.lastTimestamp' | tail -20
flux get kustomization -A | grep openclaw
kubectl logs -l app.kubernetes.io/name=openclaw -n openclaw -c openclaw --tail=20
```
