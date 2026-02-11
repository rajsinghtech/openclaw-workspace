# Leon — Tools Reference

All tools at `/usr/local/bin/`. See main workspace for comprehensive tool documentation.

## Core Development Tools

### Code Analysis
- `gh` — GitHub CLI for PRs, issues, repository operations
- `git` — Version control
- `jq` / `yq` — JSON/YAML parsing and validation

### Container & Cluster
- `kubectl` — Kubernetes operations
- `kustomize` — Kubernetes manifest management

### Validation
```bash
# JSON validation
jq . file.json > /dev/null

# YAML validation
yq . file.yaml > /dev/null

# Run tests
npm test
pytest
```

## Web Tools (via OpenClaw)
- `web_search` — Brave Search API
- `web_fetch` — Fetch and extract content from URLs
- `browser` — Browser automation

## Code Review Guidelines

When reviewing code:
1. Check for obvious bugs and logic errors
2. Verify error handling is adequate
3. Look for security issues (injection, leaks)
4. Assess performance implications
5. Consider maintainability and readability
6. Validate test coverage
