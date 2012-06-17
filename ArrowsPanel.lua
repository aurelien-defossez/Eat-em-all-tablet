-----------------------------------------------------------------------------------------
--
-- ArrowsPanel.lua
--
-----------------------------------------------------------------------------------------

module("ArrowsPanel", package.seeall)

local ArrowsPanel = {}
ArrowsPanel.__index = ArrowsPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require "utils"
require "sprite"
local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

-- Panel is 2 Arrows wide and 3 arrows tall
-- Arrows disposition:
--   [UP]
-- [LT][RT]
--   [DN]

ArrowsPanel.WIDTH = 2 * Arrow.WIDTH
ArrowsPanel.HEIGHT = 3 * Arrow.HEIGHT

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function ArrowsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ArrowsPanel)

	-- Initialize attributes
	self.width = ArrowsPanel.WIDTH
	self.height = ArrowsPanel.HEIGHT

	-- Create arrows
	self.arrowUp = Arrow.create{
		player = self.player,
		direction = Arrow.UP,
		x = self.x + self.width / 2,
		y = self.y,
		orientation = 0
	}

	self.arrowDown = Arrow.create{
		player = self.player,
		direction = Arrow.DOWN,
		x = self.x + self.width / 2,
		y = self.y + 2 * Arrow.HEIGHT,
		orientation = 180
	}

	self.arrowRight = Arrow.create{
		player = self.player,
		direction = Arrow.RIGHT,
		x = self.x + self.width / 2 + Arrow.WIDTH / 2,
		y = self.y + Arrow.HEIGHT,
		orientation = 90
	}

	self.arrowLeft = Arrow.create{
		player = self.player,
		direction = Arrow.LEFT,
		x = self.x + self.width / 2 - Arrow.WIDTH / 2,
		y = self.y + Arrow.HEIGHT,
		orientation = -90
	}

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function ArrowsPanel:display()
	-- Display arrows
	self.arrowUp:display()
	self.arrowDown:display()
	self.arrowRight:display()
	self.arrowLeft:display()
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
