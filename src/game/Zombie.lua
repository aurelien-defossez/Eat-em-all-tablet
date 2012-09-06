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

require("src.utils.Utils")
require("src.utils.Constants")
require("src.config.GameConfig")

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
	self.directionPriority = ZOMBIE.PRIORITY.NO_DIRECTION

	if self.size == 1 then
		self.speed = config.zombie.speed.normal
		self.isGiant = false
	else
		self.speed = config.zombie.speed.giant
		self.isGiant = true
	end

	ctId = ctId + 1

	-- Draw sprite
	self.zombieSprite = SpriteManager.newSprite(spriteSet)

	self:changeDirection{
		direction = self.player.direction,
		priority = ZOMBIE.PRIORITY.DEFAULT
	}

	self:computeCollisionMask()

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Position sprite
	if not self.isGiant then
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

	-- Listen to events
	Runtime:addEventListener("spritePause", self)

	-- Add to group
	self.group:insert(self.zombieSprite)

	return self
end

-- Destroy the zombie
function Zombie:destroy()
	Runtime:removeEventListener("spritePause", self)

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
		x = self.x + self.width / 2,
		y = self.y + self.height / 2
	}

	-- Determine the tile the zombie is on and send events (enter, leave and reachCenter)
	if self.tile:isInside(tileCollider) then
		-- Staying on the same tile, checking if we passed through middle
		if self.directionVector.x ~= 0 then
			-- Middle is negative when going from right to left, to facilitate further calculations
			local middle = (self.tile.x + Tile.width_2) * self.directionVector.x

			if (tileCollider.x - parameters.x) * self.directionVector.x < middle
				and tileCollider.x * self.directionVector.x >= middle then
				self.tile:reachTileCenter(self)
			end
		else
			-- Middle is negative when going from bottom to up, to facilitate further calculations
			local middle = (self.tile.y + Tile.height_2) * self.directionVector.y

			if (tileCollider.y - parameters.y) * self.directionVector.y < middle
				and tileCollider.y * self.directionVector.y >= middle then
				self.tile:reachTileCenter(self)
			end
		end
	else
		-- Leave tile
		self.tile:leaveTile(self)

		self.directionPriority = ZOMBIE.PRIORITY.NO_DIRECTION

		-- Find new tile and enter it
		self.tile = self.grid:getTileByPixels(tileCollider)
		self.tile:enterTile(self)
	end

	-- In tile event
	self.tile:inTile(self)

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

-- Move the zombie to a certain position
--
-- Parameters:
--  x: The X position to move to
--  y: The Y position to move to
--  maxMovement: The maximal number of pixels to move from
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

		self.item:startMotion()

		self:updateSprite()
	end
end

-- Changes the direction of the zombie
--
-- Parameters:
--  direction: The new direction
--  correctPosition: If true, then the position has to be corrected so the zombie stay on the tile center
--  priority: The direction priority, to prevent less priority directions to occur
--
-- Returns:
--  True if the zombie did follow the direction, false otherwise
function Zombie:changeDirection(parameters)
	if parameters.priority > self.directionPriority then
		self.direction = parameters.direction
		self.directionPriority = parameters.priority

		-- Update the direction vector
		if self.direction == DIRECTION.UP then
			self.directionVector = DIRECTION_VECTOR.UP
		elseif self.direction == DIRECTION.DOWN then
			self.directionVector = DIRECTION_VECTOR.DOWN
		elseif self.direction == DIRECTION.LEFT then
			self.directionVector = DIRECTION_VECTOR.LEFT
		elseif self.direction == DIRECTION.RIGHT then
			self.directionVector = DIRECTION_VECTOR.RIGHT
		end

		if parameters.correctPosition then
			-- Compute the offset between the zombie position and the tile center and correct the zombie position
			if self.direction == DIRECTION.UP or self.direction == DIRECTION.DOWN then
				local tileCenter = self.tile.x
				local centerOffset = math.abs(self.x - tileCenter)

				self.x = tileCenter
				self.y = self.y + centerOffset * self.directionVector.y
			else
				local tileCenter = self.tile.y
				local centerOffset = math.abs(self.y - tileCenter)

				self.y = tileCenter
				self.x = self.x + centerOffset * self.directionVector.x
			end
		end

		self:updateSprite()

		return true
	else
		return false
	end
end

-- Update the zombie sprite depending on the phase and the direction
function Zombie:updateSprite()
	local directionName
	local phaseName

	-- Update the direction vector
	if self.direction == DIRECTION.UP then
		directionName = "up"
	elseif self.direction == DIRECTION.DOWN then
		directionName = "down"
	elseif self.direction == DIRECTION.LEFT then
		directionName = "left"
	elseif self.direction == DIRECTION.RIGHT then
		directionName = "right"
	end

	if self.phase == ZOMBIE.PHASE.CARRY_ITEM then
		phaseName = "carry"
	else
		phaseName = "move"
	end

	self.zombieSprite:prepare("zombie_" .. phaseName .. "_" .. directionName .. "_" .. self.player.color.name)
	self.zombieSprite:play()
end

-- Make azombie carry an item
--
-- Parameters:
--  item: The item to carry
function Zombie:carryItem(item)
	self.item = item
	self.phase = ZOMBIE.PHASE.CARRY_ITEM_INIT

	self:changeDirection{
		direction = getReverseDirection(self.player.direction),
		priority = ZOMBIE.PRIORITY.ITEM
	}

	item:attachZombie(self)
end

-- Kills the zombie
--
-- Parameters
--  killer: The killer type, as possible Zombie constant types
--  hits: The number of hits the zombie takes (Default is all)
function Zombie:die(parameters)
	if self.phase ~= ZOMBIE.PHASE.DEAD then
		parameters.hits = parameters.hits or self.hitPoints
		self.hitPoints = self.hitPoints - parameters.hits

		if self.hitPoints <= 0 then
			self:updateSprite()

			-- Remove from the item carriers
			if self.phase == ZOMBIE.PHASE.CARRY_ITEM_INIT or self.phase == ZOMBIE.PHASE.CARRY_ITEM then
				self.item:detachZombie(self)
			end
			
			self.phase = ZOMBIE.PHASE.DEAD

			-- Remove zombie from the zombies list
			self.grid:removeZombie(self)

			-- Remove sprite from display
			self:destroy()
		end
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Zombie:enterFrame(timeDelta)
	local speedFactor = Tile.width * timeDelta / 1000

	if config.debug.fastMode then
		speedFactor = speedFactor * config.debug.fastModeRatio
	end

	if self.phase == ZOMBIE.PHASE.MOVE then
		local movement = self.speed * speedFactor

		self:move{
			x = movement * self.directionVector.x,
			y = movement * self.directionVector.y
		}
	elseif self.phase == ZOMBIE.PHASE.CARRY_ITEM_INIT then
		local speed = math.max(self.speed, self.item.speed)
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
		local movement = self.item.speed * speedFactor

		self:move{
			x = movement,
			y = 0
		}
	end

	-- Draw collision mask
	if config.debug.showCollisionMask and not self.collisionMaskDebug then
		self.collisionMaskDebug = display.newRect(config.zombie.mask.x, config.zombie.mask.y,
			config.zombie.mask.width, config.zombie.mask.height)
		self.collisionMaskDebug.strokeWidth = 3
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

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function Zombie:spritePause(event)
	if event.status then
		self.zombieSprite:pause()
	else
		self.zombieSprite:play()
	end
end

-----------------------------------------------------------------------------------------

return Zombie
