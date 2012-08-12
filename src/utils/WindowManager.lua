-----------------------------------------------------------------------------------------
--
-- WindowManager.lua
--
-----------------------------------------------------------------------------------------

module("WindowManager", package.seeall)

WindowManager.__index = WindowManager

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

windows = nil

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Initializes the window manager
function initialize()
	windows = {}
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add a window to the window stack
--
-- Parameters:
--  window: the window to add
function addWindow(window)
	local lastWindow = getTopWindow()

	if lastWindow then
		lastWindow:hide()
	end

	table.insert(windows, window)
end

function removeTopWindow()
	if table.getn(windows) > 0 then
		local window = table.remove(windows)
		window:destroy()

		local lastWindow = getTopWindow()
		if lastWindow then
			lastWindow:show()
		end
	end
end

function removeAllWindows()
	while getTopWindow() do
		removeTopWindow()
	end
end

function getTopWindow()
	local windowsCount = table.getn(windows)
	
	if windowsCount > 0 then
		return windows[windowsCount]
	else
		return nil
	end
end

-----------------------------------------------------------------------------------------

return WindowManager
