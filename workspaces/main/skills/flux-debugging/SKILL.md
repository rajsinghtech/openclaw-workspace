---
name: Flux Debugging
description: Diagnose Flux CD reconciliation failures — stale revisions, failed applies, dependency errors, SOPS decrypt failures. Use when kustomization is not Ready, source shows old commit, or flux events show errors.
requires: [flux, kubectl]
---

# Flux Debugging

## Diagnostic Chain

Always follow this order — each step narrows the problem:

```bash
# 1. Source health — is Flux seeing the latest commit?
flux get sources git -A | grep openclaw

# 2. Kustomization health — did it apply successfully?
flux get kustomizations -A | grep openclaw

# 3. Events — what went wrong?
flux events -A --for Kustomization/openclaw-workspace
kubectl get events -n flux-system --sort-by='.lastTimestamp' | tail -20
```

## Decision Tree

| Source Status | Kustomization Status | Problem | Action |
|---------------|---------------------|---------|--------|
| Old revision | any | Stale source | See `failures.md` → Stale Revision |
| Current | Ready=False | Apply error | See `failures.md` → Failed Apply |
| Current | Ready=False (dependency) | Blocked | See `failures.md` → Dependency Not Ready |
| Current | SOPS error | Decrypt failure | See `failures.md` → SOPS Decrypt Error |
| Current | Ready=True | Flux is fine | Problem is elsewhere (pod, config, etc.) |

## Quick Actions

```bash
# Force full reconciliation (source + apply)
flux reconcile kustomization openclaw-workspace --with-source

# Suspend for manual debugging
flux suspend kustomization openclaw-workspace

# Resume after manual fixes
flux resume kustomization openclaw-workspace

# Nuclear: force re-fetch and re-apply everything
flux reconcile kustomization openclaw-workspace --with-source --force
```

For detailed failure diagnosis steps, read `failures.md` in this skill directory.
