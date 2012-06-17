-----------------------------------------------------------------------------------------
--
-- Arrow.lua
--
-----------------------------------------------------------------------------------------

module("Arrow", package.seeall)

local Arrow = {}
Arrow.__index = Arrow

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

Arrow.UP = 0
Arrow.DOWN = 1
Arrow.RIGHT = 2
Arrow.LEFT = 3

Arrow.WIDTH = 64
Arrow.HEIGHT = 64

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Arrow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Arrow)

	-- Initialize attributes
	self.width = Arrow.WIDTH
	self.height = Arrow.HEIGHT

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Arrow:display()
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
-- Static Methods
-----------------------------------------------------------------------------------------

function onArrowTouch(event)
	local arrow = event.target.arrow

	if event.phase == "began" then
		print ("Arrow touched: " .. arrow.direction)

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

return Arrow
