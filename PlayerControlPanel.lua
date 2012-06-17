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

local PADDING = 16
local PANEL_WIDTH = ArrowsPanel.width + PADDING

-----------------------------------------------------------------------------------------
-- Attributes
-----------------------------------------------------------------------------------------

PlayerControlPanel.width = PANEL_WIDTH

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function PlayerControlPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PlayerControlPanel)
	
	-- Initialize attributes
	self.arrows = ArrowsPanel.create{
		player = self.player,
		x = self.x + PADDING / 2,
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
