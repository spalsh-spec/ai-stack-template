#!/bin/bash
# Prompt Optimizer — select-all → copy → optimize → paste back
# Trigger via macOS hotkey (Automator Quick Action)

set -e

# Step 1: Select all text in current field and copy it
osascript -e 'tell application "System Events" to keystroke "a" using command down'
sleep 0.2
osascript -e 'tell application "System Events" to keystroke "c" using command down'
sleep 0.3

# Step 2: Read clipboard
ORIGINAL=$(pbpaste)

if [ -z "$ORIGINAL" ]; then
  osascript -e 'display notification "Nothing on clipboard to optimize" with title "Prompt Optimizer"'
  exit 0
fi

# Step 3: Check for attachments/file references in clipboard
ATTACHMENT_CONTEXT=""
if echo "$ORIGINAL" | grep -qiE '\.(png|jpg|jpeg|pdf|csv|json|txt|docx|xlsx)'; then
  ATTACHMENT_CONTEXT="The user appears to reference file attachments. Preserve all file references and incorporate them into the optimized prompt."
fi

# Step 4: Get the active app name for context
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

# Step 5: Determine target context
TARGET_CONTEXT=""
case "$ACTIVE_APP" in
  *Claude*|*Anthropic*)
    TARGET_CONTEXT="Target: Claude (Anthropic). Leverage: artifacts, analysis tool, MCP connectors, file reading, web search, extended thinking. Be explicit about using these when relevant."
    ;;
  *ChatGPT*|*OpenAI*)
    TARGET_CONTEXT="Target: ChatGPT. Leverage: code interpreter, DALL-E, browsing, file uploads, plugins. Be explicit about using these when relevant."
    ;;
  *Gemini*|*Google*)
    TARGET_CONTEXT="Target: Google Gemini. Leverage: grounding with Google Search, code execution, file analysis. Be explicit about using these when relevant."
    ;;
  *Cursor*|*VS Code*|*Code*)
    TARGET_CONTEXT="Target: AI coding assistant (Cursor/Copilot). Leverage: codebase context, file references, terminal access. Be explicit and reference specific files/functions."
    ;;
  *Slack*)
    TARGET_CONTEXT="Target: Slack (likely AI bot or Claude integration). Keep concise but precise."
    ;;
  *Safari*|*Chrome*|*Firefox*|*Arc*|*Brave*)
    # Try to detect which web AI tool from window title
    WINDOW_TITLE=$(osascript -e "tell application \"$ACTIVE_APP\" to get name of front window" 2>/dev/null || echo "")
    case "$WINDOW_TITLE" in
      *claude*|*Claude*)
        TARGET_CONTEXT="Target: Claude web. Leverage: artifacts, analysis tool, projects, file uploads, web search, extended thinking, MCP connectors."
        ;;
      *ChatGPT*|*chatgpt*)
        TARGET_CONTEXT="Target: ChatGPT web. Leverage: code interpreter, DALL-E, browsing, file uploads, GPTs."
        ;;
      *Gemini*|*gemini*)
        TARGET_CONTEXT="Target: Google Gemini web. Leverage: Google Search grounding, code execution, Gems."
        ;;
      *Perplexity*|*perplexity*)
        TARGET_CONTEXT="Target: Perplexity. Leverage: web search, citation-backed answers. Frame as research queries."
        ;;
      *)
        TARGET_CONTEXT="Target: Unknown AI interface. Write a clear, self-contained prompt."
        ;;
    esac
    ;;
  *)
    TARGET_CONTEXT="Target: Unknown AI interface. Write a clear, self-contained prompt."
    ;;
esac

# Step 6: Send to Claude CLI for optimization
SYSTEM_PROMPT="You are a prompt optimizer. You receive a rough/lazy user message intended for an AI assistant and rewrite it into a highly specific, actionable prompt that maximizes output quality.

$TARGET_CONTEXT
$ATTACHMENT_CONTEXT

Rules:
- Output ONLY the optimized prompt text. No explanations, no wrapper, no markdown fences.
- Preserve the user's actual intent and all specific details/names/references.
- Add structure: clear goal, context, constraints, desired output format.
- If the user references files/attachments, instruct the AI to use them explicitly.
- Leverage platform-specific features (tools, plugins, connectors) when they'd help.
- Keep it concise — don't bloat. Every sentence should earn its place.
- Use imperative voice. Be direct.
- If the original is already good, make minimal changes — don't over-engineer simple requests.
- Match the complexity of optimization to the complexity of the input. A 5-word question doesn't need a 200-word prompt."

OPTIMIZED=$(echo "$ORIGINAL" | claude --print --system-prompt "$SYSTEM_PROMPT" "Optimize this prompt for maximum leverage:" 2>/dev/null)

if [ -z "$OPTIMIZED" ]; then
  osascript -e 'display notification "Optimization failed — check claude CLI" with title "Prompt Optimizer"'
  exit 1
fi

# Step 7: Copy optimized text to clipboard and paste back in place
echo "$OPTIMIZED" | pbcopy
sleep 0.1
osascript -e 'tell application "System Events" to keystroke "v" using command down'

# Step 8: Notify
ORIG_LEN=${#ORIGINAL}
OPT_LEN=${#OPTIMIZED}
osascript -e "display notification \"${ORIG_LEN} → ${OPT_LEN} chars | Pasted in place\" with title \"Prompt Optimized ✓\""
