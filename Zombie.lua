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

local config = require("GameConfig")
local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

UP = { x = 0, y = -1 }
DOWN = { x = 0, y = 1 }
LEFT = { x = -1, y = 0 }
RIGHT = { x = 1, y = 0 }

KILLER_ZOMBIE = 1
KILLER_FORTRESS = 2
KILLER_CITY = 3

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 0

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the zombie
--
-- Parameters:
--  cemetery: The cemetery the zombie spawned from
--  player: The zombie owner
--  grid: The grid
function Zombie.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Zombie)

	-- Initialize attributes
	ctId = ctId + 1
	self.id = ctId
	self.width = config.zombie.width
	self.height = config.zombie.height
	self.x = self.cemetery.x + self.width / 2
	self.y = self.cemetery.y + self.height / 2
	self.direction = self.player.direction
	self.tile = self.cemetery.tile

	self:changeDirection(self.direction)
	self:computeTileCollider()

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the zombie
function Zombie:draw()
	self.sprite = display.newImageRect("zombie_" .. self.player.color .. ".png", self.width, self.height)
	self.sprite.arrow = self

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x
	self.sprite.y = self.y

	-- TEMP
	self.debug = display.newRect(self.x, self.y, 2, 2)
	self.debug.strokeWidth = 0
	self.debug:setFillColor(0, 255, 0)
end

-- Compute the tile collider position
function Zombie:computeTileCollider()
	self.tileCollider = {
		x = self.x + config.zombie.tileColliderOffset.x * self.directionVector.x,
		y = self.y + config.zombie.tileColliderOffset.y * self.directionVector.y
	}
end

-- Move the zombie
--
-- Parameters:
--  x: X movement
--  y: Y movement
function Zombie:move(parameters)
	-- Save last tile collider location
	local lastCollider = {
		x = self.tileCollider.x,
		y = self.tileCollider.y
	}

	-- Update zombie position
	self.x = parameters.x
	self.y = parameters.y

	-- Calculate point to test tile collision
	self:computeTileCollider()

	self.debug.x = self.tileCollider.x 
	self.debug.y = self.tileCollider.y 

	-- Determine the tile the zombie is on and send events (enter, leave and reachMiddle)
	if self.tileCollider.x >= self.tile.x and self.tileCollider.x < self.tile.x + self.tile.width
		and self.tileCollider.y >= self.tile.y and self.tileCollider.y < self.tile.y + self.tile.height then
		-- Staying on the same tile, checking if we passed through middle
		if self.directionVector.x ~= 0 then
			-- Middle is negative when going from right to left, to facilitate further calculations
			local middle = (self.tile.x + self.tile.width / 2) * self.directionVector.x

			if lastCollider.x * self.directionVector.x < middle
				and self.tileCollider.x * self.directionVector.x >= middle then
				self.tile:reachTileMiddle(self)
			end
		else
			-- Middle is negative when going from bottom to up, to facilitate further calculations
			local middle = (self.tile.y + self.tile.height / 2) * self.directionVector.y

			if lastCollider.y * self.directionVector.y < middle
				and self.tileCollider.y * self.directionVector.y >= middle then
				self.tile:reachTileMiddle(self)
			end
		end
	else
		-- Leave tile
		self.tile:leaveTile(self)

		-- Find new tile and enter it
		self.tile = self.grid:getTileByPixels(self.tileCollider)
		self.tile:enterTile(self)
	end

	-- Move zombie sprite
	self.sprite.x = self.x
	self.sprite.y = self.y
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

-- Kills the zombie
--
-- Parameters
--  killer: The killer type, as possible Zombie constant types
function Zombie:die(parameters)
	-- Remove zombie from cemetery
	self.cemetery:removeZombie(self)

	-- Remove sprite from display
	self.sprite:removeSelf()

	self.debug:removeSelf()
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Zombie:enterFrame(timeDelta)
	local movement = timeDelta / 1000 * config.zombie.speed * self.tile.width

	self:move{
		x = self.x + movement * self.directionVector.x,
		y = self.y + movement * self.directionVector.y
	}
end

-----------------------------------------------------------------------------------------

return Zombie
