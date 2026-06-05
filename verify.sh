#!/bin/bash
# verify.sh — did the install work? Prints PASS/FAIL per component.
# Run:  bash ~/ai-stack-template/verify.sh   (then text the output back)
P=0; F=0
ok()  { printf "  ✅ PASS  %s\n" "$1"; P=$((P+1)); }
no()  { printf "  ❌ FAIL  %s\n" "$1"; F=$((F+1)); }
echo "== AI Stack verification — $(date '+%Y-%m-%d %H:%M') =="

command -v brew >/dev/null            && ok "Homebrew installed"            || no "Homebrew missing"
command -v node >/dev/null            && ok "node $(node -v 2>/dev/null)"   || no "node missing"
command -v gh >/dev/null              && ok "gh CLI installed"              || no "gh CLI missing"
command -v ollama >/dev/null          && ok "ollama installed"              || no "ollama missing"
[ -d "/Applications/Claude.app" ]     && ok "Claude Desktop app present"    || no "Claude Desktop not in /Applications"

N=$(ls -1 "$HOME/.claude/skills" 2>/dev/null | wc -l | tr -d ' ')
[ "${N:-0}" -ge 40 ]                  && ok "skills library ($N skills)"    || no "skills library thin ($N found, expected 40+)"

CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CFG" ]; then
  ok "MCP config file exists"
  SRV=$(python3 -c "import json;print(len(json.load(open('$CFG')).get('mcpServers',{})))" 2>/dev/null)
  [ "${SRV:-0}" -ge 6 ]               && ok "MCP servers configured ($SRV)" || no "only ${SRV:-0} MCP servers in config (expected 6)"
  PH=$(grep -o '__[A-Z_]*__' "$CFG" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  if [ "${PH:-0}" -gt 0 ]; then printf "  ⚠️  TODO  %s placeholder API key(s) still need your real keys (see stack/mcp/REQUIRED_KEYS.json)\n" "$PH"
  else ok "no placeholder keys left — all keys filled"; fi
else
  no "MCP config missing at ~/Library/Application Support/Claude/"
fi

gh auth status >/dev/null 2>&1        && ok "GitHub signed in (gh auth)"    || printf "  ⚠️  TODO  run: gh auth login\n"
M=$(ollama list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
[ "${M:-0}" -ge 1 ]                   && ok "ollama models present ($M)"    || printf "  ⚠️  TODO  no local models — rerun: bash ~/ai-stack-template/install.sh --models\n"

echo
echo "== RESULT: $P passed, $F failed =="
if [ "$F" -eq 0 ]; then echo "🎉 Stack is installed. Open Claude Desktop, sign in, and go."
else echo "Send this whole output back to Sparsh."; fi
