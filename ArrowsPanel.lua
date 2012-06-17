-----------------------------------------------------------------------------------------
--
-- ArrowsPanel.lua
--
-----------------------------------------------------------------------------------------

module("ArrowsPanel", package.seeall)

ArrowsPanel.__index = ArrowsPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("sprite")
local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

-- Panel is 2 Arrows wide and 3 arrows tall
-- Arrows disposition:
--   [UP]
-- [LT][RT]
--   [DN]

WIDTH = 2 * Arrow.WIDTH
HEIGHT = 3 * Arrow.HEIGHT

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function ArrowsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ArrowsPanel)

	-- Initialize attributes
	self.width = WIDTH
	self.height = HEIGHT

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

function ArrowsPanel:draw()
	-- Draw arrows
	self.arrowUp:draw()
	self.arrowDown:draw()
	self.arrowRight:draw()
	self.arrowLeft:draw()
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
