-----------------------------------------------------------------------------------------
--
-- Tornado.lua
--
-----------------------------------------------------------------------------------------

module("Tornado", package.seeall)

Tornado.__index = Tornado

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Utils")
require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

RANDOM_DIRECTION = {
	DIRECTION.UP,
	DIRECTION.DOWN,
	DIRECTION.RIGHT,
	DIRECTION.LEFT
}

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.TORNADO)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates a tornado
--
-- Parameters:
--  tile: The tile on tornado
function Tornado.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Tornado)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.TORNADO
	self.x = self.tile.x
	self.y = self.tile.y
	self.lifeSpan = config.item.tornado.duration

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw the sprite
	self.tornadoSprite = SpriteManager.newSprite(spriteSet)
	self.tornadoSprite:prepare("tornado")
	self.tornadoSprite:play()

	-- Position sprite
	self.tornadoSprite:setReferencePoint(display.CenterReferencePoint)
	self.tornadoSprite.x = Tile.width_2
	self.tornadoSprite.y = Tile.height_2

	-- Add to group
	self.group:insert(self.tornadoSprite)

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	Runtime:addEventListener("spritePause", self)

	return self
end

-- Destroy the item
function Tornado:destroy()
	self.tile:removeEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	Runtime:removeEventListener("spritePause", self)

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
function Tornado:reachTileCenter(event)
	local zombie = event.zombie

	if zombie.phase == ZOMBIE.PHASE.MOVE then
		-- Block direction so a sign cannot rectify the trajectory
		zombie:changeDirection{
			direction = RANDOM_DIRECTION[math.random(#RANDOM_DIRECTION)],
			correctPosition = true,
			block = true
		}
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Tornado:enterFrame(timeDelta)
	self.lifeSpan = self.lifeSpan - timeDelta

	if self.lifeSpan <= 0 then
		self:destroy()
	end
end

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function Tornado:spritePause(event)
	if event.status then
		self.tornadoSprite:pause()
	else
		self.tornadoSprite:play()
	end
end

-----------------------------------------------------------------------------------------

return Tornado
