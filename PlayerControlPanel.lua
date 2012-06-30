-----------------------------------------------------------------------------------------
--
-- PlayerControlPanel.lua
--
-----------------------------------------------------------------------------------------

module("PlayerControlPanel", package.seeall)

PlayerControlPanel.__index = PlayerControlPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local ArrowsPanel = require("ArrowsPanel")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the player control panel
--
-- Parameters:
--  player: The control panel owner
--  x: X position
--  y: Y position
--  height: Height (Width is hardcoded in configuration file)
--  grid: The grid
function PlayerControlPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PlayerControlPanel)
	
	-- Initialize attributes
	self.width = config.panels.controls.width
	self.arrows = ArrowsPanel.create{
		player = self.player,
		grid = self.grid,
		x = self.x + config.panels.controls.padding,
		y = self.y + self.height / 2 - config.panels.controls.arrows.height / 2
	}
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the control panel
function PlayerControlPanel:draw()
	local myRectangle = display.newRect(self.x, self.y, self.width, self.height)
	myRectangle.strokeWidth = 3
	myRectangle:setFillColor(204, 109, 0)
	myRectangle:setStrokeColor(135, 72, 0)
	
	self.arrows:draw()
end

-----------------------------------------------------------------------------------------

return PlayerControlPanel
