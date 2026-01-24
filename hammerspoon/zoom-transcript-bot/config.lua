--[[
================================================================================
Zoom Transcript Bot - Configuration
================================================================================
All configurable settings for the bot.
================================================================================
--]]

-- Get user home directory
local HOME = os.getenv("HOME")

local config = {
    -- ==========================================================================
    -- REQUIRED: Configure these paths for your system
    -- ==========================================================================

    -- Obsidian vault name (used for obsidian:// URLs)
    OBSIDIAN_VAULT_NAME = "Work",

    -- Obsidian vault root path (absolute path to your vault)
    OBSIDIAN_VAULT_ROOT = HOME .. "/Documents/Meetings/Work/",

    -- Subfolders within vault (relative to OBSIDIAN_VAULT_ROOT)
    -- These will be automatically prefixed with OBSIDIAN_VAULT_ROOT
    DAILY_NOTES_SUBFOLDER = "Daily/",
    TRANSCRIPTS_SUBFOLDER = "Meetings/Transcripts/",
    SUMMARY_NOTES_SUBFOLDER = "Meetings/Notes/",

    -- ==========================================================================
    -- System paths (usually don't need to change)
    -- ==========================================================================

    -- Zoom's default transcript save location (macOS default)
    ZOOM_TRANSCRIPT_DEFAULT_FOLDER = HOME .. "/Documents/Zoom/",

    -- Log file path
    LOG_FILE = HOME .. "/.zoom-transcript-bot.log",

    -- Timing configuration
    DELAY_AFTER_JOIN_SECONDS = 10,       -- Wait before opening transcript
    PERIODIC_SAVE_INTERVAL_SECONDS = 15, -- Save every 15 seconds
    UI_RETRY_ATTEMPTS = 5,                -- Number of retries for UI elements
    UI_RETRY_DELAY_SECONDS = 1,           -- Base delay between retries
    UI_RETRY_BACKOFF_MULTIPLIER = 1.5,    -- Exponential backoff multiplier
    FILE_DETECTION_WINDOW_SECONDS = 30,   -- Window to detect new transcript files

    -- Smart notifications
    LONG_MEETING_WARNING_MINUTES = 60,    -- Warn when meeting exceeds this duration
    ENABLE_SMART_NOTIFICATIONS = true,

    -- Zoom app identifier
    ZOOM_BUNDLE_ID = "us.zoom.xos",

    -- UI element identifiers (may need adjustment for Zoom versions)
    TRANSCRIPT_BUTTON_TITLES = {"Transcript", "Show Transcript", "transcript"},
    MORE_BUTTON_TITLES = {"More", "More options", "..."},
    SAVE_TRANSCRIPT_TITLES = {"Save transcript", "Save Transcript", "Save"},

    -- Hotkeys (Ctrl + number keys)
    HOTKEY_FORCE_SAVE = {{"ctrl"}, "5"},   -- Ctrl+5: Save transcript
    HOTKEY_END_SESSION = {{"ctrl"}, "6"},  -- Ctrl+6: End meeting
    HOTKEY_TOGGLE_BOT = {{"ctrl"}, "7"},   -- Ctrl+7: Toggle bot
    HOTKEY_MOVE_TO_OBSIDIAN = {{"ctrl"}, "8"},  -- Ctrl+8: Move transcripts to Obsidian
    HOTKEY_CREATE_SUMMARY = {{"ctrl"}, "9"},  -- Ctrl+9: Create summary note from clipboard
    HOTKEY_LINK_DAILY_NOTES = {{"ctrl"}, "0"},  -- Ctrl+0: Link all transcripts to daily notes

    -- Obsidian integration
    AUTO_OPEN_IN_OBSIDIAN = true,  -- Open transcript in Obsidian after meeting ends

    -- Meetings to skip during batch import (patterns)
    -- Add your personal meeting room patterns here
    SKIP_MEETING_PATTERNS = {
        "Personal Meeting Room",
        -- Add patterns like "Your Name's Zoom Meeting" here
    },

    -- Transcript file extensions
    TRANSCRIPT_EXTENSIONS = {"txt", "vtt"},
}

-- ==========================================================================
-- Computed paths (do not modify - these are derived from settings above)
-- ==========================================================================
config.DAILY_NOTES_FOLDER = config.OBSIDIAN_VAULT_ROOT .. config.DAILY_NOTES_SUBFOLDER
config.DESTINATION_FOLDER = config.OBSIDIAN_VAULT_ROOT .. config.TRANSCRIPTS_SUBFOLDER
config.SUMMARY_FOLDER = config.OBSIDIAN_VAULT_ROOT .. config.SUMMARY_NOTES_SUBFOLDER

return config
