--[[
================================================================================
Zoom Transcript Bot - Hotkeys
================================================================================
Keyboard shortcut bindings.
================================================================================
--]]

local config = require("zoom-transcript-bot.config")
local log = require("zoom-transcript-bot.logging")
local fs = require("zoom-transcript-bot.filesystem")
local ui = require("zoom-transcript-bot.ui")
local transcript = require("zoom-transcript-bot.transcript")
local summary = require("zoom-transcript-bot.summary")

local hotkeys = {}

-- Forward declaration for end meeting callback
local onMeetingEndedCallback = nil

-- Set meeting ended callback
function hotkeys.setEndMeetingCallback(callback)
    onMeetingEndedCallback = callback
end

-- Setup all hotkeys
function hotkeys.setup(state)
    -- Force save transcript (Ctrl+F5)
    hs.hotkey.bind(config.HOTKEY_FORCE_SAVE[1], config.HOTKEY_FORCE_SAVE[2], function()
        log.info("Manual save triggered via hotkey")
        if state.inMeeting then
            ui.clickSaveTranscript(state)
        else
            -- Try to save anyway in case we're in a meeting but state is wrong
            local window = ui.findZoomMeetingWindow()
            if window then
                state.inMeeting = true
                state.currentMeetingTitle = ui.getMeetingTitleFromWindow(window)
                ui.clickSaveTranscript(state)
            else
                hs.alert.show("No Zoom meeting detected")
                log.warn("Manual save attempted but no meeting found")
            end
        end
    end)

    -- End session / finalize (Ctrl+F6)
    hs.hotkey.bind(config.HOTKEY_END_SESSION[1], config.HOTKEY_END_SESSION[2], function()
        log.info("Manual end session triggered via hotkey")
        if state.inMeeting then
            -- Save first, then end
            ui.clickSaveTranscript(state)
            hs.timer.doAfter(3, function()
                if onMeetingEndedCallback then
                    onMeetingEndedCallback()
                end
                hs.alert.show("Zoom transcript session ended")
            end)
        else
            hs.alert.show("No active meeting session")
        end
    end)

    -- Toggle bot (Ctrl+F7)
    hs.hotkey.bind(config.HOTKEY_TOGGLE_BOT[1], config.HOTKEY_TOGGLE_BOT[2], function()
        state.isEnabled = not state.isEnabled
        local status = state.isEnabled and "enabled" or "disabled"
        log.info("Transcript bot " .. status)
        hs.alert.show("Zoom Transcript Bot: " .. status)
    end)

    -- Move transcripts to Obsidian (Ctrl+F8)
    hs.hotkey.bind(config.HOTKEY_MOVE_TO_OBSIDIAN[1], config.HOTKEY_MOVE_TO_OBSIDIAN[2], function()
        log.info("Manual move to Obsidian triggered via hotkey")
        transcript.moveAllTranscriptsToObsidian()
    end)

    -- Create summary note from clipboard (Ctrl+F9)
    hs.hotkey.bind(config.HOTKEY_CREATE_SUMMARY[1], config.HOTKEY_CREATE_SUMMARY[2], function()
        log.info("Create summary note triggered via hotkey")
        summary.createSummaryNote()
    end)

    -- Link all transcripts to daily notes (Ctrl+F10)
    hs.hotkey.bind(config.HOTKEY_LINK_DAILY_NOTES[1], config.HOTKEY_LINK_DAILY_NOTES[2], function()
        log.info("Link transcripts to daily notes triggered via hotkey")
        fs.linkAllTranscriptsToDailyNotes()
    end)

    log.info("Hotkeys registered:")
    log.info("  Ctrl+F5: Force save transcript")
    log.info("  Ctrl+F6: End session and finalize")
    log.info("  Ctrl+F7: Toggle bot on/off")
    log.info("  Ctrl+F8: Move transcripts to Obsidian")
    log.info("  Ctrl+F9: Create summary note from clipboard")
    log.info("  Ctrl+F10: Link all transcripts to daily notes")
end

return hotkeys
