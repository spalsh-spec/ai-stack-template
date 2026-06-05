#!/bin/bash
# install.sh — pour this AI stack onto a fresh Mac (mini). Idempotent.
# Usage:  ./install.sh            core install (recommended first run)
#         ./install.sh --full     also install every brew formula from the source Mac
#         ./install.sh --models   also pull ollama models (~8 GB download)
set -uo pipefail
cd "$(dirname "$0")"
FULL=0; MODELS=0
for a in "$@"; do [ "$a" = "--full" ] && FULL=1; [ "$a" = "--models" ] && MODELS=1; done
say() { printf "\n\033[1m== %s ==\033[0m\n" "$*"; }

say "1/7 Homebrew"
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

say "2/7 Core packages (node, gh, ollama, python)"
brew install node@20 gh ollama 2>/dev/null; brew link --overwrite node@20 2>/dev/null
if [ "$FULL" = 1 ] && [ -f stack/brew-formulae.txt ]; then
  say "   --full: installing complete formula list"
  xargs brew install < stack/brew-formulae.txt 2>/dev/null
fi

say "3/7 Claude Desktop"
brew install --cask claude 2>/dev/null || echo "   (install Claude manually from https://claude.ai/download if cask unavailable)"

say "4/7 Skills library -> ~/.claude/skills"
mkdir -p "$HOME/.claude/skills"
rsync -a --ignore-existing stack/skills/ "$HOME/.claude/skills/"
echo "   $(ls -1 "$HOME/.claude/skills" | wc -l | tr -d ' ') skills in place (existing ones untouched)"

say "5/7 MCP server config"
CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
mkdir -p "$(dirname "$CFG")"
[ -f "$CFG" ] && cp "$CFG" "$CFG.backup-$(date +%s)" && echo "   existing config backed up"
# rewrite source-machine home paths to this machine's home
sed "s#/Users/sparshsharma#$HOME#g" stack/mcp/claude_desktop_config.template.json > "$CFG"
echo "   config installed (with placeholder keys)"

say "6/7 Ollama models"
if [ "$MODELS" = 1 ] && [ -f stack/ollama-models.txt ]; then
  (ollama serve >/dev/null 2>&1 &) ; sleep 3
  while read -r m; do [ -n "$m" ] && echo "   pulling $m" && ollama pull "$m"; done < stack/ollama-models.txt
else
  echo "   skipped (run with --models to pull: $(tr '\n' ' ' < stack/ollama-models.txt 2>/dev/null))"
fi

say "7/7 What YOU still need to do (5 min)"
cat <<'EOF'
  1. Open Claude Desktop and sign in with YOUR Anthropic account.
  2. Add your own API keys — open this file and replace every __PLACEHOLDER__:
       ~/Library/Application Support/Claude/claude_desktop_config.json
     The list of required keys is in: stack/mcp/REQUIRED_KEYS.json
     For GitHub access run:  gh auth login
  3. Cowork plugins install per-account: in Claude > Settings > Capabilities,
     add the marketplaces/plugins listed in stack/plugins/*.json
  4. Restart Claude Desktop. Done — the stack is live.
EOF
echo; echo "✅ Stack installed. $(date)"
echo "👉 Check everything: bash ~/ai-stack-template/verify.sh"
