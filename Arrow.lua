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

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

UP = 0
DOWN = 180
RIGHT = 90
LEFT = 270

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
	self.sprite = display.newImageRect("arrow_up_" .. self.player.color .. ".png", self.width, self.height)
	self.sprite.arrow = self

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x or 0
	self.sprite.y = self.height / 2 + (self.y or 0)
	self.sprite:rotate(self.direction or 0)
	
	-- Handle events
	self.sprite:addEventListener("touch", onArrowTouch)
end

-----------------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------------

function onArrowTouch(event)
	local arrow = event.target.arrow

	if event.phase == "began" then
		print ("Drag start: " .. arrow.direction .. " of player " .. arrow.player.id)

		local draggedArrow = display.newImageRect("arrow_up_selected_" .. arrow.player.color .. ".png",
			arrow.width, arrow.height)
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

		-- Locate drop tile
		local tile = sprite.grid:getTileByPixels{
			x = event.x,
			y = event.y
		}

		-- Create sign
		if tile ~= nil and tile.content == nil then
			print("Create sign")
			tile.content = Sign.create{
				tile = tile,
				player = sprite.player,
				direction = sprite.direction
			}

			tile.content:draw()
		end

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
