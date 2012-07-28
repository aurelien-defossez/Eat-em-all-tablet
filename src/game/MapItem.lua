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
	self.speed = 0
	self.zombies = {}
	self.alreadyFetched = false

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

	-- Draw collision mask
	if config.debug.showCollisionMask then
		self.collisionMaskDebug = display.newRect(config.item.mask.x, config.item.mask.y,
			config.item.mask.width, config.item.mask.height)
		self.collisionMaskDebug.strokeWidth = 3
		self.collisionMaskDebug:setStrokeColor(255, 0, 0)
		self.collisionMaskDebug:setFillColor(0, 0, 0, 0)

		self.group:insert(self.collisionMaskDebug)
	end

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
--  speed: The speed added by this zombie
function MapItem:attachZombie(parameters)
	self.zombies[parameters.zombie.id] = parameters.zombie
	self.speed = self.speed + parameters.speed
end

-- Detach a zombie from this item
--
-- Parameters:
--  zombie: The zombie to detach
--  speed: The speed added by this zombie
function MapItem:detachZombie(parameters)
	self.zombies[parameters.zombie.id] = nil
	self.speed = self.speed - parameters.speed
end

-- Item is fetched by a player, giving this item to him
--
-- Parameters:
--  player: The player fetching the item
function MapItem:fetched(player)
	if not self.alreadyFetched then
		self.alreadyFetched = true

		-- Release zombies from their tasks
		for index, zombie in pairs(self.zombies) do
			if zombie.phase == ZOMBIE.PHASE.CARRY_ITEM or zombie.phase == ZOMBIE.PHASE.CARRY_ITEM_INIT then
				zombie.phase = ZOMBIE.PHASE.MOVE
				zombie:changeDirection{
					direction = zombie.player.direction
				}
			end
		end

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

		self.x = self.x + movement
		self.group.x = self.x

		self:computeCollisionMask()
	end
end


-----------------------------------------------------------------------------------------

return MapItem
