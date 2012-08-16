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
local Fire = require("src.game.Fire")
local Mine = require("src.game.Mine")

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
	
	if self.type == ITEM.SKELETON then
		self.typeName = "skeleton"
	elseif self.type == ITEM.GIANT then
		self.typeName = "giant"
	elseif self.type == ITEM.FIRE then
		self.typeName = "fire"
	elseif self.type == ITEM.MINE then
		self.typeName = "mine"
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
	self.itemSprite:addEventListener("touch", self)

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
-- Event listeners
-----------------------------------------------------------------------------------------

-- Touch handler on an item
--
-- Parameters:
--  event: The touch event
function PlayerItem:touch(event)
	local itemUsed = false
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

		if tile then
			-- Use skeleton or giant iten if the drop tile contains a cemetery
			if self.type == ITEM.SKELETON or self.type == ITEM.GIANT then
				local cemetery = tile:getContentForType{TILE.CONTENT.CEMETERY}

				if cemetery then
					itemUsed = true

					if self.type == ITEM.SKELETON then
						cemetery:quicklySpawnZombies(config.item.skeleton.nbZombies)
					elseif self.type == ITEM.GIANT then
						cemetery:spawn{
							size = config.item.giant.size
						}
					end
				end
			-- Use fire if the drop tile does not contain a cemetery, a city, a fortress wall or a fire
			elseif self.type == ITEM.FIRE then
				if not tile:hasContentType{
					TILE.CONTENT.CEMETERY,
					TILE.CONTENT.CITY,
					TILE.CONTENT.FORTRESS_WALL,
					TILE.CONTENT.FIRE
				} then
					itemUsed = true

					Fire.create{
						tile = tile
					}
				end
			-- Use mine if the drop tile does not contain a cemetery, a city or a fortress wall
			elseif self.type == ITEM.MINE then
				if not tile:hasContentType{
					TILE.CONTENT.CEMETERY,
					TILE.CONTENT.CITY,
					TILE.CONTENT.FORTRESS_WALL
				} then
					itemUsed = true

					Mine.create{
						tile = tile
					}
				end
			end
		end

		if itemUsed then
			self.player:removeItem(self)
		else
			cancel = true
		end
	elseif event.phase == "ended" then
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
	
	return true
end

-----------------------------------------------------------------------------------------

return PlayerItem
