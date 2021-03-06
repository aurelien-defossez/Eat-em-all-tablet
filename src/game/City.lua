-----------------------------------------------------------------------------------------
--
-- City.lua
--
-- A city if a map entity that needs to be captured by zombies to spawn more zombies.
-- A city is captured when it is completely full.
-- Once a city has been captured, it spawns zombies at a regular rate.
-- If the other player attacks and kill enough zombies, the city returns to its neutral
-- state.
-- Cities have various size, small, medium and large, which determines the maximal
-- number of inhabitants, the spawning rate and the decap threshold.
--
-----------------------------------------------------------------------------------------

module("City", package.seeall)
City.__index = City

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local SpriteManager = require("src.sprites.SpriteManager")
local Sprite = require("src.sprites.Sprite")
local Zombie = require("src.game.Zombie")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

-- Initialize the class
function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the city
--
-- Parameters:
--  grid: The grid
--  tile: The tile the city is on
--  size: The city size
--  id: The city unique id
function City.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, City)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.CITY
	self.x = self.tile.x
	self.y = self.tile.y
	self.player = nil
	self.spawning = false
	self.timeSinceLastSpawn = 0

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	if self.size == CITY.SIZE.SMALL then
		self.inhabitants = config.city.small.inhabitants
		self.spawnPeriod = config.city.small.spawnPeriod
		self.maxInhabitants = config.city.small.maxInhabitants
		self.requiredInhabitants = config.city.small.requiredInhabitants
	elseif self.size == CITY.SIZE.MEDIUM then
		self.inhabitants = config.city.medium.inhabitants
		self.spawnPeriod = config.city.medium.spawnPeriod
		self.maxInhabitants = config.city.medium.maxInhabitants
		self.requiredInhabitants = config.city.medium.requiredInhabitants
	else
		self.inhabitants = config.city.large.inhabitants
		self.spawnPeriod = config.city.large.spawnPeriod
		self.maxInhabitants = config.city.large.maxInhabitants
		self.requiredInhabitants = config.city.large.requiredInhabitants
	end

	-- Add to groups
	self.cityGroup = display.newGroup()
	self.barGroup = display.newGroup()

	self.group:insert(self.cityGroup)
	self.group:insert(self.barGroup)

	-- Create sprite
	self.citySprite = Sprite.create{
		spriteSet = SpriteManager.sets.city,
		group = self.cityGroup,
		x = Tile.width_2,
		y = Tile.height_2
	}

	-- Bars
	self.barHeight = config.city.bars.maxHeight * self.maxInhabitants / config.city.large.maxInhabitants
	self.pixelsPerInhabitant = self.maxInhabitants / self.barHeight

	self.backgroundBar = display.newRect(0, 0, 0, 0)
	self.backgroundBar.width = config.city.bars.width
	self.backgroundBar.height = self.barHeight
	self.backgroundBar:setReferencePoint(display.BottomLeftReferencePoint)
	self.backgroundBar.x = config.city.bars.offset.x
	self.backgroundBar.y = config.city.bars.offset.y + config.city.bars.maxHeight
	self.backgroundBar.strokeWidth = 0
	self.backgroundBar:setFillColor(165, 165, 165)
	self.backgroundBar:setStrokeColor(20, 20, 20)

	self.inhabitantsBar = display.newRect(0, 0, 0, 0)
	self.inhabitantsBar.width = config.city.bars.width
	self.inhabitantsBar.strokeWidth = 0

	self:updateInhabitants()

	-- Add to group
	self.barGroup:insert(self.backgroundBar)
	self.barGroup:insert(self.inhabitantsBar)
	
	-- Play neutral animation
	self:updateSprite()

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.ENTER_TILE, self)
	self.tile:addEventListener(TILE.EVENT.REACH_TILE_CENTER, self)

	return self
end

-- Destroy the city
function City:destroy()
	self.tile:removeEventListener(TILE.EVENT.ENTER_TILE, self)
	self.tile:removeEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	self.citySprite:destroy()
	self.tile:removeContent(self.contentId)
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add inhabitants to the city
--
-- Parameters:
--  nb: The number of inhabitants to add
function City:addInhabitants(nb)
	self.inhabitants = self.inhabitants + nb

	-- Update the spawning faculty of the city
	if not self.spawning and self.inhabitants >= self.maxInhabitants then
		self.spawning = true
		self:updateSprite()
	elseif self.spawning and self.inhabitants < self.requiredInhabitants then
		self.spawning = false
		self:updateSprite()
	end

	if self.inhabitants > self.maxInhabitants then
		self:spawn{
			free = false
		}
	elseif self.inhabitants == 0 then
		-- Notify player
		if self.player then
			self.player:loseCity(self)
		end

		self.player = nil
		self.spawning = false

		self:updateSprite()
	end

	self:updateInhabitants()
end

-- Update the number of inhabitants graphically
function City:updateInhabitants()
	local newHeight = self.barHeight - (1 - (self.inhabitants / self.maxInhabitants)) * self.barHeight
	
	self.inhabitantsBar.height = newHeight
	self.inhabitantsBar.isVisible = (newHeight > 0)

	self.inhabitantsBar:setReferencePoint(display.BottomLeftReferencePoint)
	self.inhabitantsBar.x = config.city.bars.offset.x
	self.inhabitantsBar.y = config.city.bars.offset.y + config.city.bars.maxHeight
end

-- Update the city sprite animation and the bar color
function City:updateSprite()
	local animationName;

	-- Update bar color
	if self.player then
		self.inhabitantsBar:setFillColor(self.player.color.r, self.player.color.g, self.player.color.b)
	else
		self.inhabitantsBar:setFillColor(57, 57, 57)
	end
	
	-- Update sprite color
	if not self.spawning or not self.player then
		animationName = "city" .. self.size .. "_grey"
	else
		animationName = "city" .. self.size .. "_" .. self.player.color.name
	end
	
	self.citySprite:play(animationName)
end

-- Spawn a zombie
--
-- Parameters:
--  free: If true, then this spawn is free and does not take an inhabitant
function City:spawn(parameters)
	local zombie = Zombie.create{
		player = self.player,
		tile = self.tile,
		grid = self.grid
	}

	self.grid:addZombie(zombie)

	if not parameters.free then
		self:addInhabitants(-1)
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function City:enterTile(event)
	local zombie = event.zombie

	if self.inhabitants > 0 and (not self.player or zombie.player.id ~= self.player.id) then
		zombie.stateMachine:triggerEvent{
			event = "hitEnemyCity",
			target = self
		}
	elseif self.inhabitants == 0 then
		zombie.stateMachine:triggerEvent{
			event = "hitNeutralCity",
			target = self
		}
	elseif self.inhabitants < self.maxInhabitants then
		zombie.stateMachine:triggerEvent{
			event = "hitFriendlyCity",
			target = self
		}
	end
end

-- Reach center tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function City:reachTileCenter(event)
	local zombie = event.zombie

	if self.player and zombie.player.id == self.player.id then
		zombie:changeDirection{
			direction = self.player.direction,
			priority = ZOMBIE.PRIORITY.CITY,
			correctPosition = true
		}
	end
end


-- The city is attacked
--
-- Parameters:
--  zombie: The zombie attacking the city
function City:attackCity(zombie)
	-- Attack city and die
	local hits = math.min(zombie.size, self.inhabitants)
	self:addInhabitants(-hits)
	zombie:die{
		killer = ZOMBIE.KILLER.CITY
	}
end

-- The city is taken by a player
--
-- Parameters:
--  player: The player taking the city
function City:takeCity(player)
	-- Notify player
	player:gainCity(self)

	-- Change the city owner
	self.player = player

	-- Update the bar color
	self:updateSprite()
end

-- Enforce the city with a zombie
--
-- Parameters:
--  zombie: The zombie enforcing the city
function City:enforceCity(zombie)
	if self.inhabitants < self.maxInhabitants then
		self:addInhabitants(zombie.size)
		self:updateSprite()
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function City:enterFrame(timeDelta)
	if self.player and self.spawning then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeDelta

		if self.timeSinceLastSpawn >= self.spawnPeriod then
			self.timeSinceLastSpawn = self.timeSinceLastSpawn - self.spawnPeriod
			self:spawn{
				free = true
			}
		end
	end
end

-----------------------------------------------------------------------------------------

return City
