--[[
================================================================================
Zoom Transcript Bot - Transcript Processing
================================================================================
Metadata extraction, frontmatter generation, and transcript file processing.
================================================================================
--]]

local config = require("zoom-transcript-bot.config")
local log = require("zoom-transcript-bot.logging")
local fs = require("zoom-transcript-bot.filesystem")

local transcript = {}

-- Extract unique participants from transcript content
function transcript.extractParticipants(content)
    local participants = {}
    local seen = {}

    -- Pattern: [Name] timestamp
    for name in content:gmatch("%[([^%]]+)%]%s*%d+:%d+") do
        local cleanName = name:gsub("^%s+", ""):gsub("%s+$", "")
        if not seen[cleanName] and #cleanName > 1 then
            seen[cleanName] = true
            table.insert(participants, cleanName)
        end
    end

    return participants
end

-- Detect meeting type from title and content
function transcript.detectMeetingType(meetingTitle, content)
    local tags = {"meeting", "transcript"}
    local title = (meetingTitle or ""):lower()
    local body = (content or ""):lower():sub(1, 2000)

    local patterns = {
        {match = {"standup", "stand%-up", "daily"}, tag = "standup"},
        {match = {"1:1", "1_1", "1%-1", "one on one"}, tag = "1on1"},
        {match = {"sprint", "planning", "refinement"}, tag = "planning"},
        {match = {"retro", "retrospective"}, tag = "retrospective"},
        {match = {"demo", "showcase"}, tag = "demo"},
        {match = {"interview"}, tag = "interview"},
        {match = {"onboard", "training"}, tag = "onboarding"},
        {match = {"review", "feedback"}, tag = "review"},
        {match = {"sync", "catchup", "catch%-up"}, tag = "sync"},
        {match = {"brainstorm"}, tag = "brainstorm"},
    }

    for _, pattern in ipairs(patterns) do
        for _, keyword in ipairs(pattern.match) do
            if title:find(keyword) or body:find(keyword) then
                table.insert(tags, pattern.tag)
                break
            end
        end
    end

    return tags
end

-- Extract potential action items from transcript
function transcript.extractActionItems(content)
    local actionItems = {}
    local patterns = {
        "I'?ll%s+(%w[^%.!?]*)",
        "I'?m going to%s+(%w[^%.!?]*)",
        "we need to%s+(%w[^%.!?]*)",
        "you should%s+(%w[^%.!?]*)",
        "action item[s]?:?%s*(%w[^%.!?]*)",
        "TODO:?%s*(%w[^%.!?]*)",
        "let'?s%s+(%w[^%.!?]*)",
    }

    for line in content:gmatch("[^\n]+") do
        for _, pattern in ipairs(patterns) do
            local match = line:lower():match(pattern)
            if match and #match > 10 then
                table.insert(actionItems, {
                    text = match,
                    context = line:sub(1, 100)
                })
            end
        end
    end
    return actionItems
end

-- Generate YAML frontmatter for Obsidian note
function transcript.generateYAMLFrontmatter(meetingTitle, participants, tags)
    local dateISO = os.date("%Y-%m-%dT%H:%M:%S%z")
    local dateShort = os.date("%Y-%m-%d")
    local dailyPath = config.DAILY_NOTES_SUBFOLDER:gsub("/$", "")

    local frontmatter = string.format([=[---
date: %s
source: zoom
type: transcript
status: raw
meeting_title: "%s"
%s%sdaily_note: "[[%s/%s]]"
---

> [!info] Raw Transcript
> Use **The_Summarizer** to generate structured summary, then **The_Gardener** to organize.

]=], dateISO, meetingTitle or "Untitled", fs.buildParticipantsYAML(participants), fs.buildTagsYAML(tags), dailyPath, dateShort)
    return frontmatter
end

-- Append action items to note file
function transcript.appendActionItemsToNote(filePath, actionItems)
    if #actionItems == 0 then return end

    local file = io.open(filePath, "a")
    if file then
        file:write("\n\n## Potential Action Items (Auto-Detected)\n\n")
        for i, item in ipairs(actionItems) do
            file:write(string.format("- [ ] %s\n", item.text))
        end
        file:close()
        log.info("Added " .. #actionItems .. " potential action items")
    end
end

-- Show smart notifications based on meeting analysis
function transcript.showSmartNotifications(content, actionItems, participants, meetingTitle)
    local notifications = {}

    -- Check transcript length
    local lineCount = select(2, content:gsub("\n", "\n"))
    if lineCount < 10 then
        table.insert(notifications, "⚠️ Very short transcript (" .. lineCount .. " lines) - possible error?")
    end

    -- No action items detected
    if #actionItems == 0 then
        table.insert(notifications, "📝 No action items detected - consider summarizing manually")
    else
        table.insert(notifications, "✅ " .. #actionItems .. " potential action items found")
    end

    -- Single participant
    if #participants <= 1 then
        table.insert(notifications, "👤 Only " .. #participants .. " participant detected")
    else
        table.insert(notifications, "👥 " .. #participants .. " participants: " .. table.concat(participants, ", "))
    end

    -- Show notification
    local title = meetingTitle or "Meeting"
    if #title > 30 then
        title = title:sub(1, 27) .. "..."
    end

    local message = table.concat(notifications, "\n")

    hs.notify.new({
        title = "📋 " .. title,
        informativeText = message,
        autoWithdraw = false,
        hasActionButton = true,
        actionButtonTitle = "Open",
        withdrawAfter = 30
    }):send()

    log.info("Smart notifications: " .. message:gsub("\n", " | "))
end

-- Main transcript processing function
-- openInObsidian: if true, opens the file in Obsidian after saving (only for final save)
function transcript.processTranscriptFile(sourcePath, meetingTitle, state, openInObsidian)
    if not sourcePath then
        log.warn("No source file to process")
        return false
    end

    -- Extract meeting title and timestamp from actual file path
    -- Path format: .../Zoom/2026-01-22 14.00.46 Meeting Name/meeting_saved_closed_caption.txt
    local folderName = sourcePath:match("/([^/]+)/[^/]+$")
    local meetingTimestamp = nil  -- Will hold "2026-01-22 1400" format

    if folderName then
        -- Extract date and time: "2026-01-22 14.00.46" -> "2026-01-22 1400"
        local dateStr, timeStr = folderName:match("^(%d%d%d%d%-%d%d%-%d%d) (%d%d)%.(%d%d)%.%d%d ")
        if dateStr and timeStr then
            local hour, min = folderName:match("^%d%d%d%d%-%d%d%-%d%d (%d%d)%.(%d%d)")
            meetingTimestamp = dateStr .. " " .. hour .. min
        end

        -- Extract title
        local extractedTitle = folderName:match("^%d%d%d%d%-%d%d%-%d%d %d%d%.%d%d%.%d%d (.+)$")
        if extractedTitle and #extractedTitle > 0 then
            if extractedTitle ~= meetingTitle then
                log.info("Using title from file path: " .. extractedTitle .. " (was: " .. (meetingTitle or "nil") .. ")")
                -- Update state so subsequent operations use the correct title
                state.currentMeetingTitle = extractedTitle
            end
            meetingTitle = extractedTitle
        end
    end

    -- Check if already processed
    if state.processedFiles[sourcePath] then
        log.info("File already processed, skipping: " .. sourcePath)
        return false
    end

    -- Ensure destination directory exists
    if not fs.ensureDirectoryExists(config.DESTINATION_FOLDER) then
        return false
    end

    -- Read source content
    local content = fs.readFile(sourcePath)
    if not content then
        log.error("Failed to read source file: " .. sourcePath)
        return false
    end

    -- Generate destination path using timestamp from Zoom folder
    local destPath = fs.generateDestinationPath(meetingTitle, meetingTimestamp)

    -- Check for duplicates - skip if content unchanged, update if changed
    if fs.fileExists(destPath) then
        local existingContent = fs.readFile(destPath)
        if existingContent then
            local existingBody = existingContent:match("%-%-%-.-%-%-%-(.*)") or existingContent
            if existingBody:gsub("%s+", "") == content:gsub("%s+", "") then
                log.info("Duplicate content detected, skipping")
                state.processedFiles[sourcePath] = true
                return false
            end
            -- Content changed (more transcript) - will overwrite with updated content
            log.info("Updating existing transcript with new content")
        end
    end

    -- Extract metadata from content
    local participants = transcript.extractParticipants(content)
    local tags = transcript.detectMeetingType(meetingTitle, content)
    local actionItems = transcript.extractActionItems(content)

    log.info("Detected " .. #participants .. " participants, " .. #tags .. " tags, " .. #actionItems .. " action items")

    -- Generate markdown with frontmatter
    local frontmatter = transcript.generateYAMLFrontmatter(meetingTitle, participants, tags)
    local markdownContent = frontmatter .. content

    -- Write to destination
    if fs.writeFile(destPath, markdownContent) then
        log.info("Transcript saved to: " .. destPath)
        state.processedFiles[sourcePath] = true

        -- Append action items if found
        if #actionItems > 0 then
            transcript.appendActionItemsToNote(destPath, actionItems)
        end

        -- Link to daily note
        local fileName = destPath:match("([^/]+)$")
        fs.linkToDailyNote(fileName, meetingTitle)

        -- Smart notifications (only on final save to avoid spam)
        if openInObsidian then
            transcript.showSmartNotifications(content, actionItems, participants, meetingTitle)
        end

        -- Open in Obsidian (only on final save, not during periodic saves)
        if openInObsidian then
            hs.timer.doAfter(1, function()
                fs.openInObsidian(destPath)
            end)
        end
        return true
    else
        log.error("Failed to write destination file: " .. destPath)
        return false
    end
end

-- Move all transcripts to Obsidian (batch operation)
function transcript.moveAllTranscriptsToObsidian()
    log.info("Scanning Zoom folder for transcripts to move...")
    local movedCount = 0
    local skippedCount = 0
    local dailyPath = config.DAILY_NOTES_SUBFOLDER:gsub("/$", "")

    local zoomDir = config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER
    for folder in hs.fs.dir(zoomDir) do
        if folder ~= "." and folder ~= ".." then
            local folderPath = zoomDir .. folder
            local attr = hs.fs.attributes(folderPath)

            if attr and attr.mode == "directory" then
                local txtFile = folderPath .. "/meeting_saved_closed_caption.txt"
                local txtAttr = hs.fs.attributes(txtFile)

                if txtAttr then
                    -- Parse folder name using helper
                    local parsed = fs.parseZoomFolderName(folder)

                    if not parsed then
                        skippedCount = skippedCount + 1
                    elseif fs.shouldSkipMeeting(folder) then
                        skippedCount = skippedCount + 1
                    else
                        local destFile = config.DESTINATION_FOLDER .. parsed.date .. " " .. parsed.time .. " - Zoom - " .. parsed.meetingName .. ".md"

                        if not hs.fs.attributes(destFile) then
                            local content = fs.readFile(txtFile)
                            if content then
                                -- Extract metadata from content
                                local participants = transcript.extractParticipants(content)
                                local tags = transcript.detectMeetingType(parsed.meetingName, content)

                                local mdContent = string.format([=[---
date: %s
source: zoom
type: transcript
status: raw
meeting_title: "%s"
%s%sdaily_note: "[[%s/%s]]"
---

> [!info] Raw Transcript
> Use **The_Summarizer** to generate structured summary, then **The_Gardener** to organize.

%s]=], parsed.isoDate, parsed.meetingName, fs.buildParticipantsYAML(participants), fs.buildTagsYAML(tags), dailyPath, parsed.date, content)

                                if fs.writeFile(destFile, mdContent) then
                                    log.info("Moved: " .. parsed.meetingName)
                                    movedCount = movedCount + 1
                                end
                            end
                        else
                            skippedCount = skippedCount + 1
                        end
                    end
                end
            end
        end
    end

    local msg = string.format("Moved %d transcripts, skipped %d", movedCount, skippedCount)
    log.info(msg)
    hs.alert.show(msg)
    return movedCount
end

-- Repair transcripts missing participants (one-time fix)
function transcript.repairMissingParticipants()
    log.info("Repairing transcripts missing participants...")
    local repairedCount = 0

    fs.scanMarkdownFiles(config.DESTINATION_FOLDER, function(file, fullPath, content)
        if content and not content:match("participants:") then
            -- Extract participants from transcript body
            local body = content:match("%-%-%-.-%-%-%-(.*)") or ""
            local participants = transcript.extractParticipants(body)

            if #participants > 0 then
                -- Insert after meeting_title line
                local updatedContent = content:gsub(
                    '(meeting_title: "[^"]*"\n)',
                    "%1" .. fs.buildParticipantsYAML(participants)
                )

                if updatedContent ~= content then
                    fs.writeFile(fullPath, updatedContent)
                    log.info("Repaired: " .. file .. " (" .. #participants .. " participants)")
                    repairedCount = repairedCount + 1
                end
            end
        end
    end, true)

    local msg = string.format("Repaired %d transcripts", repairedCount)
    log.info(msg)
    hs.alert.show(msg)
    return repairedCount
end

return transcript
