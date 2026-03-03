---
type: note
description: "When a cron completion result has already been delivered in-turn, respond NO_REPLY to avoid duplicate user-facing messages."
topics: ["[[moc-technical]]"]
created: 2026-03-02
---

# Cron Delivery De-dup Pattern

## Pattern
If a system-completion payload explicitly indicates the same result was already delivered in the same turn, send **`NO_REPLY`**.

## Why
Prevents duplicate notifications and keeps cron automation clean.

## Operational Signal
A completion summary may include explicit guidance like: reply only `NO_REPLY` if exact output was already sent.

## Source
- `memory/daily/2026-02-24-heartbeat-cron.md`
