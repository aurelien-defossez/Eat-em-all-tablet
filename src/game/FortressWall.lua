-----------------------------------------------------------------------------------------
--
-- FortressWall.lua
--
-- A fortress wall is a map entity representing a part of the player's wall.
-- If an enemy zombie attacks the wall, the player loses HP.
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
local Sprite = require("src.sprites.Sprite")

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

	-- Create sprite
	self.wallSprite = Sprite.create{
		spriteSet = SpriteManager.sets.fortressWall,
		group = self.group,
		x = Tile.width_2,
		y = Tile.height_2
	}

	-- Draw sprite
	self.wallSprite:play("fortress_wall_" .. self.player.color.name)

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.ENTER_TILE, self)

	return self
end

-- Destroy the wall
function FortressWall:destroy()
	self.tile:removeEventListener(TILE.EVENT.ENTER_TILE, self)
	self.wallSprite:destroy()
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

-----------------------------------------------------------------------------------------

return FortressWall
