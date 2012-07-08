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
	self.collisionMask = {
		x = self.x + config.item.mask.x,
		y = self.y + config.item.mask.y,
		width = config.item.mask.width,
		height = config.item.mask.height
	}

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

-----------------------------------------------------------------------------------------

return Item
