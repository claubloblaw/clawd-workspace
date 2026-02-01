#!/bin/bash
# Hook: review
# Health check for the vault
# Usage: ./hooks/review.sh

VAULT_DIR="$(dirname "$0")/.."
cd "$VAULT_DIR" || exit 1

echo "=== BRAIN HEALTH CHECK ==="
echo ""

# Count totals
TOTAL_NOTES=$(find notes -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
TOTAL_MOCS=$(find mocs -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
TOTAL_LEARNING=$(find learning -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
INBOX_COUNT=$(find inbox -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "## Totals"
echo "- Notes: $TOTAL_NOTES"
echo "- MOCs: $TOTAL_MOCS"
echo "- Learning: $TOTAL_LEARNING"
echo "- Inbox: $INBOX_COUNT"
echo ""

# Find orphans (notes with no incoming links)
echo "## Orphan Check"
for note in notes/*.md; do
    [[ -f "$note" ]] || continue
    BASENAME=$(basename "$note" .md)
    INCOMING=$(grep -r "\[\[$BASENAME\]\]" notes mocs learning 2>/dev/null | grep -v "^$note:" | wc -l | tr -d ' ')
    if [[ "$INCOMING" -eq 0 ]]; then
        echo "- Orphan: $BASENAME"
    fi
done
echo ""

# Find broken links
echo "## Broken Links"
grep -roh '\[\[[^]]*\]\]' notes mocs learning 2>/dev/null | sort -u | while read -r link; do
    TARGET=$(echo "$link" | sed 's/\[\[//;s/\]\]//')
    # Check if file exists in notes, mocs, or learning
    if [[ ! -f "notes/$TARGET.md" ]] && [[ ! -f "mocs/$TARGET.md" ]] && [[ ! -f "learning/$TARGET.md" ]]; then
        echo "- Missing: [[$TARGET]]"
    fi
done
echo ""

# Notes missing descriptions
echo "## Missing Descriptions"
for note in notes/*.md mocs/*.md learning/*.md; do
    [[ -f "$note" ]] || continue
    DESC=$(grep "^description:" "$note" 2>/dev/null | sed 's/description: *//')
    if [[ -z "$DESC" ]] || [[ "$DESC" == "\"\"" ]]; then
        echo "- $(basename "$note" .md)"
    fi
done
echo ""

echo "=== END HEALTH CHECK ==="
