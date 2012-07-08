-----------------------------------------------------------------------------------------
--
-- Item.lua
--
-----------------------------------------------------------------------------------------

module("Item", package.seeall)

Item.__index = Item

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local Tile = require("Tile")

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
function Item.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Item)

	-- Initialize attributes
	self.id = ctId
	self.x = self.tile.x
	self.y = self.tile.y
	self.speed = 0
	self.actualSpeed = 0

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

-- Destroy the item
function Item:destroy()
	self.itemSprite:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the item
function Item:draw()
	self.itemSprite = display.newImageRect("item.png",
		config.item.width, config.item.height)

	-- Position sprite
	self.itemSprite:setReferencePoint(display.CenterReferencePoint)
	self.itemSprite.x = self.tile.width / 2
	self.itemSprite.y = self.tile.height / 2

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
function Item:computeCollisionMask()
	self.collisionMask = {
		x = self.x + config.item.mask.x,
		y = self.y + config.item.mask.y,
		width = config.item.mask.width,
		height = config.item.mask.height
	}
end

function Item:addSpeed(speed)
	local maxSpeed = config.item.speed.max

	self.speed = self.speed + speed
	self.actualSpeed = math.max(-maxSpeed, math.min(self.speed, maxSpeed))
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Item:enterFrame(timeDelta)
	if self.actualSpeed ~= 0 then
		local movement = timeDelta / 1000 * self.actualSpeed * self.tile.width

		self.x = self.x + movement
		self.group.x = self.x

		self:computeCollisionMask()
	end
end


-----------------------------------------------------------------------------------------

return Item
