# Tools

All tools at `/usr/local/bin/`. Authenticated as `rajsinghtechbot` via GITHUB_TOKEN.

## OpenSpec Workflow

```bash
# Create a new change folder
mkdir -p openspec/changes/<change-name>
cd openspec/changes/<change-name>

# Generate planning documents structure
# (Ribak uses write/edit to create these, not a CLI tool)
```

## Document Generation

```bash
# Create planning directory structure
mkdir -p openspec/changes/<change-name>/specs

# Create initial files
touch openspec/changes/<change-name>/proposal.md
touch openspec/changes/<change-name>/design.md
touch openspec/changes/<change-name>/tasks.md
touch openspec/changes/<change-name>/specs/requirements.md
touch openspec/changes/<change-name>/specs/scenarios.md
```

## Project Discovery

```bash
# List existing OpenSpec changes
ls -la openspec/changes/ 2>/dev/null || echo "No OpenSpec changes yet"

# Check for active changes (not in archive)
find openspec/changes/ -maxdepth 1 -type d ! -name archive ! -path '*/changes' 2>/dev/null

# View archived changes
ls -la openspec/changes/archive/ 2>/dev/null || echo "No archived changes"
```

## gh

```bash
# Clone repos for planning context
gh repo clone rajsinghtech/<repo>.git -- /tmp/planning-context

# Review existing PRs for context
gh pr list --repo rajsinghtech/<repo> --limit 10

# Check related issues
gh issue list --repo rajsinghtech/<repo> --limit 10
```

## git

```bash
# Clone for context
git clone https://github.com/rajsinghtech/<repo>.git /tmp/planning-context

# Check existing patterns in codebase
git ls-files '*.md' | grep -E '(SPEC|spec|design|proposal)' | head -20

# Review recent changes for context
git log --oneline -10
```

## External Tools

| Tool | Purpose |
|------|---------|
| `web_fetch` | Fetch OpenSpec/Landlord reference docs for patterns |
| `web_search` | Find design patterns, best practices for spec problems |
| `read` | Read existing codebase for context during planning |
| `write` | Create planning documents |
| `edit` | Update planning documents iteratively |

## Ribak-Specific Skills

Located in `/home/node/.openclaw/workspaces/ribak/skills/`:

| Skill | Purpose |
|-------|---------|
| `openspec/` | OpenSpec workflow patterns, document templates, spec examples |

## Handoff to Leon

```bash
# Signal to main agent to spawn Leon with context
# (This is done via returning from the sub-agent, not direct spawn)
```

Typical handoff includes:
- Path to `tasks.md` for implementation
- Path to `specs/` for requirements reference
- Path to `design.md` for technical approach
- Any risks or gotchas discovered
