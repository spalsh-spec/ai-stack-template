#!/bin/bash
# Quick test — paste your rough prompt, hit Ctrl+D, get optimized version back on clipboard
echo "Paste your rough prompt below, then press Ctrl+D when done:"
echo "---"
ORIGINAL=$(cat)
echo "---"
echo "Optimizing..."

OPTIMIZED=$(echo "$ORIGINAL" | claude --print --system-prompt "You are a prompt optimizer. Rewrite the user's rough message into a highly specific, actionable prompt. Output ONLY the optimized prompt. No explanations. Preserve intent, add structure, be concise." "Optimize this prompt:" 2>/dev/null)

if [ -z "$OPTIMIZED" ]; then
  echo "ERROR: optimization failed"
  exit 1
fi

echo ""
echo "=== OPTIMIZED ==="
echo "$OPTIMIZED"
echo "================="
echo ""
echo "$OPTIMIZED" | pbcopy
echo "(Copied to clipboard)"
