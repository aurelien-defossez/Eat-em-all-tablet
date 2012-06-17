-----------------------------------------------------------------------------------------
--
-- multiplayer.lua
--
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local PlayerControlPanel = require("PlayerControlPanel")
local TouchListener = require("TouchListener")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

local SCREEN_WIDTH = display.contentWidth
local SCREEN_HEIGHT = display.contentHeight
local HALF_WIDTH = SCREEN_WIDTH * 0.5

local NB_ROWS = 8
local NB_COLS = 13

local TOP_ZONE_HEIGHT = 50

local GRID_START_Y = 100
local GRID_START_X = 50
local GRID_END_Y = display.contentHeight - 10
local GRID_END_X = display.contentWidth - 50

-----------------------------------------------------------------------------------------
-- Attributes
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()

-- Called when the scene's view does not exist:
function scene:createScene(event)
	local group = self.view

	-- create a grey rectangle as the backdrop
	local background = display.newRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	background:setFillColor(122, 47, 15)
	
	-- Draw background
	group:insert(background)
	
	-- Draw grid (Rows)
	local yStep = math.floor((GRID_END_Y - GRID_START_Y) / NB_ROWS)
	for y = GRID_START_Y, GRID_END_Y, yStep do
		local line = display.newLine(GRID_START_X, y, GRID_END_X, y)
		line.width = 2
		group:insert(line)
	end
	
	-- Draw grid (Columns)
	local xStep = math.floor((GRID_END_X - GRID_START_X) / NB_COLS)
	for x = GRID_START_X, GRID_END_X, xStep do
		local line = display.newLine(x, GRID_START_Y, x, GRID_END_Y)
		line.width = 2
		group:insert(line)
	end
	
	-- Create player control panels
	local controlPanel1 = PlayerControlPanel.create{
		playerId = 1,
		x = 0,
		y = TOP_ZONE_HEIGHT,
		height = SCREEN_HEIGHT - TOP_ZONE_HEIGHT
	}
	
	controlPanel1:display()

	-- Initialize touch listener
	-- TouchListener.init()
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
