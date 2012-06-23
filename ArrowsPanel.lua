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
local config = require("GameConfig")
local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Panel is 2 Arrows wide and 3 arrows tall
-- Arrows disposition:
--   [UP]
-- [LT][RT]
--   [DN]


function ArrowsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ArrowsPanel)

	-- Initialize attributes
	self.width = config.panels.controls.arrows.width
	self.height = config.panels.controls.arrows.height

	-- Create arrows
	self.arrowUp = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = Arrow.UP,
		x = self.x + self.width / 2,
		y = self.y
	}

	self.arrowDown = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = Arrow.DOWN,
		x = self.x + self.width / 2,
		y = self.y + 2 * config.arrow.height
	}

	self.arrowRight = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = Arrow.RIGHT,
		x = self.x + self.width / 2 + config.arrow.width / 2,
		y = self.y + config.arrow.height
	}

	self.arrowLeft = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = Arrow.LEFT,
		x = self.x + self.width / 2 - config.arrow.width / 2,
		y = self.y + config.arrow.height
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
