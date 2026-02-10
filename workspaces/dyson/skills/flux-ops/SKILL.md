---
name: Flux Operations
description: Diagnose and manage Flux CD across all clusters
requires: []
---

# Flux Operations

Diagnostic and management procedures for Flux CD across talos-ottawa, talos-robbinsdale, talos-stpetersburg.

## Diagnostic Chain

Run these in order to trace Flux issues from source to workload:

### 1. Sources
```bash
flux --context <ctx> get sources git -A
flux --context <ctx> get sources helm -A
flux --context <ctx> get sources oci -A
```
- Check all sources are fetching successfully
- Note last fetch time — stale fetches (>10m old) indicate connectivity issues

### 2. Kustomizations
```bash
flux --context <ctx> get kustomizations -A
```
- Identify any with `Ready: False`
- Check the `message` field for the error

### 3. HelmReleases
```bash
flux --context <ctx> get helmreleases -A
```
- Identify any with `Ready: False` or `Suspended: True`
- For failed releases: check Helm history with `helm --kube-context <ctx> history <release> -n <ns>`

### 4. Events
```bash
kubectl --context <ctx> get events -n flux-system --sort-by='.lastTimestamp' | tail -30
```
- Look for reconciliation errors, auth failures, or timeout events

## Common Failures

### Stale GitRepository Source
**Symptom:** Source shows old revision, kustomizations not updating
**Diagnosis:**
```bash
flux --context <ctx> get sources git -A
kubectl --context <ctx> describe gitrepository <name> -n flux-system
```
**Fix:** Force reconcile `flux --context <ctx> reconcile source git <name> -n flux-system`

### SOPS Decryption Error
**Symptom:** Kustomization fails with "decryption failed" or "unable to decrypt"
**Diagnosis:**
```bash
flux --context <ctx> get kustomization <name> -n flux-system
kubectl --context <ctx> logs -n flux-system deploy/kustomize-controller --tail=30 | grep -i sops
```
**Fix:** This is a secrets issue — escalate to user. Dyson cannot fix SOPS problems.

### Dependency Not Ready
**Symptom:** Kustomization shows "dependency not ready"
**Diagnosis:**
```bash
flux --context <ctx> get kustomization <name> -A -o json | jq '.items[].spec.dependsOn'
```
**Fix:** Trace the dependency chain and fix the root kustomization first.

### Substitution Variable Missing
**Symptom:** "variable not found" or rendered manifest has literal `${VAR}`
**Diagnosis:**
```bash
kubectl --context <ctx> get configmap -n flux-system cluster-settings -o yaml
kubectl --context <ctx> get configmap -n flux-system common-settings -o yaml
```
**Fix:** Check if the variable is defined in the expected ConfigMap. Open PR to add missing variable.

### HelmRelease Upgrade Failed
**Symptom:** HelmRelease stuck in "upgrade retries exhausted"
**Diagnosis:**
```bash
helm --kube-context <ctx> history <release> -n <ns>
kubectl --context <ctx> describe helmrelease <name> -n <ns>
```
**Fix:** Often resolved by bumping the chart version or fixing values. Open PR with the fix.

## Operations

### Force Reconcile
```bash
# Reconcile a specific kustomization with its source
flux --context <ctx> reconcile kustomization <name> -n flux-system --with-source

# Reconcile all kustomizations
flux --context <ctx> get kustomizations -A --no-header | awk '{print $1, $2}' | while read ns name; do
  flux --context <ctx> reconcile kustomization "$name" -n "$ns"
done
```

### Suspend / Resume
Use sparingly — only for debugging or temporarily blocking reconciliation:
```bash
flux --context <ctx> suspend kustomization <name> -n <ns>
flux --context <ctx> resume kustomization <name> -n <ns>
```

### Check Flux Controllers
```bash
kubectl --context <ctx> get pods -n flux-system
kubectl --context <ctx> logs -n flux-system deploy/source-controller --tail=20
kubectl --context <ctx> logs -n flux-system deploy/kustomize-controller --tail=20
kubectl --context <ctx> logs -n flux-system deploy/helm-controller --tail=20
```
