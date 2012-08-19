-----------------------------------------------------------------------------------------
--
-- Fire.lua
--
-----------------------------------------------------------------------------------------

module("Fire", package.seeall)

Fire.__index = Fire

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.FIRE)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates a fire
--
-- Parameters:
--  tile: The tile on fire
function Fire.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Fire)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.FIRE
	self.x = self.tile.x
	self.y = self.tile.y
	self.lifeSpan = config.item.fire.duration

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw the sprite
	self.fireSprite = SpriteManager.newSprite(spriteSet)
	self.fireSprite:prepare("fire")
	self.fireSprite:play()

	-- Position sprite
	self.fireSprite:setReferencePoint(display.CenterReferencePoint)
	self.fireSprite.x = Tile.width_2
	self.fireSprite.y = Tile.height_2

	-- Add to group
	self.group:insert(self.fireSprite)

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.IN_TILE, self)

	return self
end

-- Destroy the item
function Fire:destroy()
	self.tile:removeEventListener(TILE.EVENT.IN_TILE, self)

	self.tile:removeContent(self.contentId)

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- In tile handler, called when a zombie is in the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function Fire:inTile(event)
	local zombie = event.zombie

	zombie:die{
		killer = ZOMBIE.KILLER.FIRE
	}
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Fire:enterFrame(timeDelta)
	self.lifeSpan = self.lifeSpan - timeDelta

	if self.lifeSpan <= 0 then
		self:destroy()
	end
end


-----------------------------------------------------------------------------------------

return Fire
