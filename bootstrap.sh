#!/bin/bash
# One-liner for a fresh Mac mini:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/spalsh-spec/ai-stack-template/main/bootstrap.sh)"
set -euo pipefail
DIR="$HOME/ai-stack-template"
echo "== Fetching the stack =="
if [ -d "$DIR/.git" ]; then git -C "$DIR" pull --ff-only; else
  xcode-select -p >/dev/null 2>&1 || xcode-select --install || true
  git clone https://github.com/spalsh-spec/ai-stack-template.git "$DIR"
fi
exec /bin/bash "$DIR/install.sh" "$@"
