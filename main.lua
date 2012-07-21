-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)
system.activate("multitouch")

-- include the Corona "storyboard" module
local storyboard = require("storyboard")
local GameScene = require("GameScene")

-- Jump 30 lines in the debug console
for i = 1, 30 do
	print("")
end

-- Exit application
local exit = function()
	-- os.exit();
end

-- System event listener
local systemEventListener = function(event)
	print("System event: "..event.type)
	if event.type == "applicationExit" then
		exit()
		return true
	elseif event.type == "applicationSuspend" then
		GameScene.pause{
			system = true
		}
		return true
	elseif event.type == "applicationResume" then
		GameScene.resume{
			system = true
		}
		return true
	end

	return false
end

-- Key listener
local keyListener = function(event)
	print("Key event: "..event.keyName.." ("..event.phase..")")
	if event.keyName == "back" and event.phase == "up" then
		GameScene.pause{
			system = true
		}

		-- We caught the event so we return true
		return true
	end

	return false
end
 
-- Add the key callback
Runtime:addEventListener("key", keyListener);
 
-- Setup a system event listener
Runtime:addEventListener("system", systemEventListener)

-- Start the multiplayer game
storyboard.gotoScene("multiplayer")
