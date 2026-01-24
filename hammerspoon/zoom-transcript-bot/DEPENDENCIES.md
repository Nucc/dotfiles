# Dependencies

## Required

### 1. Hammerspoon

macOS automation tool that runs Lua scripts.

```bash
# Install
brew install --cask hammerspoon

# Verify
test -d /Applications/Hammerspoon.app && echo "OK"
```

- Homepage: https://www.hammerspoon.org/
- Config location: `~/.hammerspoon/init.lua`

### 2. Accessibility Permission

Hammerspoon needs Accessibility access to control Zoom UI.

**How to grant:**
1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Add **Hammerspoon** and enable it

```bash
# Verify (will fail if not granted)
osascript -e 'tell application "System Events" to get name of first process'
```

### 3. Zoom

Desktop client with transcript feature.

```bash
# Install
brew install --cask zoom

# Verify
test -d /Applications/zoom.us.app && echo "OK"
```

**Note:** Meeting must have transcript/closed captions enabled by host.

## Optional

### Obsidian

Markdown knowledge base for storing transcripts.

```bash
# Install
brew install --cask obsidian

# Verify
test -d /Applications/Obsidian.app && echo "OK"
```

**Required Plugins:**
- Auto Note Mover
- Copilot (for AI summaries)
- Filename Heading Sync

**Copilot API Token:** https://ai-gateway.zende.sk/applications

See SETUP.md for full Copilot configuration.

---

## Quick Install

```bash
# Install all dependencies
brew install --cask hammerspoon zoom obsidian

# Create Hammerspoon config
mkdir -p ~/.hammerspoon

# Then grant Accessibility permission manually in System Settings
```

---

## Verify All

```bash
#!/bin/bash
echo "Hammerspoon: $(test -d /Applications/Hammerspoon.app && echo OK || echo MISSING)"
echo "Zoom: $(test -d /Applications/zoom.us.app && echo OK || echo MISSING)"
echo "Obsidian: $(test -d /Applications/Obsidian.app && echo OK || echo 'MISSING (optional)')"
echo "Bot: $(test -d ~/.hammerspoon/zoom-transcript-bot && echo OK || echo MISSING)"
echo "Accessibility: $(osascript -e 'tell application "System Events" to get name of first process' &>/dev/null && echo OK || echo 'NOT GRANTED')"
```
