local This = {}
-- To easily layout windows on the screen, we use hs.grid to create
-- a 4x4 grid. If you want to use a more detailed grid, simply
-- change its dimension here
local GRID_SIZE = 4
local HALF_GRID_SIZE = GRID_SIZE / 2
local THIRD_GRID_SIZE = GRID_SIZE / 3
-- Set the grid size and add a few pixels of margin
-- Also, don't animate window changes... That's too slow
hs.grid.setGrid(GRID_SIZE .. "x" .. GRID_SIZE)
hs.grid.setMargins({ 15, 15 })
hs.window.animationDuration = 0

local screenPositions = {}
screenPositions.left = {
	x = 0,
	y = 0,
	w = HALF_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.right = {
	x = HALF_GRID_SIZE,
	y = 0,
	w = HALF_GRID_SIZE,
	h = GRID_SIZE,
}
screenPositions.top = {
	x = 0,
	y = 0,
	w = GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.bottom = {
	x = 0,
	y = HALF_GRID_SIZE,
	w = GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.topLeft = {
	x = 0,
	y = 0,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.topRight = {
	x = HALF_GRID_SIZE,
	y = 0,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.bottomLeft = {
	x = 0,
	y = HALF_GRID_SIZE,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}
screenPositions.bottomRight = {
	x = HALF_GRID_SIZE,
	y = HALF_GRID_SIZE,
	w = HALF_GRID_SIZE,
	h = HALF_GRID_SIZE,
}

screenPositions.middle = {
	x = HALF_GRID_SIZE / 3,
	y = GRID_SIZE / 10,
	w = HALF_GRID_SIZE * 1.33,
	h = HALF_GRID_SIZE * 1.6,
}

This.screenPositions = screenPositions

-- This function will move either the specified or the focuesd
-- window to the requested screen position
function This.moveWindowToPosition(cell, window)
	if window == nil then
		window = hs.window.focusedWindow()
	end
	if window then
		local screen = window:screen()
		hs.grid.set(window, cell, screen)
	end
end
-- This function will move either the specified or the focused
-- window to the center of the sreen and let it fill up the
-- entire screen.
function This.windowMaximize(factor, window)
	if window == nil then
		window = hs.window.focusedWindow()
	end
	if window then
		-- window:maximize()
		local screen = window:screen()
		local maxFrame = screen:frame()
		local margin = 15

		maxFrame.x = maxFrame.x + margin
		maxFrame.y = maxFrame.y + margin
		maxFrame.w = maxFrame.w - (2 * margin)
		maxFrame.h = maxFrame.h - (2 * margin)

		window:setFrame(maxFrame)
		-- hs.window.animationDuration(0)
	end
end
return This
