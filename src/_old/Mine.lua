-----------------------------------------------------------------------------------------
--
-- Mine.lua
--
-----------------------------------------------------------------------------------------

module("Mine", package.seeall)

Mine.__index = Mine

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

PHASE_CREATE = 1
PHASE_IDLE = 2
PHASE_TRIGGERED = 3
PHASE_EXPLODE = 4

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.MINE)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates a mine
--
-- Parameters:
--  tile: The tile on mine
function Mine.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Mine)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.MINE
	self.phase = PHASE_CREATE
	self.x = self.tile.x
	self.y = self.tile.y

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw the sprite
	self.mineSprite = SpriteManager.newSprite(spriteSet)
	self.mineSprite:prepare("mine_create")
	self.mineSprite:addEventListener("sprite", self)
	self.mineSprite:play()

	-- Position sprite
	self.mineSprite:setReferencePoint(display.CenterReferencePoint)
	self.mineSprite.x = Tile.width_2
	self.mineSprite.y = Tile.height_2

	-- Add to group
	self.group:insert(self.mineSprite)

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.ENTER_TILE, self)
	self.tile:addEventListener(TILE.EVENT.IN_TILE, self)
	self.tile:addEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	Runtime:addEventListener("spritePause", self)

	return self
end

-- Destroy the item
function Mine:destroy()
	self.mineSprite:removeEventListener("sprite", self)

	self.tile:removeEventListener(TILE.EVENT.ENTER_TILE, self)
	self.tile:removeEventListener(TILE.EVENT.IN_TILE, self)
	self.tile:removeEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
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
function Mine:enterTile(event)
	local zombie = event.zombie

	if self.phase == PHASE_IDLE then
		self.phase = PHASE_TRIGGERED

		self.mineSprite:prepare("mine_triggered")
		self.mineSprite:play()
	end
end

-- In tile handler, called when a zombie is in the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function Mine:inTile(event)
	local zombie = event.zombie

	if self.phase == PHASE_EXPLODE then
		zombie:die{
			killer = ZOMBIE.KILLER.MINE
		}
	end
end

-- Reach center tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function Mine:reachTileCenter(event)
	local zombie = event.zombie

	if self.phase == PHASE_TRIGGERED then
		self.phase = PHASE_EXPLODE

		self.mineSprite:prepare("mine_explode")
		self.mineSprite:play()
	end
end

-- Sprite animation handler
--
-- Parameters:
--  event: The tile event
function Mine:sprite(event)
	if event.phase == "end" then
		if self.phase == PHASE_CREATE then
			self.phase = PHASE_IDLE
		elseif self.phase == PHASE_EXPLODE then
			self:destroy()
		end
	end
end

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function Mine:spritePause(event)
	if event.status then
		self.mineSprite:pause()
	elseif self.phase ~= PHASE_IDLE then
		self.mineSprite:play()
	end
end

-----------------------------------------------------------------------------------------

return Mine
