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

require("utils")
local config = require("GameConfig")
local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

UP = { x = 0, y = -1 }
DOWN = { x = 0, y = 1 }
LEFT = { x = -1, y = 0 }
RIGHT = { x = 1, y = 0 }

PHASE_MOVE = 1
PHASE_CARRY_ITEM = 2
PHASE_DEAD = 3

KILLER_ZOMBIE = 1
KILLER_FORTRESS = 2
KILLER_CEMETERY = 3
KILLER_CITY = 4
KILLER_CITY_ENTER = 4

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
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
function Zombie.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Zombie)

	-- Initialize attributes
	self.id = ctId
	self.phase = PHASE_MOVE
	self.width = config.zombie.width
	self.height = config.zombie.height
	self.x = self.tile.x
	self.y = self.tile.y
	self.direction = self.player.direction

	ctId = ctId + 1

	self:changeDirection(self.direction)
	self:computeCollisionMask()

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

-- Draw the zombie
function Zombie:draw()
	self.zombieSprite = display.newImageRect("zombie_" .. self.player.color .. ".png", self.width, self.height)
	self.zombieSprite.arrow = self

	-- Position sprite
	self.zombieSprite.x = self.width / 2 +
		math.random(config.zombie.randomOffsetRange.x[1], config.zombie.randomOffsetRange.x[2])
	self.zombieSprite.y = self.height / 2 +
		math.random(config.zombie.randomOffsetRange.y[1], config.zombie.randomOffsetRange.y[2])

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
end

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
			local middle = (self.tile.x + self.tile.width / 2) * self.directionVector.x

			if (tileCollider.x - parameters.x) * self.directionVector.x < middle
				and tileCollider.x * self.directionVector.x >= middle then
				self.tile:reachTileMiddle(self)
			end
		else
			-- Middle is negative when going from bottom to up, to facilitate further calculations
			local middle = (self.tile.y + self.tile.height / 2) * self.directionVector.y

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

-- Changes the direction of the zombie
--
-- Parameters:
--  direction: The new direction
function Zombie:changeDirection(direction)
	self.direction = direction

	if direction == Arrow.UP then
		self.directionVector = Zombie.UP
	elseif direction == Arrow.DOWN then
		self.directionVector = Zombie.DOWN
	elseif direction == Arrow.LEFT then
		self.directionVector = Zombie.LEFT
	elseif direction == Arrow.RIGHT then
		self.directionVector = Zombie.RIGHT
	end
end

function Zombie:carryItem(item)
	self.item = item
	self.phase = PHASE_CARRY_ITEM
	self:changeDirection(getReverseDirection(self.player.direction))

	item:attachZombie({
		zombie = self,
		speed = config.item.speed.perZombie * self.directionVector.x
	})
end

-- Kills the zombie
--
-- Parameters
--  killer: The killer type, as possible Zombie constant types
function Zombie:die(parameters)
	-- Remove zombie from the zombies list
	self.grid:removeZombie(self)

	-- Remove sprite from display
	self.group:removeSelf()


	self.phase = PHASE_DEAD
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Zombie:enterFrame(timeDelta)
	if self.phase == PHASE_MOVE then
		local movement = timeDelta / 1000 * config.zombie.speed * self.tile.width

		self:move{
			x = movement * self.directionVector.x,
			y = movement * self.directionVector.y
		}
	elseif self.phase == PHASE_CARRY_ITEM then
		local movement = timeDelta / 1000 * self.item.actualSpeed * self.tile.width

		self:move{
			x = movement,
			y = 0
		}
	end
end

-----------------------------------------------------------------------------------------

return Zombie
