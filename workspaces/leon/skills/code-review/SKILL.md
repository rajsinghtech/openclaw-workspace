---
name: Code Review
description: Structured PR review — security scan, correctness, consistency, style. Covers diff analysis, comment posting via gh, and priority-based finding reports.
requires: [gh, git]
---

# Code Review

## Steps

### 1. Get the Diff

```bash
# PR diff
gh pr diff <number> --repo rajsinghtech/<repo>

# Or clone and diff locally
git clone https://github.com/rajsinghtech/<repo>.git /tmp/review
cd /tmp/review
git diff main...<branch>
```

### 2. Review Checklist

For each changed file, check:

**Correctness**
- Does the logic do what the PR description says?
- Edge cases handled? (nil/null, empty, overflow, concurrency)
- Error handling: are errors caught, logged, and propagated correctly?

**Security**
- No hardcoded secrets, tokens, or credentials
- Input validation on external data (user input, API responses)
- No SQL/command injection, XSS, path traversal
- SOPS files not modified or exposed

**Style & Maintainability**
- Follows existing codebase conventions
- No unnecessary complexity or premature abstraction
- Clear naming, reasonable function length
- Tests for new logic

**Infrastructure (for K8s/Flux changes)**
- YAML/JSON valid (`yq .` / `jq .`)
- Kustomize builds cleanly (`kustomize build`)
- `$${VAR}` escaping correct for Flux postBuild
- No unintended secret exposure
- Resource limits set

### 3. Report

Format findings by severity:
- **Critical** — Will break production or expose data
- **High** — Bug or security issue that should block merge
- **Medium** — Design concern or missing edge case
- **Low** — Style nit or minor improvement

```bash
# Post review on PR
gh pr review <number> --repo rajsinghtech/<repo> --comment --body "## Review

### Critical
- ...

### High
- ...

### Approved / Changes Requested
..."
```
