# Security Council

Nightly multi-perspective security audit for your codebase.

## Architecture

```
Codebase → Claude Code CLI (reads actual code)
    ↓
┌─────────┬───────────┬──────────────┬──────────┐
│Offensive│Defensive  │Data Privacy  │Realism   │
│"exploit"│"protect"  │"data safe?"  │"theater?"│
└────┬────┴─────┬─────┴──────┬───────┴────┬─────┘
     └──────────┴────────────┴────────────┘
                     ↓
            Opus 4.6 Summarizer
            (structured JSON)
                     ↓
            Numbered Findings
                     ↓
              Telegram Alert
        (critical = immediate)
```

## Usage

```bash
# Run against a codebase
./audit.sh /path/to/codebase

# Dry run (no Telegram)
./audit.sh /path/to/codebase --dry-run
```

## Setup

1. Requires `claude` CLI (Claude Code) authenticated
2. Set `TELEGRAM_CHAT_ID` in config or rely on OpenClaw cron for delivery
3. Schedule via OpenClaw cron at 3:30 AM nightly
