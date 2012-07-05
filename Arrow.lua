-----------------------------------------------------------------------------------------
--
-- Arrow.lua
--
-----------------------------------------------------------------------------------------

module("Arrow", package.seeall)

Arrow.__index = Arrow

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local Sign = require("Sign")
local Tile = require("Tile")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

UP = 0
DOWN = 180
RIGHT = 90
LEFT = 270
DELETE = 360

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create a control arrow
--
-- Parameters:
--  player: The arrow owner
--  grid: The grid
--  direction: The arrow direction, using arrow constants
--  x: X position
--  y: Y position
function Arrow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Arrow)

	-- Initialize attributes
	self.width = config.arrow.width
	self.height = config.arrow.height

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the arrow
function Arrow:draw()
	if self.direction ~= DELETE then
		self.sprite = display.newImageRect("arrow_up_" .. self.player.color .. ".png", self.width, self.height)
	else 
		self.sprite = display.newImageRect("arrow_crossed_" .. self.player.color .. ".png", self.width, self.height)
	end

	self.sprite.arrow = self

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x or 0
	self.sprite.y = self.height / 2 + (self.y or 0)
	self.sprite:rotate(self.direction or 0)
	
	-- Handle events
	self.sprite:addEventListener("touch", onArrowTouch)

	-- Add to group
	self.group:insert(self.sprite)
end

-----------------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------------

-- Touch handler on one of the four arrows of the control panel
function onArrowTouch(event)
	local arrow = event.target.arrow

	-- Begin drag by creating a new draggable arrow
	if event.phase == "began" then
		local draggedArrow = nil

		if arrow.direction ~= DELETE then
			draggedArrow = display.newImageRect("arrow_up_selected_" .. arrow.player.color .. ".png",
				arrow.width, arrow.height)
		else 
			draggedArrow = display.newImageRect("arrow_crossed_" .. arrow.player.color .. ".png",
				arrow.width, arrow.height)
		end

		draggedArrow.direction = arrow.direction
		draggedArrow.player = arrow.player
		draggedArrow.grid = arrow.grid

		-- Position arrow
		draggedArrow:setReferencePoint(display.CenterReferencePoint)
		draggedArrow.x = event.x
		draggedArrow.y = event.y
		draggedArrow:rotate(arrow.direction)

		-- Handle events
		draggedArrow:addEventListener("touch", onDraggedArrowTouch)
	end
end

-- Touch handler on a draggable arrow
function onDraggedArrowTouch(event)
	local sprite = event.target

	-- Follow the finger movement
	if event.phase == "moved" then
		sprite.x = event.x
		sprite.y = event.y

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(sprite, event.id)

	-- Drop the arrow
	elseif event.phase == "ended" then
		-- Locate drop tile
		local tile = sprite.grid:getTileByPixels{
			x = event.x,
			y = event.y
		}

		if tile ~= nil then
			if sprite.direction ~= DELETE then
				-- Create sign
				if tile ~= nil and tile.content == nil then
					tile.content = Sign.create{
						tile = tile,
						player = sprite.player,
						direction = sprite.direction
					}

					tile.content:draw()
				end
			elseif tile.content ~= nil and tile.content.type == Tile.TYPE_SIGN
				and tile.content.player == sprite.player then
				-- Remove sign
				tile:removeContent()
			end
		end

		-- Remove dragged sprite
		sprite:removeSelf()

		-- Remove focus
		display.getCurrentStage():setFocus(nil, event.id)

	-- Delete the arrow
	elseif event.phase == "cancelled" then
		sprite:removeSelf()
		display.getCurrentStage():setFocus(nil, event.id)
	end
end

-----------------------------------------------------------------------------------------

return Arrow
