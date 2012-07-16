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
-- Class methods
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

-- Destroy the arrow
function Arrow:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the arrow
function Arrow:draw()
	if self.direction ~= DELETE then
		self.arrowSprite = display.newImageRect("arrow_up_" .. self.player.color .. ".png", self.width, self.height)
	else 
		self.arrowSprite = display.newImageRect("arrow_crossed_" .. self.player.color .. ".png", self.width, self.height)
	end

	self.arrowSprite.arrow = self

	-- Position sprite
	self.arrowSprite:setReferencePoint(display.CenterReferencePoint)
	self.arrowSprite.x = self.x or 0
	self.arrowSprite.y = self.height / 2 + (self.y or 0)
	self.arrowSprite:rotate(self.direction or 0)
	
	-- Handle events
	self.arrowSprite:addEventListener("touch", onArrowTouch)

	-- Add to group
	self.group:insert(self.arrowSprite)
end

-----------------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------------

-- Touch handler on one of the four arrows of the control panel
function onArrowTouch(event)
	local self = event.target.arrow

	-- Begin drag by creating a new draggable arrow
	if event.phase == "began" then
		local draggedArrow = nil

		if self.direction ~= DELETE then
			draggedArrow = display.newImageRect("arrow_up_selected_" .. self.player.color .. ".png",
				self.width, self.height)
		else 
			draggedArrow = display.newImageRect("arrow_crossed_" .. self.player.color .. ".png",
				self.width, self.height)
		end

		draggedArrow.direction = self.direction
		draggedArrow.player = self.player
		draggedArrow.grid = self.grid

		-- Position arrow
		draggedArrow:setReferencePoint(display.CenterReferencePoint)
		draggedArrow.x = event.x
		draggedArrow.y = event.y
		draggedArrow:rotate(self.direction)

		-- Handle events
		draggedArrow:addEventListener("touch", onDraggedArrowTouch)
	end
end

-- Touch handler on a draggable arrow
function onDraggedArrowTouch(event)
	local arrowSprite = event.target

	-- Follow the finger movement
	if event.phase == "moved" then
		arrowSprite.x = event.x
		arrowSprite.y = event.y

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(arrowSprite, event.id)

	-- Drop the arrow
	elseif event.phase == "ended" then
		-- Locate drop tile
		local tile = arrowSprite.grid:getTileByPixels{
			x = event.x,
			y = event.y
		}

		if tile then
			if arrowSprite.direction ~= DELETE then
				-- Create sign
				if not tile.content
					or tile.content.type == Tile.TYPE_SIGN and tile.content.player == arrowSprite.player then

					if tile.content then
						tile.content:destroy()
					end

					tile.content = Sign.create{
						tile = tile,
						player = arrowSprite.player,
						direction = arrowSprite.direction
					}

					tile.content:draw()
				end
			elseif tile.content ~= nil and tile.content.type == Tile.TYPE_SIGN
				and tile.content.player == arrowSprite.player then
				-- Remove sign
				tile:removeContent()
			end
		end

		-- Remove dragged sprite
		arrowSprite:removeSelf()

		-- Remove focus
		display.getCurrentStage():setFocus(nil, event.id)

	-- Delete the arrow
	elseif event.phase == "cancelled" then
		arrowSprite:removeSelf()
		display.getCurrentStage():setFocus(nil, event.id)
	end
end

-----------------------------------------------------------------------------------------

return Arrow
