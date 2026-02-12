# Ribak Heartbeat

Ribak does **not** run autonomous heartbeats. Ribak is a reactive sub-agent only spawned by Leon for specific tasks.

## Activation

Triggered by:
- Leon spawning with a specific code review task
- Manual invocation via `sessions_spawn`

## No Scheduled Tasks

Unlike Dyson or Robert, Ribak has no cron jobs or heartbeat schedule. Ribak only runs when explicitly called by Leon.

## Output Destination

When spawned:
- Primary output: Return to Leon (parent session)
- Secondary: Direct message to channel if `deliver: true` set by Leon
