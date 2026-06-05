#!/bin/bash
# export.sh — harvest THIS Mac's AI stack into ./stack/ (sanitized, no secrets).
# Run from the repo root on the source machine. Re-run anytime to refresh.
set -uo pipefail
cd "$(dirname "$0")"
mkdir -p stack/mcp stack/plugins stack/skills

echo "[1/6] brew packages"
brew leaves > stack/brew-formulae.txt 2>/dev/null
brew list --cask > stack/brew-casks.txt 2>/dev/null

echo "[2/6] MCP config (secrets -> placeholders)"
python3 - <<'PY'
import json, re, os
src = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")
d = json.load(open(src))
secrets = {}
def clean(name, env):
    out = {}
    for k, v in (env or {}).items():
        ph = f"__{k}__"
        out[k] = ph
        secrets[ph] = f"{name}: set your own {k}"
    return out
for name, srv in d.get("mcpServers", {}).items():
    if "env" in srv: srv["env"] = clean(name, srv["env"])
    # scrub tokens embedded in args (e.g. --token=xyz, PATs in URLs)
    srv["args"] = [re.sub(r'(ghp_|gho_|github_pat_|sk-|key-)[A-Za-z0-9_]+', r'\1__REDACTED_SET_YOUR_OWN__', a) for a in srv.get("args", [])]
json.dump(d, open("stack/mcp/claude_desktop_config.template.json","w"), indent=2)
json.dump(secrets, open("stack/mcp/REQUIRED_KEYS.json","w"), indent=2)
print(f"  servers: {list(d.get('mcpServers',{}).keys())}")
print(f"  keys the new owner must supply: {len(secrets)}")
PY

echo "[3/6] skills (sources only — no node_modules/venvs/caches)"
rsync -aL --delete --max-size=20m \
  --exclude 'gstack' --exclude 'node_modules' --exclude '.venv' --exclude 'venv' \
  --exclude '__pycache__' --exclude '.git' --exclude 'dist' \
  --exclude '*.env' --exclude '.env*' --exclude '*.pem' --exclude '*.sqlite*' \
  --exclude '*.bin' --exclude '*.onnx' --exclude '*.gguf' \
  "$HOME/.claude/skills/" stack/skills/
echo "  size: $(du -sh stack/skills | cut -f1)"

echo "[4/6] cowork plugin manifests"
for f in installed_plugins.json known_marketplaces.json; do
  [ -f "$HOME/.claude/plugins/$f" ] && cp "$HOME/.claude/plugins/$f" stack/plugins/
done

echo "[5/6] ollama models"
ollama list 2>/dev/null | awk 'NR>1{print $1}' > stack/ollama-models.txt

echo "[6/6] manifest stamp"
date "+exported %Y-%m-%d %H:%M from $(hostname)" > stack/EXPORTED.txt
echo "DONE — review stack/, then commit & push."
