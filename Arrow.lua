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

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

UP = 0
DOWN = 1
RIGHT = 2
LEFT = 3

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Arrow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Arrow)

	-- Initialize attributes
	self.width = config.arrow.width
	self.height = config.arrow.height

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Arrow:draw()
	self.sprite = display.newImageRect("arrow_up.png", self.width, self.height)
	self.sprite.arrow = self

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x or 0
	self.sprite.y = self.height / 2 + (self.y or 0)
	self.sprite:rotate(self.orientation or 0)
	
	-- Handle events
	self.sprite:addEventListener("touch", onArrowTouch)
end

-----------------------------------------------------------------------------------------
-- Private static Methods
-----------------------------------------------------------------------------------------

function onArrowTouch(event)
	local arrow = event.target.arrow

	if event.phase == "began" then
		print ("Drag start: " .. arrow.direction .. " of player " .. arrow.player.id)

		local draggedArrow = display.newImageRect("arrow_up_selected.png", arrow.width, arrow.height)
		draggedArrow.direction = arrow.direction
		draggedArrow.player = arrow.player

		-- Position arrow
		draggedArrow:setReferencePoint(display.CenterReferencePoint)
		draggedArrow.x = event.x
		draggedArrow.y = event.y
		draggedArrow:rotate(arrow.orientation)

		-- Handle events
		draggedArrow:addEventListener("touch", onDraggedArrowTouch)
	end
end

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
		print ("Drag end:   " .. sprite.direction .. " of player " .. sprite.player.id)
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
