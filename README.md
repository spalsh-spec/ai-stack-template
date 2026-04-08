# Prompt Optimizer & LinkedIn Outreach Pipeline

A toolkit with two utilities:

1. **Prompt Optimizer** -- A macOS hotkey-triggered script that captures text from any input field, rewrites it into a high-quality AI prompt using Claude CLI, and pastes it back in place. It auto-detects the active app (Claude, ChatGPT, Gemini, Cursor, etc.) and tailors the optimized prompt to that platform's capabilities.

2. **LinkedIn Outreach Pipeline** -- A Node.js script that researches a target company using Claude, generates personalized LinkedIn connection requests and cold emails using Claude + GPT-4o, builds a 2-week outreach strategy, and saves everything as a structured Obsidian note with tracking tables.

## Setup

```bash
# Install Node.js dependencies
npm install

# Create your environment file
cp .env.example .env
# Then edit .env and fill in your API keys
```

## Required Environment Variables

| Variable | Required | Description |
|---|---|---|
| `ANTHROPIC_API_KEY` | Yes | Anthropic API key for Claude |
| `OPENAI_API_KEY` | Yes | OpenAI API key for GPT-4o |
| `OBSIDIAN_VAULT` | No | Path to Obsidian vault (defaults to `~/Obsidian/Vault`) |

## How to Run

### Prompt Optimizer

**Via macOS hotkey (recommended):**
Set up `optimize.sh` as a macOS Automator Quick Action bound to a keyboard shortcut. It will select all text in the current field, optimize it, and paste the result back.

**Manual test mode:**
```bash
./test.sh
```
Paste a rough prompt, press Ctrl+D, and get the optimized version back (also copied to clipboard).

> Both shell scripts require the `claude` CLI to be installed and available on your PATH.

### LinkedIn Outreach Pipeline

```bash
node linkedin-pipeline.js "Company Name" [count]
```

- `Company Name` -- the target company to research (required)
- `count` -- number of contacts to generate (optional, defaults to 10)

Output is saved as a Markdown file in your Obsidian vault under `Job Hunt/Outreach/`.

## Dependencies

- **[@anthropic-ai/sdk](https://www.npmjs.com/package/@anthropic-ai/sdk)** (^0.82.0) -- Anthropic SDK for Claude API calls
- **[openai](https://www.npmjs.com/package/openai)** (^6.33.0) -- OpenAI SDK for GPT-4o API calls
- **[claude CLI](https://docs.anthropic.com/en/docs/claude-cli)** -- Required by the shell scripts for prompt optimization
- **macOS** -- The shell scripts use `osascript`, `pbcopy`, and `pbpaste` (macOS-only)
