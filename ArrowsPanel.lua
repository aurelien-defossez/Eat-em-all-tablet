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
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	group = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Panel is 2 Arrows wide and 4 arrows tall
-- Arrows disposition:
--   [UP]
-- [LT][RT]
--   [DN]
--   [XX]

-- Create the arrows panel
--
-- Parameters:
--  player: The panel owner
--  grid: The grid
--  x: X position
--  y: Y position
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

	self.arrowDelete = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = Arrow.DELETE,
		x = self.x + self.width / 2,
		y = self.y + 3 * config.arrow.height
	}

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the arrows panel
function ArrowsPanel:draw()
	-- Draw arrows
	self.arrowUp:draw()
	self.arrowDown:draw()
	self.arrowRight:draw()
	self.arrowLeft:draw()
	self.arrowDelete:draw()
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
