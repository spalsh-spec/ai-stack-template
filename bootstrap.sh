#!/bin/bash
# iMessage-safe one-liner (no quotes, survives copy-paste):
#   curl -fsSL https://raw.githubusercontent.com/spalsh-spec/ai-stack-template/main/bootstrap.sh | bash
set -u
DIR="$HOME/ai-stack-template"
echo "== Fetching the AI stack (no git needed) =="
mkdir -p "$DIR"
curl -fsSL https://github.com/spalsh-spec/ai-stack-template/archive/refs/heads/main.tar.gz | tar xz -C "$DIR" --strip-components=1 \
  || { echo "Download failed — check internet connection."; exit 1; }
echo "== Stack downloaded to ~/ai-stack-template =="
# re-attach the keyboard when running via curl|bash so password prompts work
if [ -t 0 ]; then
  bash "$DIR/install.sh"
elif [ -e /dev/tty ]; then
  bash "$DIR/install.sh" </dev/tty
else
  echo "Now run:  bash ~/ai-stack-template/install.sh"
fi
