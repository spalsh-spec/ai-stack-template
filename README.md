# ⚡ AI Agent Stack Template

> **50+ MCP connectors · 200+ skills · 20+ domains** — built on [Anthropic Claude](https://claude.ai) + Cowork.

## 🌐 Live Preview

Open `index.html` in any browser — or just share the raw GitHub link below.

```
https://github.com/spalsh-spec/ai-stack-template
```

## What's Inside

A single-file HTML template cataloguing every connector and skill wired into my Claude Cowork setup. Includes:

- **MCP Connectors** grouped by domain — project management, sales/CRM, data & BI, design, infra, communication, files, web automation, research, AI/blockchain
- **Skills Library** across 16 domains — engineering, sales, marketing, product, design, data, finance, legal, HR, ops, bio research, brand voice, customer support, docs, creative, meta/infra
- Status indicators: live (green), partial (amber), available-via-plugin (blue)

## Stack

| Layer | Tech |
|-------|------|
| AI Runtime | Anthropic Claude (Sonnet / Opus) |
| Desktop App | Claude Cowork |
| Connector Protocol | MCP (Model Context Protocol) |
| Skills | Claude Cowork Plugin Marketplace |

## How to Use

1. Clone or download this repo
2. Open `index.html` in a browser
3. Forward/share the file in an email — HTML renders inline in Gmail
4. Customise: swap out connectors/skills to match your own stack

## Contact

Built by **Sparsh Sharma** · [sparshsharma219@gmail.com](mailto:sparshsharma219@gmail.com)

---

*Snapshot: May 2026 — connector count grows continuously.*

---

## 🖥 Load this stack onto a Mac mini (or any Mac)

One command on the new machine:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/spalsh-spec/ai-stack-template/main/bootstrap.sh)"
```

That clones this repo and runs `install.sh`, which sets up:

| Step | What it installs |
|---|---|
| Homebrew + core packages | `node`, `gh`, `ollama` (add `--full` for the complete formula list) |
| Claude Desktop | via brew cask |
| **47 skills** | copied into `~/.claude/skills/` (existing skills untouched) |
| **6 MCP servers** | filesystem · desktop-commander · playwright · higgsfield · ollama · github — config written with `__PLACEHOLDER__` keys, paths rewritten for the new user |
| Local models | `--models` flag pulls `qwen2.5:7b` + `gemma3:4b` (~8 GB) |

Then the new owner does 5 minutes of personal setup: sign into Claude, drop their own API keys where the placeholders are (`stack/mcp/REQUIRED_KEYS.json` lists them), `gh auth login`, and add the Cowork plugins from `stack/plugins/*.json`.

**No secrets ship in this repo** — every key is a placeholder (verified with gitleaks on every export).

To refresh the snapshot from the source machine: `./export.sh && git commit -am "refresh stack" && git push`.
