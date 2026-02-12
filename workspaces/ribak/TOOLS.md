# Ribak Tools

All tools at `/usr/local/bin/` and on `$PATH`.

## Primary Tools

| Tool | Purpose |
|------|---------|
| `read` | Read file contents |
| `edit` | Surgical text edits |
| `write` | Create new files |
| `image` | Analyze images |
| `web_fetch` | Fetch documentation |

## Leon-Specific Tools

Ribak inherits the same toolset as Leon but with more constrained scope:
- No `exec` or `process` tools (hand off to Leon if needed)
- No `browser` or `canvas` tools (Leon handles UI tasks)

## File Operations

```bash
# Read existing code
read /path/to/file.md

# Write new file
write /path/to/output.md "content"

# Edit specific text
edit /path/to/file.md "old text" "new text"
```

## Image Analysis

```bash
image /path/to/screenshot.png "Describe this UI"
image /path/to/diagram.png "Extract the architecture"
```

## Documentation Lookup

```bash
web_fetch https://docs.example.com/api
```
