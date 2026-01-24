# AI Setup Instructions

Instructions for Claude Code or similar AI to set up this project.

## Pre-requisites (User Must Provide)

Before running setup, ask the user for:
1. **Vault name** - Their Obsidian vault name (e.g., "notes", "work")
2. **Vault path** - Full path to vault (e.g., `~/Documents/notes`)

## Automated Setup Steps

Run these commands:

```bash
# 1. Install dependencies
brew install --cask hammerspoon zoom obsidian

# 2. Create Hammerspoon config directory
mkdir -p ~/.hammerspoon

# 3. Copy zoom-transcript-bot to Hammerspoon
# (Assumes the folder is in current directory)
cp -r zoom-transcript-bot ~/.hammerspoon/

# 4. Create vault folders (replace VAULT_PATH)
VAULT_PATH=~/Documents/YOUR_VAULT_NAME
mkdir -p "$VAULT_PATH/Daily"
mkdir -p "$VAULT_PATH/Meetings/Transcripts"
mkdir -p "$VAULT_PATH/Meetings/Notes"
mkdir -p "$VAULT_PATH/copilot/copilot-custom-prompts"

# 5. Copy example prompts to vault
cp -r ~/.hammerspoon/zoom-transcript-bot/example-prompts/* "$VAULT_PATH/copilot/copilot-custom-prompts/"

# 6. Add bot to Hammerspoon init.lua
echo 'require("zoom-transcript-bot")' >> ~/.hammerspoon/init.lua
```

## Configuration

Edit `~/.hammerspoon/zoom-transcript-bot/config.lua`:

Replace these values:
```lua
OBSIDIAN_VAULT_NAME = "YOUR_VAULT_NAME",  -- Line 18
OBSIDIAN_VAULT_ROOT = HOME .. "/Documents/YOUR_VAULT_NAME/",  -- Line 21
```

## Manual Steps (Tell User)

After automated setup, instruct user to:

1. **Grant Accessibility Permission:**
   - Open System Settings → Privacy & Security → Accessibility
   - Add Hammerspoon and enable it

2. **Get API Token (for Obsidian Copilot):**
   - Go to https://ai-gateway.zende.sk/applications
   - Create/copy API token

3. **Configure Obsidian Copilot:**
   - Settings → Community Plugins → Copilot
   - Add model `gpt-5.1-chat-latest` with base URL `https://ai-gateway.zende.sk/v1`
   - Add embedding `text-embedding-3-large` with same base URL
   - Enable CORS for both, disable other models

4. **Reload Hammerspoon:**
   - Click menu bar icon → Reload Config

## Verification

```bash
# Check installation
test -d ~/.hammerspoon/zoom-transcript-bot && echo "Bot installed: OK"
grep -q "zoom-transcript-bot" ~/.hammerspoon/init.lua && echo "init.lua configured: OK"
tail -5 ~/.zoom-transcript-bot.log 2>/dev/null || echo "Log file not created yet (normal before first run)"
```

## Troubleshooting

If bot doesn't start:
- Check `~/.zoom-transcript-bot.log` for errors
- Verify Accessibility permission is granted
- Run `hs -c "hs.reload()"` to reload Hammerspoon
