#!/bin/bash
# Hook: validate-note
# Check note quality after creation/edit
# Usage: ./hooks/validate-note.sh <note-path>

NOTE_PATH="$1"

if [[ -z "$NOTE_PATH" ]]; then
    echo "Usage: validate-note.sh <note-path>"
    exit 1
fi

if [[ ! -f "$NOTE_PATH" ]]; then
    echo "Error: File not found: $NOTE_PATH"
    exit 1
fi

ERRORS=0

# Check for YAML frontmatter
if ! head -1 "$NOTE_PATH" | grep -q "^---$"; then
    echo "❌ Missing YAML frontmatter"
    ERRORS=$((ERRORS + 1))
fi

# Check for description field
if ! grep -q "^description:" "$NOTE_PATH"; then
    echo "❌ Missing description field"
    ERRORS=$((ERRORS + 1))
else
    DESC=$(grep "^description:" "$NOTE_PATH" | sed 's/description: *//')
    if [[ -z "$DESC" ]] || [[ "$DESC" == "\"\"" ]]; then
        echo "⚠️  Empty description"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Check for type field
if ! grep -q "^type:" "$NOTE_PATH"; then
    echo "⚠️  Missing type field"
fi

# Check for wiki links
LINK_COUNT=$(grep -o '\[\[.*\]\]' "$NOTE_PATH" | wc -l | tr -d ' ')
if [[ "$LINK_COUNT" -eq 0 ]]; then
    echo "⚠️  No wiki links (orphan risk)"
fi

# Check file name is a claim (lowercase, no special chars except spaces)
FILENAME=$(basename "$NOTE_PATH" .md)
if [[ "$FILENAME" =~ ^[A-Z] ]] && [[ ! "$FILENAME" =~ ^(SYSTEM|README) ]]; then
    echo "⚠️  Title starts with capital (prefer lowercase claims)"
fi

if [[ $ERRORS -eq 0 ]]; then
    echo "✅ Note passes validation"
    exit 0
else
    echo "❌ $ERRORS validation errors"
    exit 1
fi
