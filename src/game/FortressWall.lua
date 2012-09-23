-----------------------------------------------------------------------------------------
--
-- FortressWall.lua
--
-----------------------------------------------------------------------------------------

module("FortressWall", package.seeall)

FortressWall.__index = FortressWall

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.sprites.SpriteManager")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.FORTRESS_WALL)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates the sign
--
-- Parameters:
--  tile: The tile the sign is on
--  player: The wall owner
function FortressWall.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, FortressWall)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.FORTRESS_WALL
	self.x = self.tile.x
	self.y = self.tile.y

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw sprite
	self.wallSprite = SpriteManager.newSprite(spriteSet)
	self.wallSprite:prepare("fortress_wall_" .. self.player.color.name)
	self.wallSprite:play()

	-- Position sprite
	self.wallSprite:setReferencePoint(display.CenterReferencePoint)
	self.wallSprite.x = self.tile.width / 2
	self.wallSprite.y = self.tile.height / 2

	-- Add to group
	self.group:insert(self.wallSprite)

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.ENTER_TILE, self)
	Runtime:addEventListener("spritePause", self)

	return self
end

-- Destroy the wall
function FortressWall:destroy()
	self.tile:removeEventListener(TILE.EVENT.ENTER_TILE, self)
	Runtime:removeEventListener("spritePause", self)

	self.tile:removeContent(self.contentId)

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function FortressWall:enterTile(event)
	local zombie = event.zombie

	if zombie.player.id ~= self.player.id then
		zombie.stateMachine:triggerEvent{
			event = "hitEnemyWall",
			target = self
		}
	else
		zombie.stateMachine:triggerEvent{
			event = "hitFriendlyWall",
			target = self
		}
	end
end

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function FortressWall:spritePause(event)
	if event.status then
		self.wallSprite:pause()
	else
		self.wallSprite:play()
	end
end

-----------------------------------------------------------------------------------------

return FortressWall
