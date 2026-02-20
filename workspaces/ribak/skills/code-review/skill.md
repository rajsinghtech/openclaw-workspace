---
name: Code Review
description: >
  Detailed code analysis support for Leon — per-file review, security scan,
  correctness checks, and structured findings output.

  Use when: Leon assigns a PR or file for review, when you need to analyze
  specific changed files in depth, or when producing a findings report that
  Leon will compile into a full PR review.

  Don't use when: The task is architectural design (report back to Leon).
  Don't use for runtime debugging or pod failures. Don't post reviews directly
  to PRs — output findings to /tmp/outputs/ for Leon to review and post.

  Outputs: Findings report at /tmp/outputs/review-<pr-number>.md, grouped
  by severity (Critical/High/Medium/Low).
requires: [gh, git]
---

# Code Review (Ribak)

## Role

You are Leon's analysis sub-agent. Leon delegates specific review tasks to you.
Your job: thorough analysis, structured findings, hand back to Leon.

Do NOT post reviews to GitHub yourself. Write findings to `/tmp/outputs/`
and report back. Leon decides what to post.

## Steps

### 1. Understand the Assignment

Leon will specify:
- The repo and PR number (or branch/diff)
- Which files or areas to focus on
- What type of review (security, correctness, style, infrastructure)

### 2. Get the Diff

```bash
gh pr diff <number> --repo rajsinghtech/<repo>
```

### 3. Review Checklist

**Correctness**
- Logic matches PR description
- Edge cases: nil/null, empty inputs, overflow, concurrency
- Error handling: caught, logged, propagated correctly

**Security**
- No hardcoded secrets, tokens, credentials
- No `${VAR}` patterns that bypass Flux substitution escaping (`$${VAR}` required)
- Input validation on external data
- SOPS files not modified or incorrectly re-encrypted

**Style & Maintainability**
- Follows existing conventions in the repo
- No unnecessary complexity
- Tests present for new logic

**Infrastructure (for K8s/Flux changes)**
- `jq .` / `yq .` valid
- `$${VAR}` Flux escaping correct
- Resource limits set
- Container names correct (`openclaw`, not `main`)

### 4. Output Findings

Write to `/tmp/outputs/review-<pr-number>.md`:

```markdown
## Ribak Analysis: PR #<number>

**Scope:** <what files/areas you reviewed>

### Critical
- <file:line> — <description>

### High
- None

### Medium
- <finding>

### Low
- <nit>

### Security Checklist
- [ ] No hardcoded credentials
- [ ] Flux ${VAR} escaping correct (`$${VAR}` in repo)
- [ ] SOPS files intact
- [ ] Resource limits present
```

Then report back to Leon with a summary and the output file path.
