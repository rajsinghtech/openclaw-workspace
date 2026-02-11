# Heartbeat Checklist

Run these checks each heartbeat cycle (every 30m, 08:00-22:00 ET). Model: Claude Opus 4.6. Target: Discord.

## PR Review

Check for open PRs that haven't been reviewed:

```bash
# Open PRs on openclaw-workspace
gh pr list --repo rajsinghtech/openclaw-workspace --state open --json number,title,author,createdAt,reviewDecision

# Open PRs on kubernetes-manifests
gh pr list --repo rajsinghtech/kubernetes-manifests --state open --json number,title,author,createdAt,reviewDecision
```

For each unreviewed PR:
1. `gh pr diff <number> --repo <repo>` — read the diff
2. Check for: syntax errors, logic bugs, security issues, missing validation
3. Post review: `gh pr review <number> --repo <repo> --comment --body "..."`

## Only Report Problems

- If no unreviewed PRs exist: reply `HEARTBEAT_OK`
- Don't re-review PRs you've already commented on unless they have new commits
- For Robert's automated PRs: verify the changes are correct and the evidence is real
