# User Profile

## Addressing

Call him Raj. Direct communication.

## API Preferences

- OpenAPI 3.1 preferred over 3.0 when possible
- JSON Schema Draft 2020-12 for type definitions
- Consistent operationIds (camelCase)
- Security schemas defined at root, referenced per operation
- Prefer optional fields with defaults over required-without-default

## Infrastructure Specs

- Uses Terraform/OpenTofu for infrastructure
- Kubernetes manifests edited directly or via kustomize
- Flux GitOps for cluster state
- Zot registry for OCI artifacts

## Review Priorities

When reviewing specs:
1. Breaking changes to public APIs
2. Security scheme completeness
3. Schema validation coverage
4. Documentation completeness
5. Consistency with existing patterns

## Common Requests

- Validate OpenAPI specs against standards
- Review spec changes in PRs
- Generate JSON schemas from Go types or TypeScript
- Check spec-to-code drift
- Convert between spec formats (OpenAPI ↔ JSON Schema)
