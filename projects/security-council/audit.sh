#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
OUTPUT_DIR="$SCRIPT_DIR/reports/$(date +%Y-%m-%d_%H%M%S)"
TARGET="${1:?Usage: audit.sh /path/to/codebase [--dry-run]}"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

mkdir -p "$OUTPUT_DIR"

echo "🔒 Security Council — Auditing: $TARGET"
echo "   Output: $OUTPUT_DIR"
echo ""

# ── Phase 1: Parallel specialist analysis via Claude Code CLI ──
run_analyst() {
  local name="$1"
  local prompt_file="$2"
  local output_file="$OUTPUT_DIR/${name}.md"
  local system_prompt
  system_prompt=$(cat "$prompt_file")

  echo "  ⏳ $name analyst starting..."
  claude -p \
    --model sonnet \
    --output-format text \
    --max-turns 10 \
    "$system_prompt

Analyze the codebase at: $TARGET

Read through the actual source files. Focus on the most security-relevant files first (auth, API routes, database, config, middleware, env handling). Be thorough but focus on real code, not docs or tests unless they reveal issues.

Output your findings in markdown format." \
    > "$output_file" 2>"$OUTPUT_DIR/${name}.stderr.log"
  
  local rc=$?
  if [[ $rc -ne 0 ]] || [[ ! -s "$output_file" ]] || [[ $(wc -c < "$output_file") -lt 100 ]]; then
    echo "  ❌ $name FAILED (exit=$rc, size=$(wc -c < "$output_file" 2>/dev/null || echo 0)b)"
    echo "     stderr: $(head -3 "$OUTPUT_DIR/${name}.stderr.log" 2>/dev/null)"
    return 1
  fi

  local count
  count=$(grep -c "^\- \*\*\|^##\|^\*\*File\|^\*\*Severity" "$output_file" 2>/dev/null || echo "0")
  echo "  ✅ $name complete ($count items)"
}

# Run all 4 analysts in parallel
run_analyst "offensive" "$PROMPTS_DIR/offensive.md" &
PID_OFF=$!
run_analyst "defensive" "$PROMPTS_DIR/defensive.md" &
PID_DEF=$!
run_analyst "data-privacy" "$PROMPTS_DIR/data-privacy.md" &
PID_DAT=$!

# Wait for first 3 individually (detect per-analyst failures)
FAIL=0
for pid_name in "$PID_OFF:offensive" "$PID_DEF:defensive" "$PID_DAT:data-privacy"; do
  pid="${pid_name%%:*}"; name="${pid_name##*:}"
  wait "$pid" || { echo "  ❌ $name analyst failed"; FAIL=1; }
done
[[ $FAIL -eq 1 ]] && { echo "❌ One or more analysts failed. Aborting."; exit 1; }
echo ""
echo "  Phase 1 complete. Running realism check..."

# ── Phase 2: Realism filter ──
REALISM_PROMPT=$(cat "$PROMPTS_DIR/realism.md")
claude -p \
  --model sonnet \
  --output-format text \
  "$REALISM_PROMPT

Here are the raw findings from the three analysts:

---
OFFENSIVE ANALYSIS:
$(cat "$OUTPUT_DIR/offensive.md")

---
DEFENSIVE ANALYSIS:
$(cat "$OUTPUT_DIR/defensive.md")

---
DATA PRIVACY ANALYSIS:
$(cat "$OUTPUT_DIR/data-privacy.md")
---

Provide your realism assessment." \
  > "$OUTPUT_DIR/realism.md" 2>"$OUTPUT_DIR/realism.stderr.log"

echo "  ✅ Realism check complete"
echo ""

# ── Phase 3: Opus summarizer → structured JSON ──
echo "  ⏳ Opus summarizer generating final report..."

claude -p \
  --model opus \
  --output-format text \
  "You are the final summarizer for a Security Council audit. You receive findings from 4 specialists: Offensive, Defensive, Data Privacy, and Realism.

Produce a single structured JSON object with this schema:

{
  \"audit_date\": \"ISO date\",
  \"target\": \"codebase path\",
  \"summary\": \"2-3 sentence executive summary\",
  \"critical_count\": number,
  \"high_count\": number,
  \"medium_count\": number,
  \"low_count\": number,
  \"findings\": [
    {
      \"id\": 1,
      \"title\": \"short title\",
      \"severity\": \"critical|high|medium|low\",
      \"category\": \"offensive|defensive|data-privacy\",
      \"realism\": \"real-risk|low-risk|theater|needs-context\",
      \"file\": \"path/to/file\",
      \"lines\": \"line range or null\",
      \"description\": \"what's wrong\",
      \"attack_vector\": \"how to exploit (if applicable)\",
      \"recommendation\": \"how to fix\",
      \"priority\": number
    }
  ],
  \"top_3_immediate\": [\"action 1\", \"action 2\", \"action 3\"],
  \"security_theater\": [\"things that look scary but aren't\"],
  \"missed_concerns\": [\"things analysts may have overlooked\"]
}

Output ONLY valid JSON, no markdown fences.

---
OFFENSIVE:
$(cat "$OUTPUT_DIR/offensive.md")

---
DEFENSIVE:
$(cat "$OUTPUT_DIR/defensive.md")

---
DATA PRIVACY:
$(cat "$OUTPUT_DIR/data-privacy.md")

---
REALISM:
$(cat "$OUTPUT_DIR/realism.md")
---" \
  > "$OUTPUT_DIR/findings.json" 2>"$OUTPUT_DIR/summarizer.stderr.log"

echo "  ✅ Final report generated"

# ── Phase 4: Format for Telegram ──
# Generate a human-readable summary
python3 -c "
import json, sys

try:
    with open('$OUTPUT_DIR/findings.json') as f:
        data = json.load(f)
except (json.JSONDecodeError, FileNotFoundError) as e:
    print(f'Error parsing findings: {e}', file=sys.stderr)
    # Fallback: just output raw
    with open('$OUTPUT_DIR/findings.json') as f:
        print(f.read()[:3000])
    sys.exit(0)

lines = []
lines.append('🔒 **Security Council Report**')
lines.append(f'📁 {data.get(\"target\", \"unknown\")}')
lines.append(f'📅 {data.get(\"audit_date\", \"today\")}')
lines.append('')
lines.append(data.get('summary', ''))
lines.append('')

c = data.get('critical_count', 0)
h = data.get('high_count', 0)
m = data.get('medium_count', 0)
l = data.get('low_count', 0)
lines.append(f'🔴 Critical: {c} | 🟠 High: {h} | 🟡 Medium: {m} | 🟢 Low: {l}')
lines.append('')

# Top 3 immediate
top3 = data.get('top_3_immediate', [])
if top3:
    lines.append('⚡ **Fix NOW:**')
    for i, item in enumerate(top3, 1):
        lines.append(f'{i}. {item}')
    lines.append('')

# Numbered findings
findings = data.get('findings', [])
if findings:
    lines.append(f'**Findings ({len(findings)}):**')
    lines.append('')
    for f in sorted(findings, key=lambda x: x.get('priority', 99)):
        sev = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🟢'}.get(f.get('severity', ''), '⚪')
        real = f.get('realism', '')
        tag = ' 🎭' if real == 'theater' else ''
        lines.append(f'{sev} **#{f[\"id\"]}** {f[\"title\"]}{tag}')
        lines.append(f'   {f.get(\"file\", \"?\")} | {f.get(\"description\", \"\")}')
        lines.append(f'   → {f.get(\"recommendation\", \"\")}')
        lines.append('')

# Theater
theater = data.get('security_theater', [])
if theater:
    lines.append('🎭 **Security theater (skip these):**')
    for t in theater:
        lines.append(f'- {t}')

print('\n'.join(lines))
" > "$OUTPUT_DIR/telegram.md"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$OUTPUT_DIR/telegram.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Phase 5: Alert critical findings ──
CRITICAL_COUNT=$(python3 -c "
import json
try:
    data = json.load(open('$OUTPUT_DIR/findings.json'))
    print(data.get('critical_count', 0))
except (json.JSONDecodeError, FileNotFoundError, KeyError):
    print(-1)
")

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "🏁 Dry run complete. Report saved to $OUTPUT_DIR/"
  echo "   findings.json — structured data"
  echo "   telegram.md   — formatted summary"
  echo "   *.md          — raw analyst reports"
else
  echo ""
  echo "🏁 Audit complete. Report: $OUTPUT_DIR/"
  # Output the telegram message to stdout for the cron job to pick up
  if [[ "$CRITICAL_COUNT" -gt 0 ]]; then
    echo "🚨 $CRITICAL_COUNT CRITICAL findings detected!"
  fi
fi

# Output the telegram-formatted report path for the caller
echo "REPORT_FILE=$OUTPUT_DIR/telegram.md"
echo "FINDINGS_FILE=$OUTPUT_DIR/findings.json"
echo "CRITICAL_COUNT=$CRITICAL_COUNT"
