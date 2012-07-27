-----------------------------------------------------------------------------------------
--
-- multiplayer.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local scene = storyboard.newScene()

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
function scene:createScene(event)
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
function scene:enterScene(event)
	local group = self.view

	-- Bind enter frame event
	Runtime:addEventListener("enterFrame", self);
end

-- Called when scene is about to move offscreen:
function scene:exitScene(event)
	local group = self.view

	-- Unbind events
	Runtime:removeEventListener("enterFrame", self)
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene(event)
	self.gameScene:destroy()
	local group = self.view
end

-----------------------------------------------------------------------------------------
-- Enter Frame
-----------------------------------------------------------------------------------------

function scene:enterFrame(event)
	local timeDelta =  event.time - self.lastFrameTime
	self.lastFrameTime = event.time

	self.gameScene:enterFrame(timeDelta)
end

-----------------------------------------------------------------------------------------
-- Binding
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener("createScene", scene)

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener("enterScene", scene)

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener("exitScene", scene)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener("destroyScene", scene)


-----------------------------------------------------------------------------------------

return scene
