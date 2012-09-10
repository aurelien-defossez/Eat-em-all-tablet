-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

-- include the Corona "storyboard" module
local storyboard = require("storyboard")
local GameScene = require("src.game.GameScene")
local WindowManager = require("src.utils.WindowManager")

-- Jump 30 lines in the debug console
for i = 1, 30 do
	print("")
end

-- Pauses the game
--
-- Parameters:
--  pauseStatus: True if the game has to be paused, false to resume
local pause = function(pauseStatus)
	Runtime:dispatchEvent{
		name = "pause",
		system = true,
		switch = false,
		status = pauseStatus
	}
end

local quit = function()
	Runtime:dispatchEvent{
		name = "gameQuit",
	}
end

-- System event listener
local systemEventListener = function(event)
	print("System event: "..event.type)
	if event.type == "applicationStart" then
		-- Seed randomizer
		math.randomseed(os.time())

		-- Start the multiplayer game
		storyboard.gotoScene("src.hud.Welcome")
	elseif event.type == "applicationExit" then
		-- quit()
		return true
	elseif event.type == "applicationSuspend" then
		pause(true)
		return true
	elseif event.type == "applicationResume" then
		pause(false)
		return true
	end

	return false
end

-- Key listener
local keyListener = function(event)
	if event.keyName == "back" and event.phase == "up" then
		if WindowManager.getTopWindow() then
			WindowManager.removeTopWindow()
		else
			quit()
		end

		-- We caught the event so we return true
		return true
	end

	return false
end

-- Add the key callback
Runtime:addEventListener("key", keyListener)
 
-- Setup a system event listener
Runtime:addEventListener("system", systemEventListener)
