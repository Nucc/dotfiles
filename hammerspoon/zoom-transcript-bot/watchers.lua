--[[
================================================================================
Zoom Transcript Bot - Watchers
================================================================================
Window and file watchers for meeting detection and transcript monitoring.
================================================================================
--]]

local config = require("zoom-transcript-bot.config")
local log = require("zoom-transcript-bot.logging")
local fs = require("zoom-transcript-bot.filesystem")
local ui = require("zoom-transcript-bot.ui")
local transcript = require("zoom-transcript-bot.transcript")

local watchers = {}

-- Forward declarations for lifecycle callbacks (will be set by init)
local onMeetingJoined = nil
local onMeetingEnded = nil

-- Set lifecycle callbacks
function watchers.setCallbacks(joinCallback, endCallback)
    onMeetingJoined = joinCallback
    onMeetingEnded = endCallback
end

-- Setup window watcher for Zoom meetings
function watchers.setupWindowWatcher(state, timers, watcherRefs)
    if watcherRefs.window then
        watcherRefs.window:stop()
    end
    if timers.meetingPoll then
        timers.meetingPoll:stop()
    end

    -- Use application watcher combined with window filter
    local windowFilter = hs.window.filter.new(false)
    windowFilter:setAppFilter("zoom.us", {allowTitles = ".*"})
    windowFilter:setAppFilter("Zoom", {allowTitles = ".*"})

    windowFilter:subscribe(hs.window.filter.windowCreated, function(window)
        if not state.isEnabled then return end

        hs.timer.doAfter(1, function()
            local meetingWindow = ui.findZoomMeetingWindow()
            if meetingWindow and not state.inMeeting then
                if onMeetingJoined then
                    onMeetingJoined(meetingWindow)
                end
            end
        end)
    end)

    -- Window focus events (more reliable)
    windowFilter:subscribe(hs.window.filter.windowFocused, function(window)
        if not state.isEnabled then return end
        if state.inMeeting then return end

        local meetingWindow = ui.findZoomMeetingWindow()
        if meetingWindow then
            log.info("Meeting detected via window focus")
            if onMeetingJoined then
                onMeetingJoined(meetingWindow)
            end
        end
    end)

    windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
        log.debug("Window event - ignoring for meeting end detection")
    end)

    watcherRefs.window = windowFilter
    log.info("Window watcher initialized")

    -- Polling fallback (every 5 seconds)
    timers.meetingPoll = hs.timer.doEvery(5, function()
        if not state.isEnabled then return end
        if state.inMeeting then return end

        local meetingWindow = ui.findZoomMeetingWindow()
        if meetingWindow then
            log.info("Meeting detected via polling")
            if onMeetingJoined then
                onMeetingJoined(meetingWindow)
            end
        end
    end)
    log.info("Meeting poll timer started (every 5 seconds)")

    -- Check current state
    local meetingWindow = ui.findZoomMeetingWindow()
    if meetingWindow and not state.inMeeting then
        log.info("Found existing meeting window on startup")
        if onMeetingJoined then
            onMeetingJoined(meetingWindow)
        end
    end
end

-- Setup file watcher for transcript files
function watchers.setupFileWatcher(state, watcherRefs)
    if watcherRefs.file then
        watcherRefs.file:stop()
    end

    local watchPath = config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER
    if not hs.fs.attributes(watchPath) then
        log.warn("Transcript folder does not exist yet: " .. watchPath)
        return
    end

    watcherRefs.file = hs.pathwatcher.new(watchPath, function(paths)
        if not state.inMeeting then return end

        for _, path in ipairs(paths) do
            local ext = path:match("%.([^%.]+)$")
            if ext and (ext:lower() == "txt" or ext:lower() == "vtt") then
                log.debug("File change detected: " .. path)
                hs.timer.doAfter(1, function()
                    if not state.processedFiles[path] then
                        -- Don't open Obsidian during periodic saves (false = don't open)
                        transcript.processTranscriptFile(path, state.currentMeetingTitle, state, false)
                    end
                end)
            end
        end
    end)

    watcherRefs.file:start()
    log.info("File watcher initialized for: " .. watchPath)
end

-- Start periodic save timer
function watchers.startPeriodicSave(state, timers)
    if timers.periodicSave then
        timers.periodicSave:stop()
    end

    log.info("Starting periodic save every " .. config.PERIODIC_SAVE_INTERVAL_SECONDS .. " seconds")

    timers.periodicSave = hs.timer.doEvery(config.PERIODIC_SAVE_INTERVAL_SECONDS, function()
        if not state.isEnabled then return end
        if not state.inMeeting then return end
        if state.dialogShowing then return end

        -- Check if Zoom Meeting window exists
        local meetingWindow = ui.findZoomMeetingWindow()
        if not meetingWindow then
            state.failedSaveCount = state.failedSaveCount + 1
            log.debug("Meeting window not found, failed count: " .. state.failedSaveCount)

            -- After 5 minutes (20 failures at 15s interval), ask user
            if state.failedSaveCount >= 20 then
                log.info("Meeting window not found for 5 minutes - asking user")
                state.dialogShowing = true
                hs.dialog.alert(100, 100, function(result)
                    state.dialogShowing = false
                    if result == "Continue" then
                        log.info("User confirmed meeting still active - continuing")
                        state.failedSaveCount = 0
                    else
                        log.info("User confirmed meeting ended - stopping")
                        if timers.periodicSave then
                            timers.periodicSave:stop()
                            timers.periodicSave = nil
                        end
                        state.inMeeting = false
                        state.failedSaveCount = 0
                        hs.alert.show("Zoom transcript session ended")
                    end
                end, "Zoom Transcript Bot",
                "Meeting window not found for 5 minutes.\n\nIs your meeting still active?",
                "Continue", "End Meeting")
            end
            return
        end

        -- Reset failed count on success
        state.failedSaveCount = 0

        -- Check for long meeting warning
        if config.ENABLE_SMART_NOTIFICATIONS and state.meetingStartTime and not state.longMeetingWarningShown then
            local duration = os.time() - state.meetingStartTime
            local warningThreshold = config.LONG_MEETING_WARNING_MINUTES * 60
            if duration >= warningThreshold then
                state.longMeetingWarningShown = true
                local minutes = math.floor(duration / 60)
                hs.notify.new({
                    title = "⏰ Long Meeting Alert",
                    informativeText = string.format("Meeting has been running for %d minutes.\nConsider wrapping up or taking a break!", minutes),
                    autoWithdraw = false,
                    withdrawAfter = 60
                }):send()
                log.info("Long meeting warning shown at " .. minutes .. " minutes")
            end
        end

        log.info("Periodic save triggered")
        ui.clickSaveTranscript(state)
    end)
end

-- Handle transcript save (find and process newest file)
function watchers.handleTranscriptSave(state)
    log.info("Looking for saved transcript file")

    local sourceFile = fs.findNewestFile(
        config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER,
        config.FILE_DETECTION_WINDOW_SECONDS
    )

    if sourceFile then
        log.info("Found transcript file: " .. sourceFile)
        transcript.processTranscriptFile(sourceFile, state.currentMeetingTitle, state)
    else
        log.warn("No new transcript file found in: " .. config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER)
    end
end

return watchers
