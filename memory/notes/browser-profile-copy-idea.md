---
type: note
description: "Copy Chrome profile to give Playwright agent sessions — avoids auth flows. Not yet implemented."
topics: ["[[moc-technical]]"]
created: 2026-02-17
---

# Browser Profile Copy for Auth

**Status:** Planned, not yet implemented

## Idea
Copy Marcel's Chrome Default profile to a dedicated path (e.g. `~/.openclaw/browser/chrome-profile/`) and point Playwright to it. This gives the agent all existing cookies/sessions — no auth flows needed.

## Steps
1. Close Chrome
2. Copy `~/Library/Application Support/Google/Chrome/Default` → `~/.openclaw/browser/chrome-profile/`
3. Configure OpenClaw's Playwright to use that profile
4. Refresh the copy periodically when sessions expire

## Caveats
- Chrome locks profile while running — copy when Chrome is closed
- Copy is a snapshot — new logins in Chrome won't auto-sync
- Some sites use device fingerprinting that might flag a "new" browser even with same cookies
- Profile is 56MB (as of 2026-02-17)

## Tags
`#improvement` `#browser` `#auth`
