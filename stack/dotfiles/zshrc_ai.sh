# zshrc_ai.sh — AI toolchain shell additions
# -------------------------------------------
# Source from ~/.zshrc (install.sh does this automatically):
#   source ~/ai-stack-template/stack/dotfiles/zshrc_ai.sh

# ── API keys ───────────────────────────────────────────────────
[ -f "$HOME/.api_keys" ] && source "$HOME/.api_keys"

# ── Claude Code ────────────────────────────────────────────────
export PATH="$HOME/bin:$PATH"
alias cc="$HOME/bin/claude"

# kimi-for-coding alias (routes claude → kimi endpoint)
alias kc='ANTHROPIC_API_KEY="$KIMI_CODE_API_KEY" $HOME/bin/claude --api-url https://api.kimi.com/coding'

# ── Ollama ─────────────────────────────────────────────────────
if command -v ollama &>/dev/null; then
  alias ostart='ollama serve >/dev/null 2>&1 &'
  alias olist='ollama list'
fi

# ── Stack management ───────────────────────────────────────────
alias ai-check='bash $HOME/ai-stack-template/verify.sh'
alias ai-export='bash $HOME/ai-stack-template/export.sh && cd $HOME/ai-stack-template && git add -A && git commit -m "refresh stack $(date +%Y-%m-%d)" && git push'
alias ai-update='cd $HOME/ai-stack-template && git pull && bash install.sh'
