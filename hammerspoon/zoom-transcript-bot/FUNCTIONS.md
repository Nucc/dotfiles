# Zoom Transcript Bot - API Documentation

## Overview

Hammerspoon module that automatically captures Zoom meeting transcripts and integrates them with Obsidian.

**Features:**
- Auto-detects Zoom meeting join/end
- Opens transcript sidebar automatically
- Periodic transcript saves during meeting
- Converts transcripts to Obsidian notes with YAML frontmatter
- Extracts participants, tags, and action items
- Creates summary notes from AI-generated content
- Links transcripts to daily notes
- Smart notifications for meeting analysis

---

## Module Structure

```
zoom-transcript-bot/
├── init.lua        # Main module, lifecycle management
├── config.lua      # Configuration constants
├── state.lua       # State management
├── logging.lua     # Timestamped logging
├── filesystem.lua  # File operations, path helpers
├── ui.lua          # Zoom UI automation (accessibility)
├── transcript.lua  # Transcript processing
├── watchers.lua    # Window & file watchers
├── hotkeys.lua     # Keyboard shortcuts
└── summary.lua     # Summary note creation
```

---

## Configuration (config.lua)

### Required Settings

These must be configured for your system:

| Setting | Default | Description |
|---------|---------|-------------|
| `OBSIDIAN_VAULT_NAME` | `"work"` | Your Obsidian vault name (used in `obsidian://` URLs) |
| `OBSIDIAN_VAULT_ROOT` | `$HOME/Documents/work/` | Absolute path to your Obsidian vault root |

### Subfolder Paths

Paths relative to `OBSIDIAN_VAULT_ROOT`:

| Setting | Default | Description |
|---------|---------|-------------|
| `DAILY_NOTES_SUBFOLDER` | `"Daily/"` | Daily notes folder |
| `TRANSCRIPTS_SUBFOLDER` | `"Meetings/Transcripts/"` | Raw transcript destination |
| `SUMMARY_NOTES_SUBFOLDER` | `"Meetings/Notes/"` | AI-generated summary notes |

### System Paths

Usually don't need to change:

| Setting | Default | Description |
|---------|---------|-------------|
| `ZOOM_TRANSCRIPT_DEFAULT_FOLDER` | `$HOME/Documents/Zoom/` | Where Zoom saves transcripts |
| `LOG_FILE` | `$HOME/.zoom-transcript-bot.log` | Log file location |

### Timing Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `DELAY_AFTER_JOIN_SECONDS` | `10` | Wait before opening transcript sidebar |
| `PERIODIC_SAVE_INTERVAL_SECONDS` | `15` | Save interval during meeting |
| `UI_RETRY_ATTEMPTS` | `5` | Retry count for UI elements |
| `UI_RETRY_DELAY_SECONDS` | `1` | Base delay between retries |
| `UI_RETRY_BACKOFF_MULTIPLIER` | `1.5` | Exponential backoff multiplier |
| `FILE_DETECTION_WINDOW_SECONDS` | `30` | Window to detect new transcript files |

### Notification Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `LONG_MEETING_WARNING_MINUTES` | `60` | Warn when meeting exceeds duration |
| `ENABLE_SMART_NOTIFICATIONS` | `true` | Show meeting analysis notifications |
| `AUTO_OPEN_IN_OBSIDIAN` | `true` | Open transcript in Obsidian after meeting |

### UI Element Identifiers

May need adjustment for different Zoom versions:

| Setting | Default | Description |
|---------|---------|-------------|
| `ZOOM_BUNDLE_ID` | `"us.zoom.xos"` | Zoom app bundle identifier |
| `TRANSCRIPT_BUTTON_TITLES` | `{"Transcript", "Show Transcript", "transcript"}` | Button labels to search |
| `MORE_BUTTON_TITLES` | `{"More", "More options", "..."}` | More menu button labels |
| `SAVE_TRANSCRIPT_TITLES` | `{"Save transcript", "Save Transcript", "Save"}` | Save button labels |

### Skip Patterns

| Setting | Default | Description |
|---------|---------|-------------|
| `SKIP_MEETING_PATTERNS` | `{"Personal Meeting Room"}` | Meeting names to skip during batch import |
| `TRANSCRIPT_EXTENSIONS` | `{"txt", "vtt"}` | Valid transcript file extensions |

### Computed Paths

These are automatically derived (do not modify):

| Variable | Computed From |
|----------|---------------|
| `DAILY_NOTES_FOLDER` | `OBSIDIAN_VAULT_ROOT .. DAILY_NOTES_SUBFOLDER` |
| `DESTINATION_FOLDER` | `OBSIDIAN_VAULT_ROOT .. TRANSCRIPTS_SUBFOLDER` |
| `SUMMARY_FOLDER` | `OBSIDIAN_VAULT_ROOT .. SUMMARY_NOTES_SUBFOLDER` |

---

## Hotkeys

| Hotkey | Config Key | Description |
|--------|------------|-------------|
| **Ctrl+F5** | `HOTKEY_FORCE_SAVE` | Save transcript immediately |
| **Ctrl+F6** | `HOTKEY_END_SESSION` | End meeting and finalize |
| **Ctrl+F7** | `HOTKEY_TOGGLE_BOT` | Enable/disable bot |
| **Ctrl+F8** | `HOTKEY_MOVE_TO_OBSIDIAN` | Batch move all Zoom transcripts |
| **Ctrl+F9** | `HOTKEY_CREATE_SUMMARY` | Create meeting note from clipboard |
| **Ctrl+F10** | `HOTKEY_LINK_DAILY_NOTES` | Link all transcripts to daily notes |

---

## Functions by Module

### logging.lua

| Function | Description |
|----------|-------------|
| `log.info(msg)` | Log info message |
| `log.warn(msg)` | Log warning message |
| `log.error(msg)` | Log error message |
| `log.debug(msg)` | Log debug message |

### state.lua

| Function | Description |
|----------|-------------|
| `state.reset()` | Reset all state for new meeting |

**State Variables:**
- `isEnabled` - Bot enabled state
- `inMeeting` - Currently in meeting
- `currentMeetingTitle` - Active meeting title
- `transcriptSidebarOpen` - Sidebar state
- `processedFiles` - Processed file tracking
- `meetingStartTime` - When meeting started
- `saveCount` - Number of saves performed
- `failedSaveCount` - Consecutive failed saves
- `meetingEndedTime` - Cooldown timestamp

### filesystem.lua

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `ensureDirectoryExists(path)` | path | boolean | Create directory if needed |
| `fileExists(path)` | path | boolean | Check file existence |
| `readFile(path)` | path | string/nil | Read file contents |
| `writeFile(path, content)` | path, content | boolean | Write file |
| `getFileModificationTime(path)` | path | number/nil | Get modification time |
| `findNewestFile(dir, maxAge)` | directory, seconds | path, time | Find newest transcript file |
| `generateDestinationPath(title)` | meetingTitle | string | Generate transcript path |
| `openInObsidian(path)` | filePath | - | Open file in Obsidian |
| `openSummaryInObsidian(filename)` | filename | - | Open summary in Obsidian |
| `createDailyNote(date)` | date | boolean | Create daily note with template |
| `linkToDailyNote(file, title, date)` | filename, title, date | - | Add link to daily note |
| `linkAllTranscriptsToDailyNotes()` | - | linked, created | Batch link all transcripts |
| `getMeetingTitleFromZoomFolder()` | - | string/nil | Extract title from Zoom folder |
| `isTranscriptFile(filename)` | filename | boolean | Check if valid extension |
| `shouldSkipMeeting(name)` | meetingName | boolean | Check against skip patterns |
| `parseZoomFolderName(folder)` | folderName | table/nil | Parse Zoom folder metadata |
| `scanMarkdownFiles(dir, cb, load)` | directory, callback, loadContent | - | Iterate markdown files |
| `buildParticipantsYAML(list)` | participants | string | Build YAML participants block |
| `buildTagsYAML(tags)` | tags | string | Build YAML tags block |

### ui.lua

| Function | Description |
|----------|-------------|
| `findZoomApp()` | Find Zoom application |
| `findZoomMeetingWindow()` | Find active meeting window |
| `getMeetingTitleFromWindow(window)` | Extract meeting title from window |
| `findUIElement(root, criteria, depth)` | Search accessibility tree |
| `findUIElementWithRetry(root, criteria, desc)` | Search with retry and backoff |
| `clickElement(element)` | Click UI element |
| `getWindowAXUIElement(window)` | Get window accessibility element |
| `isTranscriptSidebarOpen(windowElement)` | Check if transcript sidebar is open |
| `openTranscriptSidebar(state)` | Open transcript sidebar |
| `clickSaveTranscript(state)` | Click save transcript button |
| `dumpAccessibilityTree(element, depth, maxDepth)` | Debug: dump UI tree |
| `inspectZoomUI()` | Debug: inspect Zoom accessibility structure |

### transcript.lua

| Function | Description |
|----------|-------------|
| `extractParticipants(content)` | Extract participant names from transcript |
| `detectMeetingType(title, content)` | Auto-detect meeting type tags |
| `extractActionItems(content)` | Extract potential action items |
| `generateYAMLFrontmatter(title, participants, tags)` | Generate YAML frontmatter |
| `appendActionItemsToNote(path, items)` | Append action items to note |
| `showSmartNotifications(content, items, participants, title)` | Show meeting analysis notification |
| `processTranscriptFile(source, title, state, openInObsidian)` | Main transcript processing |
| `moveAllTranscriptsToObsidian()` | Batch move all transcripts |
| `repairMissingParticipants()` | Fix transcripts missing participants |

### summary.lua

| Function | Description |
|----------|-------------|
| `createSummaryNote()` | Create meeting note from clipboard |
| `repairMissingParticipants()` | Fix meeting notes missing participants |

### watchers.lua

| Function | Description |
|----------|-------------|
| `setCallbacks(joinCallback, endCallback)` | Set lifecycle callbacks |
| `setupWindowWatcher(state, timers, watcherRefs)` | Initialize window detection |
| `setupFileWatcher(state, watcherRefs)` | Initialize file watcher |
| `startPeriodicSave(state, timers)` | Start periodic save timer |
| `handleTranscriptSave(state)` | Find and process newest transcript |

### hotkeys.lua

| Function | Description |
|----------|-------------|
| `setup(state)` | Register all hotkeys |
| `setEndMeetingCallback(callback)` | Set meeting end callback |

### init.lua (Main Module)

| Function | Description |
|----------|-------------|
| `M.start()` | Initialize and start bot |
| `M.stop()` | Stop bot and cleanup |
| `M.restart()` | Restart bot |
| `M.getStatus()` | Print current status to console |
| `M.testOpenTranscript()` | Test opening transcript sidebar |
| `M.testSaveTranscript()` | Test saving transcript |
| `M.testFindNewestFile()` | Test finding newest transcript file |
| `M.inspectZoomUI()` | Debug UI inspection |

**Exported Properties:**
- `M.config` - Configuration table
- `M.state` - Current state
- `M.timers` - Active timers
- `M.watchers` - Active watchers

---

## File Formats

### Transcript Note

Location: `{TRANSCRIPTS_SUBFOLDER}/{date} {time} - Zoom - {title}.md`

```yaml
---
date: 2026-01-14T10:31:35+0000
source: zoom
type: transcript
status: raw|processed
meeting_title: "Meeting Name"
participants:
  - "Name 1"
  - "Name 2"
tags:
  - meeting
  - transcript
  - standup
summary: "[[Meetings/Notes/2026-01-14 1031 - Meeting Name]]"
daily_note: "[[Daily/2026-01-14]]"
---

> [!info] Raw Transcript
> Use **The_Summarizer** to generate structured summary.

[Speaker Name] 10:31:34
Transcript content here...

## Potential Action Items (Auto-Detected)

- [ ] Follow up on X
- [ ] Schedule meeting about Y
```

### Summary Note

Location: `{SUMMARY_NOTES_SUBFOLDER}/{date} {time} - {title}.md`

```yaml
---
date: 2026-01-14T10:31:00
source: zoom
type: meeting-notes
status: processed
meeting_title: "Meeting Name"
participants:
  - "Name 1"
  - "Name 2"
tags:
  - meeting
  - transcript
  - notes
daily_note: "[[Daily/2026-01-14]]"
transcript: "[[Meetings/Transcripts/2026-01-14 1031 - Zoom - Meeting Name]]"
---

## TL;DR
Brief summary of the meeting...

## Key Discussion Points
- Point 1
- Point 2

## Action Items
- [ ] Task assigned to Person

---

## Source
- **Transcript:** [[Meetings/Transcripts/...|Full Transcript]]
- **Processed:** 2026-01-14 14:30
```

### Daily Note

Location: `{DAILY_NOTES_SUBFOLDER}/{date}.md`

```yaml
---
date: 2026-01-14
type: daily
tags:
  - daily
---

# 2026-01-14

## Meetings

- 10:31 [[Meetings/Transcripts/2026-01-14 1031 - Zoom - Meeting Name|Meeting Name]]
- 14:00 [[Meetings/Transcripts/2026-01-14 1400 - Zoom - Another Meeting|Another Meeting]]
```

---

## Workflow

1. **Join Meeting** - Bot detects Zoom meeting window, waits configured delay
2. **Open Transcript** - Opens transcript sidebar via accessibility API
3. **Periodic Save** - Saves transcript every N seconds during meeting
4. **Meeting End** - Detects meeting end, performs final save
5. **Process** - Converts to markdown, extracts metadata, moves to Obsidian
6. **Link** - Links transcript to daily note
7. **Summarize** - User generates AI summary, presses Ctrl+F9 to create note

---

## Troubleshooting

**Bot not detecting meeting:**
- Ensure Hammerspoon has Accessibility permissions in System Preferences
- Check if Zoom meeting window title contains "Zoom Meeting"
- Run `ZoomBot.getStatus()` in Hammerspoon console
- Check log: `tail -f ~/.zoom-transcript-bot.log`

**Transcript not saving:**
- Ensure Zoom's transcript/closed captions feature is enabled for the meeting
- Check transcript sidebar is visible in Zoom
- Try `Ctrl+F5` to force save
- Run `ZoomBot.inspectZoomUI()` to debug accessibility tree

**Links broken in Obsidian:**
- Verify subfolder paths in config.lua match your vault structure
- Ensure folders exist: Daily/, Meetings/Transcripts/, Meetings/Notes/
- Run `Ctrl+F10` to re-link all daily notes

**Missing participants:**
- Run repair: `require("zoom-transcript-bot.transcript").repairMissingParticipants()`
- For meeting notes: `require("zoom-transcript-bot.summary").repairMissingParticipants()`

**UI elements not found:**
- Zoom may have changed button labels - update `TRANSCRIPT_BUTTON_TITLES` etc. in config
- Run `ZoomBot.inspectZoomUI()` during a meeting to see current UI structure

---

## Console Commands

In Hammerspoon console, use the global `ZoomBot` object:

```lua
-- Check current status
ZoomBot.getStatus()

-- Inspect Zoom accessibility tree (during meeting)
ZoomBot.inspectZoomUI()

-- Test opening transcript sidebar
ZoomBot.testOpenTranscript()

-- Test saving transcript
ZoomBot.testSaveTranscript()

-- Test finding newest transcript file
ZoomBot.testFindNewestFile()

-- Access configuration
ZoomBot.config.PERIODIC_SAVE_INTERVAL_SECONDS

-- Check state
ZoomBot.state.inMeeting
ZoomBot.state.currentMeetingTitle
```

---

## Version History

- **v2.1** - Configurable paths, shareable configuration
- **v2.0** - Modular refactor, vault restructure, helper functions
- **v1.0** - Initial monolithic implementation
