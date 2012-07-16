-----------------------------------------------------------------------------------------
--
-- Cemetery.lua
--
-----------------------------------------------------------------------------------------

module("Cemetery", package.seeall)

Cemetery.__index = Cemetery

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local Zombie = require("Zombie")
local Tile = require("Tile")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the cemetery
--
-- Parameters:
--  grid: The grid
--  tile: The tile the cemetery is on
--  player: The cemetery owner
function Cemetery.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Cemetery)

	-- Initialize attributes
	self.type = Tile.TYPE_CEMETERY
	self.x = self.tile.x
	self.y = self.tile.y
	self.timeSinceLastSpawn = 0
	self.timeSinceLastQuickSpawn = 0
	self.nbQuickZombies = 0

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	if config.debug.immediateSpawn then
		self.timeSinceLastSpawn = config.cemetery.spawnPeriod.normal
	end

	return self
end

-- Destroy the cemetery
function Cemetery:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the cemetery
function Cemetery:draw()
	self.cemeterySprite = display.newImageRect("cemetery_" .. self.player.color .. ".png",
		config.cemetery.width, config.cemetery.height)

	-- Position sprite
	self.cemeterySprite:setReferencePoint(display.CenterReferencePoint)
	self.cemeterySprite.x = Tile.width_2
	self.cemeterySprite.y = Tile.height_2

	-- Add to group
	self.group:insert(self.cemeterySprite)
end

-- Spawn a single zombie
--
-- Parameters:
--  size: The zombie size (default = 1)
function Cemetery:spawn(parameters)
	if not config.debug.oneZombie or self.grid.nbZombies == 0 then
		local zombie = Zombie.create{
			player = self.player,
			tile = self.tile,
			grid = self.grid,
			size = parameters.size or 1
		}

		self.grid:addZombie(zombie)

		zombie:draw()
	end
end

-- Quickly spawn n zombies
--
-- Parameters
--  nbZombies: The number of zombies to spawn
function Cemetery:quicklySpawnZombies(nbZombies)
	self.nbQuickZombies = self.nbQuickZombies + nbZombies
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  zombie: The zombie entering the tile
function Cemetery:enterTile(zombie)
	if zombie.player.id ~= self.player.id then
		-- Lose HP
		self.player:addHPs(-zombie.size)

		-- Kill zombie
		zombie:die{
			killer = Zombie.KILLER_CEMETERY
		}
	elseif zombie.phase == Zombie.PHASE_MOVE or zombie.phase == Zombie.PHASE_CARRY_ITEM_INIT then
		-- Move backward
		zombie:changeDirection(self.player.direction)
	elseif zombie.phase == Zombie.PHASE_CARRY_ITEM then
		-- Fetch item
		zombie.item:fetched(self.player)
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Cemetery:enterFrame(timeDelta)
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeDelta
	self.timeSinceLastQuickSpawn = self.timeSinceLastQuickSpawn + timeDelta

	-- Count spawn time
	if self.timeSinceLastSpawn >= config.cemetery.spawnPeriod.normal then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn - config.cemetery.spawnPeriod.normal

		local size = 1
		if config.debug.randomGiants and math.random() < 0.2 then
			size = config.item.giant.size
		end

		self:spawn{
			size = size
		}
	end

	-- Count quick spawn time
	if self.nbQuickZombies == 0 then
		self.timeSinceLastQuickSpawn = math.min(self.timeSinceLastQuickSpawn, config.cemetery.spawnPeriod.quick)
	elseif self.timeSinceLastQuickSpawn >= config.cemetery.spawnPeriod.quick then
		self.timeSinceLastQuickSpawn = self.timeSinceLastQuickSpawn - config.cemetery.spawnPeriod.quick
		self.nbQuickZombies = self.nbQuickZombies - 1
		self:spawn{
			size = 1
		}
	end
end

-----------------------------------------------------------------------------------------

return Cemetery
