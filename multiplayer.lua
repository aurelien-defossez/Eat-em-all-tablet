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

local config = require("GameConfig")
local Player = require("Player")
local PlayerControlPanel = require("PlayerControlPanel")
local Arrow = require("Arrow")
local Grid = require("Grid")

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
		direction = Arrow.RIGHT,
		hitPoints = config.player.hitPoints
	}

	self.players[2] = Player.create{
		id = 2,
		color = "blue",
		direction = Arrow.LEFT,
		hitPoints = config.player.hitPoints
	}

	-- Create the background
	local background = display.newRect(0, 0, config.screen.width, config.screen.height)
	background:setFillColor(142, 57, 20)

	-- Sizes
	local mainHeight = config.screen.height - config.panels.hitPoints.height

	-- Create grid
	self.grid = Grid.create{
		players = self.players,
		x = config.panels.controls.width + config.panels.grid.xpadding,
		y = config.panels.hitPoints.height,
		width = config.screen.width - 2 * config.panels.controls.width - 2 * config.panels.grid.xpadding,
		height = mainHeight
	}

	-- Load default map
	self.grid:loadMap(config.defaultMap)
	
	-- Create player control panels
	self.controlPanel1 = PlayerControlPanel.create{
		player = self.players[1],
		x = 0,
		y = config.panels.hitPoints.height,
		height = mainHeight,
		grid = self.grid
	}

	self.controlPanel2 = PlayerControlPanel.create{
		player = self.players[2],
		x = config.screen.width - config.panels.controls.width,
		y = config.panels.hitPoints.height,
		height = mainHeight,
		grid = self.grid
	}

	-- Draw
	self.controlPanel1:draw()
	self.controlPanel2:draw()
	self.grid:draw()

	-- Bind enterFrane event
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
	local group = self.view
end

-----------------------------------------------------------------------------------------
-- Enter Frame
-----------------------------------------------------------------------------------------

function scene:enterFrame(event)
	local timeDelta =  event.time - self.lastFrameTime
	self.lastFrameTime = event.time

	self.grid:enterFrame(timeDelta)
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
