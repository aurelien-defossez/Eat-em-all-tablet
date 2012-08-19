-----------------------------------------------------------------------------------------
--
-- Sign.lua
--
-----------------------------------------------------------------------------------------

module("Sign", package.seeall)

Sign.__index = Sign

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.ARROW)
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

	ctId = ctId + 1

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw sprite
	self.signSprite = SpriteManager.newSprite(spriteSet)
	self.signSprite:prepare("arrow_" .. self.player.color)
	self.signSprite:play()

	-- Position sprite
	self.signSprite:setReferencePoint(display.CenterReferencePoint)
	self.signSprite.x = self.tile.width / 2
	self.signSprite.y = self.tile.height / 2
	self.signSprite:rotate(self.direction or 0)

	-- Add to group
	self.group:insert(self.signSprite)

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

	if zombie.phase == ZOMBIE.PHASE.MOVE and zombie.player.id == self.player.id then
		-- Ignore direction on special cases
		if not (self.tile.isOnFirstRow and self.direction == DIRECTION.UP)
			and not (self.tile.isOnLastRow and self.direction == DIRECTION.DOWN) then
			zombie:changeDirection{
				direction = self.direction,
				correctPosition = true
			}
		end
	end
end

-----------------------------------------------------------------------------------------

return Sign
