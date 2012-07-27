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
	self.arrowSprite.arrow = self
	self.arrowSprite:addEventListener("touch", onArrowTouch)

	-- Add to group
	self.group:insert(self.arrowSprite)

	return self
end

-- Destroy the arrow
function Arrow:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Touch handler on one of the four arrows of the control panel
function onArrowTouch(event)
	local self = event.target.arrow

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
			if arrowSprite.direction ~= DIRECTION.DELETE then
				-- Create sign
				if not tile.content
					or tile:getContentType() == TILE.CONTENT.SIGN and tile.content.player == arrowSprite.player then

					if tile.content then
						tile.content:destroy()
					end

					tile.content = Sign.create{
						tile = tile,
						player = arrowSprite.player,
						direction = arrowSprite.direction
					}
				end
			elseif tile:getContentType() == TILE.CONTENT.SIGN and tile.content.player == arrowSprite.player then
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
