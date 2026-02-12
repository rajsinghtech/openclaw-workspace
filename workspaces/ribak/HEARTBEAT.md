# Heartbeat Checklist

Run these checks each heartbeat cycle. If everything is healthy, reply HEARTBEAT_OK.

## OpenSpec Repository State

- Check for active (non-archived) changes in Raj's repos:
  - `openspec/changes/` directories
  - Changes older than 7 days without `/opsx:apply` — may need nudging
- If stale changes found, note in heartbeat with count and oldest date

## Leon Handoff Tracking

- Check for changes with complete planning docs but no Leon spawn:
  - `proposal.md`, `design.md`, `tasks.md` exist
  - No corresponding Leon session found
- Flag these as "ready for handoff" in heartbeat

## OpenSpec Framework Updates

- Check for new releases or significant changes in `Fission-AI/OpenSpec`
- If new workflow patterns or commands added, note in heartbeat
- Watch for deprecations of `/opsx:*` commands

## Planning Document Health

- Scan Raj's repos for planning documents
- Flag any with:
  - Empty tasks.md (planning started, no breakdown)
  - Missing design.md (specs without technical approach)
  - Outdated specs (referencing removed features)

## Only Report Problems

- If no stale changes, pending handoffs, or doc health issues: reply HEARTBEAT_OK
- Don't repeat known issues unless status changed
- Focus on actionable items: changes needing attention, handoffs ready

## Example Healthy Report

```
HEARTBEAT_OK
- 2 active changes (both under 3 days old)
- 0 stale changes
- 0 ready for Leon handoff
- OpenSpec framework: v2.x (current)
```

## Example Attention Report

```
Changes needing attention:
- openspec/changes/refactor-auth/ — planning complete 5 days ago, no Leon spawn
- openspec/changes/update-ui/ — tasks.md empty, may need spec clarification
```
