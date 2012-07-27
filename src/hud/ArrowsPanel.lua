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

require("src.utils.Constants")
require("src.config.GameConfig")

local Arrow = require("src.hud.Arrow")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
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

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.width = config.panels.controls.arrows.width
	self.height = config.panels.controls.arrows.height

	-- Create arrows
	self.arrowUp = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = DIRECTION.UP,
		x = self.x + self.width / 2,
		y = self.y
	}

	self.arrowDown = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = DIRECTION.DOWN,
		x = self.x + self.width / 2,
		y = self.y + 2 * config.arrow.height
	}

	self.arrowRight = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = DIRECTION.RIGHT,
		x = self.x + self.width / 2 + config.arrow.width / 2,
		y = self.y + config.arrow.height
	}

	self.arrowLeft = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = DIRECTION.LEFT,
		x = self.x + self.width / 2 - config.arrow.width / 2,
		y = self.y + config.arrow.height
	}

	self.arrowDelete = Arrow.create{
		player = self.player,
		grid = self.grid,
		direction = DIRECTION.DELETE,
		x = self.x + self.width / 2,
		y = self.y + 3 * config.arrow.height
	}

	return self
end

-- Destroy the panel
function ArrowsPanel:destroy()
	self.arrowUp:destroy()
	self.arrowDown:destroy()
	self.arrowRight:destroy()
	self.arrowLeft:destroy()
	self.arrowDelete:destroy()

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
