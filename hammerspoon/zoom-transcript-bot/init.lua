--[[
================================================================================
Zoom Transcript Bot - Main Module
================================================================================
Automatically opens Zoom's Transcript sidebar after joining a meeting and
saves transcripts to an Obsidian vault folder.

Architecture:
- Window watcher detects Zoom meeting windows
- AXUIElement API navigates Zoom's accessibility tree
- Periodic timer saves transcripts every N minutes
- File watcher moves saved transcripts to destination folder
- Meeting end detection triggers final save

Modules:
- config.lua     - Configuration constants
- state.lua      - State management
- logging.lua    - Timestamped logging
- filesystem.lua - File operations
- ui.lua         - Accessibility UI automation
- transcript.lua - Transcript processing
- watchers.lua   - Window & file watchers
- hotkeys.lua    - Keyboard shortcuts
- summary.lua    - Summary note creation

Author: Claude Code
License: MIT
================================================================================
--]]

-- Load modules
local config = require("zoom-transcript-bot.config")
local stateModule = require("zoom-transcript-bot.state")
local log = require("zoom-transcript-bot.logging")
local fs = require("zoom-transcript-bot.filesystem")
local ui = require("zoom-transcript-bot.ui")
local transcript = require("zoom-transcript-bot.transcript")
local watchersModule = require("zoom-transcript-bot.watchers")
local hotkeys = require("zoom-transcript-bot.hotkeys")

-- Main module
local M = {}

-- Export state and config for external access
M.config = config
M.state = stateModule.state
M.timers = stateModule.timers
M.watchers = stateModule.watchers

--------------------------------------------------------------------------------
-- MEETING LIFECYCLE
--------------------------------------------------------------------------------

local function onMeetingJoined(window)
    local state = stateModule.state
    local timers = stateModule.timers

    if state.inMeeting then
        log.debug("Already in meeting, ignoring join event")
        return
    end

    -- Cooldown: ignore meeting detection for 10 seconds after meeting ended
    if state.meetingEndedTime and (os.time() - state.meetingEndedTime) < 10 then
        log.debug("Ignoring meeting detection - cooldown period after meeting ended")
        return
    end

    log.info("Meeting joined detected")
    state.inMeeting = true
    state.currentMeetingWindowId = window:id()
    state.currentMeetingTitle = ui.getMeetingTitleFromWindow(window)
    state.meetingStartTime = os.time()
    state.transcriptSidebarOpen = false
    state.saveCount = 0
    state.failedSaveCount = 0
    state.longMeetingWarningShown = false

    log.info("Meeting title: " .. (state.currentMeetingTitle or "Unknown"))

    -- Schedule transcript opening after delay
    if timers.joinDelay then
        timers.joinDelay:stop()
    end

    log.info("Scheduling transcript open in " .. config.DELAY_AFTER_JOIN_SECONDS .. " seconds")
    timers.joinDelay = hs.timer.doAfter(config.DELAY_AFTER_JOIN_SECONDS, function()
        if state.inMeeting then
            ui.openTranscriptSidebar(state)
            watchersModule.startPeriodicSave(state, timers)
        end
    end)
end

local function onMeetingEnded()
    local state = stateModule.state
    local timers = stateModule.timers

    if not state.inMeeting then
        return
    end

    log.info("Meeting ended detected")

    -- Set cooldown timestamp to prevent immediate re-detection
    state.meetingEndedTime = os.time()

    -- Stop timers
    if timers.joinDelay then
        timers.joinDelay:stop()
        timers.joinDelay = nil
    end
    if timers.periodicSave then
        timers.periodicSave:stop()
        timers.periodicSave = nil
    end

    -- Capture state before resetting
    local meetingTitle = state.currentMeetingTitle
    local duration = os.time() - (state.meetingStartTime or os.time())

    log.info(string.format("Meeting ended. Duration: %d minutes. Saves performed: %d",
        math.floor(duration / 60), state.saveCount))

    -- Reset state (clears processedFiles so final save can work)
    stateModule.reset()

    -- Final save attempt
    log.info("Performing final transcript save and move to Obsidian")
    hs.timer.doAfter(2, function()
        local sourceFile = fs.findNewestFile(
            config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER,
            120  -- Look back 2 minutes
        )
        if sourceFile then
            log.info("Found transcript file: " .. sourceFile)
            -- true = open in Obsidian (only on final save)
            transcript.processTranscriptFile(sourceFile, meetingTitle, state, true)
        else
            log.warn("No transcript file found to move")
        end
    end)
end

--------------------------------------------------------------------------------
-- DEBUG / UTILITY FUNCTIONS (exported)
--------------------------------------------------------------------------------

function M.inspectZoomUI()
    ui.inspectZoomUI()
end

function M.testOpenTranscript()
    return ui.openTranscriptSidebar(stateModule.state)
end

function M.testSaveTranscript()
    return ui.clickSaveTranscript(stateModule.state)
end

function M.testFindNewestFile()
    local file, time = fs.findNewestFile(config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER, 3600)
    if file then
        print("Newest file: " .. file)
        print("Modified: " .. os.date("%Y-%m-%d %H:%M:%S", time))
    else
        print("No transcript files found")
    end
    return file
end

function M.getStatus()
    local state = stateModule.state
    print("=== Zoom Transcript Bot Status ===")
    print("Enabled: " .. tostring(state.isEnabled))
    print("In Meeting: " .. tostring(state.inMeeting))
    print("Meeting Title: " .. (state.currentMeetingTitle or "N/A"))
    print("Transcript Sidebar Open: " .. tostring(state.transcriptSidebarOpen))
    print("Save Count: " .. state.saveCount)
    print("Processed Files: " .. #state.processedFiles)
end

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

function M.start()
    local state = stateModule.state
    local timers = stateModule.timers
    local watcherRefs = stateModule.watchers

    log.info("==============================================")
    log.info("Zoom Transcript Bot starting...")
    log.info("==============================================")

    -- Ensure destination folder exists
    fs.ensureDirectoryExists(config.DESTINATION_FOLDER)

    -- Setup callbacks
    watchersModule.setCallbacks(onMeetingJoined, onMeetingEnded)
    hotkeys.setEndMeetingCallback(onMeetingEnded)

    -- Setup components
    hotkeys.setup(state)
    watchersModule.setupWindowWatcher(state, timers, watcherRefs)
    watchersModule.setupFileWatcher(state, watcherRefs)

    log.info("Zoom Transcript Bot initialized successfully")
    log.info("Destination folder: " .. config.DESTINATION_FOLDER)
    log.info("Zoom transcript folder: " .. config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER)

    hs.alert.show("Zoom Transcript Bot Started")

    return M
end

function M.stop()
    local timers = stateModule.timers
    local watcherRefs = stateModule.watchers

    log.info("Zoom Transcript Bot stopping...")

    -- Stop all timers
    if timers.joinDelay then
        timers.joinDelay:stop()
        timers.joinDelay = nil
    end
    if timers.periodicSave then
        timers.periodicSave:stop()
        timers.periodicSave = nil
    end
    if timers.meetingPoll then
        timers.meetingPoll:stop()
        timers.meetingPoll = nil
    end

    -- Stop watchers
    if watcherRefs.window then
        watcherRefs.window:unsubscribeAll()
        watcherRefs.window = nil
    end
    if watcherRefs.file then
        watcherRefs.file:stop()
        watcherRefs.file = nil
    end

    log.info("Zoom Transcript Bot stopped")
    hs.alert.show("Zoom Transcript Bot Stopped")
end

function M.restart()
    M.stop()
    hs.timer.doAfter(1, function()
        M.start()
    end)
end

-- Auto-start when loaded
return M.start()
