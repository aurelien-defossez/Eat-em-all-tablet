-----------------------------------------------------------------------------------------
--
-- PlayerItem.lua
--
-----------------------------------------------------------------------------------------

module("PlayerItem", package.seeall)

PlayerItem.__index = PlayerItem

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local Tile = require("Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

TYPES = {
	COUNT = 4,
	SKELETON = 1,
	GIANT = 2,
	FIRE = 3,
	MINE = 4
}

ALLOWED_DROP_ZONE = {
	ALL,
	CEMETERIES,
	EMPTY_EXCEPT_ARROWS,
	EMPTY
}

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
--  x: The X position
--  y: The Y position
function PlayerItem.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PlayerItem)

	-- Initialize attributes
	self.id = ctId
	self.width = config.item.width
	self.height = config.item.height
	self.width_2 = config.item.width / 2
	self.height_2 = config.item.height / 2
	if self.type == TYPES.SKELETON then
		self.typeName = "skeleton"
		self.dropZones = ALLOWED_DROP_ZONE.CEMETERIES
	elseif self.type == TYPES.GIANT then
		self.typeName = "giant"
		self.dropZones = ALLOWED_DROP_ZONE.CEMETERIES
	elseif self.type == TYPES.FIRE then
		self.typeName = "fire"
		self.dropZones = ALLOWED_DROP_ZONE.EMPTY_EXCEPT_ARROWS
	elseif self.type == TYPES.MINE then
		self.typeName = "mine"
		self.dropZones = ALLOWED_DROP_ZONE.EMPTY_EXCEPT_ARROWS
	end

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
function PlayerItem:draw()
	self.itemSprite = display.newImageRect("item_" .. self.typeName .. ".png",
		config.item.width, config.item.height)

	-- Position sprite
	self.itemSprite:setReferencePoint(display.CenterReferencePoint)
	self.itemSprite.x = Tile.width_2
	self.itemSprite.y = Tile.height_2

	-- Handle events
	self.itemSprite.item = self
	self.itemSprite:addEventListener("touch", onItemTouch)

	-- Add to group
	self.group:insert(self.itemSprite)
end

-- Move the item to an absolute position on the screen, easing it
function PlayerItem:moveTo(parameters)
	transition.to(self.group, {
		transition = easing.outExpo,
		time = config.item.easingTime,
		x = parameters.x,
		y = parameters.y
	})

	self.x = parameters.x
	self.y = parameters.y
end

-----------------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------------

-- Touch handler on the item
function onItemTouch(event)
	local self = event.target.item

	-- Begin drag
	if event.phase == "began" or event.phase == "moved" then
		-- Position item
		self.group.x = event.x - self.width_2
		self.group.y = event.y - self.height_2

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(self.itemSprite, event.id)
	elseif event.phase == "ended" or event.phase == "cancelled" then
		self:moveTo{
			x = self.x,
			y = self.y
		}
	end
end

-----------------------------------------------------------------------------------------

return PlayerItem
