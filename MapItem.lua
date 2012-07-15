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

local config = require("GameConfig")
local Tile = require("Tile")
local PlayerItem = require("PlayerItem")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
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

	-- Initialize attributes
	self.id = ctId
	self.x = self.tile.x
	self.y = self.tile.y
	self.speed = 0
	self.actualSpeed = 0
	self.zombies = {}

	self:computeCollisionMask()

	ctId = ctId + 1

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the item
function MapItem:draw()
	self.itemSprite = display.newImageRect("item.png",
		config.item.width, config.item.height)

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
end

-- Compute the item collision mask
function MapItem:computeCollisionMask()
	self.collisionMask = {
		x = self.x + config.item.mask.x,
		y = self.y + config.item.mask.y,
		width = config.item.mask.width,
		height = config.item.mask.height
	}
end

function MapItem:attachZombie(parameters)
	local maxSpeed = config.item.speed.max

	self.zombies[parameters.zombie.id] = parameters.zombie
	self.speed = self.speed + parameters.speed
	self.actualSpeed = math.max(-maxSpeed, math.min(self.speed, maxSpeed))
end

function MapItem:fetched(player)
	-- Release zombies from their tasks
	for index, zombie in pairs(self.zombies) do
		if zombie.phase == Zombie.PHASE_CARRY_ITEM then
			zombie.phase = Zombie.PHASE_MOVE
			zombie:changeDirection(zombie.player.direction)
		end
	end

	-- Create player item
	local playerItem = PlayerItem.create{
		x = self.x,
		y = self.y,
		type = math.random(1, PlayerItem.TYPES.COUNT)
	}

	playerItem:draw()
	player:gainItem(playerItem)
	self.grid:removeItem(self)

	self.group:removeSelf()
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function MapItem:enterFrame(timeDelta)
	if self.actualSpeed ~= 0 then
		local movement = timeDelta / 1000 * self.actualSpeed * Tile.width

		self.x = self.x + movement
		self.group.x = self.x

		self:computeCollisionMask()
	end
end


-----------------------------------------------------------------------------------------

return MapItem
