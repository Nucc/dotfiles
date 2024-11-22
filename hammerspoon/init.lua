-- hs.loadSpoon("SpoonInstall")

require("auto-reload")

-- Finally, show a notification that we finished loading the config
hs.notify.new({ title = "Hammerspoon", subTitle = "Configuration loaded" }):send()

local wm = require("window-management")
-- Window Management
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "return", function()
	wm.windowMaximize(20)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "l", function()
	wm.moveWindowToPosition(wm.screenPositions.right)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "h", function()
	wm.moveWindowToPosition(wm.screenPositions.left)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "k", function()
	wm.moveWindowToPosition(wm.screenPositions.top)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "j", function()
	wm.moveWindowToPosition(wm.screenPositions.bottom)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "-", function()
	wm.moveWindowToPosition(wm.screenPositions.topLeft)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "=", function()
	wm.moveWindowToPosition(wm.screenPositions.topRight)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "[", function()
	wm.moveWindowToPosition(wm.screenPositions.bottomLeft)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "]", function()
	wm.moveWindowToPosition(wm.screenPositions.bottomRight)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "\\", function()
	wm.moveWindowToPosition(wm.screenPositions.middle)
end)

hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "1", function()
	hs.spaces.gotoSpace(1)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "2", function()
	hs.spaces.gotoSpace(2)
end)

hs.hotkey.bind({ "cmd", "shift", "ctrl" }, "c", function()
	hs.eventtap.keyStroke({ "cmd" }, "c")
	copy = hs.pasteboard.getContents()
	for index = 8, 0, -1 do
		paste = hs.pasteboard.readAllData(tostring(index))
		if paste["public.utf8-plain-text"] == nil then
			hs.pasteboard.writeObjects("", tostring(index + 1))
		else
			hs.pasteboard.writeObjects(paste["public.utf8-plain-text"], tostring(index + 1))
		end
	end
	hs.pasteboard.writeObjects(copy, "0")
	hs.pasteboard.setContents(copy)
end)

local choices = {}

local function focusLastFocused()
	local wf = hs.window.filter
	local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
	if #lastFocused > 0 then
		lastFocused[1]:focus()
	end
end

local chooser = hs.chooser.new(function(choice)
	if not choice then
		focusLastFocused()
		return
	end
	hs.pasteboard.setContents(choice["text"])
	focusLastFocused()
	hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
function get_content(index)
	paste = hs.pasteboard.readAllData(tostring(index))
	return paste["public.utf8-plain-text"]
end
function update_choices()
	choices = {}
	for i = 1, 9, 1 do
		table.insert(choices, { ["text"] = get_content(i) })
	end
	chooser:choices(choices)
end

hs.hotkey.bind({ "cmd", "shift" }, "v", function()
	update_choices()
	chooser:show()
end)

-- Move windows to the middle by default
windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowCreated, function(win)
	local windowTitle = win:title()
	if windowTitle:match("Menu window") then
		return
	end
	wm.moveWindowToPosition(wm.screenPositions.middle, win)
end)

function startVPN()
	hs.alert.show("VPN connecting!")
	hs.execute("/opt/homebrew/bin/zetup vpn connect", true)
	hs.alert.show("VPN connected!")
end
hs.hotkey.bind({ "ctrl", "cmd", "shift" }, "v", startVPN)

hs.hotkey.bind({ "ctrl", "cmd", "shift" }, "S", function()
	local app = hs.application.find("Slack")
	if app then
		app:activate()
	else
		hs.alert.show("Slack is not running!")
	end
end)

-- Define a hotkey to focus on the default browser
hs.hotkey.bind({ "ctrl", "cmd", "shift" }, "D", function()
	local browserAppName = "Arc"
	local app = hs.application.find(browserAppName)
	if app then
		app:activate()
	else
		hs.alert.show(browserAppName .. " is not running!")
	end
end)

-- Define a hotkey to focus on the default browser
hs.hotkey.bind({ "ctrl", "cmd", "shift" }, "A", function()
	local app = hs.application.find("Alacritty")
	if app then
		app:activate()
	else
		hs.alert.show("Alacritty is not running!")
	end
end)
