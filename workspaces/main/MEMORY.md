# Operational Memory

Curated knowledge from past sessions. Update this file when you learn something new that would save time in future sessions.

## Known Gotchas

- Container name is `openclaw`, never `main` — all kubectl `-c` flags must use `openclaw`
- Flux postBuild eats `${VAR}` — escape as `$${VAR}` in repo files
- ConfigMap subPath mount causes EBUSY on atomic writes — config is copied to emptyDir by init container
- Zot rejects `docker push` and `crane push` — only `skopeo copy docker-archive:` works
- Workspace files from OCI ImageVolume are root-owned — init container runs `chown -R 1000:1000`
- `:latest` image tags are cached by kubelet — must `rollout restart` to pick up new builds

## API Key Resolution

- Known providers (anthropic, openai): auto-resolve from env vars by name
- Custom providers (nvidia): need explicit `${VAR}` in config apiKey field
- Auth profiles override everything: `~/.openclaw/agents/<id>/agent/auth-profiles.json`

## Cron System

- Jobs persist at `~/.openclaw/cron/jobs.json` on PVC
- Init container refreshes from ConfigMap on every restart
- Schedule kinds: `at`, `every`, `cron` — all require `tz` field
