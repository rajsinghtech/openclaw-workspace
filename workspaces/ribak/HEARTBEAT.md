# Heartbeat Checklist

Run these checks each heartbeat cycle. If everything is healthy, reply HEARTBEAT_OK.

## OpenSpec/Landlord Repos

- Check for new issues or PRs in `Fission-AI/OpenSpec` and `jaxxstorm/landlord`
- If significant activity (new releases, breaking changes), note in heartbeat

## Spec Compliance in Raj's Repos

- Scan `rajsinghtech` repos for OpenAPI/JSON Schema files with recent changes
- Validate any specs changed since last check
- Report validation failures immediately

## Tooling State

- Verify `spectral` and `openapi-generator` are available
- Check for new versions/releases of validation tools

## Only Report Problems

- If no new spec issues and tools are functional: reply HEARTBEAT_OK
- Don't repeat known issues unless status changed
