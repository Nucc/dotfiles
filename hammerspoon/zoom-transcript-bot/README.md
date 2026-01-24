# Zoom Transcript Bot

Hammerspoon module for automatic Zoom transcript capture and Obsidian integration.

## Features

- Auto-detects Zoom meeting join/end
- Opens transcript sidebar automatically
- Periodic transcript saves during meeting
- Converts transcripts to Obsidian markdown notes with YAML frontmatter
- Extracts participants, tags, and action items
- Creates summary notes from AI-generated content
- Links transcripts to daily notes
- Smart notifications for meeting analysis

## Requirements

- macOS
- [Hammerspoon](https://www.hammerspoon.org/) installed
- [Obsidian](https://obsidian.md/) (optional, for vault integration)
- Zoom with transcript/closed captions enabled

## Installation

1. **Clone or copy** the `zoom-transcript-bot` folder to your Hammerspoon config:
   ```bash
   cp -r zoom-transcript-bot ~/.hammerspoon/
   ```

2. **Configure paths** in `~/.hammerspoon/zoom-transcript-bot/config.lua`:
   ```lua
   -- Required: Set your Obsidian vault name and path
   OBSIDIAN_VAULT_NAME = "your-vault-name",
   OBSIDIAN_VAULT_ROOT = os.getenv("HOME") .. "/path/to/your/vault/",

   -- Optional: Customize subfolder paths (defaults shown)
   DAILY_NOTES_SUBFOLDER = "Daily/",
   TRANSCRIPTS_SUBFOLDER = "Meetings/Transcripts/",
   SUMMARY_NOTES_SUBFOLDER = "Meetings/Notes/",
   ```

3. **Add to** `~/.hammerspoon/init.lua`:
   ```lua
   require("zoom-transcript-bot")
   ```

4. **Reload Hammerspoon** (or press your reload hotkey)

5. **Grant permissions**: macOS will prompt for Accessibility permissions for Hammerspoon

## Configuration

Edit `config.lua` to customize:

| Setting | Description |
|---------|-------------|
| `OBSIDIAN_VAULT_NAME` | Your Obsidian vault name (for obsidian:// URLs) |
| `OBSIDIAN_VAULT_ROOT` | Absolute path to your vault root |
| `DAILY_NOTES_SUBFOLDER` | Path to daily notes within vault |
| `TRANSCRIPTS_SUBFOLDER` | Path for raw transcripts |
| `SUMMARY_NOTES_SUBFOLDER` | Path for AI-generated summaries |
| `ZOOM_TRANSCRIPT_DEFAULT_FOLDER` | Where Zoom saves transcripts (default: `~/Documents/Zoom/`) |
| `PERIODIC_SAVE_INTERVAL_SECONDS` | How often to save during meeting (default: 15) |
| `SKIP_MEETING_PATTERNS` | Meeting names to skip during batch import |

## Hotkeys

| Key | Action |
|-----|--------|
| `Ctrl+F5` | Force save transcript |
| `Ctrl+F6` | End session & finalize |
| `Ctrl+F7` | Toggle bot on/off |
| `Ctrl+F8` | Batch move transcripts to Obsidian |
| `Ctrl+F9` | Create summary from clipboard |
| `Ctrl+F10` | Link transcripts to daily notes |

## Vault Structure

The bot expects this folder structure in your Obsidian vault:

```
your-vault/
├── Daily/              # Daily notes (auto-linked)
├── Meetings/
│   ├── Notes/          # AI summaries (Ctrl+F9)
│   └── Transcripts/    # Raw transcripts
```

Create these folders before using the bot, or customize the paths in `config.lua`.

## Usage

### Automatic Mode
1. Join a Zoom meeting
2. Bot automatically detects the meeting
3. Opens transcript sidebar
4. Saves periodically during meeting
5. Moves final transcript to Obsidian when meeting ends

### Creating Summary Notes
1. Open a transcript in Obsidian
2. Use AI (e.g., Obsidian Copilot, ChatGPT) to generate a summary
3. Copy summary to clipboard
4. Press `Ctrl+F9`
5. Summary note is created with links to transcript and daily note

### Manual Controls
- `Ctrl+F5` - Force save if auto-save isn't working
- `Ctrl+F6` - Manually end session if meeting end wasn't detected
- `Ctrl+F7` - Temporarily disable bot
- `Ctrl+F8` - Batch import old Zoom transcripts

## Troubleshooting

**Bot not detecting meeting:**
- Ensure Hammerspoon has Accessibility permissions
- Check `~/.zoom-transcript-bot.log` for errors
- Try `ZoomBot.getStatus()` in Hammerspoon console

**Transcript not saving:**
- Ensure Zoom's transcript/closed captions feature is enabled
- Check if transcript sidebar is visible in Zoom
- Try `Ctrl+F5` to force save

**Links broken in Obsidian:**
- Verify folder paths in `config.lua` match your vault structure
- Run `Ctrl+F10` to re-link daily notes

## Logs

View real-time logs:
```bash
tail -f ~/.zoom-transcript-bot.log
```

## Documentation

See [FUNCTIONS.md](FUNCTIONS.md) for full API documentation.

## License

MIT
