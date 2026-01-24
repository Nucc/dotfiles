# Setup Guide

## Prerequisites

Install dependencies:
```bash
brew install --cask hammerspoon zoom obsidian
```

## Installation

### 1. Copy bot to Hammerspoon

```bash
cp -r zoom-transcript-bot ~/.hammerspoon/
```

### 2. Configure paths

Edit `~/.hammerspoon/zoom-transcript-bot/config.lua`:

```lua
-- Set your vault name and path
OBSIDIAN_VAULT_NAME = "your-vault-name",
OBSIDIAN_VAULT_ROOT = HOME .. "/Documents/your-vault-name/",
```

### 3. Create vault folders

```bash
VAULT=~/Documents/your-vault-name
mkdir -p "$VAULT/Daily"
mkdir -p "$VAULT/Meetings/Transcripts"
mkdir -p "$VAULT/Meetings/Notes"
```

### 4. Load in Hammerspoon

Add to `~/.hammerspoon/init.lua`:

```lua
require("zoom-transcript-bot")
```

### 5. Grant Accessibility permission

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Add **Hammerspoon** and enable it

### 6. Reload Hammerspoon

Click the Hammerspoon menu bar icon → **Reload Config**

## Verify

```bash
# Check log for startup
tail ~/.zoom-transcript-bot.log
```

Should show:
```
[INFO] Zoom Transcript Bot starting...
[INFO] Zoom Transcript Bot initialized successfully
```

## Quick Setup Script

```bash
#!/bin/bash
VAULT_NAME="work"
VAULT="$HOME/Documents/$VAULT_NAME"

# Install deps
brew install --cask hammerspoon zoom obsidian

# Create folders
mkdir -p ~/.hammerspoon
mkdir -p "$VAULT/Daily" "$VAULT/Meetings/Transcripts" "$VAULT/Meetings/Notes"

# Copy bot (adjust source path)
cp -r zoom-transcript-bot ~/.hammerspoon/

# Add to init.lua
echo 'require("zoom-transcript-bot")' >> ~/.hammerspoon/init.lua

echo "Done. Now:"
echo "1. Edit ~/.hammerspoon/zoom-transcript-bot/config.lua"
echo "2. Grant Accessibility permission to Hammerspoon"
echo "3. Reload Hammerspoon"
```

## Obsidian Setup

### Required Plugins

Install these community plugins in Obsidian:
- **Auto Note Mover** - Automatically organize notes
- **Copilot** - AI assistant for summaries
- **Filename Heading Sync** - Sync note titles

### Copilot Plugin Configuration

1. Get API token from: https://ai-gateway.zende.sk/applications

2. Open Obsidian → **Settings** → **Community Plugins** → **Copilot**

3. **Add Chat Model:**
   - Model: `gpt-5.1-chat-latest`
   - Format: `OpenAI Format`
   - Base URL: `https://ai-gateway.zende.sk/v1`
   - Enable: ✓
   - CORS: ✓

4. **Add Embedding Model:**
   - Model: `text-embedding-3-large`
   - Format: `OpenAI Format`
   - Base URL: `https://ai-gateway.zende.sk/v1`
   - CORS: ✓

5. **Disable all other models** (uncheck them)

6. **Custom Prompts:**
   - In Copilot settings → **Commands**
   - Set prompts location: `copilot/copilot-custom-prompts`
   - Copy example prompts: `cp -r example-prompts/* your-vault/copilot/copilot-custom-prompts/`

### Example Prompts Included

| Prompt | Purpose |
|--------|---------|
| `The_Summarizer` | Compress transcripts into executive summaries |
| `Meeting_Processor` | Transform transcripts into structured meeting notes |
| `The_Gardener` | Name, tag, and refactor notes |
| `Tech_Lead` | Answer questions from vault context |
| `The_Architect` | Generate code, specs, or communications |

### Vault Structure

```
your-vault/
├── Daily/
├── Meetings/
│   ├── Notes/
│   └── Transcripts/
└── copilot/
    └── copilot-custom-prompts/
        ├── Meeting_Processor.md
        ├── Tech_Lead.md
        ├── The_Architect.md
        ├── The_Gardener.md
        └── The_Summarizer.md
```

---

## Uninstall

```bash
rm -rf ~/.hammerspoon/zoom-transcript-bot
rm ~/.zoom-transcript-bot.log
# Remove 'require("zoom-transcript-bot")' from ~/.hammerspoon/init.lua
```
