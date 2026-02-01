# RULES.md - Mistakes & Lessons Learned

*Don't repeat mistakes. When something goes wrong, document it here so future-you learns from it.*

## Process Rules

### 1. Be Proactive About Context Window
- **Don't let compaction sneak up on you.** Monitor context usage and serialize important state to files BEFORE hitting limits.
- When a session gets long, periodically flush key context to `daily/` or `memory/` files.
- Summarize ongoing work state to a scratch file so compaction doesn't wipe critical context.
- **Every 10-15 exchanges in a long session**: write a state checkpoint to `memory/YYYY-MM-DD.md` with:
  - What we're working on
  - Key decisions made
  - Current state / next steps
  - Any important details that would be painful to lose
- Clawdbot has a built-in pre-compaction memory flush, but it only fires once near the limit — don't rely on it alone.
- Use `/compact` proactively with good instructions rather than letting auto-compaction summarize blindly.

### 2. Write It Down Immediately
- If Marcel says "remember this" or makes a decision → write to file THAT TURN, not later.
- Don't rely on conversation history persisting. It won't.

### 3. Don't Ask What You Can Figure Out
- Check files, search, read context before asking Marcel to repeat himself.
- Post-compaction: check memory files and recent daily notes before asking "what were we doing?"

## Technical Lessons

### WordPress / WP-CLI
- `WP_DEBUG_DISPLAY` should be `false` on production/staging — log errors, don't show them to visitors.
- Always flush transients after removing plugins (stale references cause frontend errors).
- WPMU DEV hosting includes backups — UpdraftPlus is redundant there.

## Social / Communication
- Don't say the same thing twice when Marcel repeats info (he may have forgotten he told you, just acknowledge briefly).
- In group chats: quality > quantity. React don't reply when that's sufficient.

---

*Add to this file whenever something goes wrong or a lesson is learned.*
