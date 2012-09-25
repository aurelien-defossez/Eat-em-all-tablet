-----------------------------------------------------------------------------------------
--
-- Multiplayer.lua
--
-- This scene represents the multiplayer mode.
-- It listens to scene events, and also game events, such as the pause or the restart
-- event.
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local Multiplayer = storyboard.newScene()

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local Player = require("src.game.Player")
local GameScene = require("src.game.GameScene")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function Multiplayer:createScene(event)
	-- Do nothing
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function Multiplayer:destroyScene(event)
	-- Do nothing
end

-- Called immediately after scene has moved onscreen:
function Multiplayer:enterScene(event)
	-- Initialize attributes
	self.paused = {
		system = false,
		user = false
	}

	-- Enter frame time
	self.lastFrameTime = -1

	-- Create game scene
	self.gameScene = GameScene.create()

	-- Bind events
	Runtime:addEventListener("enterFrame", self)
	Runtime:addEventListener("tap", self)
	Runtime:addEventListener("gamePause", self)
	Runtime:addEventListener("gameRestart", self)
	Runtime:addEventListener("gameQuit", self)
end

-- Called when scene is about to move offscreen:
function Multiplayer:exitScene(event)
	-- Unbind events
	Runtime:removeEventListener("enterFrame", self)
	Runtime:removeEventListener("tap", self)
	Runtime:removeEventListener("gamePause", self)
	Runtime:removeEventListener("gameRestart", self)
	Runtime:removeEventListener("gameQuit", self)

	-- Destroy objects
	self.gameScene:destroy()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Pause handler
--
-- Parameters:
--  event: The event object, with these data:
--   status: Determines the pause status, default is false
--   system: Tells whether the event is a system event, default is false
function Multiplayer:gamePause(event)
	if event.system then
		self.paused.system = (event.status == true)
	else
		self.paused.user = (event.status == true)
	end
	local paused = self.paused.user or self.paused.system

	Runtime:dispatchEvent{
		name = "spritePause",
		status = self.paused.user or self.paused.system
	}
end

-- Restart handler
--
-- Parameters:
--  event: The event object, with these data
function Multiplayer:gameRestart(event)
	storyboard.reloadScene()
end

-- Quit handler
--
-- Parameters:
--  event: The event object
function Multiplayer:gameQuit(event)
	storyboard.removeScene("src.game.Multiplayer")

	os.exit()
end

-- Enter frame handler
--
-- Parameters:
--  event: The event object
function Multiplayer:enterFrame(event)
	if self.lastFrameTime == -1 then
		self.lastFrameTime = event.time
	else
		local timeDelta =  event.time - self.lastFrameTime
		self.lastFrameTime = event.time

		if not self.paused.user and not self.paused.system then
			if config.debug.superFastMode then
				timeDelta = timeDelta * config.debug.superFastModeRatio
			elseif config.debug.fastMode then
				timeDelta = timeDelta * config.debug.fastModeRatio
			end

			self.gameScene:enterFrame(timeDelta)
		end
	end
end

-- Tap handler
--
-- Parameters:
--  event: The event object
function Multiplayer:tap(event)
	if config.debug.frameByFrame then
		Runtime:dispatchEvent{
			name = "gamePause",
			status = false
		}
	end
	
	return true
end

-----------------------------------------------------------------------------------------
-- Binding
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
Multiplayer:addEventListener("createScene", Multiplayer)

-- "enterScene" event is dispatched whenever scene transition has finished
Multiplayer:addEventListener("enterScene", Multiplayer)

-- "exitScene" event is dispatched whenever before next scene's transition begins
Multiplayer:addEventListener("exitScene", Multiplayer)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
Multiplayer:addEventListener("destroyScene", Multiplayer)

-----------------------------------------------------------------------------------------

return Multiplayer
