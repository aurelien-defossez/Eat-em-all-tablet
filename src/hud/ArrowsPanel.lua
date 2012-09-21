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

	-- Create arrow counter
	self.signCounter = display.newText(config.player.maxSigns, config.panels.controls.arrows.counter.xoffset,
		config.panels.controls.arrows.counter.yoffset, native.systemFontBold, 32)
	self.signCounter:rotate(self.player.direction)
	self.signCounter:setReferencePoint(display.BottomCenterReferencePoint)
	self.signCounter:setTextColor(0, 0, 0)
	self.group:insert(self.signCounter)

	-- Position counter depending on player's side
	if self.player.id == 1 then
		self.signCounter.x = self.width - config.panels.controls.arrows.counter.xoffset
	else
		self.signCounter.x = config.panels.controls.arrows.counter.xoffset
	end

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Register itself to the player
	self.player.arrowsPanel = self

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
-- Methods
-----------------------------------------------------------------------------------------

-- Enable the dragging of the panel arrows
function ArrowsPanel:enable()
	self.arrowUp:enable()
	self.arrowDown:enable()
	self.arrowRight:enable()
	self.arrowLeft:enable()
end

-- Disable the dragging of the panel arrows
function ArrowsPanel:disable()
	self.arrowUp:disable()
	self.arrowDown:disable()
	self.arrowRight:disable()
	self.arrowLeft:disable()
end

-- Update the sign count
--
-- Parameters:
--  signCount: The new value
function ArrowsPanel:updateSignCount(signCount)
	self.signCounter.text = signCount
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
