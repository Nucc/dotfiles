--[[
================================================================================
Zoom Transcript Bot - Filesystem Utilities
================================================================================
File operations, path handling, and directory management.
================================================================================
--]]

local config = require("zoom-transcript-bot.config")
local log = require("zoom-transcript-bot.logging")

local fs = {}

-- Ensure directory exists, create if needed
function fs.ensureDirectoryExists(path)
    local success, err = hs.fs.mkdir(path)
    if not success and not string.match(tostring(err), "File exists") then
        local attr = hs.fs.attributes(path)
        if not attr or attr.mode ~= "directory" then
            log.error("Failed to create directory: " .. path .. " - " .. tostring(err))
            return false
        end
    end
    return true
end

-- Check if file exists
function fs.fileExists(path)
    local attr = hs.fs.attributes(path)
    return attr ~= nil
end

-- Read entire file contents
function fs.readFile(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Write content to file
function fs.writeFile(path, content)
    local file = io.open(path, "w")
    if not file then
        return false
    end
    file:write(content)
    file:close()
    return true
end

-- Get file modification time
function fs.getFileModificationTime(path)
    local attr = hs.fs.attributes(path)
    if attr then
        return attr.modification
    end
    return nil
end

-- Find newest .txt/.vtt file in directory (recursive)
function fs.findNewestFile(directory, maxAgeSeconds)
    local now = os.time()
    local newestFile = nil
    local newestTime = 0

    local function searchDir(dir)
        for file in hs.fs.dir(dir) do
            if file ~= "." and file ~= ".." then
                local fullPath = dir .. "/" .. file
                local attr = hs.fs.attributes(fullPath)
                if attr then
                    if attr.mode == "directory" then
                        searchDir(fullPath)
                    elseif attr.mode == "file" then
                        local ext = file:match("%.([^%.]+)$")
                        if ext and (ext:lower() == "txt" or ext:lower() == "vtt") then
                            if attr.modification > newestTime then
                                local age = now - attr.modification
                                if age <= maxAgeSeconds then
                                    newestTime = attr.modification
                                    newestFile = fullPath
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if hs.fs.attributes(directory) then
        searchDir(directory)
    end

    return newestFile, newestTime
end

-- Generate destination path for transcript
-- meetingTimestamp: optional, format "2026-01-22 1400" - uses current time if not provided
function fs.generateDestinationPath(meetingTitle, meetingTimestamp)
    -- Use provided timestamp (from Zoom folder) or fall back to current time
    local timestamp = meetingTimestamp or os.date("%Y-%m-%d %H%M")
    local sanitizedTitle = meetingTitle or "Untitled"
    -- Sanitize title for filename
    sanitizedTitle = sanitizedTitle:gsub("[/\\:*?\"<>|]", "-")
    sanitizedTitle = sanitizedTitle:gsub("%s+", " ")
    sanitizedTitle = sanitizedTitle:sub(1, 100)  -- Limit length

    local filename = string.format("%s - Zoom - %s.md", timestamp, sanitizedTitle)
    return config.DESTINATION_FOLDER .. filename
end

-- URL encode a string for obsidian:// URLs
local function urlEncode(str)
    return str:gsub("([^%w%-_%.~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

-- Open file in Obsidian
function fs.openInObsidian(filePath)
    if not config.AUTO_OPEN_IN_OBSIDIAN then
        return
    end
    local fileName = filePath:match("([^/]+)$")
    local vaultName = config.OBSIDIAN_VAULT_NAME
    -- Use configured subfolder path (remove trailing slash, encode path separators)
    local subfolderPath = config.TRANSCRIPTS_SUBFOLDER:gsub("/$", "")
    local encodedPath = urlEncode(subfolderPath .. "/" .. fileName)
    local obsidianURL = string.format("obsidian://open?vault=%s&file=%s", vaultName, encodedPath)
    hs.urlevent.openURL(obsidianURL)
    log.info("Opened in Obsidian: " .. fileName)
end

-- Open summary note in Obsidian
function fs.openSummaryInObsidian(filename)
    -- Use configured subfolder path (remove trailing slash, encode path separators)
    local subfolderPath = config.SUMMARY_NOTES_SUBFOLDER:gsub("/$", "")
    local encodedPath = urlEncode(subfolderPath .. "/" .. filename)
    local obsidianURL = string.format("obsidian://open?vault=%s&file=%s",
        config.OBSIDIAN_VAULT_NAME, encodedPath)
    hs.urlevent.openURL(obsidianURL)
end

-- Create daily note with basic template
function fs.createDailyNote(date)
    local dailyNotePath = config.DAILY_NOTES_FOLDER .. date .. ".md"

    local content = string.format([=[---
date: %s
type: daily
tags:
  - daily
---

# %s

## Meetings

]=], date, date)

    local file = io.open(dailyNotePath, "w")
    if file then
        file:write(content)
        file:close()
        log.info("Created daily note: " .. date)
        return true
    end
    return false
end

-- Link transcript to daily note (creates daily note if needed)
function fs.linkToDailyNote(transcriptFileName, meetingTitle, dateOverride)
    local date = dateOverride or os.date("%Y-%m-%d")
    local dailyNotePath = config.DAILY_NOTES_FOLDER .. date .. ".md"

    -- Create daily note if it doesn't exist
    local attr = hs.fs.attributes(dailyNotePath)
    if not attr then
        log.info("Daily note doesn't exist, creating: " .. dailyNotePath)
        fs.createDailyNote(date)
    end

    -- Check if link already exists (avoid duplicates)
    local existingContent = fs.readFile(dailyNotePath) or ""
    local linkName = transcriptFileName:gsub("%.md$", "")
    if existingContent:find(linkName, 1, true) then
        log.debug("Link already exists in daily note, skipping")
        return
    end

    -- Append meeting link
    local file = io.open(dailyNotePath, "a")
    if file then
        -- Extract time from filename: "2026-01-14 1100 - Zoom - ..."
        local time = transcriptFileName:match("%d%d%d%d%-%d%d%-%d%d (%d%d%d%d)") or "0000"
        local formattedTime = time:sub(1,2) .. ":" .. time:sub(3,4)
        local transcriptsPath = config.TRANSCRIPTS_SUBFOLDER:gsub("/$", "")
        file:write(string.format("- %s [[%s/%s|%s]]\n",
            formattedTime, transcriptsPath, linkName, meetingTitle or "Meeting"))
        file:close()
        log.info("Linked transcript to daily note: " .. date)
    end
end

-- Retroactively link all transcripts to their daily notes
function fs.linkAllTranscriptsToDailyNotes()
    log.info("Scanning transcripts to link to daily notes...")
    local linkedCount = 0
    local createdCount = 0

    fs.scanMarkdownFiles(config.DESTINATION_FOLDER, function(file)
        -- Parse date from filename: "2026-01-13 1031 - Zoom - Meeting.md"
        local date = file:match("^(%d%d%d%d%-%d%d%-%d%d)")
        local title = file:match("Zoom %- (.+)%.md$")

        if date and title then
            local dailyNotePath = config.DAILY_NOTES_FOLDER .. date .. ".md"
            local attr = hs.fs.attributes(dailyNotePath)

            -- Create daily note if missing
            if not attr then
                fs.createDailyNote(date)
                createdCount = createdCount + 1
            end

            -- Link transcript
            local existingContent = fs.readFile(dailyNotePath) or ""
            local linkName = file:gsub("%.md$", "")
            if not existingContent:find(linkName, 1, true) then
                fs.linkToDailyNote(file, title, date)
                linkedCount = linkedCount + 1
            end
        end
    end, false)

    local msg = string.format("Created %d daily notes, linked %d transcripts", createdCount, linkedCount)
    log.info(msg)
    hs.alert.show(msg)
    return linkedCount, createdCount
end

-- Get meeting title from most recent Zoom transcript folder
function fs.getMeetingTitleFromZoomFolder()
    local zoomDir = config.ZOOM_TRANSCRIPT_DEFAULT_FOLDER
    local newestFolder = nil
    local newestTime = 0

    for folder in hs.fs.dir(zoomDir) do
        if folder ~= "." and folder ~= ".." then
            local folderPath = zoomDir .. folder
            local attr = hs.fs.attributes(folderPath)
            if attr and attr.mode == "directory" then
                if attr.modification > newestTime then
                    newestTime = attr.modification
                    newestFolder = folder
                end
            end
        end
    end

    if newestFolder then
        -- Parse folder name: "2026-01-14 11.00.57 Pine O11y sync"
        local meetingName = newestFolder:match("^%d%d%d%d%-%d%d%-%d%d %d%d%.%d%d%.%d%d (.+)$")
        if meetingName and #meetingName > 0 then
            log.debug("Got meeting title from Zoom folder: " .. meetingName)
            return meetingName
        end
    end

    return nil
end

-- Check if file is a transcript source file
function fs.isTranscriptFile(filename)
    local ext = filename:match("%.([^%.]+)$")
    if not ext then return false end
    ext = ext:lower()
    for _, validExt in ipairs(config.TRANSCRIPT_EXTENSIONS) do
        if ext == validExt then return true end
    end
    return false
end

-- Check if meeting should be skipped
function fs.shouldSkipMeeting(meetingName)
    for _, pattern in ipairs(config.SKIP_MEETING_PATTERNS) do
        if meetingName:match(pattern) then
            return true
        end
    end
    return false
end

-- Parse Zoom folder name into components
-- Format: "2026-01-14 11.00.57 Meeting Name"
function fs.parseZoomFolderName(folderName)
    local datePart = folderName:match("^(%d%d%d%d%-%d%d%-%d%d)")
    local timeRaw = folderName:match("^%d%d%d%d%-%d%d%-%d%d (%d%d%.%d%d%.%d%d)")
    local meetingName = folderName:match("^%d%d%d%d%-%d%d%-%d%d %d%d%.%d%d%.%d%d (.+)$")

    if not datePart or not timeRaw or not meetingName then
        return nil
    end

    local timeFmt = timeRaw:sub(1,2) .. timeRaw:sub(4,5)  -- "1100" format
    local timeISO = timeRaw:gsub("%.", ":")               -- "11:00:57" format

    return {
        date = datePart,
        time = timeFmt,
        timeISO = timeISO,
        meetingName = meetingName:gsub("^%s+", ""):gsub("/", "-"),
        isoDate = datePart .. "T" .. timeISO
    }
end

-- Iterate over markdown files in directory, calling callback for each
-- callback(filename, fullPath, content) - content only loaded if requested
function fs.scanMarkdownFiles(directory, callback, loadContent)
    for file in hs.fs.dir(directory) do
        if file:match("%.md$") and not file:match("^%.") then
            local fullPath = directory .. file
            local content = nil
            if loadContent then
                content = fs.readFile(fullPath)
            end
            local shouldContinue = callback(file, fullPath, content)
            if shouldContinue == false then
                break
            end
        end
    end
end

-- Build participants YAML block
function fs.buildParticipantsYAML(participants)
    if not participants or #participants == 0 then
        return ""
    end
    local yaml = "participants:\n"
    for _, p in ipairs(participants) do
        yaml = yaml .. string.format("  - \"%s\"\n", p)
    end
    return yaml
end

-- Build tags YAML block
function fs.buildTagsYAML(tags)
    tags = tags or {"meeting", "transcript"}
    local yaml = "tags:\n"
    for _, t in ipairs(tags) do
        yaml = yaml .. string.format("  - %s\n", t)
    end
    return yaml
end

return fs
