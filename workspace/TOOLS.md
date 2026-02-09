# Workspace Tools

The following CLI tools are pre-installed in `/home/node/.openclaw/bin`:

| Tool | Purpose |
|------|---------|
| `kubectl` | Kubernetes cluster management |
| `flux` | Flux CD GitOps toolkit |
| `helm` | Kubernetes package manager |
| `kustomize` | Kubernetes manifest customization |
| `yq` | YAML processor |
| `sops` | Secrets encryption/decryption |
| `jq` | JSON processor |

All tools are on `$PATH` and ready to use. The workspace has a kubeconfig and RBAC configured for in-cluster access.
