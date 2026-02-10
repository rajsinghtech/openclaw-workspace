---
name: Storage Operations
description: Rook-Ceph diagnostics (Ottawa + Robbinsdale) and storage troubleshooting
requires: []
---

# Storage Operations

Storage diagnostics for all 3 clusters. Ottawa and Robbinsdale run Rook-Ceph; StPetersburg uses local-path-provisioner.

## Rook-Ceph (Ottawa + Robbinsdale)

### Cluster Health
```bash
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph status
```
- `HEALTH_OK` — all good
- `HEALTH_WARN` — degraded but functional, investigate
- `HEALTH_ERR` — data at risk, report immediately

### OSD Health
```bash
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd status
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd tree
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd df
```
- Verify all OSDs are `up` and `in`
- Check for uneven data distribution (variance >10%)
- Flag OSDs >85% full

### Placement Group Status
```bash
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph pg stat
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph pg dump_stuck
```
- All PGs should be `active+clean`
- `degraded`, `undersized`, `stale`, `incomplete` PGs need investigation
- Stuck PGs: check if an OSD is down or a node is unreachable

### Pool Usage
```bash
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph df
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- ceph osd pool ls detail
kubectl --context <ctx> exec -n rook-ceph deploy/rook-ceph-tools -- rados df
```
- Check per-pool usage
- Flag pools >80% capacity
- Note replication factor (should be 3 for data pools)

### Ceph Operator
```bash
kubectl --context <ctx> get pods -n rook-ceph -l app=rook-ceph-operator
kubectl --context <ctx> logs -n rook-ceph -l app=rook-ceph-operator --tail=30
```
- Verify operator is running
- Check for reconciliation errors

## PVC Troubleshooting (All Clusters)

### Unbound PVCs
```bash
kubectl --context <ctx> get pvc -A | grep -v Bound
```
- `Pending` PVC: check events with `kubectl describe pvc <name> -n <ns>`
- Common causes: no available PV, storageClass misconfigured, Ceph pool full

### PVC Capacity
```bash
kubectl --context <ctx> get pvc -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,CAPACITY:.status.capacity.storage,CLASS:.spec.storageClassName'
```

### Volume Attachment Issues
```bash
kubectl --context <ctx> get volumeattachments
kubectl --context <ctx> get events -A --field-selector reason=FailedAttachVolume
kubectl --context <ctx> get events -A --field-selector reason=FailedMount
```
- Multi-attach errors: RWO volume still attached to old node after reschedule
- Common fix: delete the stale VolumeAttachment (but verify pod is actually gone first)

## Local-Path (StPetersburg)

```bash
# Check provisioner
kubectl --context talos-stpetersburg get pods -n local-path-storage

# List PVCs
kubectl --context talos-stpetersburg get pvc -A

# Check local-path config
kubectl --context talos-stpetersburg get configmap -n local-path-storage local-path-config -o yaml
```
- local-path provisions on the node where the pod runs
- No replication — if the node dies, data is lost
- Mostly used for AI model caches and ephemeral workloads

## Common Issues

| Symptom | Likely Cause | Action |
|---------|-------------|--------|
| HEALTH_WARN: 1 OSD down | Node offline or OSD crashed | Check node status, OSD pod logs |
| PG degraded | OSD down, rebalancing | Wait if OSD is recovering; escalate if OSD stays down |
| Pool nearfull | Storage capacity | Report — needs OSD expansion or data cleanup |
| PVC Pending | StorageClass mismatch or pool full | Check storageClass exists and pool has capacity |
| FailedMount | Stale VolumeAttachment | Verify old pod is gone, then report |
| local-path Pending | Node selector or path issue | Check provisioner logs |
