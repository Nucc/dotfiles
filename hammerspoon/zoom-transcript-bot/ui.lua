--[[
================================================================================
Zoom Transcript Bot - UI Automation
================================================================================
Accessibility API utilities for Zoom window manipulation.
================================================================================
--]]

local config = require("zoom-transcript-bot.config")
local log = require("zoom-transcript-bot.logging")
local fs = require("zoom-transcript-bot.filesystem")

local ui = {}

-- Find running Zoom application
function ui.findZoomApp()
    local app = hs.application.get(config.ZOOM_BUNDLE_ID)
    if not app then
        app = hs.application.get("zoom.us")
    end
    return app
end

-- Find active Zoom Meeting window
function ui.findZoomMeetingWindow()
    local app = ui.findZoomApp()
    if not app then
        return nil
    end

    -- Check all windows including minimized
    local windows = app:allWindows()
    for _, win in ipairs(windows) do
        local title = win:title() or ""
        -- Only match windows with "Zoom Meeting" in the title
        if title:match("Zoom Meeting") then
            return win
        end
    end

    -- Fallback: use osascript to check window names (more reliable for minimized)
    local output, status = hs.execute([[osascript -e 'tell application "System Events" to get name of every window of (processes whose name contains "zoom")' 2>/dev/null]])
    if status and output and output:match("Zoom Meeting") then
        -- Try to extract actual meeting title from osascript output
        local meetingTitle = output:match("Zoom Meeting %- ([^,]+)") or output:match("Zoom Meeting")
        return {
            title = function() return meetingTitle or "Zoom Meeting" end,
            id = function() return -1 end,
            isMinimized = true
        }
    end

    return nil
end

-- Get meeting title from window
-- Note: At join time, Zoom folder doesn't exist yet so we only use window title
-- The correct title is extracted from the file path at save time
function ui.getMeetingTitleFromWindow(window)
    if not window then
        return nil
    end

    local title = window:title()
    if title then
        -- Clean up title - remove "Zoom Meeting" prefix if present
        title = title:gsub("^Zoom Meeting%s*[-–]?%s*", "")
        title = title:gsub("^Zoom%s*[-–]?%s*", "")
        if title == "" then
            title = nil
        end
    end

    return title
end

-- Deep search for UI element by various attributes
function ui.findUIElement(rootElement, searchCriteria, maxDepth)
    maxDepth = maxDepth or 10

    local function search(element, depth)
        if depth > maxDepth then
            return nil
        end

        if not element then
            return nil
        end

        -- Check current element
        local role = element:attributeValue("AXRole")
        local title = element:attributeValue("AXTitle")
        local description = element:attributeValue("AXDescription")
        local identifier = element:attributeValue("AXIdentifier")
        local label = element:attributeValue("AXLabel")

        local matches = false

        if searchCriteria.role and role == searchCriteria.role then
            matches = true
        end

        if searchCriteria.titles then
            for _, searchTitle in ipairs(searchCriteria.titles) do
                local searchLower = searchTitle:lower()
                if (title and title:lower():find(searchLower, 1, true)) or
                   (description and description:lower():find(searchLower, 1, true)) or
                   (identifier and identifier:lower():find(searchLower, 1, true)) or
                   (label and label:lower():find(searchLower, 1, true)) then
                    matches = true
                    break
                end
            end
        end

        if searchCriteria.exactTitle then
            if title == searchCriteria.exactTitle then
                matches = true
            end
        end

        if matches then
            if searchCriteria.requireRole then
                if role == searchCriteria.requireRole then
                    return element
                end
            else
                return element
            end
        end

        -- Search children
        local children = element:attributeValue("AXChildren")
        if children then
            for _, child in ipairs(children) do
                local result = search(child, depth + 1)
                if result then
                    return result
                end
            end
        end

        return nil
    end

    return search(rootElement, 0)
end

-- Find UI element with retry and backoff
function ui.findUIElementWithRetry(rootElement, searchCriteria, description)
    local attempts = config.UI_RETRY_ATTEMPTS
    local delay = config.UI_RETRY_DELAY_SECONDS

    for attempt = 1, attempts do
        local element = ui.findUIElement(rootElement, searchCriteria)
        if element then
            log.debug("Found " .. description .. " on attempt " .. attempt)
            return element
        end

        if attempt < attempts then
            log.debug("Retry " .. attempt .. "/" .. attempts .. " for " .. description)
            hs.timer.usleep(delay * 1000000)
            delay = delay * config.UI_RETRY_BACKOFF_MULTIPLIER
        end
    end

    log.warn("Failed to find " .. description .. " after " .. attempts .. " attempts")
    return nil
end

-- Click a UI element
function ui.clickElement(element)
    if not element then
        return false
    end

    -- Try AXPress action first
    local actions = element:attributeValue("AXActions") or {}
    for _, action in ipairs(actions) do
        if action == "AXPress" then
            element:performAction("AXPress")
            log.debug("Clicked element via AXPress")
            return true
        end
    end

    -- Fallback to position-based click
    local position = element:attributeValue("AXPosition")
    local size = element:attributeValue("AXSize")
    if position and size then
        local x = position.x + size.w / 2
        local y = position.y + size.h / 2
        hs.eventtap.leftClick({x = x, y = y})
        log.debug("Clicked element at position: " .. x .. ", " .. y)
        return true
    end

    log.warn("Failed to click element")
    return false
end

-- Get accessibility element for window
function ui.getWindowAXUIElement(window)
    if not window then
        return nil
    end
    local app = window:application()
    if not app then
        return nil
    end
    local appElement = hs.axuielement.applicationElement(app)
    if not appElement then
        return nil
    end

    -- Find the specific window element
    local windows = appElement:attributeValue("AXWindows")
    if windows then
        for _, winElement in ipairs(windows) do
            local title = winElement:attributeValue("AXTitle")
            if title == window:title() then
                return winElement
            end
        end
        -- Return first window if no match
        if #windows > 0 then
            return windows[1]
        end
    end

    return appElement
end

-- Check if transcript sidebar is open
function ui.isTranscriptSidebarOpen(windowElement)
    local transcriptPanel = ui.findUIElement(windowElement, {
        titles = {"Transcript", "transcript"},
        requireRole = "AXGroup"
    }, 8)

    if transcriptPanel then
        local saveButton = ui.findUIElement(transcriptPanel, {
            titles = config.SAVE_TRANSCRIPT_TITLES
        }, 5)
        if saveButton then
            return true
        end
    end

    return false
end

-- Open transcript sidebar
function ui.openTranscriptSidebar(state)
    log.info("Attempting to open Transcript sidebar")

    local window = ui.findZoomMeetingWindow()
    if not window then
        log.error("No Zoom meeting window found")
        return false
    end

    local windowElement = ui.getWindowAXUIElement(window)
    if not windowElement then
        log.error("Failed to get window AX element")
        return false
    end

    -- Check if already open
    if ui.isTranscriptSidebarOpen(windowElement) then
        log.info("Transcript sidebar already open")
        state.transcriptSidebarOpen = true
        return true
    end

    -- Try to find pinned Transcript button first
    log.debug("Looking for pinned Transcript button")
    local transcriptButton = ui.findUIElementWithRetry(windowElement, {
        titles = config.TRANSCRIPT_BUTTON_TITLES,
        requireRole = "AXButton"
    }, "Transcript button")

    if transcriptButton then
        if ui.clickElement(transcriptButton) then
            hs.timer.usleep(500000)
            state.transcriptSidebarOpen = true
            log.info("Opened Transcript via pinned button")
            return true
        end
    end

    -- Try via More menu
    log.debug("Transcript button not found, trying More menu")
    local moreButton = ui.findUIElementWithRetry(windowElement, {
        titles = config.MORE_BUTTON_TITLES,
        requireRole = "AXButton"
    }, "More button")

    if moreButton then
        if ui.clickElement(moreButton) then
            hs.timer.usleep(300000)

            local app = ui.findZoomApp()
            if app then
                local appElement = hs.axuielement.applicationElement(app)
                local transcriptMenuItem = ui.findUIElementWithRetry(appElement, {
                    titles = config.TRANSCRIPT_BUTTON_TITLES
                }, "Transcript menu item")

                if transcriptMenuItem then
                    if ui.clickElement(transcriptMenuItem) then
                        hs.timer.usleep(500000)
                        state.transcriptSidebarOpen = true
                        log.info("Opened Transcript via More menu")
                        return true
                    end
                end
            end
        end
    end

    log.warn("Failed to open Transcript sidebar - may not be available for this meeting")
    return false
end

-- Click save transcript button
function ui.clickSaveTranscript(state)
    log.info("Attempting to save transcript")

    local window = ui.findZoomMeetingWindow()
    if not window then
        log.error("No Zoom meeting window found for save")
        return false
    end

    local windowElement = ui.getWindowAXUIElement(window)
    if not windowElement then
        log.error("Failed to get window AX element for save")
        return false
    end

    -- Quick check for Save button (1 attempt only)
    local saveButton = ui.findUIElement(windowElement, {
        titles = config.SAVE_TRANSCRIPT_TITLES,
        requireRole = "AXButton"
    })

    -- If not found, try to open transcript sidebar first
    if not saveButton then
        log.debug("Save button not visible, opening transcript sidebar")
        state.transcriptSidebarOpen = false  -- Reset state
        if not ui.openTranscriptSidebar(state) then
            return false
        end
        hs.timer.usleep(500000)  -- Wait for UI to update

        -- Now try again with retry
        saveButton = ui.findUIElementWithRetry(windowElement, {
            titles = config.SAVE_TRANSCRIPT_TITLES,
            requireRole = "AXButton"
        }, "Save transcript button")
    end

    if not saveButton then
        local app = ui.findZoomApp()
        if app then
            local appElement = hs.axuielement.applicationElement(app)
            saveButton = ui.findUIElementWithRetry(appElement, {
                titles = config.SAVE_TRANSCRIPT_TITLES,
                requireRole = "AXButton"
            }, "Save transcript button (app-wide)")
        end
    end

    if saveButton then
        if ui.clickElement(saveButton) then
            log.info("Clicked Save transcript button")
            state.lastSaveTime = os.time()
            state.saveCount = state.saveCount + 1
            return true
        end
    end

    log.warn("Save transcript button not found")
    return false
end

-- Debug: dump accessibility tree
function ui.dumpAccessibilityTree(element, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 5

    if depth > maxDepth then return end

    local indent = string.rep("  ", depth)
    local role = element:attributeValue("AXRole") or "?"
    local title = element:attributeValue("AXTitle") or ""
    local description = element:attributeValue("AXDescription") or ""
    local identifier = element:attributeValue("AXIdentifier") or ""

    print(string.format("%s[%s] title='%s' desc='%s' id='%s'",
        indent, role, title, description, identifier))

    local children = element:attributeValue("AXChildren")
    if children then
        for _, child in ipairs(children) do
            ui.dumpAccessibilityTree(child, depth + 1, maxDepth)
        end
    end
end

-- Debug: inspect Zoom UI
function ui.inspectZoomUI()
    local window = ui.findZoomMeetingWindow()
    if not window then
        print("No Zoom meeting window found")
        return
    end

    print("Meeting window: " .. (window:title() or "untitled"))

    local windowElement = ui.getWindowAXUIElement(window)
    if windowElement then
        print("\nAccessibility tree:")
        ui.dumpAccessibilityTree(windowElement, 0, 6)
    end
end

return ui
