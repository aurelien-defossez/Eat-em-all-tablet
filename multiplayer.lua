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

local Player = require("Player")
local PlayerControlPanel = require("PlayerControlPanel")
local Grid = require("Grid")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

local SCREEN_WIDTH = display.contentWidth
local SCREEN_HEIGHT = display.contentHeight
local HALF_WIDTH = SCREEN_WIDTH * 0.5

local TOP_ZONE_HEIGHT = 50

local GRID_START_Y = 100
local GRID_START_X = 50
local GRID_END_Y = display.contentHeight - 10
local GRID_END_X = display.contentWidth - 50

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene(event)
	-- Create players
	local player1 = Player.create{
		id = 1
	}

	local player2 = Player.create{
		id = 2
	}

	-- Create the background
	local background = display.newRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	background:setFillColor(122, 47, 15)

	-- Sizes
	local mainHeight = SCREEN_HEIGHT - TOP_ZONE_HEIGHT
	
	-- Create player control panels
	local controlPanel1 = PlayerControlPanel.create{
		player = player1,
		x = 0,
		y = TOP_ZONE_HEIGHT,
		height = mainHeight
	}

	local controlPanel2 = PlayerControlPanel.create{
		player = player2,
		x = SCREEN_WIDTH - PlayerControlPanel.WIDTH,
		y = TOP_ZONE_HEIGHT,
		height = mainHeight
	}

	-- Create grid
	local grid = Grid.create{
		x = PlayerControlPanel.WIDTH + Grid.PADDING,
		y = TOP_ZONE_HEIGHT,
		width = SCREEN_WIDTH - 2 * PlayerControlPanel.WIDTH - 2 * Grid.PADDING,
		height = mainHeight
	}

	-- Draw
	controlPanel1:draw()
	controlPanel2:draw()
	grid:draw()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
	local group = self.view
end

-- Called when scene is about to move offscreen:
function scene:exitScene(event)
	local group = self.view
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene(event)
	local group = self.view
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
