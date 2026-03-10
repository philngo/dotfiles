# Claude Code usage (hits undocumented OAuth endpoint)
claude-usage() {
  local token
  token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null |
    python3 -c "import json,sys; print(json.load(sys.stdin)['claudeAiOauth']['accessToken'])" 2>/dev/null) || {
    echo "Could not get OAuth token from keychain"; return 1
  }
  curl -s --max-time 5 "https://api.anthropic.com/api/oauth/usage" \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "Content-Type: application/json" |
    python3 -c "
import json, sys
from datetime import datetime, timezone

d = json.load(sys.stdin)
h = d.get('five_hour', {})
w = d.get('seven_day', {})

h_pct = h.get('utilization', 0)
w_pct = w.get('utilization', 0)

def fmt_reset(iso):
    if not iso: return ''
    t = datetime.fromisoformat(iso).astimezone()
    return t.strftime('%a %I:%M %p')

print(f'5h:  {h_pct:5.1f}% used  ({100-h_pct:.0f}% left)  resets {fmt_reset(h.get(\"resets_at\"))}')
print(f'7d:  {w_pct:5.1f}% used  ({100-w_pct:.0f}% left)  resets {fmt_reset(w.get(\"resets_at\"))}')
"
}
