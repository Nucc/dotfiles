--[[
================================================================================
Zoom Transcript Bot - Summary Note Creation
================================================================================
Creates meeting notes from AI-generated summaries (Ctrl+F9).
================================================================================
--]]

local config = require("zoom-transcript-bot.config")
local log = require("zoom-transcript-bot.logging")
local fs = require("zoom-transcript-bot.filesystem")

local summary = {}

-- Create summary note from clipboard content
function summary.createSummaryNote()
    -- Get clipboard content (should be the AI-generated summary)
    local summaryText = hs.pasteboard.getContents()
    if not summaryText or #summaryText < 50 then
        hs.alert.show("Clipboard is empty or too short")
        log.warn("Summary creation failed: clipboard empty or too short")
        return
    end

    -- Check if it looks like a summary (has TL;DR or Key Discussion)
    if not summaryText:find("TL;DR") and not summaryText:find("Key Discussion") then
        hs.alert.show("Clipboard doesn't look like a meeting summary")
        log.warn("Summary creation failed: doesn't look like a summary")
        return
    end

    -- Try to detect which transcript is currently open in Obsidian
    local transcript = nil

    -- Get Obsidian window title (usually contains the note name)
    local obsidianApp = hs.application.get("Obsidian")
    if obsidianApp then
        local focusedWindow = obsidianApp:focusedWindow()
        if focusedWindow then
            local windowTitle = focusedWindow:title() or ""
            -- Window title format: "Note Name - vault - Obsidian v1.x.x"
            -- Strip " - Obsidian v..." and " - vault" from end
            local noteName = windowTitle:gsub(" %- Obsidian.*$", ""):gsub(" %- work$", "")
            log.debug("Obsidian window title: " .. windowTitle)
            log.debug("Detected note name: " .. noteName)

            -- Check if this matches a transcript in Meetings/Transcripts
            local transcriptDir = config.DESTINATION_FOLDER
            for file in hs.fs.dir(transcriptDir) do
                if file:match("%.md$") then
                    local fileBase = file:gsub("%.md$", "")
                    if noteName:find(fileBase, 1, true) or fileBase:find(noteName, 1, true) then
                        transcript = file
                        log.info("Found matching transcript from Obsidian: " .. file)
                        break
                    end
                end
            end
        end
    end

    -- Fallback to most recent transcript if Obsidian detection failed
    if not transcript then
        log.debug("Could not detect from Obsidian, using most recent transcript")
        local transcriptDir = config.DESTINATION_FOLDER
        local newestTime = 0

        for file in hs.fs.dir(transcriptDir) do
            if file:match("%.md$") and not file:match("^%.") then
                local fullPath = transcriptDir .. file
                local attr = hs.fs.attributes(fullPath)
                if attr and attr.modification > newestTime then
                    newestTime = attr.modification
                    transcript = file
                end
            end
        end
    end

    if not transcript then
        hs.alert.show("No transcript found")
        log.warn("Summary creation failed: no transcript found")
        return
    end

    local newestTranscript = transcript
    local transcriptDir = config.DESTINATION_FOLDER

    -- Parse transcript filename for metadata
    -- Format: "2026-01-13 1417 - Zoom - Meeting Title.md"
    local datePart = newestTranscript:match("^(%d%d%d%d%-%d%d%-%d%d)")
    local timePart = newestTranscript:match("^%d%d%d%d%-%d%d%-%d%d (%d%d%d%d)")
    local titlePart = newestTranscript:match("Zoom %- (.+)%.md$")

    log.debug("Parsing: date=" .. (datePart or "nil") .. " time=" .. (timePart or "nil") .. " title=" .. (titlePart or "nil"))

    if not datePart or not titlePart then
        hs.alert.show("Cannot parse transcript filename")
        log.warn("Summary creation failed: cannot parse filename: " .. newestTranscript)
        return
    end

    -- Read transcript to get frontmatter
    local transcriptPath = transcriptDir .. newestTranscript
    local transcriptFile = io.open(transcriptPath, "r")
    local transcriptContent = transcriptFile and transcriptFile:read("*all") or ""
    if transcriptFile then transcriptFile:close() end

    -- Extract participants and tags from transcript frontmatter
    -- Use more specific patterns to avoid capturing summary: line
    local participantsBlock = transcriptContent:match("participants:(.-)\ntags:") or ""
    -- Stop at summary: or daily_note: (whichever comes first)
    local tagsBlock = transcriptContent:match("tags:(.-)\nsummary:")
                   or transcriptContent:match("tags:(.-)\ndaily_note:")
                   or ""

    -- Ensure summary folder exists
    fs.ensureDirectoryExists(config.SUMMARY_FOLDER)

    -- Create summary filename
    local summaryFilename = string.format("%s %s - %s.md", datePart, timePart, titlePart)
    local summaryPath = config.SUMMARY_FOLDER .. summaryFilename

    -- Build summary note content
    local transcriptLink = newestTranscript:gsub("%.md$", "")

    local participantsYAML = ""
    if #participantsBlock > 0 then
        participantsYAML = "participants:" .. participantsBlock .. "\n"
    end

    local tagsYAML = "tags:" .. tagsBlock .. "\n  - notes\n"

    -- Get subfolder paths (remove trailing slashes for wikilinks)
    local dailyPath = config.DAILY_NOTES_SUBFOLDER:gsub("/$", "")
    local transcriptsPath = config.TRANSCRIPTS_SUBFOLDER:gsub("/$", "")

    local summaryContent = string.format([=[---
date: %sT%s:00
source: zoom
type: meeting-notes
status: processed
meeting_title: "%s"
%s%sdaily_note: "[[%s/%s]]"
transcript: "[[%s/%s]]"
---

%s

---

## 📜 Source
- **Transcript:** [[%s/%s|Full Transcript]]
- **Processed:** %s
]=], datePart, timePart:sub(1,2) .. ":" .. timePart:sub(3,4),
    titlePart,
    participantsYAML,
    tagsYAML,
    dailyPath,
    datePart,
    transcriptsPath,
    transcriptLink,
    summaryText,
    transcriptsPath,
    transcriptLink,
    os.date("%Y-%m-%d %H:%M"))

    -- Write summary file
    local outFile = io.open(summaryPath, "w")
    if outFile then
        outFile:write(summaryContent)
        outFile:close()
        log.info("Created summary note: " .. summaryPath)

        -- Update transcript status to processed
        local updatedTranscript = transcriptContent:gsub("status: raw", "status: processed")
        -- Add link to summary note
        if not updatedTranscript:find("summary:") then
            local summaryPath = config.SUMMARY_NOTES_SUBFOLDER:gsub("/$", "")
            updatedTranscript = updatedTranscript:gsub(
                "daily_note:",
                string.format('summary: "[[%s/%s]]"\ndaily_note:', summaryPath, summaryFilename:gsub("%.md$", ""))
            )
        end
        local updateFile = io.open(transcriptPath, "w")
        if updateFile then
            updateFile:write(updatedTranscript)
            updateFile:close()
            log.info("Updated transcript status to processed")
        end

        -- Open summary in Obsidian
        fs.openSummaryInObsidian(summaryFilename)

        hs.alert.show("Summary note created!")
    else
        hs.alert.show("Failed to create summary note")
        log.error("Failed to write summary: " .. summaryPath)
    end
end

-- Repair meeting notes missing participants (pulls from transcripts)
function summary.repairMissingParticipants()
    log.info("Repairing meeting notes missing participants...")
    local repairedCount = 0
    local transcriptDir = config.DESTINATION_FOLDER

    fs.scanMarkdownFiles(config.SUMMARY_FOLDER, function(file, summaryPath, content)
        if content and not content:match("participants:") then
            -- Find corresponding transcript
            -- Meeting note: "2026-01-14 1031 - Neon - Standup.md"
            -- Transcript: "2026-01-14 1031 - Zoom - Neon - Standup.md"
            local datePart = file:match("^(%d%d%d%d%-%d%d%-%d%d %d%d%d%d)")
            local titlePart = file:match("^%d%d%d%d%-%d%d%-%d%d %d%d%d%d %- (.+)%.md$")

            if datePart and titlePart then
                local transcriptFile = datePart .. " - Zoom - " .. titlePart .. ".md"
                local transcriptContent = fs.readFile(transcriptDir .. transcriptFile)

                if transcriptContent then
                    -- Extract participants from transcript (stop at tags:, daily_note:, or ---)
                    local participantsBlock = transcriptContent:match("participants:(.-)\ntags:")
                                           or transcriptContent:match("participants:(.-)\ndaily_note:")
                                           or transcriptContent:match("participants:(.-)\n%-%-%-")
                                           or ""

                    if #participantsBlock > 5 then
                        -- Insert after meeting_title line
                        local updatedContent = content:gsub(
                            '(meeting_title: "[^"]*"\n)',
                            "%1participants:" .. participantsBlock
                        )

                        if updatedContent ~= content then
                            fs.writeFile(summaryPath, updatedContent)
                            log.info("Repaired meeting note: " .. file)
                            repairedCount = repairedCount + 1
                        end
                    end
                end
            end
        end
    end, true)

    local msg = string.format("Repaired %d meeting notes", repairedCount)
    log.info(msg)
    hs.alert.show(msg)
    return repairedCount
end

return summary
