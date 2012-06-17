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
local UP = 0
local DOWN = 1
local RIGHT = 2
local LEFT = 3

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
		direction = UP,
		x = 0,
		y = 0,
		orientation = 0
	}

	local arrowDown = self:_createArrow{
		direction = DOWN,
		x = 0,
		y = 2 * ARROW_HEIGHT,
		orientation = 180
	}

	local arrowRight = self:_createArrow{
		direction = RIGHT,
		x = ARROW_WIDTH / 2,
		y = ARROW_HEIGHT,
		orientation = 90
	}

	local arrowLeft = self:_createArrow{
		direction = LEFT,
		x = -ARROW_WIDTH / 2,
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
	self.arrows.y = self.y
end

function ArrowsPanel:_createArrow(parameters)
	local arrow = display.newImageRect("arrow_up.png", ARROW_WIDTH, ARROW_HEIGHT)
	arrow.direction = parameters.direction or -1

	-- Position arrow
	arrow:setReferencePoint(display.CenterReferencePoint)
	arrow.x = self.width / 2 + (parameters.x or 0)
	arrow.y = ARROW_HEIGHT / 2 + (parameters.y or 0)
	arrow:rotate(parameters.orientation or 0)

	-- Handle events
	arrow:addEventListener("touch", onArrowTouch)

	return arrow
end

-----------------------------------------------------------------------------------------
-- Static Methods
-----------------------------------------------------------------------------------------

function onArrowTouch(event)
	local self = event.target

	print ("Arrow touched: " .. self.direction)
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
