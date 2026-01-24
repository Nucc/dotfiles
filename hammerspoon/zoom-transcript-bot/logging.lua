--[[
================================================================================
Zoom Transcript Bot - Logging
================================================================================
Timestamped logging to console and file.
================================================================================
--]]

local config = require("zoom-transcript-bot.config")

local logging = {}

local function getTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function log(level, message)
    local timestamp = getTimestamp()
    local logLine = string.format("[%s] [%s] %s\n", timestamp, level, message)

    -- Print to Hammerspoon console
    print(logLine)

    -- Write to log file
    local file = io.open(config.LOG_FILE, "a")
    if file then
        file:write(logLine)
        file:close()
    end
end

function logging.info(message)
    log("INFO", message)
end

function logging.warn(message)
    log("WARN", message)
end

function logging.error(message)
    log("ERROR", message)
end

function logging.debug(message)
    log("DEBUG", message)
end

return logging
