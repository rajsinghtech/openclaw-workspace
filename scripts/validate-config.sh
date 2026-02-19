#!/bin/bash
# Config validation script - run before committing config changes
# Exits with non-zero if issues found

set -e

CONFIG_FILE="${1:-kustomization/openclaw.json}"

echo "Validating $CONFIG_FILE..."

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Check for gateway.bind = localhost (breaks pod-internal tool communication)
if grep -q '"bind": *"localhost"' "$CONFIG_FILE"; then
    echo "ERROR: gateway.bind=localhost breaks pod-internal tool communication"
    echo "       Tools running inside the pod cannot connect to localhost:18789"
    echo "       Use gateway.mode=remote with remote.url=ws://127.0.0.1:18789 instead"
    exit 1
fi

# Check for gateway.bind = lan without remote.url (exposes gateway on pod IP)
if grep -q '"bind": *"lan"' "$CONFIG_FILE" && ! grep -q '"remote":' "$CONFIG_FILE"; then
    echo "WARNING: gateway.bind=lan without gateway.remote.url will expose gateway on pod IP"
    echo "         This triggers security errors when tools try to connect"
    echo "         Add gateway.remote.url or expect sub-agent spawning to fail"
fi

# Check for memorySearch.enabled without valid embeddings API
if grep -q '"memorySearch": *{' "$CONFIG_FILE"; then
    if ! grep -q 'OPENAI_API_KEY' "$CONFIG_FILE"; then
        echo "WARNING: memorySearch enabled but no OPENAI_API_KEY found - will fail with 401"
    fi
fi

# Check for Flux postBuild variable escaping
if grep -q '\${' "$CONFIG_FILE" && ! grep -q '\$\${' "$CONFIG_FILE"; then
    echo "WARNING: Found \${VAR} in config - Flux postBuild will eat these"
    echo "         Escape as \$\$VAR for literal \${VAR} in final output"
fi

echo "Validation complete."
