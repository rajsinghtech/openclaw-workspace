# Heartbeat Checklist

## Cluster Health
- Run `kubectl get pods -n openclaw` on all clusters and alert if any pod is not Running/Completed
- Check for CrashLoopBackOff or ImagePullBackOff across the namespace

## Flux GitOps
- Run `flux get kustomizations` and alert if any show Ready=False
- Run `flux get sources git` and alert if any source is failing

## Self-Check
- Verify workspace volume is mounted at /home/node/.openclaw/workspace
- Check that config file exists at /home/node/.openclaw/clawdbot.json

## Rules
- If everything is healthy, reply HEARTBEAT_OK
- Keep output to one bullet per finding
- Do not repeat alerts that were already surfaced in the previous heartbeat
