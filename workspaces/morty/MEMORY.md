# Operational Memory

Curated knowledge from past audit sessions. Update when you discover new patterns or gotchas.

## Validation Pitfalls

- `kustomize build` fails silently on missing files — always cross-check `resources[]` against actual files
- `configMapGenerator` files list must include `cron-jobs.json` alongside `openclaw.json`
- YAML anchors in deployment.yaml don't survive kustomize — use explicit values

## Config Escaping

- Flux postBuild substitutes all `${VAR}` — repo files must use `$${VAR}` for OpenClaw's own env resolution
- Double-check all `apiKey` fields in openclaw.json for correct escaping after edits

## Container Facts

- Container name: `openclaw` (not `main`)
- Init containers: `sysctler`, `init-workspace`
- Config path: `/home/node/.openclaw/clawdbot.json` (emptyDir, writable)
- Workspace path: `/home/node/.openclaw/workspaces/<agent>/`

## CI Patterns

- Push method: `skopeo copy docker-archive:` only (Zot rejects docker push)
- Multi-arch: `crane index append` after per-arch skopeo pushes
- Base image: `ghcr.io/openclaw/openclaw:2026.2.9`

## Skill Design Patterns

- Skill descriptions should function as routing logic (when to use / when NOT to use)
- Negative examples ("Don't use when...") reduce misfires between similar skills
- Templates and examples inside skills are free when the skill isn't invoked
- Design for compaction: write findings to `/tmp/outputs/` as you go
- Standard artifact path: `/tmp/outputs/<task>.md`
