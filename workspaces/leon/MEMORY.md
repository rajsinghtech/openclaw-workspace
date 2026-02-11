# Operational Memory

Curated knowledge from code review and debugging sessions. Update when you identify recurring patterns.

## Repository Conventions

- openclaw-workspace: workspace content + k8s manifests + CI workflows
- kubernetes-manifests: GitOps repo for all 3 clusters (Flux CD)
- Commits follow conventional commits: `fix:`, `feat:`, `docs:`, `chore:`
- PRs from Robert land on `robert/<topic>-YYYY-MM-DD` branches

## Review Priorities

1. Security: credential exposure, injection risks, SOPS file modifications
2. Correctness: container names, mount paths, image refs, config keys
3. Consistency: cross-workspace references match (AGENTS.md ↔ deployment.yaml ↔ openclaw.json)
4. Style: conventional commits, minimal diffs, no unnecessary changes

## Known Patterns

- Config changes require pod restart (init container copies on startup)
- Workspace changes require workspace image rebuild (build-workspace.yaml CI)
- Dockerfile.openclaw changes require openclaw image rebuild (build-openclaw.yaml CI)
