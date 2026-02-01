#!/bin/bash
# Hook: session-start
# Run at the start of a brain session to inject context
# Usage: ./hooks/session-start.sh

VAULT_DIR="$(dirname "$0")/.."
cd "$VAULT_DIR" || exit 1

echo "=== BRAIN CONTEXT ==="
echo ""
echo "## File Tree (notes/)"
find notes -name "*.md" -type f 2>/dev/null | sed 's|notes/||' | sed 's|\.md$||' | sort

echo ""
echo "## File Tree (mocs/)"
find mocs -name "*.md" -type f 2>/dev/null | sed 's|mocs/||' | sed 's|\.md$||' | sort

echo ""
echo "## Inbox Items ($(find inbox -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '))"
find inbox -name "*.md" -type f 2>/dev/null | head -10

echo ""
echo "## Recent Learning"
find learning -name "*.md" -type f -mtime -7 2>/dev/null | head -5

echo ""
echo "=== END CONTEXT ==="
