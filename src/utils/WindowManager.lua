-----------------------------------------------------------------------------------------
--
-- WindowManager.lua
-- 
-- A window manager to manage the different menu windows on the screen.
-- Windows can stack, and the manager make sure only one is displayed at a time.
-- Windows can be pushed and poped from this stack.
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

-- Remove the top window (equivalent to a pop of the windows stack)
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

-- Remove all windows from the stack
function removeAllWindows()
	while getTopWindow() do
		removeTopWindow()
	end
end

-- Return the top window currently displayed
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
