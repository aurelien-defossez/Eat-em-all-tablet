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

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

local ARROW_WIDTH = 64
local ARROW_HEIGHT = 64

-----------------------------------------------------------------------------------------
-- Attributes
-----------------------------------------------------------------------------------------

ArrowsPanel.width = 2 * ARROW_WIDTH
ArrowsPanel.height = 3 * ARROW_HEIGHT

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function ArrowsPanel.create(values)
	-- Create object
	local self = values or {}
	setmetatable(self, ArrowsPanel)

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function ArrowsPanel:display()
	-- Create arrows
	local arrowUp = self:_createArrow{
		x = self.width / 2,
		y = 0,
		orientation = 0
	}

	local arrowDown = self:_createArrow{
		x = self.width / 2,
		y = 2 * ARROW_HEIGHT,
		orientation = 180
	}

	local arrowRight = self:_createArrow{
		x = self.width / 2 + ARROW_WIDTH / 2,
		y = ARROW_HEIGHT,
		orientation = 90
	}

	local arrowLeft = self:_createArrow{
		x = self.width / 2 - ARROW_WIDTH / 2,
		y = ARROW_HEIGHT,
		orientation = -90
	}

	-- Create arrows' group
	self.arrows = display.newGroup()
	self.arrows:insert(arrowUp)
	self.arrows:insert(arrowDown)
	self.arrows:insert(arrowRight)
	self.arrows:insert(arrowLeft)

	-- Position the arrows
	self.arrows.x = self.x
	self.arrows.y = self.y + ARROW_HEIGHT / 2
end

function ArrowsPanel:_createArrow(parameters)
	local arrow = display.newImageRect("arrow_up.png", ARROW_WIDTH, ARROW_HEIGHT)
	arrow:setReferencePoint(display.CenterReferencePoint)
	arrow.x = parameters.x or 0
	arrow.y = parameters.y or 0
	arrow:rotate(parameters.orientation or 0)

	return arrow
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
