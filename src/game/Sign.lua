-----------------------------------------------------------------------------------------
--
-- Sign.lua
--
-- A sign is a map entity that redirects the zombies.
-- When a zombie arrives in the middle of a sign, it follows the sign if it belongs
-- to their player.
-- If the sign points to a wall, the tile will block this movement and correct it so the
-- zombie goes along the wall.
--
-----------------------------------------------------------------------------------------

module("Sign", package.seeall)
Sign.__index = Sign

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local SpriteManager = require("src.sprites.SpriteManager")
local Sprite = require("src.sprites.Sprite")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

-- Initialize the class
function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates the sign
--
-- Parameters:
--  tile: The tile the sign is on
--  player: The sign owner
--  direction: The sign direction, as arrow direction constant
function Sign.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Sign)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.SIGN
	self.x = self.tile.x
	self.y = self.tile.y
	self.id = ctId

	-- Update class attributes
	ctId = ctId + 1

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Create sprite
	self.signSprite = Sprite.create{
		spriteSet = SpriteManager.sets.arrow,
		group = self.group,
		x = Tile.width_2,
		y = Tile.height_2,
		orientation = self.direction or 0
	}

	-- Draw sprite
	self.signSprite:play("arrow_" .. self.player.color.name)

	-- Register to the tile and player
	self.contentId = self.tile:addContent(self)
	self.player:addSign(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.REACH_TILE_CENTER, self)

	return self
end

-- Destroy the sign
function Sign:destroy()
	self.tile:removeEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	self.player:removeSign(self)
	self.signSprite:destroy()
	self.tile:removeContent(self.contentId)
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Reach center tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function Sign:reachTileCenter(event)
	local zombie = event.zombie

	if zombie.followSigns and zombie.player.id == self.player.id then
		-- Ignore direction on special cases
		if not (self.tile.isOnFirstRow and self.direction == DIRECTION.UP)
			and not (self.tile.isOnLastRow and self.direction == DIRECTION.DOWN) then
			zombie:changeDirection{
				direction = self.direction,
				priority = ZOMBIE.PRIORITY.SIGN,
				correctPosition = true
			}
		end
	end
end

-----------------------------------------------------------------------------------------

return Sign
