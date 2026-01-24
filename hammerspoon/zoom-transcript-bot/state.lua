--[[
================================================================================
Zoom Transcript Bot - State Management
================================================================================
Manages bot state, timers, and watchers.
================================================================================
--]]

local state = {
    -- Bot state
    isEnabled = true,
    inMeeting = false,
    currentMeetingTitle = nil,
    currentMeetingWindowId = nil,
    transcriptSidebarOpen = false,
    lastSaveTime = nil,
    processedFiles = {},  -- Track files we've already moved
    meetingStartTime = nil,
    saveCount = 0,
    failedSaveCount = 0,  -- Track consecutive failed saves
    dialogShowing = false,  -- Prevent multiple dialogs
    longMeetingWarningShown = false,  -- Track if we've warned about long meeting
    meetingEndedTime = nil,  -- Cooldown after meeting ends
}

-- Timers (initialized as nil, will be set when needed)
local timers = {
    joinDelay = nil,
    periodicSave = nil,
    meetingPoll = nil,
}

-- Watchers (initialized as nil, will be set when needed)
local watchers = {
    window = nil,
    file = nil,
}

-- Reset state for new meeting
local function reset()
    state.inMeeting = false
    state.currentMeetingTitle = nil
    state.currentMeetingWindowId = nil
    state.transcriptSidebarOpen = false
    state.meetingStartTime = nil
    state.saveCount = 0
    state.failedSaveCount = 0
    state.longMeetingWarningShown = false
    state.processedFiles = {}
end

return {
    state = state,
    timers = timers,
    watchers = watchers,
    reset = reset,
}
