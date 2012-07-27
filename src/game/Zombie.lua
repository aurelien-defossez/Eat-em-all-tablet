-----------------------------------------------------------------------------------------
--
-- Zombie.lua
--
-----------------------------------------------------------------------------------------

module("Zombie", package.seeall)

Zombie.__index = Zombie

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")
require("src.utils.Utils")

local SpriteManager = require("src.utils.SpriteManager")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

DIRECTION_VECTOR = {
	UP = { x = 0, y = -1 },
	DOWN = { x = 0, y = 1 },
	LEFT = { x = -1, y = 0 },
	RIGHT = { x = 1, y = 0 }	
}

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.ZOMBIE)
end

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the zombie
--
-- Parameters:
--  tile: The tile the zombie spawned from
--  player: The zombie owner
--  grid: The grid
--  size: The zombie size
function Zombie.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Zombie)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.id = ctId
	self.phase = ZOMBIE.PHASE.MOVE
	self.width = config.zombie.width
	self.height = config.zombie.height
	self.x = self.tile.x
	self.y = self.tile.y
	self.direction = self.player.direction
	self.size = self.size or 1
	self.hitPoints = self.size

	if self.size == 1 then
		self.speed = config.zombie.speed.normal
	else
		self.speed = config.zombie.speed.giant
	end

	if config.debug.fastZombies then
		self.speed = self.speed * 3
	end

	ctId = ctId + 1

	self:changeDirection(self.direction)
	self:computeCollisionMask()

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw sprite
	self.zombieSprite = SpriteManager.newSprite(spriteSet)
	self.zombieSprite:prepare("zombie_" .. self.player.color)
	self.zombieSprite:play()

	-- Position sprite
	if self.size == 1 then
		self.zombieSprite.x = self.width / 2 +
			math.random(config.zombie.randomOffsetRange.x[1], config.zombie.randomOffsetRange.x[2])
		self.zombieSprite.y = self.height / 2 +
			math.random(config.zombie.randomOffsetRange.y[1], config.zombie.randomOffsetRange.y[2])
	else
		self.zombieSprite.xScale = 1.5
		self.zombieSprite.yScale = 1.5
		self.zombieSprite.x = 32
		self.zombieSprite.y = 20
	end

	-- Add to group
	self.group:insert(self.zombieSprite)

	-- Draw collision mask
	if config.debug.showCollisionMask then
		self.collisionMaskDebug = display.newRect(config.zombie.mask.x, config.zombie.mask.y,
			config.zombie.mask.width, config.zombie.mask.height)
		self.collisionMaskDebug.strokeWidth = 3
		self.collisionMaskDebug:setStrokeColor(255, 0, 0)
		self.collisionMaskDebug:setFillColor(0, 0, 0, 0)

		self.group:insert(self.collisionMaskDebug)
	end

	return self
end

-- Destroy the zombie
function Zombie:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Compute the zombie collision mask
function Zombie:computeCollisionMask()
	self.collisionMask = {
		x = self.x + config.zombie.mask.x,
		y = self.y + config.zombie.mask.y,
		width = config.zombie.mask.width,
		height = config.zombie.mask.height
	}
end

-- Move the zombie
--
-- Parameters:
--  x: X movement
--  y: Y movement
function Zombie:move(parameters)
	-- Update zombie position
	self.x = self.x + parameters.x
	self.y = self.y + parameters.y

	-- Determine tile collider
	local tileCollider = {
		x = self.x + self.width / 2 + config.zombie.tileColliderOffset.x * self.directionVector.x,
		y = self.y + self.height / 2 + config.zombie.tileColliderOffset.y * self.directionVector.y
	}

	-- Determine the tile the zombie is on and send events (enter, leave and reachMiddle)
	if self.tile:isInside(tileCollider) then
		-- Staying on the same tile, checking if we passed through middle
		if self.directionVector.x ~= 0 then
			-- Middle is negative when going from right to left, to facilitate further calculations
			local middle = (self.tile.x + Tile.width_2) * self.directionVector.x

			if (tileCollider.x - parameters.x) * self.directionVector.x < middle
				and tileCollider.x * self.directionVector.x >= middle then
				self.tile:reachTileMiddle(self)
			end
		else
			-- Middle is negative when going from bottom to up, to facilitate further calculations
			local middle = (self.tile.y + Tile.height_2) * self.directionVector.y

			if (tileCollider.y - parameters.y) * self.directionVector.y < middle
				and tileCollider.y * self.directionVector.y >= middle then
				self.tile:reachTileMiddle(self)
			end
		end
	else
		-- Leave tile
		self.tile:leaveTile(self)

		-- Find new tile and enter it
		self.tile = self.grid:getTileByPixels(tileCollider)
		self.tile:enterTile(self)
	end

	-- Correct trajectory
	if self.directionVector.x ~= 0 then
		if self.y > self.tile.y + 0.5 then
			self.y = self.y - 1
		elseif self.y < self.tile.y - 0.5 then
			self.y = self.y + 1
		end
	else
		if self.x > self.tile.x + 0.5 then
			self.x = self.x - 1
		elseif self.x < self.tile.x - 0.5 then
			self.x = self.x + 1
		end
	end

	-- Update collision mask
	self:computeCollisionMask()

	-- Move zombie sprite
	self.group.x = self.x
	self.group.y = self.y
end

function Zombie:moveTo(parameters)
	if self.x < parameters.x then
		self.x = math.min(self.x + parameters.maxMovement, parameters.x)
	elseif self.x > parameters.x then
		self.x = math.max(self.x - parameters.maxMovement, parameters.x)
	end

	if self.y < parameters.y then
		self.y = math.min(self.y + parameters.maxMovement, parameters.y)
	elseif self.y > parameters.y then
		self.y = math.max(self.y - parameters.maxMovement, parameters.y)
	end

	-- Move zombie sprite
	self.group.x = self.x
	self.group.y = self.y

	if self.x == parameters.x and self.y == parameters.y then
		self.phase = ZOMBIE.PHASE.CARRY_ITEM
	end
end

-- Changes the direction of the zombie
--
-- Parameters:
--  direction: The new direction
function Zombie:changeDirection(direction)
	self.direction = direction

	if direction == DIRECTION.UP then
		self.directionVector = DIRECTION_VECTOR.UP
	elseif direction == DIRECTION.DOWN then
		self.directionVector = DIRECTION_VECTOR.DOWN
	elseif direction == DIRECTION.LEFT then
		self.directionVector = DIRECTION_VECTOR.LEFT
	elseif direction == DIRECTION.RIGHT then
		self.directionVector = DIRECTION_VECTOR.RIGHT
	end
end

function Zombie:carryItem(item)
	self.item = item
	self.phase = ZOMBIE.PHASE.CARRY_ITEM_INIT
	self:changeDirection(getReverseDirection(self.player.direction))

	local speed
	if self.size == 1 then
		speed = config.item.speed.perZombie
	else
		speed = config.item.speed.perGiant
	end

	item:attachZombie({
		zombie = self,
		speed = speed * self.directionVector.x
	})
end

-- Kills the zombie
--
-- Parameters
--  killer: The killer type, as possible Zombie constant types
--  hits: The number of hits the zombie takes (Default is all)
function Zombie:die(parameters)
	parameters.hits = parameters.hits or self.hitPoints
	self.hitPoints = self.hitPoints - parameters.hits

	if self.hitPoints <= 0 then
		-- Remove zombie from the zombies list
		self.grid:removeZombie(self)

		-- Remove sprite from display
		self:destroy()

		self.phase = ZOMBIE.PHASE.DEAD
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Zombie:enterFrame(timeDelta)
	local speedFactor = Tile.width * timeDelta / 1000

	if self.phase == ZOMBIE.PHASE.MOVE then
		local movement = self.speed * speedFactor

		self:move{
			x = movement * self.directionVector.x,
			y = movement * self.directionVector.y
		}
	elseif self.phase == ZOMBIE.PHASE.CARRY_ITEM_INIT then
		local speed = math.max(self.speed, self.item.actualSpeed)
		local movement = speed * speedFactor
		local itemMask = self.item.collisionMask

		if self.player.direction == DIRECTION.RIGHT then
			self:moveTo{
				x = self.item.x - itemMask.width,
				y = self.item.y,
				maxMovement = movement
			}
		else
			self:moveTo{
				x = self.item.x + itemMask.width,
				y = self.item.y,
				maxMovement = movement
			}
		end
	elseif self.phase == ZOMBIE.PHASE.CARRY_ITEM then
		local movement = self.item.actualSpeed * speedFactor

		self:move{
			x = movement,
			y = 0
		}
	end
end

-----------------------------------------------------------------------------------------

return Zombie