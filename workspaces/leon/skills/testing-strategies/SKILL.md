---
name: Testing Strategies
description: Identify missing test coverage, design test cases, recommend test strategies. Covers unit, integration, and end-to-end testing patterns with coverage gap analysis.
requires: []
---

# Testing Strategies

## Test Coverage Analysis

### Identify gaps

```bash
# Check existing tests
find . -name "*_test.go" -o -name "*.test.ts" -o -name "test_*.py" | wc -l

# Check test commands
grep -r "test" Makefile package.json 2>/dev/null
```

### Priority order for new tests

1. **Critical paths** — Auth, payments, data mutations
2. **Edge cases** — Nil inputs, empty collections, boundary values
3. **Error paths** — Network failures, invalid input, timeouts
4. **Integration points** — API boundaries, database queries, external services
5. **Regression** — Any bug that was found should get a test

## Test Design Principles

- **One assertion per test** — Tests should verify one behavior
- **Descriptive names** — `TestUserLogin_WithExpiredToken_ReturnsUnauthorized`
- **Arrange-Act-Assert** — Clear setup, action, verification
- **No test interdependence** — Each test runs independently
- **Test behavior, not implementation** — Don't test private methods directly

## Infrastructure Testing

For Kubernetes manifests:

```bash
# Syntax validation
jq . kustomization/openclaw.json > /dev/null
yq . kustomization/deployment.yaml > /dev/null

# Kustomize render
kustomize build kustomization/ > /dev/null

# Dry-run apply
kustomize build kustomization/ | kubectl apply --dry-run=client -f -
```
