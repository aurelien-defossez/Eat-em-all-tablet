-----------------------------------------------------------------------------------------
--
-- DraggedArrow.lua
--
-----------------------------------------------------------------------------------------

module("DraggedArrow", package.seeall)

DraggedArrow.__index = DraggedArrow

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.sprites.SpriteManager")
local Sprite = require("src.sprites.Sprite")
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

-- Create a dragged arrow
--
-- Parameters:
--  player: The arrow owner
--  grid: The grid
--  direction: The arrow direction, using Direction constants
--  x: X position
--  y: Y position
function DraggedArrow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, DraggedArrow)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.width = config.arrow.width
	self.height = config.arrow.height

	-- Create sprite
	self.arrowSprite = Sprite.create{
		spriteSet = spriteSet,
		group = self.group,
		x = self.x,
		y = self.y,
		orientation = self.direction
	}

	-- Draw sprite
	local animationName = nil
	if self.direction ~= DIRECTION.DELETE then
		animationName = "arrow_selected_" .. self.player.color.name
	else 
		animationName = "arrow_crossed_" .. self.player.color.name
	end

	self.arrowSprite:play(animationName)

	-- Handle events
	self.arrowSprite:addEventListener("touch", self)

	return self
end

-- Destroy the arrow
function DraggedArrow:destroy()
	self.arrowSprite:removeEventListener("touch", self)
	self.arrowSprite:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Touch handler on the dragged arrow
--
-- Parameters:
--  event: The touch event
function DraggedArrow:touch(event)
	-- Follow the finger movement
	if event.phase == "moved" then
		self.arrowSprite:move{
			x = event.x,
			y = event.y
		}

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(self.arrowSprite.sprite, event.id)

	-- Drop the arrow
	elseif event.phase == "ended" then
		-- Locate drop tile
		local tile = self.grid:getTileByPixels{
			x = event.x,
			y = event.y
		}

		if tile then
			local sign = tile:getContentForType{TILE.CONTENT.SIGN}

			if self.direction ~= DIRECTION.DELETE then
				-- Create sign
				if not tile:hasContentType(CONTENT_GROUP.PRIMARY)
					or (sign and sign.player == self.player) then

					if sign then
						sign:destroy()
					end

					Sign.create{
						tile = tile,
						player = self.player,
						direction = self.direction
					}
				end
			elseif sign and sign.player == self.player then
				-- Remove sign
				sign:destroy()
			end
		end

		-- Remove focus
		display.getCurrentStage():setFocus(nil, event.id)

		-- Remove dragged sprite
		self:destroy()

	-- Delete the arrow
	elseif event.phase == "cancelled" then
		display.getCurrentStage():setFocus(nil, event.id)
		self:destroy()
	end

	return true
end

-----------------------------------------------------------------------------------------

return DraggedArrow
