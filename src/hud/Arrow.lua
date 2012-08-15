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

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Sign = require("src.game.Sign")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.ARROW)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create a control arrow
--
-- Parameters:
--  player: The arrow owner
--  grid: The grid
--  direction: The arrow direction, using Direction constants
--  x: X position
--  y: Y position
function Arrow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Arrow)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.width = config.arrow.width
	self.height = config.arrow.height

	-- Determine sprite animation
	local animationName
	if self.direction ~= DIRECTION.DELETE then
		animationName = "arrow_" .. self.player.color
	else 
		animationName = "arrow_crossed_" .. self.player.color
	end

	-- Draw sprite
	self.arrowSprite = SpriteManager.newSprite(spriteSet)
	self.arrowSprite:prepare(animationName)
	self.arrowSprite:play()

	-- Position sprite
	self.arrowSprite:setReferencePoint(display.CenterReferencePoint)
	self.arrowSprite.x = self.x or 0
	self.arrowSprite.y = self.height / 2 + (self.y or 0)
	self.arrowSprite:rotate(self.direction or 0)
	
	-- Handle events
	self.arrowSprite:addEventListener("touch", self)

	-- Add to group
	self.group:insert(self.arrowSprite)

	return self
end

-- Destroy the arrow
function Arrow:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Touch handler on one of the four arrows of the control panel
--
-- Parameters:
--  event: The touch event
function Arrow:touch(event)
	-- Begin drag by creating a new draggable arrow
	if event.phase == "began" then
		local animationName = nil

		if self.direction ~= DIRECTION.DELETE then
			animationName = "arrow_selected_" .. self.player.color
		else 
			animationName = "arrow_crossed_" .. self.player.color 
		end

		-- Draw arrow
		draggedArrow = SpriteManager.newSprite(spriteSet)
		draggedArrow:prepare(animationName)
		draggedArrow:play()

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

	return true
end

-- Touch handler on a draggable arrow
--
-- Parameters:
--  event: The touch event
function onDraggedArrowTouch(event)
	local draggedArrowSprite = event.target

	-- Follow the finger movement
	if event.phase == "moved" then
		draggedArrowSprite.x = event.x
		draggedArrowSprite.y = event.y

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(draggedArrowSprite, event.id)

	-- Drop the arrow
	elseif event.phase == "ended" then
		-- Locate drop tile
		local tile = draggedArrowSprite.grid:getTileByPixels{
			x = event.x,
			y = event.y
		}

		if tile then
			local sign = tile:getContentForType{TILE.CONTENT.SIGN}

			if draggedArrowSprite.direction ~= DIRECTION.DELETE then
				-- Create sign
				if not tile:hasContentType(CONTENT_GROUP.PRIMARY)
					or (sign and sign.player == draggedArrowSprite.player) then

					if sign then
						sign:destroy()
					end

					Sign.create{
						tile = tile,
						player = draggedArrowSprite.player,
						direction = draggedArrowSprite.direction
					}
				end
			elseif sign and sign.player == draggedArrowSprite.player then
				-- Remove sign
				sign:destroy()
			end
		end

		-- Remove dragged sprite
		draggedArrowSprite:removeSelf()

		-- Remove focus
		display.getCurrentStage():setFocus(nil, event.id)

	-- Delete the arrow
	elseif event.phase == "cancelled" then
		draggedArrowSprite:removeSelf()
		display.getCurrentStage():setFocus(nil, event.id)
	end

	return true
end

-----------------------------------------------------------------------------------------

return Arrow
