-----------------------------------------------------------------------------------------
--
-- ManaDrop.lua
--
-----------------------------------------------------------------------------------------

module("ManaDrop", package.seeall)

ManaDrop.__index = ManaDrop

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.sprites.SpriteManager")
local Sprite = require("src.sprites.Sprite")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1
ct = 0

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.MANA)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates the mana drop
--
-- Parameters:
--  tile: The tile the mana is on
--  grid: The grid
function ManaDrop.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ManaDrop)

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

	-- Update class attributes
	ctId = ctId + 1
	ct = ct + 1

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Create sprite
	self.manaSprite = Sprite.create{
		spriteSet = spriteSet,
		group = self.group,
		x = Tile.width_2,
		y = Tile.height_2
	}

	-- Draw sprite
	self.manaSprite:play("mana")

	return self
end

-- Destroy the mana
function ManaDrop:destroy()
	ct = ct - 1

	self.grid:removeManaDrop(self)
	self.manaSprite:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Compute the mana collision mask
function ManaDrop:computeCollisionMask()
	self.collisionMask = {
		x = self.x + config.mana.mask.x,
		y = self.y + config.mana.mask.y,
		width = config.mana.mask.width,
		height = config.mana.mask.height
	}
end

-- Attach a zombie to this mana
--
-- Parameters:
--  zombie: The zombie to attach
function ManaDrop:attachZombie(zombie)
	self.zombie = zombie
end

-- Detach a zombie from this mana
--
-- Parameters:
--  zombie: The zombie to detach
function ManaDrop:detachZombie(zombie)
	self.zombie = nil
	self.speed = 0
end

-- Start the motion of the mana being carried by the zombie
function ManaDrop:startMotion()
	self.speed = self.config.mana.speed * self.zombie.directionVector.x
end

-- Mana is fetched by a player, giving this mana to him
--
-- Parameters:
--  player: The player fetching the mana
function ManaDrop:fetched(player)
	self.zombie:changeDirection{
		direction = self.zombie.player.direction,
		priority = ZOMBIE.PRIORITY.DEFAULT
	}

	player:addMana(config.mana.value)

	self:detachZombie(self.zombie)
	self:destroy()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function ManaDrop:enterFrame(timeDelta)
	if self.speed ~= 0 then
		local movement = timeDelta / 1000 * self.speed * Tile.width

		self.x = self.x + movement
		self.group.x = self.x

		self:computeCollisionMask()
	end

	-- Draw collision mask
	if config.debug.showCollisionMask and not self.collisionMaskDebug then
		self.collisionMaskDebug = display.newRect(config.mana.mask.x, config.mana.mask.y,
			config.mana.mask.width, config.mana.mask.height)
		self.collisionMaskDebug.strokeWidth = 1
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

return ManaDrop
