-----------------------------------------------------------------------------------------
--
-- ArrowsPanel.lua
--
-----------------------------------------------------------------------------------------

module("ArrowsPanel", package.seeall)

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require "utils"
require "sprite"

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

local WIDTH = 64
local HEIGHT = 64

-----------------------------------------------------------------------------------------
-- Attributes
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

local ArrowsPanel = {}
ArrowsPanel.__index = ArrowsPanel

function ArrowsPanel.create(values)
	-- Create object
	local self = values or {}
	setmetatable(self, ArrowsPanel)
	
	-- Initialize attributes
	
	
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
		y = 2 * HEIGHT,
		orientation = 180
	}

	local arrowRight = self:_createArrow{
		x = self.width / 2 + WIDTH / 2,
		y = HEIGHT,
		orientation = 90
	}

	local arrowLeft = self:_createArrow{
		x = self.width / 2 - WIDTH / 2,
		y = HEIGHT,
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
	self.arrows.y = self.y + HEIGHT / 2
end

function ArrowsPanel:_createArrow(parameters)
	local arrow = display.newImageRect("arrow_up.png", 64, 64)
	arrow:setReferencePoint(display.CenterReferencePoint)
	arrow.x = parameters.x or 0
	arrow.y = parameters.y or 0
	arrow:rotate(parameters.orientation or 0)

	return arrow
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
