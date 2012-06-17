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

-- Panel is 2 Arrows wide and 3 arrows tall
-- Arrows disposition:
--   [UP]
-- [LT][RT]
--   [DN]

ArrowsPanel.width = 2 * ARROW_WIDTH
ArrowsPanel.height = 3 * ARROW_HEIGHT

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function ArrowsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ArrowsPanel)

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function ArrowsPanel:display()
	-- Create arrows
	local arrowUp = self:_createArrow{
		player = self.player,
		direction = UP,
		x = 0,
		y = 0,
		orientation = 0
	}

	local arrowDown = self:_createArrow{
		player = self.player,
		direction = DOWN,
		x = 0,
		y = 2 * ARROW_HEIGHT,
		orientation = 180
	}

	local arrowRight = self:_createArrow{
		player = self.player,
		direction = RIGHT,
		x = ARROW_WIDTH / 2,
		y = ARROW_HEIGHT,
		orientation = 90
	}

	local arrowLeft = self:_createArrow{
		player = self.player,
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
	arrow.player = parameters.player

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
	local arrow = event.target

	if event.phase == "began" then
		print ("Arrow touched: " .. arrow.direction)

		local draggedArrow = display.newImageRect("arrow_up_selected.png", ARROW_WIDTH, ARROW_HEIGHT)
		draggedArrow.direction = arrow.direction
		draggedArrow.player = arrow.player

		-- Position arrow
		draggedArrow:setReferencePoint(display.CenterReferencePoint)
		draggedArrow.x = event.x
		draggedArrow.y = event.y
		draggedArrow:rotate(arrow.rotation)

		-- Handle events
		draggedArrow:addEventListener("touch", onDraggedArrowTouch)

		return arrow
	end
end

function onDraggedArrowTouch(event)
	local arrow = event.target

	-- Follow the finger movement
	if event.phase == "moved" then
		arrow.x = event.x
		arrow.y = event.y

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(arrow, event.id)

	-- Drop the arrow
	elseif event.phase == "ended" then
		print ("Arrow " .. arrow.direction .. " positioned by player " .. arrow.player.id)
		arrow:removeSelf()

		-- Remove focus
		display.getCurrentStage():setFocus(nil, event.id)

	-- Delete the arrow
	elseif event.phase == "cancelled" then
		arrow:removeSelf()
		display.getCurrentStage():setFocus(nil, event.id)
	end
end

-----------------------------------------------------------------------------------------

return ArrowsPanel
