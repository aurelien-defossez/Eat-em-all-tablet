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

local ArrowsPanel = require("ArrowsPanel")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

PADDING = 16
WIDTH = ArrowsPanel.WIDTH + PADDING

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function PlayerControlPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PlayerControlPanel)
	
	-- Initialize attributes
	self.width = WIDTH
	self.arrows = ArrowsPanel.create{
		player = self.player,
		x = self.x + PADDING / 2,
		y = self.y + self.height / 2 - ArrowsPanel.HEIGHT / 2
	}
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function PlayerControlPanel:draw()
	local myRectangle = display.newRect(self.x, self.y, self.width, self.height)
	myRectangle.strokeWidth = 3
	myRectangle:setFillColor(204, 109, 0)
	myRectangle:setStrokeColor(135, 72, 0)
	
	self.arrows:draw()
end

-----------------------------------------------------------------------------------------

return PlayerControlPanel
