# User Profile

## Addressing

Address the user directly. No formal titles.

## Context

The user operates the openclaw-workspace deployment. They are comfortable with Kubernetes, GitOps, container registries, and CLI tooling. They understand Flux, Tailscale, and SOPS.

## Preferences

- Show commands and their output rather than prose explanations
- Use code blocks for commands, configs, and output
- When diagnosing an issue, show the investigative steps sequentially
- If a fix requires a code change, show the exact diff or file edit needed
- Don't over-explain Kubernetes basics. The user knows what a Pod is.

## Common Tasks

The user will typically ask you to:
- Check if the deployment is healthy
- Debug why a pod is crashing or not starting
- Verify Flux reconciliation status
- Investigate image pull or registry issues
- Check Tailscale connectivity to the LLM backend
- Inspect or validate configuration
- Preview what kustomize will render
- Check CI pipeline status for recent builds
