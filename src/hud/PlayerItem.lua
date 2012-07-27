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

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

ALLOWED_DROP_ZONE = {
	ALL = 1,
	CEMETERIES = 2,
	EMPTY_EXCEPT_SIGNS = 3,
	EMPTY = 4
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
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.ITEM)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates the item
--
-- Parameters:
--  player: The player that owns this item
--  grid: The grid
--  x: The X position
--  y: The Y position
function PlayerItem.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PlayerItem)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.id = ctId
	self.width = config.item.width
	self.height = config.item.height
	self.width_2 = config.item.width / 2
	self.height_2 = config.item.height / 2
	
	if self.type == ITEM.TYPE.SKELETON then
		self.typeName = "skeleton"
		self.dropZones = ALLOWED_DROP_ZONE.CEMETERIES
	elseif self.type == ITEM.TYPE.GIANT then
		self.typeName = "giant"
		self.dropZones = ALLOWED_DROP_ZONE.CEMETERIES
	elseif self.type == ITEM.TYPE.FIRE then
		self.typeName = "fire"
		self.dropZones = ALLOWED_DROP_ZONE.EMPTY_EXCEPT_SIGNS
	elseif self.type == ITEM.TYPE.MINE then
		self.typeName = "mine"
		self.dropZones = ALLOWED_DROP_ZONE.EMPTY_EXCEPT_SIGNS
	end

	ctId = ctId + 1

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw sprite
	self.itemSprite = SpriteManager.newSprite(spriteSet)
	self.itemSprite:prepare("item_" .. self.typeName)
	self.itemSprite:play()

	-- Position sprite
	self.itemSprite:setReferencePoint(display.CenterReferencePoint)
	self.itemSprite.x = Tile.width_2
	self.itemSprite.y = Tile.height_2

	-- Handle events
	self.itemSprite.item = self
	self.itemSprite:addEventListener("touch", onItemTouch)

	-- Add to group
	self.group:insert(self.itemSprite)

	return self
end

-- Destroy the item
function PlayerItem:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Use the item on the specified tile
--
-- Parameters:
--  tile: The tile to use the item on
function PlayerItem:useItem(tile)
	if self.type == ITEM.TYPE.SKELETON then
		tile.content:quicklySpawnZombies(config.item.skeleton.nbZombies)
	elseif self.type == ITEM.TYPE.GIANT then
		tile.content:spawn{
			size = config.item.giant.size
		}
	elseif self.type == ITEM.TYPE.FIRE then
	elseif self.type == ITEM.TYPE.MINE then
	end
end

-- Move the item to an absolute position on the screen, easing it
--
-- Parameters:
--  x: The X target position
--  y: The y target position
--  easingTimeL The time took to make the easing (Default is config.item.easingTime.reorganize)
function PlayerItem:transitionTo(parameters)
	transition.to(self.group, {
		transition = easing.outExpo,
		time = parameters.easingTime or config.item.easingTime.reorganize,
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
	local cancel = false

	-- Begin drag
	if event.phase == "began" or event.phase == "moved" then
		-- Position item
		self.group.x = event.x - self.width_2
		self.group.y = event.y - self.height_2

		-- Focus this object in order to track this finger properly
		display.getCurrentStage():setFocus(self.itemSprite, event.id)
	elseif event.phase == "ended" then
		-- Locate drop tile
		local tile = self.grid:getTileByPixels{
			x = event.x,
			y = event.y
		}

		if tile == nil then
			cancel = true
		else
			-- Check if the drop is a legal drop for this item
			if self.dropZones == ALLOWED_DROP_ZONE.ALL
				or self.dropZones == ALLOWED_DROP_ZONE.CEMETERIES and tile:getContentType() == TILE.CONTENT.CEMETERY
				or self.dropZones == ALLOWED_DROP_ZONE.EMPTY and tile.content == nil
				or self.dropZones == ALLOWED_DROP_ZONE.EMPTY_EXCEPT_SIGNS and
					(tile.content == nil or tile:getContentType() == TILE.CONTENT.SIGN) then
				self:useItem(tile)
				self.player:removeItem(self)
			else
				cancel = true
			end
		end
	elseif event.phase == "cancelled" then
		cancel = true
	end

	if cancel then
		display.getCurrentStage():setFocus(nil, event.id)

		self:transitionTo{
			x = self.x,
			y = self.y,
			easingTime = config.item.easingTime.cancel
		}
	end
end

-----------------------------------------------------------------------------------------

return PlayerItem
