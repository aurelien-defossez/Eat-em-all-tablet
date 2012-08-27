-----------------------------------------------------------------------------------------
--
-- MapItem.lua
--
-----------------------------------------------------------------------------------------

module("MapItem", package.seeall)

MapItem.__index = MapItem

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Tile = require("src.game.Tile")
local PlayerItem = require("src.hud.PlayerItem")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.ITEM)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates the item
--
-- Parameters:
--  tile: The tile the item is on
--  grid: The grid
function MapItem.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, MapItem)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.id = ctId
	self.x = self.tile.x
	self.y = self.tile.y
	self.zombie = nil
	self.speed = 0

	self:computeCollisionMask()

	ctId = ctId + 1

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw sprite
	self.itemSprite = SpriteManager.newSprite(spriteSet)
	self.itemSprite:prepare("item")
	self.itemSprite:play()

	-- Position sprite
	self.itemSprite:setReferencePoint(display.CenterReferencePoint)
	self.itemSprite.x = Tile.width_2
	self.itemSprite.y = Tile.height_2

	-- Add to group
	self.group:insert(self.itemSprite)

	return self
end

-- Destroy the item
function MapItem:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Compute the item collision mask
function MapItem:computeCollisionMask()
	self.collisionMask = {
		x = self.x + config.item.mask.x,
		y = self.y + config.item.mask.y,
		width = config.item.mask.width,
		height = config.item.mask.height
	}
end

-- Attach a zombie to this item
--
-- Parameters:
--  zombie: The zombie to attach
function MapItem:attachZombie(zombie)
	self.zombie = zombie
end

-- Detach a zombie from this item
--
-- Parameters:
--  zombie: The zombie to detach
function MapItem:detachZombie(zombie)
	self.zombie = nil
	self.speed = 0
end

-- Start the motion of the item being carried by the zombie
function MapItem:startMotion()
	self.speed = self.config.item.speed * self.zombie.directionVector.x
end

-- Item is fetched by a player, giving this item to him
--
-- Parameters:
--  player: The player fetching the item
function MapItem:fetched(player)
	self.zombie.phase = ZOMBIE.PHASE.MOVE
	self.zombie:changeDirection{
		direction = self.zombie.player.direction
	}

	-- Create player item
	local playerItem = PlayerItem.create{
		player = player,
		grid = self.grid,
		x = self.x,
		y = self.y,
		type = math.random(1, ITEM.COUNT)
	}

	player:gainItem(playerItem)
	self.grid:removeItem(self)

	self:destroy()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function MapItem:enterFrame(timeDelta)
	if self.speed ~= 0 then
		local movement = timeDelta / 1000 * self.speed * Tile.width

		if config.debug.fastMode then
			movement = movement * config.debug.fastModeRatio
		end

		self.x = self.x + movement
		self.group.x = self.x

		self:computeCollisionMask()
	end

	-- Draw collision mask
	if config.debug.showCollisionMask and not self.collisionMaskDebug then
		self.collisionMaskDebug = display.newRect(config.item.mask.x, config.item.mask.y,
			config.item.mask.width, config.item.mask.height)
		self.collisionMaskDebug.strokeWidth = 3
		self.collisionMaskDebug:setStrokeColor(255, 0, 0)
		self.collisionMaskDebug:setFillColor(0, 0, 0, 0)

		self.group:insert(self.collisionMaskDebug)
	end

	-- Remove collision mask
	if not config.debug.showCollisionMask and self.collisionMaskDebug then
		self.collisionMaskDebug:removeSelf()
		self.collisionMaskDebug = nil
	end
end


-----------------------------------------------------------------------------------------

return MapItem
