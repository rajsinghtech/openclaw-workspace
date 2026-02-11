# Tools

All tools at `/usr/local/bin/`. Authenticated as `rajsinghtechbot` via GITHUB_TOKEN.

## Schema Validation

```bash
# Validate OpenAPI 3.x spec
spectral lint openapi.yaml

# Validate JSON Schema
jq . schema.json > /dev/null

# Convert YAML to JSON for validation
yq -o json spec.yaml > spec.json
```

## Code Generation

```bash
# Generate client from OpenAPI
openapi-generator generate -i openapi.yaml -g <language> -o ./output

# Available generators
openapi-generator list
```

## gh

```bash
# Clone repos
gh repo clone rajsinghtech/<repo>.git -- /tmp/spec-review

# Review PRs with spec changes
gh pr diff <number> --repo rajsinghtech/<repo>
gh pr view <number> --repo rajsinghtech/<repo>

# Comment on PRs
gh pr comment <number> --body "..." --repo rajsinghtech/<repo>
```

## git

```bash
git clone https://github.com/rajsinghtech/<repo>.git /tmp/spec-review
git diff HEAD~1 -- '*.yaml' '*.yml' '*.json'
git log --oneline -10 --all -- '*.yaml' '*.yml'
```

## External Tools

- `web_fetch` — Fetch OpenSpec/Landlord reference docs
- `web_search` — Find API design patterns, OpenAPI best practices
- `read` — Read spec files
- `image` — Analyze API diagrams if provided

## Ribak-Specific Skills

Located in `/home/node/.openclaw/workspaces/ribak/skills/`:

| Skill | Purpose |
|-------|---------|
| `openspec/` | OpenAPI validation, JSON Schema, spec patterns |
