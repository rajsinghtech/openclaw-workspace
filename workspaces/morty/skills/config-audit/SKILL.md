---
name: Config Audit
description: Validate openclaw.json and related config files
requires: [jq, yq]
---

# Config Audit

## Steps

```bash
# Clone fresh
git clone https://github.com/rajsinghtech/openclaw-workspace.git /tmp/oc-audit
cd /tmp/oc-audit
```

### 1. JSON Syntax
```bash
jq . kustomization/openclaw.json > /dev/null
```

### 2. Model References
Every `"primary"` value must match `<provider>/<model-id>` where the provider exists in `models.providers`:
```bash
# List configured providers
jq -r '.models.providers | keys[]' kustomization/openclaw.json

# List all model refs in agents
jq -r '.. | .primary? // empty' kustomization/openclaw.json
```
Verify each model ref's provider prefix exists in the providers list.

### 3. Env Var Escaping
Any `${VAR}` that OpenClaw should resolve at runtime must be `$${VAR}` in the repo (Flux postBuild eats single `${}`):
```bash
# Find all ${} refs — these will be substituted by Flux (possibly wrong)
grep -n '${' kustomization/openclaw.json | grep -v '$${'
# ^ should be empty. If not, those vars get Flux-substituted.

# Find all $${} refs — these survive Flux and become ${} for OpenClaw
grep -n '$${' kustomization/openclaw.json
```

### 4. Agent Config
```bash
# Check all agents have identity
jq '.agents.list[] | {id, identity}' kustomization/openclaw.json

# Check workspace paths exist in the OCI image
jq -r '.agents.defaults.workspace, (.agents.list[] | .workspace // empty)' kustomization/openclaw.json
```

### 5. Known Bad Patterns
- Top-level `compaction` or `memorySearch` keys → must be under `agents.defaults`
- `"primary": "provider/model"` where provider has slashes (OpenRouter) → needs full prefix
- `apiKey` without `$${}` escaping for Flux-substituted secrets
- `web.search.enabled: true` without a provider or apiKey
