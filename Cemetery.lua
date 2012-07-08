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

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

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
	self.cemeterySprite = display.newImageRect("cemetery_" .. self.player.color .. ".png",
		config.cemetery.width, config.cemetery.height)

	-- Position sprite
	self.cemeterySprite:setReferencePoint(display.CenterReferencePoint)
	self.cemeterySprite.x = self.tile.width / 2
	self.cemeterySprite.y = self.tile.height / 2

	-- Add to group
	self.group:insert(self.cemeterySprite)
end

-- Spawn a single zombie
function Cemetery:spawn()
	if not config.debug.oneZombie or self.grid.nbZombies == 0 then
		local zombie = Zombie.create{
			player = self.player,
			tile = self.tile,
			grid = self.grid
		}

		self.grid:addZombie(zombie)

		zombie:draw()
	end
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  zombie: The zombie entering the tile
function Cemetery:enterTile(zombie)
	if zombie.player.id ~= self.player.id then
		-- Lose HP
		self.player:addHPs(-1)

		-- Kill zombie
		zombie:die{
			killer = Zombie.KILLER_CEMETERY
		}
	elseif zombie.phase == Zombie.PHASE_MOVE then
		-- Move backward
		zombie:changeDirection(self.player.direction)
	elseif zombie.phase == Zombie.PHASE_CARRY_ITEM then
		zombie.item:fetched(self.player)
	end
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
end

-----------------------------------------------------------------------------------------

return Cemetery
