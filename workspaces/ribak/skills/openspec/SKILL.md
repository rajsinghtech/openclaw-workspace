---
name: OpenSpec and API Validation
description: Validate and design OpenAPI 3.x specifications, JSON Schema, and infrastructure-as-code specs. Reference patterns from OpenSpec and Landlord.
requires: [spectral, openapi-generator, yq, jq]
---

# OpenSpec API Specifications

This skill provides guidance for working with OpenAPI specifications, JSON Schema, and infrastructure API definitions.

## References

- **OpenSpec**: https://github.com/Fission-AI/OpenSpec — API specification standards and validation rules
- **Landlord**: https://github.com/jaxxstorm/landlord — Infrastructure specification examples and patterns

Use these repositories as authoritative references for:
- OpenAPI structure and validation rules
- JSON Schema patterns
- Code generation workflows
- Infrastructure spec patterns

## Validation Commands

```bash
# Clean OpenAPI validation with Spectral
spectral lint openapi.yaml --ruleset .spectral.yaml

# Validate JSON Schema conformance
jq 'if .openapi then "OpenAPI doc" elif .\$schema then "JSON Schema" else "Unknown" end' spec.json

# Check for breaking changes (requires openapi-diff or similar)
# Walkthrough comparison of two specs
yq -o json old.yaml > old.json
yq -o json new.yaml > new.json
diff <(jq .paths old.json | sort) <(jq .paths new.json | sort)
```

## Schema Generation

```bash
# Generate TypeScript from OpenAPI
openapi-generator generate -i openapi.yaml -g typescript-fetch -o ./ts-client

# Generate Go client from OpenAPI
openapi-generator generate -i openapi.yaml -g go -o ./go-client

# Generate JSON Schema from OpenAPI components
jq '.components.schemas' openapi.yaml > schemas.json
```

## OpenAPI Structure Reference

```yaml
openapi: 3.1.0
info:
  title: API Name
  version: 1.0.0
  description: Clear, concise description
servers:
  - url: https://api.example.com/v1
paths:
  /resource:
    get:
      operationId: listResources
      summary: List all resources
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourceList'
components:
  schemas:
    ResourceList:
      type: array
      items:
        $ref: '#/components/schemas/Resource'
    Resource:
      type: object
      required: [id, name]
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

## Validation Checklist

| Check | Tool | Command |
|-------|------|---------|
| Syntax | yq/jq | `yq . spec.yaml` |
| OpenAPI validity | spectral | `spectral lint spec.yaml` |
| Security schemes | jq | `jq '.components.securitySchemes // {}'` |
| Operation completeness | jq | `jq '.paths[][].operationId // "missing"'` |
| Schema coverage | jq | `jq '.components.schemas | keys'` |

## Common Patterns (from Landlord)

- Use `operationId` for every operation (used for client generation)
- Prefer `snake_case` for field names, `camelCase` for operationIds
- Always include `description` for non-trivial schemas
- Use `examples` for complex or ambiguous fields
- Reference schemas from `#/components/schemas/` rather than inline

## Error Response Pattern

```yaml
ErrorResponse:
  type: object
  required: [error, message]
  properties:
    error:
      type: string
      description: Machine-readable error code
    message:
      type: string
      description: Human-readable error description
    details:
      type: object
      description: Additional context (optional)
```
