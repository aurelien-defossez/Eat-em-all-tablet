-----------------------------------------------------------------------------------------
--
-- PlayerControlPanel.lua
--
-----------------------------------------------------------------------------------------

module("PlayerControlPanel", package.seeall)

local PlayerControlPanel = {}
PlayerControlPanel.__index = PlayerControlPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require "utils"
local ArrowsPanel = require("ArrowsPanel")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

local DEFAULT_WIDTH = 128
local DEFAULT_HEIGHT = 500

-----------------------------------------------------------------------------------------
-- Attributes
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function PlayerControlPanel.create(values)
	-- Create object
	local self = values or {}
	setmetatable(self, PlayerControlPanel)
	
	-- Default values
	applyDefaults(self, {
		width = DEFAULT_WIDTH,
		height = DEFAULT_HEIGHT
	})
	
	-- Initialize attributes
	self.arrows = ArrowsPanel.create{
		x = self.x,
		y = self.y + self.height / 2 - ArrowsPanel.height / 2
	}
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function PlayerControlPanel:display()
	local myRectangle = display.newRect(self.x, self.y, self.width, self.height)
	myRectangle.strokeWidth = 3
	myRectangle:setFillColor(204, 109, 0)
	myRectangle:setStrokeColor(135, 72, 0)
	
	self.arrows:display()
end

-----------------------------------------------------------------------------------------

return PlayerControlPanel
