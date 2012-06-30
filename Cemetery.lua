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
	self.x = self.tile.x
	self.y = self.tile.y
	self.timeSinceLastSpawn = 0
	self.zombies = {}
	self.nbZombies = 0

	if config.debug.immediateSpawn then
		self.timeSinceLastSpawn = config.cemetery.spawnPeriod
	end

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the cemetery
function Cemetery:draw()
	self.sprite = display.newImageRect("cemetery_" .. self.player.color .. ".png",
		config.cemetery.width, config.cemetery.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x + self.tile.width / 2
	self.sprite.y = self.y + self.tile.height / 2
end

-- Spawn a single zombie
function Cemetery:spawn()
	if config.debug.oneZombie == false or self.nbZombies == 0 then
		local zombie = Zombie.create{
			cemetery = self,
			player = self.player,
			grid = self.grid
		}

		zombie:draw()

		self.zombies[zombie.id] = zombie
		self.nbZombies = self.nbZombies + 1
	end
end

-- Removes a zombie from the zombies list
--
-- Parameters
--  zombie: The zombie to remove
function Cemetery:removeZombie(zombie)
	self.zombies[zombie.id] = nil
	self.nbZombies = self.nbZombies - 1
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Cemetery:enterFrame(timeDelta)
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeDelta

	-- Count spawn time
	if self.timeSinceLastSpawn >= config.cemetery.spawnPeriod then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn - config.cemetery.spawnPeriod
		self:spawn()
	end

	-- Relay event to zombies
	for index, zombie in pairs(self.zombies) do
		zombie:enterFrame(timeDelta)
	end
end

-----------------------------------------------------------------------------------------

return Cemetery
