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
local Grid = require("Grid")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene(event)
	-- Create players
	self.player1 = Player.create{
		id = 1,
		color = "red"
	}

	self.player2 = Player.create{
		id = 2,
		color = "blue"
	}

	-- Create the background
	local background = display.newRect(0, 0, config.screen.width, config.screen.height)
	background:setFillColor(142, 57, 20)

	-- Sizes
	local mainHeight = config.screen.height - config.panels.hitpoints.height

	-- Create grid
	self.grid = Grid.create{
		player1 = self.player1,
		player2 = self.player2,
		x = config.panels.controls.width + config.panels.grid.xpadding,
		y = config.panels.hitpoints.height,
		width = config.screen.width - 2 * config.panels.controls.width - 2 * config.panels.grid.xpadding,
		height = mainHeight
	}

	-- Load default map
	self.grid:loadMap(config.defaultMap)
	
	-- Create player control panels
	self.controlPanel1 = PlayerControlPanel.create{
		player = self.player1,
		x = 0,
		y = config.panels.hitpoints.height,
		height = mainHeight,
		grid = self.grid
	}

	self.controlPanel2 = PlayerControlPanel.create{
		player = self.player2,
		x = config.screen.width - config.panels.controls.width,
		y = config.panels.hitpoints.height,
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
	self.grid:enterFrame(event)
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
