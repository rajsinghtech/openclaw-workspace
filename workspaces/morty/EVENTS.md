# Event-Driven Alerting

This document describes how Morty can watch for specific conditions and proactively alert, rather than relying solely on time-based heartbeats.

## Watch Conditions

Instead of periodic heartbeats, Morty can monitor for specific event conditions and trigger alerts when those conditions are met.

### Alert Triggers

| Condition | Check Command | Alert Threshold |
|-----------|---------------|-----------------|
| Pod crash | `kubectl get pods -n openclaw -o jsonpath='{.items[*].status.containerStatuses[?(@.lastState.terminated.exitCode<0)]}'` | Any crash |
| ImagePullBackOff | `kubectl get pods -n openclaw -o jsonpath='{.items[*].status.conditions[?(@.type=="PodScheduled")].message}'` | Contains "ImagePullBackOff" |
| OOMKilled | `kubectl get pods -n openclaw -o jsonpath='{.items[*].status.containerStatuses[*].lastState.terminated.reason}'` | Contains "OOMKilled" |
| Flux reconciliation failure | `flux get kustomization -A \| grep -v Ready` | Any failed reconciliation |
| Pod not Ready | `kubectl get pods -n openclaw -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}'` | Any "False" |
| High restart count | `kubectl get pods -n openclaw -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}'` | Any > 5 |
| Recent warning events | `kubectl get events -n openclaw --field-selector type=Warning --since=15m` | Any warnings in 15min |

### Event-Watch Script

Run this to check all alert conditions:

```bash
#!/bin/bash
# event-watch.sh - Check all alert conditions and output JSON

ALERTS=[]

# Check for CrashLoopBackOff or OOMKilled
CRASHES=$(kubectl get pods -n openclaw -o json | jq -r '.items[] | select(.status.containerStatuses[]?.lastState?.terminated?.exitCode < 0) | .metadata.name')
if [ -n "$CRASHES" ]; then
  ALERTS=$(echo "$ALERTS" | jq --arg msg "$CRASHES" '. + [{severity: "critical", message: "Pods with crashes: \($msg)"}]')
fi

# Check for ImagePullBackOff
IMAGE_ERR=$(kubectl get pods -n openclaw -o json | jq -r '.items[] | select(.status.phase=="Pending") | .metadata.name')
if [ -n "$IMAGE_ERR" ]; then
  ALERTS=$(echo "$ALERTS" | jq --arg msg "$IMAGE_ERR" '. + [{severity: "critical", message: "Pods with ImagePullBackOff: \($msg)"}]')
fi

# Check Flux reconciliation
FLUX_ERR=$(flux get kustomization -A 2>/dev/null | grep -v "Ready" | grep -v "NAME")
if [ -n "$FLUX_ERR" ]; then
  ALERTS=$(echo "$ALERTS" | jq --arg msg "$FLUX_ERR" '. + [{severity: "high", message: "Flux reconciliation failed: \($msg)"}]')
fi

# Check for recent warnings
WARNINGS=$(kubectl get events -n openclaw --field-selector type=Warning --since=30m -o json | jq -r '.items[] | "\(.lastTimestamp) \(.reason) \(.message)"')
if [ -n "$WARNINGS" ]; then
  ALERTS=$(echo "$ALERTS" | jq --arg msg "$WARNINGS" '. + [{severity: "medium", message: "Recent warnings: \($msg)"}]')
fi

# Output
echo "$ALERTS" | jq .
```

### Integration with Heartbeat

Add event-driven checks to HEARTBEAT.md by including the watch script:

```bash
# Run event-watch.sh before periodic heartbeat
bash /path/to/event-watch.sh

# If alerts returned, include in heartbeat response:
# ALERT: <severity> - <message>
```

## Proactive Alert Pattern

When Morty detects an alert condition, it should:

1. **Format the alert**: `ALERT: <severity> - <condition> - <details>`
2. **Include context**: What failed, when, and suggested action
3. **Escalate appropriately**:
   - `critical`: Immediate Discord message with @mention
   - `high`: Discord message, no @mention
   - `medium`: Include in next heartbeat response

## Example Alert Output

```
ALERT: critical - Pod crash detected - openclaw-xyz123 restarted 3 times in last 10 minutes. Last exit code: 137 (OOMKilled)
ALERT: high - Flux reconciliation failed - openclaw kustomization stuck on revision abc123, error: "git repository not found"
ALERT: medium - Warning events - 2 warning events in last 30min: FailedMount (openclaw ConfigMap)
```
