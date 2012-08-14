-----------------------------------------------------------------------------------------
--
-- multiplayer.lua
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
	-- Initialize attributes
	self.paused = {
		system = false,
		user = false
	}

	-- Enter frame time
	self.lastFrameTime = 0

	-- Create players
	self.players = {}
	self.players[1] = Player.create{
		id = 1,
		color = "red",
		direction = DIRECTION.RIGHT,
		tableLayoutDirection = TABLE_LAYOUT.DIRECTION.LEFT_TO_RIGHT,
		hitPoints = config.player.hitPoints
	}

	self.players[2] = Player.create{
		id = 2,
		color = "blue",
		direction = DIRECTION.LEFT,
		tableLayoutDirection = TABLE_LAYOUT.DIRECTION.RIGHT_TO_LEFT,
		hitPoints = config.player.hitPoints
	}

	-- Create game scene
	self.gameScene = GameScene.create{
		players = self.players
	}
end

-- Called immediately after scene has moved onscreen:
function Multiplayer:enterScene(event)
	local group = self.view

	-- Bind evente
	Runtime:addEventListener("enterFrame", self)
	Runtime:addEventListener("gamePause", self)
	Runtime:addEventListener("gameQuit", self)
end

-- Called when scene is about to move offscreen:
function Multiplayer:exitScene(event)
	local group = self.view

	-- Unbind events
	Runtime:removeEventListener("enterFrame", self)
	Runtime:removeEventListener("gamePause", self)
	Runtime:removeEventListener("gameQuit", self)
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function Multiplayer:destroyScene(event)
	self.gameScene:destroy()
	self.players[1]:destroy()
	self.players[2]:destroy()
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Pause handler
--
-- Parameters:
--  event: The event object, with these data:
--   switch: If true, then switches the pause status
--   system: Tells whether the event is a system event
function Multiplayer:gamePause(event)
	if event.system then
		self.paused.system = (event.status == true)
	else
		self.paused.user = (event.status == true)
	end
end

-- Quit handler
--
-- Parameters:
--  event: The event object
function Multiplayer:gameQuit(event)
	storyboard.removeScene("src.game.Multiplayer")

	os.exit()
end

function Multiplayer:enterFrame(event)
	local timeDelta =  event.time - self.lastFrameTime
	self.lastFrameTime = event.time

	if not self.paused.user and not self.paused.system then
		self.gameScene:enterFrame(timeDelta)
	end
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
