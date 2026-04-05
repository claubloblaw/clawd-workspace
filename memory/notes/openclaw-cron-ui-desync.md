---
type: note
description: "OpenClaw cron jobs can exist on disk while dashboard appears empty due to control UI session/websocket desync."
topics: ["[[moc-technical]]"]
created: 2026-03-02
updated: 2026-04-04
---

# OpenClaw Cron UI Desync (Jobs Present, Dashboard Empty)

## What happened
- Cron jobs were present in `~/.openclaw/cron/jobs.json` and returned by backend cron list APIs.
- Dashboard Cron page temporarily showed no jobs.
- Root issue appeared to be control UI state/websocket instability, not missing job data.

## Reliable checks
1. Verify jobs on disk (`~/.openclaw/cron/jobs.json`).
2. Verify backend sees jobs (cron list API/CLI).
3. Treat empty dashboard alone as non-authoritative until backend checks pass.

## Fast recovery sequence
1. Close all OpenClaw dashboard tabs.
2. Reopen only `http://127.0.0.1:18789`.
3. Hard refresh once (`Cmd+Shift+R`).
4. Wait 10-15 seconds on the Cron page.

## Escalation
- If still empty after recovery sequence, restart gateway (`openclaw gateway restart`).
- If backend still has jobs, avoid destructive re-creation; prefer UI/session reset first.

## Related
- Reduced from `memory/daily/archive/2026-03-02-cron-ui-desync-and-gateway-state.md`.
- See also: [[cron-delivery-dedup-pattern]]
